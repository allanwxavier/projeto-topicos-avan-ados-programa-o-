import request from 'supertest';
import app from '../src/server';


jest.mock('@prisma/client', () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => {
      return {
        usuario: {
          findFirst: jest.fn().mockResolvedValue(null), 
          update: jest.fn().mockResolvedValue({}),
        },
      };
    }),
  };
});

describe('POST /api/v1/auth/login', () => {
  it('deve retornar erro sem credenciais', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({});
    expect(res.status).toBe(400);
    expect(res.body.status).toBe('error');
  });

  it('deve retornar erro com credenciais inválidas', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ name: 'usuario_inexistente', password: 'senhaerrada' });
    expect(res.status).toBe(401);
    expect(res.body.status).toBe('error');
  });
});

afterAll(async () => {
  await new Promise(resolve => setTimeout(resolve, 500));
});