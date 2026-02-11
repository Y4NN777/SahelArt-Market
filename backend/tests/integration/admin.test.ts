import { request } from '../helpers/app.helper';
import { createAuthenticatedUser } from '../helpers/auth.helper';

describe('Admin API', () => {
  describe('GET /api/v1/admin/stats', () => {
    it('should return stats for admin', async () => {
      const { token } = await createAuthenticatedUser({ role: 'admin', email: 'stats-admin@test.com' });

      const res = await request()
        .get('/api/v1/admin/stats')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('users');
      expect(res.body.data).toHaveProperty('products');
      expect(res.body.data).toHaveProperty('orders');
      expect(res.body.data).toHaveProperty('revenue');
    });

    it('should return 403 for non-admin', async () => {
      const { token } = await createAuthenticatedUser({ role: 'customer', email: 'not-admin@test.com' });

      const res = await request()
        .get('/api/v1/admin/stats')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(403);
    });
  });

  describe('GET /api/v1/admin/users', () => {
    it('should list users with pagination', async () => {
      const { token } = await createAuthenticatedUser({ role: 'admin', email: 'list-admin@test.com' });
      await createAuthenticatedUser({ role: 'customer', email: 'u1@test.com' });
      await createAuthenticatedUser({ role: 'vendor', email: 'u2@test.com' });

      const res = await request()
        .get('/api/v1/admin/users')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThanOrEqual(3);
      expect(res.body.pagination).toBeDefined();
    });

    it('should filter by role', async () => {
      const { token } = await createAuthenticatedUser({ role: 'admin', email: 'filter-admin@test.com' });
      await createAuthenticatedUser({ role: 'vendor', email: 'v-filter@test.com' });

      const res = await request()
        .get('/api/v1/admin/users?role=vendor')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      const roles = res.body.data.map((u: any) => u.role);
      expect(roles.every((r: string) => r === 'vendor')).toBe(true);
    });
  });

  describe('PATCH /api/v1/admin/users/:id/suspend', () => {
    it('should suspend a user', async () => {
      const admin = await createAuthenticatedUser({ role: 'admin', email: 'suspend-admin@test.com' });
      const target = await createAuthenticatedUser({ role: 'customer', email: 'target@test.com' });

      const res = await request()
        .patch(`/api/v1/admin/users/${target.user.id}/suspend`)
        .set('Authorization', `Bearer ${admin.token}`)
        .send({ reason: 'Violation des règles' });

      expect(res.status).toBe(200);
      expect(res.body.data.user.status).toBe('suspended');
    });

    it('should prevent suspended user from logging in', async () => {
      const admin = await createAuthenticatedUser({ role: 'admin', email: 'sus-admin2@test.com' });
      const target = await createAuthenticatedUser({
        role: 'customer',
        email: 'login-target@test.com',
        password: 'TargetPass1!'
      });

      await request()
        .patch(`/api/v1/admin/users/${target.user.id}/suspend`)
        .set('Authorization', `Bearer ${admin.token}`);

      const loginRes = await request()
        .post('/api/v1/auth/login')
        .send({ email: 'login-target@test.com', password: 'TargetPass1!' });

      expect(loginRes.status).toBe(403);
      expect(loginRes.body.error.code).toBe('ACCOUNT_SUSPENDED');
    });
  });
});
