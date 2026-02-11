import { Request, Response, NextFunction } from 'express';
import { requireAuth } from '../../../src/middleware/auth';
import { User } from '../../../src/models/User';
import { verifyAccessToken } from '../../../src/config/jwt';
import { ApiError } from '../../../src/utils/ApiError';

jest.mock('../../../src/models/User');
jest.mock('../../../src/config/jwt');

const mockReq = (headers: Record<string, string> = {}) =>
  ({ headers, user: undefined } as unknown as Request);

const mockRes = () => ({} as Response);

describe('requireAuth middleware', () => {
  let next: jest.Mock;

  beforeEach(() => {
    next = jest.fn();
  });

  it('should return 401 when no Authorization header', async () => {
    await requireAuth(mockReq(), mockRes(), next);
    expect(next).toHaveBeenCalledWith(expect.any(ApiError));
    const err = next.mock.calls[0][0] as ApiError;
    expect(err.statusCode).toBe(401);
  });

  it('should return 401 for malformed header', async () => {
    await requireAuth(mockReq({ authorization: 'Basic abc' }), mockRes(), next);
    expect(next).toHaveBeenCalledWith(expect.any(ApiError));
    const err = next.mock.calls[0][0] as ApiError;
    expect(err.statusCode).toBe(401);
  });

  it('should return 401 for invalid token', async () => {
    (verifyAccessToken as jest.Mock).mockImplementation(() => {
      throw new Error('invalid');
    });

    await requireAuth(mockReq({ authorization: 'Bearer bad-token' }), mockRes(), next);
    expect(next).toHaveBeenCalledWith(expect.any(ApiError));
    const err = next.mock.calls[0][0] as ApiError;
    expect(err.statusCode).toBe(401);
  });

  it('should return 401 when user not found', async () => {
    (verifyAccessToken as jest.Mock).mockReturnValue({ userId: 'nonexistent', email: 'a@b.com', role: 'customer' });
    (User.findById as jest.Mock).mockResolvedValue(null);

    await requireAuth(mockReq({ authorization: 'Bearer valid-token' }), mockRes(), next);
    expect(next).toHaveBeenCalledWith(expect.any(ApiError));
    const err = next.mock.calls[0][0] as ApiError;
    expect(err.statusCode).toBe(401);
  });

  it('should return 403 for suspended user', async () => {
    (verifyAccessToken as jest.Mock).mockReturnValue({ userId: 'u1', email: 'sus@test.com', role: 'customer' });
    (User.findById as jest.Mock).mockResolvedValue({
      id: 'u1',
      email: 'sus@test.com',
      role: 'customer',
      status: 'suspended'
    });

    await requireAuth(mockReq({ authorization: 'Bearer valid-token' }), mockRes(), next);
    expect(next).toHaveBeenCalledWith(expect.any(ApiError));
    const err = next.mock.calls[0][0] as ApiError;
    expect(err.statusCode).toBe(403);
    expect(err.code).toBe('ACCOUNT_SUSPENDED');
  });

  it('should set req.user and call next() for valid token', async () => {
    (verifyAccessToken as jest.Mock).mockReturnValue({ userId: 'u1', email: 'ok@test.com', role: 'vendor' });
    (User.findById as jest.Mock).mockResolvedValue({
      id: 'u1',
      email: 'ok@test.com',
      role: 'vendor',
      status: 'active'
    });

    const req = mockReq({ authorization: 'Bearer valid-token' });
    await requireAuth(req, mockRes(), next);

    expect(next).toHaveBeenCalledWith();
    expect(req.user).toEqual({
      id: 'u1',
      email: 'ok@test.com',
      role: 'vendor',
      status: 'active'
    });
  });
});
