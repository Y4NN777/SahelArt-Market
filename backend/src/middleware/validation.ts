import { Request, Response, NextFunction } from 'express';
import { Schema } from 'joi';
import { ApiError } from '../utils/ApiError';

export const validate = (schema: Schema) => {
  return (req: Request, _res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, { abortEarly: false, allowUnknown: false });
    if (error) {
      return next(
        new ApiError(
          400,
          'VALIDATION_ERROR',
          'Validation failed',
          error.details.map((detail) => ({ field: detail.path.join('.'), message: detail.message }))
        )
      );
    }
    return next();
  };
};
