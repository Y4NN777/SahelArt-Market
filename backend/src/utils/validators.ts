import { ApiError } from './ApiError';

export const parsePagination = (pageRaw?: string, limitRaw?: string) => {
  const page = Math.max(parseInt(pageRaw || '1', 10) || 1, 1);
  const limit = Math.min(Math.max(parseInt(limitRaw || '20', 10) || 20, 1), 100);
  return { page, limit, skip: (page - 1) * limit };
};

export const ensureObjectId = (id: string, field = 'id') => {
  if (!id || id.length < 12) {
    throw new ApiError(400, 'VALIDATION_ERROR', `${field} is invalid`);
  }
};
