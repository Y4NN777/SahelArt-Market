import bcrypt from 'bcryptjs';
import { User } from '../../src/models/User';
import { signAccessToken } from '../../src/config/jwt';
import { IUser, UserRole } from '../../src/types/auth.types';

interface TestUserOpts {
  email?: string;
  password?: string;
  role?: UserRole;
  firstName?: string;
  lastName?: string;
  status?: 'active' | 'suspended';
}

export const createTestUser = async (opts: TestUserOpts = {}) => {
  const password = opts.password || 'TestPass123!';
  const passwordHash = await bcrypt.hash(password, 4);
  const user = await User.create({
    email: opts.email || `user-${Date.now()}@test.com`,
    passwordHash,
    role: opts.role || 'customer',
    profile: {
      firstName: opts.firstName || 'Amadou',
      lastName: opts.lastName || 'Diallo'
    },
    status: opts.status || 'active'
  });
  return { user, password };
};

export const getAuthToken = (user: { id?: string; _id?: unknown; email: string; role: UserRole; status: string }): string => {
  const payload: IUser = {
    id: (user.id || String(user._id)) as string,
    email: user.email,
    role: user.role,
    status: user.status as IUser['status']
  };
  return signAccessToken(payload);
};

export const createAuthenticatedUser = async (opts: TestUserOpts = {}) => {
  const { user, password } = await createTestUser(opts);
  const token = getAuthToken(user as unknown as { id: string; email: string; role: UserRole; status: string });
  return { user, password, token };
};
