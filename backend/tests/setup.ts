import mongoose from 'mongoose';
import { MongoMemoryReplSet } from 'mongodb-memory-server';

let replSet: MongoMemoryReplSet;

beforeAll(async () => {
  process.env.NODE_ENV = 'test';
  process.env.JWT_SECRET = 'test-jwt-secret';
  process.env.JWT_EXPIRES_IN = '15m';
  process.env.REFRESH_TOKEN_PEPPER = 'test-pepper';
  process.env.PAYMENT_WEBHOOK_SECRET = 'test-webhook-secret';
  process.env.ALLOWED_ORIGINS = 'http://localhost:3000';

  replSet = await MongoMemoryReplSet.create({
    replSet: { count: 1, storageEngine: 'wiredTiger' }
  });

  const uri = replSet.getUri();
  await mongoose.connect(uri);

  // Ensure all indexes are created before tests run
  await Promise.all(
    Object.values(mongoose.connection.models).map((model) => model.ensureIndexes())
  );
}, 60000);

afterEach(async () => {
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    await collections[key].deleteMany({});
  }
});

afterAll(async () => {
  await mongoose.disconnect();
  await replSet.stop();
});
