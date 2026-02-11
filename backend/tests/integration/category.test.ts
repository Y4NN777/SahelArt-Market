import { request } from '../helpers/app.helper';
import { createTestCategory } from '../helpers/fixtures';

describe('Category API', () => {
  describe('GET /api/v1/categories', () => {
    it('should return sorted category list', async () => {
      await createTestCategory({ name: 'Bijoux', slug: 'bijoux', description: 'Bijoux artisanaux' });
      await createTestCategory({ name: 'Artisanat', slug: 'artisanat', description: 'Artisanat général' });

      const res = await request().get('/api/v1/categories');

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(2);
      expect(res.body.data[0].name).toBe('Artisanat');
      expect(res.body.data[1].name).toBe('Bijoux');
    });
  });
});
