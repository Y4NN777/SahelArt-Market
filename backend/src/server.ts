import dotenv from 'dotenv';
import { createApp } from './app';
import { connectDatabase } from './config/database';

dotenv.config();

const port = process.env.PORT || 3000;

const start = async () => {
  await connectDatabase();
  const app = createApp();
  app.listen(port, () => {
    // eslint-disable-next-line no-console
    console.log(`API running on port ${port}`);
  });
};

start().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('Failed to start server', err);
  process.exit(1);
});
