import { Request, Response } from 'express';
import { UserService } from '../services/user.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess } from '../utils/ApiResponse';

export const UserController = {
  updateMe: asyncHandler(async (req: Request, res: Response) => {
    const { profile } = req.body;
    const user = await UserService.updateProfile(req.user!.id, profile || {});
    return sendSuccess(res, { user }, 'Profile updated successfully');
  })
};
