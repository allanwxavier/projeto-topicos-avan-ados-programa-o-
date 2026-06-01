import request from 'supertest';
import app from '../../src/server';
import { prisma } from '../../src/config/prisma';

// Mocks de infraestrutura para evitar conexões pendentes em background durante o teste de API
jest.mock('../../src/services/redis.service', () => ({
  redisService: {
    del: jest.fn().mockResolvedValue(true),
    get: jest.fn().mockResolvedValue(null),
    set: jest.fn().mockResolvedValue(true),
    redisConnect: jest.fn().mockResolvedValue(true)
  }
}));

jest.mock('../../src/services/rabbitmq.service', () => ({
  RabbitMQService: {
    enviarParaFila: jest.fn().mockResolvedValue(true)
  }
}));

describe('API de Reuniões - Fluxo E2E de Integração', () => {
  // Limpeza de banco de dados antes e depois de rodar os testes
  beforeAll(async () => {
    await prisma.participanteReuniao.deleteMany();
    await prisma.reuniao.deleteMany();
    await prisma.usuario.deleteMany();
  });

  afterAll(async () => {
    await prisma.participanteReuniao.deleteMany();
    await prisma.reuniao.deleteMany();
    await prisma.usuario.deleteMany();
    await prisma.$disconnect();
  });

  it('deve realizar o fluxo completo: registrar, logar e criar reunião protegida por JWT', async () => {
    const nomeUsuario = 'desenvolvedor2';
    const senhaUsuario = 'senhaforte123';

    // PASSO 1: Registrar o Usuário via API
    const responseRegistro = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: nomeUsuario,
        password: senhaUsuario
      });

    expect(responseRegistro.status).toBe(201);
    expect(responseRegistro.body).toHaveProperty('id');
    expect(responseRegistro.body.name).toBe(nomeUsuario);

    // PASSO 2: Autenticar (Login) e obter o token JWT
    const responseLogin = await request(app)
      .post('/api/v1/auth/login')
      .send({
        name: nomeUsuario,
        password: senhaUsuario
      });

    expect(responseLogin.status).toBe(200);
    expect(responseLogin.body.status).toBe('ok');
    expect(responseLogin.body.data).toHaveProperty('token');
    
    const tokenJwt = responseLogin.body.data.token;

    // PASSO 3: Criar Reunião enviando o token JWT no header Authorization
    const dadosReuniao = {
      assunto: 'Integração de Pipeline CI',
      local: 'Sala de Conferências 1',
      data: '2026-06-10',
      horaInicio: '14:00',
      horaFim: '15:30'
    };

    const responseCriarReuniao = await request(app)
      .post('/api/v1/reunioes')
      .set('Authorization', `Bearer ${tokenJwt}`)
      .send(dadosReuniao);

    expect(responseCriarReuniao.status).toBe(201);
    expect(responseCriarReuniao.body.status).toBe('ok');
    expect(responseCriarReuniao.body.data).toHaveProperty('id');
    expect(responseCriarReuniao.body.data.assunto).toBe(dadosReuniao.assunto);
    expect(responseCriarReuniao.body.data.local).toBe(dadosReuniao.local);

    // PASSO 4: Validar se a reunião está realmente gravada no banco de dados
    const idReuniaoCriada = responseCriarReuniao.body.data.id;
    const reuniaoNoBanco = await prisma.reuniao.findUnique({
      where: { id: idReuniaoCriada }
    });

    expect(reuniaoNoBanco).not.toBeNull();
    expect(reuniaoNoBanco?.assunto).toBe(dadosReuniao.assunto);
    expect(reuniaoNoBanco?.status).toBe('Agendada'); // Garante o status default "Agendada"
  });
});
