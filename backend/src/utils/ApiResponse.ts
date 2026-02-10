import { Response } from 'express';

export const sendSuccess = (res: Response, data: unknown, message?: string, status = 200) => {
  return res.status(status).json({
    success: true,
    data,
    message
  });
};

export const sendError = (res: Response, status: number, code: string, message: string, details?: unknown) => {
  return res.status(status).json({
    success: false,
    error: {
      code,
      message,
      ...(details ? { details } : {})
    }
  });
};
