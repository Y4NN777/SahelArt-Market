import { getAI, isAIEnabled } from '../config/ai';

interface CacheEntry {
  data: any;
  timestamp: number;
}

const cache = new Map<string, CacheEntry>();
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours

const getCached = (key: string): any | null => {
  const entry = cache.get(key);
  if (!entry) return null;
  if (Date.now() - entry.timestamp > CACHE_TTL) {
    cache.delete(key);
    return null;
  }
  return entry.data;
};

const setCache = (key: string, data: any) => {
  cache.set(key, { data, timestamp: Date.now() });
};

const retry = async <T>(fn: () => Promise<T>, retries = 3): Promise<T> => {
  let lastError: Error | null = null;
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;
      if (i < retries - 1) {
        await new Promise((resolve) => setTimeout(resolve, Math.pow(2, i) * 1000));
      }
    }
  }
  throw lastError;
};

export const AIService = {
  async enhanceProductDescription(
    name: string,
    categoryName: string,
    existingDesc?: string
  ): Promise<{ success: boolean; data?: { fr: string; en: string }; error?: string }> {
    if (!isAIEnabled()) {
      return { success: false, error: 'AI features are disabled' };
    }

    const cacheKey = `enhance:${name}:${categoryName}:${existingDesc || ''}`;
    const cached = getCached(cacheKey);
    if (cached) {
      return { success: true, data: cached };
    }

    try {
      const result = await retry(async () => {
        const genAI = getAI();
        const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

        const prompt = `Tu es un expert en artisanat africain, particulièrement de la région du Sahel (Mali, Sénégal, Niger, Burkina Faso, Mauritanie).

Produit: ${name}
Catégorie: ${categoryName}
${existingDesc ? `Description actuelle: ${existingDesc}` : ''}

Génère deux descriptions riches et culturellement appropriées pour ce produit artisanal :
1. Une description en français (150-200 mots)
2. Une description en anglais (150-200 mots)

Les descriptions doivent :
- Mettre en valeur le savoir-faire artisanal et les techniques traditionnelles
- Mentionner l'origine culturelle et géographique (région du Sahel)
- Évoquer les matériaux utilisés et leur provenance locale
- Souligner l'authenticité et l'unicité de la pièce
- Être attrayantes pour des acheteurs internationaux intéressés par l'artisanat africain authentique

Retourne au format JSON strict :
{
  "fr": "description en français",
  "en": "description in English"
}`;

        const response = await model.generateContent(prompt);
        const text = response.response.text();
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          throw new Error('Invalid response format');
        }
        return JSON.parse(jsonMatch[0]);
      });

      setCache(cacheKey, result);
      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: (error as Error).message };
    }
  },

  async analyzeProductImage(
    imageBase64: string,
    mimeType: string
  ): Promise<{ success: boolean; data?: { categories: string[]; tags: string[]; description: string }; error?: string }> {
    if (!isAIEnabled()) {
      return { success: false, error: 'AI features are disabled' };
    }

    try {
      const result = await retry(async () => {
        const genAI = getAI();
        const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

        const prompt = `Analyse cette image d'un produit artisanal africain (région du Sahel).

Identifie :
1. Les catégories appropriées (ex: "Textiles", "Bijoux", "Poterie", "Vannerie", "Sculptures", "Instruments de musique", "Maroquinerie")
2. Des tags descriptifs (matériaux, couleurs, motifs, techniques, origine ethnique si identifiable)
3. Une brève description du produit (50-100 mots)

Retourne au format JSON strict :
{
  "categories": ["categorie1", "categorie2"],
  "tags": ["tag1", "tag2", "tag3", "tag4", "tag5"],
  "description": "description du produit"
}`;

        const response = await model.generateContent([
          prompt,
          {
            inlineData: {
              data: imageBase64,
              mimeType
            }
          }
        ]);

        const text = response.response.text();
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          throw new Error('Invalid response format');
        }
        return JSON.parse(jsonMatch[0]);
      });

      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: (error as Error).message };
    }
  },

  async generateRecommendations(
    userId: string,
    orderHistory: { productName: string; categoryName: string }[]
  ): Promise<{ success: boolean; data?: { recommendations: string[] }; error?: string }> {
    if (!isAIEnabled()) {
      return { success: false, error: 'AI features are disabled' };
    }

    const cacheKey = `reco:${userId}:${orderHistory.map((o) => o.productName).join(',')}`;
    const cached = getCached(cacheKey);
    if (cached) {
      return { success: true, data: cached };
    }

    try {
      const result = await retry(async () => {
        const genAI = getAI();
        const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

        const historyText = orderHistory
          .map((o) => `- ${o.productName} (${o.categoryName})`)
          .join('\n');

        const prompt = `Basé sur l'historique d'achat suivant de produits artisanaux du Sahel :

${historyText}

Génère 5 recommandations de produits artisanaux qui pourraient intéresser ce client. Chaque recommandation doit être spécifique et pertinente par rapport à l'historique.

Retourne au format JSON strict :
{
  "recommendations": [
    "Nom de produit recommandé 1",
    "Nom de produit recommandé 2",
    "Nom de produit recommandé 3",
    "Nom de produit recommandé 4",
    "Nom de produit recommandé 5"
  ]
}`;

        const response = await model.generateContent(prompt);
        const text = response.response.text();
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          throw new Error('Invalid response format');
        }
        return JSON.parse(jsonMatch[0]);
      });

      setCache(cacheKey, result);
      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: (error as Error).message };
    }
  },

  async generateAdminInsights(stats: {
    totalOrders: number;
    totalRevenue: number;
    totalProducts: number;
    totalVendors: number;
    topCategories: { name: string; count: number }[];
    recentTrends: string;
  }): Promise<{ success: boolean; data?: { summary: string; insights: string[]; recommendations: string[] }; error?: string }> {
    if (!isAIEnabled()) {
      return { success: false, error: 'AI features are disabled' };
    }

    try {
      const result = await retry(async () => {
        const genAI = getAI();
        const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

        const prompt = `En tant qu'analyste business pour une plateforme d'artisanat du Sahel, analyse ces statistiques :

Commandes totales : ${stats.totalOrders}
Revenu total : ${stats.totalRevenue} FCFA
Produits actifs : ${stats.totalProducts}
Vendeurs actifs : ${stats.totalVendors}
Top catégories : ${stats.topCategories.map((c) => `${c.name} (${c.count})`).join(', ')}
Tendances récentes : ${stats.recentTrends}

Génère :
1. Un résumé exécutif (2-3 phrases)
2. 3-5 insights clés sur la performance de la plateforme
3. 3-5 recommandations stratégiques pour améliorer les ventes et l'engagement

Retourne au format JSON strict :
{
  "summary": "résumé exécutif",
  "insights": ["insight 1", "insight 2", "insight 3"],
  "recommendations": ["recommendation 1", "recommendation 2", "recommendation 3"]
}`;

        const response = await model.generateContent(prompt);
        const text = response.response.text();
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          throw new Error('Invalid response format');
        }
        return JSON.parse(jsonMatch[0]);
      });

      return { success: true, data: result };
    } catch (error) {
      return { success: false, error: (error as Error).message };
    }
  }
};
