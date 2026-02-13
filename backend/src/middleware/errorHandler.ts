import { Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { ApiError } from '../utils/ApiError';
import { sendError } from '../utils/ApiResponse';

export const errorHandler = (err: unknown, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return sendError(res, 413, 'FILE_TOO_LARGE', 'File size exceeds the 5MB limit');
    }
    return sendError(res, 400, 'UPLOAD_ERROR', err.message);
  }

  if (err instanceof ApiError) {
    return sendError(res, err.statusCode, err.code, err.message, err.details);
  }

  if (err instanceof Error) {
    const message = process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message;
    return sendError(res, 500, 'INTERNAL_ERROR', message);
  }

  return sendError(res, 500, 'INTERNAL_ERROR', 'An unexpected error occurred');
};
