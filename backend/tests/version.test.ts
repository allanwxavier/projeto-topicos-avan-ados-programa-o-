import request from 'supertest';
import app from '../src/server';

jest.mock('@prisma/client', () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => {
      return {};
    }),
  };
});

describe('GET /api/v1/version', () => {
  it('deve retornar as informacoes de versao corretas', async () => {
    const res = await request(app).get('/api/v1/version');

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('version');
    expect(res.body).toHaveProperty('environment');
    expect(res.body).toHaveProperty('buildDate');

    expect(typeof res.body.version).toBe('string');
    expect(typeof res.body.environment).toBe('string');
    expect(typeof res.body.buildDate).toBe('string');

    // Valida se o buildDate está no formato ISO
    expect(isNaN(Date.parse(res.body.buildDate))).toBe(false);
  });
});

afterAll(async () => {
  await new Promise(resolve => setTimeout(resolve, 500));
});
