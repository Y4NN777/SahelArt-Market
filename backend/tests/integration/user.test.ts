import { request } from '../helpers/app.helper';
import { createAuthenticatedUser } from '../helpers/auth.helper';

describe('User API', () => {
  describe('PATCH /api/v1/users/me', () => {
    it('should update user profile', async () => {
      const { token } = await createAuthenticatedUser({ email: 'update-me@test.com' });

      const res = await request()
        .patch('/api/v1/users/me')
        .set('Authorization', `Bearer ${token}`)
        .send({
          profile: {
            firstName: 'Awa',
            lastName: 'Coulibaly',
            phone: '+22376543210'
          }
        });

      expect(res.status).toBe(200);
      expect(res.body.data.user.profile.firstName).toBe('Awa');
      expect(res.body.data.user.profile.phone).toBe('+22376543210');
    });

    it('should return 401 without auth', async () => {
      const res = await request()
        .patch('/api/v1/users/me')
        .send({ profile: { firstName: 'Hacker' } });

      expect(res.status).toBe(401);
    });
  });
});
