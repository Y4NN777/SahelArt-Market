import { Request, Response } from 'express';
import { UserService } from '../services/user.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess } from '../utils/ApiResponse';

export const UserController = {
  updateMe: asyncHandler(async (req: Request, res: Response) => {
    const { profile } = req.body;
    const user = await UserService.updateProfile(req.user!.id, profile || {});
    const obj = user.toObject ? user.toObject() : user;
    delete obj.passwordHash;
    return sendSuccess(res, { user: obj }, 'Profile updated successfully');
  })
};
