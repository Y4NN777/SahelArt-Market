import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import cookieParser from 'cookie-parser';
import path from 'path';
import router from './routes';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './middleware/logger';
import { apiRateLimiter } from './middleware/rateLimiter';

export const createApp = () => {
  const app = express();

  app.use(helmet());
  app.use(compression());

  const allowedOrigins = process.env.ALLOWED_ORIGINS
    ? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim())
    : [];

  app.use(cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true
  }));
  // AI image analysis receives base64 payloads that can be several MB.
  app.use(express.json({ limit: '8mb' }));
  app.use(cookieParser());
  app.use(logger);

  const uploadDir = process.env.UPLOAD_DIR || 'uploads';
  app.use('/uploads', express.static(path.resolve(uploadDir)));

  const healthHandler = (_req: express.Request, res: express.Response) => {
    res.json({ status: 'ok' });
  };

  app.get('/api/v1/health', healthHandler);

  app.use('/api/v1', apiRateLimiter, router);

  app.use(errorHandler);

  return app;
};
