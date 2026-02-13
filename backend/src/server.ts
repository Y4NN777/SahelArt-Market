import dotenv from 'dotenv';
import http from 'http';
import { createApp } from './app';
import { connectDatabase } from './config/database';
import { validateEnv } from './config/env';
import { initializeSocketIO } from './config/socket';
import { initializeAI } from './config/ai';

dotenv.config();

const port = process.env.PORT || 3000;

const start = async () => {
  validateEnv();
  await connectDatabase();
  initializeAI();
  const app = createApp();
  const httpServer = http.createServer(app);
  initializeSocketIO(httpServer);
  httpServer.listen(port, () => {
    // eslint-disable-next-line no-console
    console.log(`API running on port ${port}`);
  });
};

start().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('Failed to start server', err);
  process.exit(1);
});
