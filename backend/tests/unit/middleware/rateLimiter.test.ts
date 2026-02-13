import { Request, Response, NextFunction } from 'express';
import { authRateLimiter, webhookRateLimiter, apiRateLimiter } from '../../../src/middleware/rateLimiter';

describe('Rate Limiters', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;
  let nextFn: jest.Mock;

  beforeEach(() => {
    mockReq = {};
    mockRes = {};
    nextFn = jest.fn();
  });

  it('should pass through in test mode - authRateLimiter', () => {
    process.env.NODE_ENV = 'test';
    authRateLimiter(mockReq as Request, mockRes as Response, nextFn);
    expect(nextFn).toHaveBeenCalled();
  });

  it('should pass through in test mode - webhookRateLimiter', () => {
    process.env.NODE_ENV = 'test';
    webhookRateLimiter(mockReq as Request, mockRes as Response, nextFn);
    expect(nextFn).toHaveBeenCalled();
  });

  it('should pass through in test mode - apiRateLimiter', () => {
    process.env.NODE_ENV = 'test';
    apiRateLimiter(mockReq as Request, mockRes as Response, nextFn);
    expect(nextFn).toHaveBeenCalled();
  });
});
