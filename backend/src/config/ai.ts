import { GoogleGenerativeAI } from '@google/generative-ai';

let genAI: GoogleGenerativeAI | null = null;
let aiEnabled = false;

export const initializeAI = () => {
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    // eslint-disable-next-line no-console
    console.warn('GEMINI_API_KEY not set. AI features will be disabled.');
    aiEnabled = false;
    return;
  }

  genAI = new GoogleGenerativeAI(apiKey);
  aiEnabled = true;
  // eslint-disable-next-line no-console
  console.log('AI features enabled with Gemini');
};

export const getAI = (): GoogleGenerativeAI => {
  if (!genAI) {
    throw new Error('AI not initialized');
  }
  return genAI;
};

export const isAIEnabled = (): boolean => {
  return aiEnabled;
};
