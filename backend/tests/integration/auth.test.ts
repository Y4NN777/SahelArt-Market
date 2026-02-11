import { request } from '../helpers/app.helper';
import { createTestUser, createAuthenticatedUser } from '../helpers/auth.helper';
import { RefreshToken } from '../../src/models/RefreshToken';

describe('Auth API', () => {
  describe('POST /api/v1/auth/register', () => {
    it('should register a new customer and return user + tokens', async () => {
      const res = await request()
        .post('/api/v1/auth/register')
        .send({
          email: 'fatou@example.com',
          password: 'SecurePass123!',
          role: 'customer',
          profile: { firstName: 'Fatou', lastName: 'Traoré' }
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user.email).toBe('fatou@example.com');
      expect(res.body.data.user.role).toBe('customer');
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
      expect(res.body.data.user.passwordHash).toBeUndefined();
    });

    it('should return 409 for duplicate email', async () => {
      await createTestUser({ email: 'dupe@example.com' });

      const res = await request()
        .post('/api/v1/auth/register')
        .send({
          email: 'dupe@example.com',
          password: 'SecurePass123!',
          role: 'customer',
          profile: { firstName: 'Test', lastName: 'User' }
        });

      expect(res.status).toBe(409);
      expect(res.body.error.code).toBe('EMAIL_ALREADY_EXISTS');
    });

    it('should return 400 for missing required fields', async () => {
      const res = await request()
        .post('/api/v1/auth/register')
        .send({ email: 'test@example.com' });

      expect(res.status).toBe(400);
    });

    it('should return 400 for admin role', async () => {
      const res = await request()
        .post('/api/v1/auth/register')
        .send({
          email: 'admin@example.com',
          password: 'SecurePass123!',
          role: 'admin',
          profile: { firstName: 'Test', lastName: 'Admin' }
        });

      expect(res.status).toBe(400);
    });
  });

  describe('POST /api/v1/auth/login', () => {
    it('should login with correct credentials', async () => {
      await createTestUser({ email: 'login@example.com', password: 'MyPassword1!' });

      const res = await request()
        .post('/api/v1/auth/login')
        .send({ email: 'login@example.com', password: 'MyPassword1!' });

      expect(res.status).toBe(200);
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
    });

    it('should return 401 for wrong password', async () => {
      await createTestUser({ email: 'wrong@example.com', password: 'CorrectPass1!' });

      const res = await request()
        .post('/api/v1/auth/login')
        .send({ email: 'wrong@example.com', password: 'WrongPass1!' });

      expect(res.status).toBe(401);
      expect(res.body.error.code).toBe('INVALID_CREDENTIALS');
    });

    it('should return 401 for non-existent email', async () => {
      const res = await request()
        .post('/api/v1/auth/login')
        .send({ email: 'noexist@example.com', password: 'SomePass1!' });

      expect(res.status).toBe(401);
    });

    it('should return 403 for suspended account', async () => {
      await createTestUser({ email: 'suspended@example.com', password: 'MyPass1!', status: 'suspended' });

      const res = await request()
        .post('/api/v1/auth/login')
        .send({ email: 'suspended@example.com', password: 'MyPass1!' });

      expect(res.status).toBe(403);
      expect(res.body.error.code).toBe('ACCOUNT_SUSPENDED');
    });
  });

  describe('GET /api/v1/auth/me', () => {
    it('should return current user with valid token', async () => {
      const { token } = await createAuthenticatedUser({ email: 'me@example.com' });

      const res = await request()
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.user.email).toBe('me@example.com');
    });

    it('should return 401 without token', async () => {
      const res = await request().get('/api/v1/auth/me');
      expect(res.status).toBe(401);
    });
  });

  describe('POST /api/v1/auth/refresh', () => {
    it('should rotate refresh tokens', async () => {
      const registerRes = await request()
        .post('/api/v1/auth/register')
        .send({
          email: 'refresh@example.com',
          password: 'SecurePass123!',
          role: 'customer',
          profile: { firstName: 'Test', lastName: 'Refresh' }
        });

      const oldRefresh = registerRes.body.data.refreshToken;

      const res = await request()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: oldRefresh });

      expect(res.status).toBe(200);
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
      expect(res.body.data.refreshToken).not.toBe(oldRefresh);
    });

    it('should return 401 for revoked token', async () => {
      const registerRes = await request()
        .post('/api/v1/auth/register')
        .send({
          email: 'revoke@example.com',
          password: 'SecurePass123!',
          role: 'customer',
          profile: { firstName: 'Test', lastName: 'Revoke' }
        });

      const oldRefresh = registerRes.body.data.refreshToken;

      // Use the token once (rotates it)
      await request()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: oldRefresh });

      // Try to reuse the old (now revoked) token
      const res = await request()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: oldRefresh });

      expect(res.status).toBe(401);
    });
  });

  describe('POST /api/v1/auth/logout', () => {
    it('should revoke refresh token', async () => {
      const registerRes = await request()
        .post('/api/v1/auth/register')
        .send({
          email: 'logout@example.com',
          password: 'SecurePass123!',
          role: 'customer',
          profile: { firstName: 'Test', lastName: 'Logout' }
        });

      const refreshToken = registerRes.body.data.refreshToken;

      const logoutRes = await request()
        .post('/api/v1/auth/logout')
        .send({ refreshToken });

      expect(logoutRes.status).toBe(200);

      // Token should be revoked now
      const refreshRes = await request()
        .post('/api/v1/auth/refresh')
        .send({ refreshToken });

      expect(refreshRes.status).toBe(401);
    });
  });
});
