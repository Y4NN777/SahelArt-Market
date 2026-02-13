import { Response } from 'express';

export const sendSuccess = (res: Response, data: unknown, message?: string, status = 200) => {
  return res.status(status).json({
    success: true,
    data,
    message
  });
};

export const sendPaginatedSuccess = (
  res: Response,
  data: unknown,
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
  },
  message?: string
) => {
  return res.status(200).json({
    success: true,
    data,
    pagination,
    ...(message ? { message } : {})
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
