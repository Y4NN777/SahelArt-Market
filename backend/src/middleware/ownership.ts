import { ApiError } from '../utils/ApiError';

export const ensureOwner = (ownerId: string | undefined, userId: string) => {
  if (!ownerId || ownerId.toString() !== userId.toString()) {
    throw new ApiError(403, 'FORBIDDEN', 'Not owner of resource');
  }
};
