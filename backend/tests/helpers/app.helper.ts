import supertest from 'supertest';
import type { Express } from 'express';
import { createApp } from '../../src/app';

let app: Express | null = null;

export const getTestApp = (): Express => {
  if (!app) {
    app = createApp();
  }
  return app;
};

export const request = () => supertest(getTestApp());
