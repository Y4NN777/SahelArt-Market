import { Request, Response } from 'express';
import { CategoryService } from '../services/category.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess } from '../utils/ApiResponse';

export const CategoryController = {
  list: asyncHandler(async (_req: Request, res: Response) => {
    const categories = await CategoryService.list();
    return sendSuccess(res, categories);
  })
};
