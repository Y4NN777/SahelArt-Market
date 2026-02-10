import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import path from 'path';
import router from './routes';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './middleware/logger';

export const createApp = () => {
  const app = express();

  app.use(helmet());
  app.use(cors({
    origin: true,
    credentials: true
  }));
  app.use(express.json());
  app.use(cookieParser());
  app.use(logger);

  const uploadDir = process.env.UPLOAD_DIR || 'uploads';
  app.use('/uploads', express.static(path.resolve(uploadDir)));

  const healthHandler = (_req: express.Request, res: express.Response) => {
    res.json({ status: 'ok' });
  };

  app.get('/api/v1/health', healthHandler);

  app.use('/api/v1', router);

  app.use(errorHandler);

  return app;
};
