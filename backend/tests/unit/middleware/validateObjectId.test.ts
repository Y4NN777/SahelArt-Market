import { Request, Response } from 'express';
import { validateObjectId } from '../../../src/middleware/validateObjectId';

describe('validateObjectId middleware', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;
  let nextFn: jest.Mock;

  beforeEach(() => {
    mockReq = {
      params: {}
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    nextFn = jest.fn();
  });

  it('should call next() for valid ObjectId', () => {
    mockReq.params = { id: '507f1f77bcf86cd799439011' };
    const middleware = validateObjectId('id');
    middleware(mockReq as Request, mockRes as Response, nextFn);

    expect(nextFn).toHaveBeenCalled();
    expect(mockRes.status).not.toHaveBeenCalled();
  });

  it('should return 400 for invalid ObjectId', () => {
    mockReq.params = { id: 'invalid-id' };
    const middleware = validateObjectId('id');
    middleware(mockReq as Request, mockRes as Response, nextFn);

    expect(mockRes.status).toHaveBeenCalledWith(400);
    expect(mockRes.json).toHaveBeenCalledWith({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid id format'
      }
    });
    expect(nextFn).not.toHaveBeenCalled();
  });

  it('should return 400 for missing parameter', () => {
    mockReq.params = {};
    const middleware = validateObjectId('userId');
    middleware(mockReq as Request, mockRes as Response, nextFn);

    expect(mockRes.status).toHaveBeenCalledWith(400);
    expect(mockRes.json).toHaveBeenCalledWith({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid userId format'
      }
    });
    expect(nextFn).not.toHaveBeenCalled();
  });

  it('should work with different parameter names', () => {
    mockReq.params = { orderId: '507f1f77bcf86cd799439011' };
    const middleware = validateObjectId('orderId');
    middleware(mockReq as Request, mockRes as Response, nextFn);

    expect(nextFn).toHaveBeenCalled();
    expect(mockRes.status).not.toHaveBeenCalled();
  });
});
