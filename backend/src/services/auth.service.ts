import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { User } from '../models/User';
import { RefreshToken } from '../models/RefreshToken';
import { ApiError } from '../utils/ApiError';
import { signAccessToken } from '../config/jwt';
import { IUser, UserRole } from '../types/auth.types';
import { EmailService } from './email.service';
import { RealtimeService } from './realtime.service';

const refreshDays = () => parseInt(process.env.REFRESH_TOKEN_TTL_DAYS || '7', 10);
const refreshPepper = () => process.env.REFRESH_TOKEN_PEPPER || 'pepper';

const hashToken = (token: string) => {
  return crypto.createHash('sha256').update(token + refreshPepper()).digest('hex');
};

const generateRefreshToken = () => crypto.randomBytes(64).toString('hex');

const buildUserPayload = (user: any): IUser => ({
  id: user.id,
  email: user.email,
  role: user.role as UserRole,
  status: user.status
});

const createRefreshRecord = async (userId: string, token: string, ip?: string, userAgent?: string) => {
  const tokenHash = hashToken(token);
  const expiresAt = new Date(Date.now() + refreshDays() * 24 * 60 * 60 * 1000);
  await RefreshToken.create({
    userId,
    tokenHash,
    expiresAt,
    createdByIp: ip,
    userAgent
  });
};

export const AuthService = {
  async register(data: {
    email: string;
    password: string;
    role: UserRole;
    profile: { firstName: string; lastName: string; phone?: string; address?: string };
  }, ip?: string, userAgent?: string) {
    if (data.role === 'admin') {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Admin role is not allowed');
    }
    const existing = await User.findOne({ email: data.email.toLowerCase() });
    if (existing) {
      throw new ApiError(409, 'EMAIL_ALREADY_EXISTS', 'Email already registered');
    }
    const passwordHash = await bcrypt.hash(data.password, 10);
    const user = await User.create({
      email: data.email.toLowerCase(),
      passwordHash,
      role: data.role,
      profile: data.profile,
      status: 'active'
    });

    const refreshToken = generateRefreshToken();
    await createRefreshRecord(user.id, refreshToken, ip, userAgent);

    const userPayload = buildUserPayload(user);
    const accessToken = signAccessToken(userPayload);

    EmailService.sendWelcome(user.email, data.profile.firstName).catch(() => {});

    RealtimeService.emitToAdmin('admin:new_user', {
      userId: user.id,
      email: user.email,
      role: user.role,
      name: `${data.profile.firstName} ${data.profile.lastName}`
    });

    return { user, accessToken, refreshToken };
  },

  async login(email: string, password: string, ip?: string, userAgent?: string) {
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      throw new ApiError(401, 'INVALID_CREDENTIALS', 'Invalid email or password');
    }
    if (user.status === 'suspended') {
      throw new ApiError(403, 'ACCOUNT_SUSPENDED', 'Account is suspended');
    }
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      throw new ApiError(401, 'INVALID_CREDENTIALS', 'Invalid email or password');
    }

    const refreshToken = generateRefreshToken();
    await createRefreshRecord(user.id, refreshToken, ip, userAgent);

    const userPayload = buildUserPayload(user);
    const accessToken = signAccessToken(userPayload);

    return { user, accessToken, refreshToken };
  },

  async refresh(rawToken: string, ip?: string, userAgent?: string) {
    const tokenHash = hashToken(rawToken);
    const stored = await RefreshToken.findOne({ tokenHash });
    if (!stored) {
      throw new ApiError(401, 'UNAUTHORIZED', 'Refresh token not found');
    }
    if (stored.revokedAt) {
      await RefreshToken.updateMany({ userId: stored.userId, revokedAt: null }, { revokedAt: new Date() });
      throw new ApiError(401, 'UNAUTHORIZED', 'Refresh token revoked');
    }
    if (stored.expiresAt.getTime() < Date.now()) {
      await RefreshToken.findByIdAndUpdate(stored.id, { revokedAt: new Date() });
      throw new ApiError(401, 'UNAUTHORIZED', 'Refresh token expired');
    }

    const user = await User.findById(stored.userId);
    if (!user) {
      throw new ApiError(401, 'UNAUTHORIZED', 'User not found');
    }
    if (user.status === 'suspended') {
      throw new ApiError(403, 'ACCOUNT_SUSPENDED', 'Account is suspended');
    }

    const newRefresh = generateRefreshToken();
    await createRefreshRecord(user.id, newRefresh, ip, userAgent);

    await RefreshToken.findByIdAndUpdate(stored.id, {
      revokedAt: new Date(),
      replacedByTokenHash: hashToken(newRefresh)
    });

    const userPayload = buildUserPayload(user);
    const accessToken = signAccessToken(userPayload);

    return { accessToken, refreshToken: newRefresh };
  },

  async logout(rawToken: string) {
    const tokenHash = hashToken(rawToken);
    const stored = await RefreshToken.findOne({ tokenHash });
    if (!stored) {
      return;
    }
    await RefreshToken.findByIdAndUpdate(stored.id, { revokedAt: new Date() });
  }
};
