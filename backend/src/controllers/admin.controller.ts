import { Request, Response } from 'express';
import { AdminService } from '../services/admin.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess, sendPaginatedSuccess } from '../utils/ApiResponse';
import { parsePagination } from '../utils/validators';

export const AdminController = {
  stats: asyncHandler(async (_req: Request, res: Response) => {
    const stats = await AdminService.stats();
    return sendSuccess(res, stats);
  }),

  listUsers: asyncHandler(async (req: Request, res: Response) => {
    const { page, limit } = parsePagination(req.query.page as string, req.query.limit as string);
    const result = await AdminService.listUsers({
      role: req.query.role as string,
      status: req.query.status as string,
      page,
      limit
    });
    return sendPaginatedSuccess(res, result.data, result.pagination);
  }),

  suspendUser: asyncHandler(async (req: Request, res: Response) => {
    const user = await AdminService.suspendUser(req.user!.id, req.params.id, req.body.reason);
    return sendSuccess(res, { user }, 'User suspended successfully');
  })
};
