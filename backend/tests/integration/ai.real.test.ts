/**
 * Real AI Integration Tests (Optional)
 *
 * These tests use the actual Gemini API and only run when GEMINI_API_KEY is set.
 *
 * To run these tests:
 * 1. Set GEMINI_API_KEY in your .env file
 * 2. Run: npm test -- ai.real.test.ts
 *
 * Note: These tests consume API quota and may be slower.
 */

import request from 'supertest';
import { createApp } from '../../src/app';
import { createAuthenticatedUser } from '../helpers/auth.helper';
import { initializeAI, isAIEnabled } from '../../src/config/ai';

const hasApiKey = !!process.env.GEMINI_API_KEY;

const describeOrSkip = hasApiKey ? describe : describe.skip;

describeOrSkip('Real AI API Integration (requires GEMINI_API_KEY)', () => {
  const app = createApp();

  beforeAll(() => {
    initializeAI();
    if (!isAIEnabled()) {
      throw new Error('AI not initialized despite GEMINI_API_KEY being set');
    }
  });

  describe('POST /api/v1/ai/enhance-description', () => {
    it('should generate real FR/EN descriptions', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .post('/api/v1/ai/enhance-description')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Panier en osier traditionnel',
          categoryName: 'Vannerie'
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('fr');
      expect(res.body.data).toHaveProperty('en');
      expect(res.body.data.fr).toMatch(/panier|vannerie|artisan/i);
      expect(res.body.data.en).toMatch(/basket|weaving|craft/i);

      // Descriptions should be substantial
      expect(res.body.data.fr.length).toBeGreaterThan(100);
      expect(res.body.data.en.length).toBeGreaterThan(100);
    }, 30000); // 30s timeout for API call

    it('should include cultural context about Sahel region', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .post('/api/v1/ai/enhance-description')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Bijoux touareg en argent',
          categoryName: 'Bijoux',
          existingDescription: 'Bijoux fait main'
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);

      // Should mention Sahel, traditional techniques, or cultural elements
      const frText = res.body.data.fr.toLowerCase();
      const hasRelevantContext =
        frText.includes('sahel') ||
        frText.includes('touareg') ||
        frText.includes('traditionnel') ||
        frText.includes('artisan') ||
        frText.includes('afrique');

      expect(hasRelevantContext).toBe(true);
    }, 30000);
  });

  describe('POST /api/v1/ai/analyze-image', () => {
    it('should analyze a base64 image and return categories/tags', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      // Simple 1x1 red pixel PNG as base64
      const redPixelPng = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';

      const res = await request(app)
        .post('/api/v1/ai/analyze-image')
        .set('Authorization', `Bearer ${token}`)
        .send({
          imageBase64: redPixelPng,
          mimeType: 'image/png'
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('categories');
      expect(res.body.data).toHaveProperty('tags');
      expect(res.body.data).toHaveProperty('description');
      expect(Array.isArray(res.body.data.categories)).toBe(true);
      expect(Array.isArray(res.body.data.tags)).toBe(true);
    }, 30000);
  });

  describe('GET /api/v1/ai/recommendations', () => {
    it('should return empty recommendations for user with no orders', async () => {
      const { token } = await createAuthenticatedUser({ role: 'customer' });

      const res = await request(app)
        .get('/api/v1/ai/recommendations')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.recommendations).toEqual([]);
    }, 30000);

    // Note: Testing with actual orders would require more complex setup
    // and would be better suited for E2E tests
  });

  describe('GET /api/v1/ai/insights', () => {
    it('should generate real admin insights', async () => {
      const { token } = await createAuthenticatedUser({ role: 'admin' });

      const res = await request(app)
        .get('/api/v1/ai/insights')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('summary');
      expect(res.body.data).toHaveProperty('insights');
      expect(res.body.data).toHaveProperty('recommendations');

      expect(typeof res.body.data.summary).toBe('string');
      expect(Array.isArray(res.body.data.insights)).toBe(true);
      expect(Array.isArray(res.body.data.recommendations)).toBe(true);

      // Should provide meaningful content
      expect(res.body.data.summary.length).toBeGreaterThan(50);
      expect(res.body.data.insights.length).toBeGreaterThan(0);
      expect(res.body.data.recommendations.length).toBeGreaterThan(0);
    }, 30000);
  });
});

// Log a message if tests are skipped
if (!hasApiKey) {
  console.log('\n⚠️  Skipping real AI integration tests (GEMINI_API_KEY not set)\n');
  console.log('To run these tests, set GEMINI_API_KEY in your environment.\n');
}
