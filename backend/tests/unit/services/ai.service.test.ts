import { AIService } from '../../../src/services/ai.service';
import * as aiConfig from '../../../src/config/ai';

jest.mock('../../../src/config/ai');

describe('AI Service', () => {
  const mockIsAIEnabled = aiConfig.isAIEnabled as jest.MockedFunction<typeof aiConfig.isAIEnabled>;
  const mockGetAI = aiConfig.getAI as jest.MockedFunction<typeof aiConfig.getAI>;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('enhanceProductDescription', () => {
    it('should return error when AI is disabled', async () => {
      mockIsAIEnabled.mockReturnValue(false);

      const result = await AIService.enhanceProductDescription('Basket', 'Handicraft');

      expect(result.success).toBe(false);
      expect(result.error).toBe('AI features are disabled');
      expect(result.data).toBeUndefined();
    });

    it('should return enhanced descriptions when AI is enabled', async () => {
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

      const result = await AIService.enhanceProductDescription('Basket', 'Handicraft', 'Old description');

      expect(result.success).toBe(true);
      expect(result.data).toEqual({
        fr: 'Description en français',
        en: 'Description in English'
      });
      expect(result.error).toBeUndefined();
    });

    it('should handle API errors gracefully', async () => {
      mockIsAIEnabled.mockReturnValue(true);

      const mockModel = {
        generateContent: jest.fn()
          .mockRejectedValueOnce(new Error('API Error'))
          .mockRejectedValueOnce(new Error('API Error'))
          .mockRejectedValue(new Error('API Error'))
      };

      mockGetAI.mockReturnValue({
        getGenerativeModel: () => mockModel
      } as any);

      // Use unique product name to avoid cache hit from previous test
      const uniqueName = `ErrorTestBasket-${Date.now()}`;
      const result = await AIService.enhanceProductDescription(uniqueName, 'Handicraft');

      expect(result.success).toBe(false);
      expect(result.error).toBe('API Error');
      expect(result.data).toBeUndefined();
      expect(mockModel.generateContent).toHaveBeenCalledTimes(3); // 3 retries
    });
  });

  describe('analyzeProductImage', () => {
    it('should return error when AI is disabled', async () => {
      mockIsAIEnabled.mockReturnValue(false);

      const result = await AIService.analyzeProductImage('base64data', 'image/jpeg');

      expect(result.success).toBe(false);
      expect(result.error).toBe('AI features are disabled');
    });

    it('should return analysis when AI is enabled', async () => {
      mockIsAIEnabled.mockReturnValue(true);

      const mockResponse = {
        response: {
          text: () => JSON.stringify({
            categories: ['Textiles', 'Handicraft'],
            tags: ['cotton', 'handmade', 'colorful'],
            description: 'A beautiful handmade basket'
          })
        }
      };

      const mockModel = {
        generateContent: jest.fn().mockResolvedValue(mockResponse)
      };

      mockGetAI.mockReturnValue({
        getGenerativeModel: () => mockModel
      } as any);

      const result = await AIService.analyzeProductImage('base64data', 'image/jpeg');

      expect(result.success).toBe(true);
      expect(result.data?.categories).toEqual(['Textiles', 'Handicraft']);
      expect(result.data?.tags).toEqual(['cotton', 'handmade', 'colorful']);
    });
  });

  describe('generateRecommendations', () => {
    it('should return error when AI is disabled', async () => {
      mockIsAIEnabled.mockReturnValue(false);

      const result = await AIService.generateRecommendations('user123', []);

      expect(result.success).toBe(false);
      expect(result.error).toBe('AI features are disabled');
    });

    it('should return recommendations when AI is enabled', async () => {
      mockIsAIEnabled.mockReturnValue(true);

      const mockResponse = {
        response: {
          text: () => JSON.stringify({
            recommendations: ['Product 1', 'Product 2', 'Product 3']
          })
        }
      };

      const mockModel = {
        generateContent: jest.fn().mockResolvedValue(mockResponse)
      };

      mockGetAI.mockReturnValue({
        getGenerativeModel: () => mockModel
      } as any);

      const orderHistory = [
        { productName: 'Basket', categoryName: 'Handicraft' },
        { productName: 'Textile', categoryName: 'Textiles' }
      ];

      const result = await AIService.generateRecommendations('user123', orderHistory);

      expect(result.success).toBe(true);
      expect(result.data?.recommendations).toHaveLength(3);
    });
  });

  describe('generateAdminInsights', () => {
    it('should return error when AI is disabled', async () => {
      mockIsAIEnabled.mockReturnValue(false);

      const stats = {
        totalOrders: 100,
        totalRevenue: 50000,
        totalProducts: 200,
        totalVendors: 50,
        topCategories: [],
        recentTrends: 'Growing'
      };

      const result = await AIService.generateAdminInsights(stats);

      expect(result.success).toBe(false);
      expect(result.error).toBe('AI features are disabled');
    });

    it('should return insights when AI is enabled', async () => {
      mockIsAIEnabled.mockReturnValue(true);

      const mockResponse = {
        response: {
          text: () => JSON.stringify({
            summary: 'Platform is performing well',
            insights: ['Insight 1', 'Insight 2'],
            recommendations: ['Recommendation 1', 'Recommendation 2']
          })
        }
      };

      const mockModel = {
        generateContent: jest.fn().mockResolvedValue(mockResponse)
      };

      mockGetAI.mockReturnValue({
        getGenerativeModel: () => mockModel
      } as any);

      const stats = {
        totalOrders: 100,
        totalRevenue: 50000,
        totalProducts: 200,
        totalVendors: 50,
        topCategories: [{ name: 'Textiles', count: 50 }],
        recentTrends: 'Growing'
      };

      const result = await AIService.generateAdminInsights(stats);

      expect(result.success).toBe(true);
      expect(result.data?.summary).toBeDefined();
      expect(result.data?.insights).toHaveLength(2);
      expect(result.data?.recommendations).toHaveLength(2);
    });
  });
});
