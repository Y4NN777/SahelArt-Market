import { validateEnv } from '../../../src/config/env';

describe('Environment Validation', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it('should pass with all required env vars', () => {
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = 'strong-secret';
    process.env.REFRESH_TOKEN_PEPPER = 'strong-pepper';

    expect(() => validateEnv()).not.toThrow();
  });

  it('should throw if MONGO_URI is missing', () => {
    delete process.env.MONGO_URI;
    process.env.JWT_SECRET = 'strong-secret';
    process.env.REFRESH_TOKEN_PEPPER = 'strong-pepper';

    expect(() => validateEnv()).toThrow('Missing required environment variables: MONGO_URI');
  });

  it('should throw if JWT_SECRET is missing', () => {
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    delete process.env.JWT_SECRET;
    process.env.REFRESH_TOKEN_PEPPER = 'strong-pepper';

    expect(() => validateEnv()).toThrow('Missing required environment variables: JWT_SECRET');
  });

  it('should throw if REFRESH_TOKEN_PEPPER is missing', () => {
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = 'strong-secret';
    delete process.env.REFRESH_TOKEN_PEPPER;

    expect(() => validateEnv()).toThrow('Missing required environment variables: REFRESH_TOKEN_PEPPER');
  });

  it('should throw if multiple required vars are missing', () => {
    delete process.env.MONGO_URI;
    delete process.env.JWT_SECRET;
    process.env.REFRESH_TOKEN_PEPPER = 'strong-pepper';

    expect(() => validateEnv()).toThrow('Missing required environment variables: MONGO_URI, JWT_SECRET');
  });

  it('should reject weak secrets in production', () => {
    process.env.NODE_ENV = 'production';
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = 'change_me';
    process.env.REFRESH_TOKEN_PEPPER = 'strong-pepper';

    expect(() => validateEnv()).toThrow('Weak secrets detected in production');
  });

  it('should reject weak pepper in production', () => {
    process.env.NODE_ENV = 'production';
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = 'strong-secret';
    process.env.REFRESH_TOKEN_PEPPER = 'change_me_too';

    expect(() => validateEnv()).toThrow('Weak secrets detected in production');
  });

  it('should reject weak webhook secret in production', () => {
    process.env.NODE_ENV = 'production';
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = 'strong-secret';
    process.env.REFRESH_TOKEN_PEPPER = 'strong-pepper';
    process.env.PAYMENT_WEBHOOK_SECRET = 'change_me_webhook';

    expect(() => validateEnv()).toThrow('Weak secrets detected in production');
  });

  it('should allow weak secrets in development', () => {
    process.env.NODE_ENV = 'development';
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = 'change_me';
    process.env.REFRESH_TOKEN_PEPPER = 'change_me_too';

    expect(() => validateEnv()).not.toThrow();
  });

  it('should allow weak secrets in test', () => {
    process.env.NODE_ENV = 'test';
    process.env.MONGO_URI = 'mongodb://localhost:27017/test';
    process.env.JWT_SECRET = 'change_me';
    process.env.REFRESH_TOKEN_PEPPER = 'change_me_too';

    expect(() => validateEnv()).not.toThrow();
  });
});
