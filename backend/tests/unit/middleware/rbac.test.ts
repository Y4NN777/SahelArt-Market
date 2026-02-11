import { Request, Response, NextFunction } from 'express';
import { allowRoles } from '../../../src/middleware/rbac';
import { ApiError } from '../../../src/utils/ApiError';

const mockRes = () => ({} as Response);

describe('allowRoles middleware', () => {
  let next: jest.Mock;

  beforeEach(() => {
    next = jest.fn();
  });

  it('should return 401 when no user on request', () => {
    const middleware = allowRoles('admin');
    const req = { user: undefined } as unknown as Request;

    middleware(req, mockRes(), next);

    expect(next).toHaveBeenCalledWith(expect.any(ApiError));
    const err = next.mock.calls[0][0] as ApiError;
    expect(err.statusCode).toBe(401);
  });

  it('should return 403 when user role is not allowed', () => {
    const middleware = allowRoles('admin');
    const req = { user: { id: '1', email: 'a@b.com', role: 'customer', status: 'active' } } as unknown as Request;

    middleware(req, mockRes(), next);

    expect(next).toHaveBeenCalledWith(expect.any(ApiError));
    const err = next.mock.calls[0][0] as ApiError;
    expect(err.statusCode).toBe(403);
  });

  it('should call next() when user role is allowed', () => {
    const middleware = allowRoles('vendor', 'admin');
    const req = { user: { id: '1', email: 'a@b.com', role: 'vendor', status: 'active' } } as unknown as Request;

    middleware(req, mockRes(), next);

    expect(next).toHaveBeenCalledWith();
  });
});
