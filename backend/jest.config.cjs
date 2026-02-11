module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.ts'],
  clearMocks: true,
  setupFiles: ['./tests/helpers/email.mock.ts'],
  setupFilesAfterEnv: ['./tests/setup.ts'],
  testTimeout: 30000,
  maxWorkers: 1
};
