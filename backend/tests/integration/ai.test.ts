import request from 'supertest';
import { createApp } from '../../src/app';
import { createAuthenticatedUser } from '../helpers/auth.helper';
import * as aiConfig from '../../src/config/ai';

jest.mock('../../src/config/ai');

const app = createApp();

describe('AI API', () => {
  const mockIsAIEnabled = aiConfig.isAIEnabled as jest.MockedFunction<typeof aiConfig.isAIEnabled>;
  const mockGetAI = aiConfig.getAI as jest.MockedFunction<typeof aiConfig.getAI>;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /api/v1/ai/enhance-description', () => {
    it('should require authentication', async () => {
      const res = await request(app)
        .post('/api/v1/ai/enhance-description')
        .send({
          name: 'Test Product',
          categoryName: 'Handicraft'
        });

      expect(res.status).toBe(401);
    });

    it('should require vendor or admin role', async () => {
      const { token } = await createAuthenticatedUser({ role: 'customer' });

      const res = await request(app)
        .post('/api/v1/ai/enhance-description')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Test Product',
          categoryName: 'Handicraft'
        });

      expect(res.status).toBe(403);
    });

    it('should return 503 when AI is disabled', async () => {
      mockIsAIEnabled.mockReturnValue(false);
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .post('/api/v1/ai/enhance-description')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Test Product',
          categoryName: 'Handicraft'
        });

      expect(res.status).toBe(503);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AI_SERVICE_ERROR');
    });

    it('should enhance description when AI is enabled', async () => {
      mockIsAIEnabled.mockReturnValue(true);

      const mockResponse = {
        response: {
          text: () => JSON.stringify({
            fr: 'Description en français',
            en: 'Description in English'
          })
        }
      };

      const mockModel = {
        generateContent: jest.fn().mockResolvedValue(mockResponse)
      };

      mockGetAI.mockReturnValue({
        getGenerativeModel: () => mockModel
      } as any);

      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .post('/api/v1/ai/enhance-description')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Test Product',
          categoryName: 'Handicraft'
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toEqual({
        fr: 'Description en français',
        en: 'Description in English'
      });
    });

    it('should validate required fields', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .post('/api/v1/ai/enhance-description')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Test Product'
          // missing categoryName
        });

      expect(res.status).toBe(400);
    });
  });

  describe('POST /api/v1/ai/analyze-image', () => {
    it('should require authentication', async () => {
      const res = await request(app)
        .post('/api/v1/ai/analyze-image')
        .send({
          imageBase64: 'base64data',
          mimeType: 'image/jpeg'
        });

      expect(res.status).toBe(401);
    });

    it('should require vendor or admin role', async () => {
      const { token } = await createAuthenticatedUser({ role: 'customer' });

      const res = await request(app)
        .post('/api/v1/ai/analyze-image')
        .set('Authorization', `Bearer ${token}`)
        .send({
          imageBase64: 'base64data',
          mimeType: 'image/jpeg'
        });

      expect(res.status).toBe(403);
    });

    it('should analyze image when AI is enabled', async () => {
      mockIsAIEnabled.mockReturnValue(true);

      const mockResponse = {
        response: {
          text: () => JSON.stringify({
            categories: ['Textiles'],
            tags: ['cotton', 'handmade'],
            description: 'A beautiful textile'
          })
        }
      };

      const mockModel = {
        generateContent: jest.fn().mockResolvedValue(mockResponse)
      };

      mockGetAI.mockReturnValue({
        getGenerativeModel: () => mockModel
      } as any);

      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .post('/api/v1/ai/analyze-image')
        .set('Authorization', `Bearer ${token}`)
        .send({
          imageBase64: 'base64data',
          mimeType: 'image/jpeg'
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.categories).toBeDefined();
      expect(res.body.data.tags).toBeDefined();
      expect(res.body.data.description).toBeDefined();
    });

    it('should validate mime type', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .post('/api/v1/ai/analyze-image')
        .set('Authorization', `Bearer ${token}`)
        .send({
          imageBase64: 'base64data',
          mimeType: 'application/pdf' // invalid
        });

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/ai/recommendations', () => {
    it('should require authentication', async () => {
      const res = await request(app).get('/api/v1/ai/recommendations');

      expect(res.status).toBe(401);
    });

    it('should require customer role', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .get('/api/v1/ai/recommendations')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(403);
    });

    it('should return empty recommendations for customers with no orders', async () => {
      const { token } = await createAuthenticatedUser({ role: 'customer' });

      const res = await request(app)
        .get('/api/v1/ai/recommendations')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.recommendations).toEqual([]);
    });
  });

  describe('GET /api/v1/ai/insights', () => {
    it('should require authentication', async () => {
      const res = await request(app).get('/api/v1/ai/insights');

      expect(res.status).toBe(401);
    });

    it('should require admin role', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request(app)
        .get('/api/v1/ai/insights')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(403);
    });

    it('should return insights for admin', async () => {
      mockIsAIEnabled.mockReturnValue(true);

      const mockResponse = {
        response: {
          text: () => JSON.stringify({
            summary: 'Platform is performing well',
            insights: ['Insight 1'],
            recommendations: ['Recommendation 1']
          })
        }
      };

      const mockModel = {
        generateContent: jest.fn().mockResolvedValue(mockResponse)
      };

      mockGetAI.mockReturnValue({
        getGenerativeModel: () => mockModel
      } as any);

      const { token } = await createAuthenticatedUser({ role: 'admin' });

      const res = await request(app)
        .get('/api/v1/ai/insights')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.summary).toBeDefined();
      expect(res.body.data.insights).toBeDefined();
      expect(res.body.data.recommendations).toBeDefined();
    });
  });
});
