import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import { UserService } from '../services/user.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendError, sendSuccess } from '../utils/ApiResponse';

const cookieSecure = () => (process.env.COOKIE_SECURE || 'false') === 'true';

const sanitizeUser = (user: any) => {
  const obj = user.toObject ? user.toObject() : { ...user };
  delete obj.passwordHash;
  return obj;
};

const setRefreshCookie = (res: Response, token: string) => {
  res.cookie('refresh_token', token, {
    httpOnly: true,
    secure: cookieSecure(),
    sameSite: process.env.NODE_ENV === 'production' ? 'strict' : 'lax',
    path: '/api/v1/auth/refresh',
    maxAge: (parseInt(process.env.REFRESH_TOKEN_TTL_DAYS || '7', 10) || 7) * 24 * 60 * 60 * 1000
  });
};

const clearRefreshCookie = (res: Response) => {
  res.clearCookie('refresh_token', {
    httpOnly: true,
    secure: cookieSecure(),
    sameSite: process.env.NODE_ENV === 'production' ? 'strict' : 'lax',
    path: '/api/v1/auth/refresh'
  });
};

export const AuthController = {
  register: asyncHandler(async (req: Request, res: Response) => {
    const { email, password, role, profile } = req.body;
    const result = await AuthService.register({ email, password, role, profile }, req.ip, req.get('user-agent') || undefined);
    setRefreshCookie(res, result.refreshToken);
    return sendSuccess(
      res,
      {
        user: sanitizeUser(result.user),
        accessToken: result.accessToken,
        refreshToken: result.refreshToken
      },
      'Account created successfully',
      201
    );
  }),

  login: asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;
    const result = await AuthService.login(email, password, req.ip, req.get('user-agent') || undefined);
    setRefreshCookie(res, result.refreshToken);
    return sendSuccess(
      res,
      {
        user: sanitizeUser(result.user),
        accessToken: result.accessToken,
        refreshToken: result.refreshToken
      },
      'Login successful'
    );
  }),

  me: asyncHandler(async (req: Request, res: Response) => {
    const user = await UserService.getById(req.user!.id);
    return sendSuccess(res, { user: sanitizeUser(user) });
  }),

  refresh: asyncHandler(async (req: Request, res: Response) => {
    const rawToken = req.cookies?.refresh_token || req.body?.refreshToken;
    if (!rawToken) {
      return sendError(res, 401, 'UNAUTHORIZED', 'No refresh token provided');
    }
    const result = await AuthService.refresh(rawToken, req.ip, req.get('user-agent') || undefined);
    setRefreshCookie(res, result.refreshToken);
    return sendSuccess(res, {
      accessToken: result.accessToken,
      refreshToken: result.refreshToken
    });
  }),

  logout: asyncHandler(async (req: Request, res: Response) => {
    const rawToken = req.cookies?.refresh_token || req.body?.refreshToken;
    if (rawToken) {
      await AuthService.logout(rawToken);
    }
    clearRefreshCookie(res);
    return sendSuccess(res, null, 'Logged out');
  })
};
