import request from 'supertest';
import app from '../src/server';


jest.mock('@prisma/client', () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => {
      return {
        reuniao: {
          findMany: jest.fn().mockResolvedValue([{ id: 1, titulo: 'Reunião Mock' }]), 
          create: jest.fn().mockResolvedValue({ id: 2, titulo: 'Reunião Criada' }), 
        },
      };
    }),
  };
});

describe('GET /api/v1/reunioes', () => {
  it('deve retornar lista de reuniões', async () => {
    const res = await request(app).get('/api/v1/reunioes');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(Array.isArray(res.body.data)).toBe(true);
  });
});

describe('POST /api/v1/reunioes', () => {
  it('deve criar uma reunião', async () => {
    const res = await request(app)
      .post('/api/v1/reunioes')
      .send({
        titulo: "Reunião de teste",
        local: "AUDITÓRIO",
        data: "22/03/2026",
        inicio: "14:00",
        fim: "15:00"
      });
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

afterAll(async () => {
  await new Promise(resolve => setTimeout(resolve, 500));
});