import { Request, Response, NextFunction } from 'express';

export const invariantsCheck = (_req: Request, _res: Response, next: NextFunction) => {
  return next();
};
