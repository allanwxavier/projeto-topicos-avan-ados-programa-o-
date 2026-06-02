import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import swaggerUi from 'swagger-ui-express';
import jwt from 'jsonwebtoken';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';
import { swaggerSpec } from './config/swagger';
import authRoutes from './routes/auth.routes';
import reuniaoRoutes from './routes/reuniao.routes';
import kanbanRoutes from './routes/kanban.routes';
import healthRoutes from './routes/health.routes';
import metricsRoutes from './routes/metrics.routes';
import versionRoutes from './routes/version.routes';
import { redisService } from './services/redis.service';
import { iniciarConsumer } from './services/rabbitmq-consumer.service';
import { logger } from './config/logger';
import { correlationIdMiddleware } from './middlewares/correlation-id.middleware';
import { httpLogger } from './middlewares/http-logger.middleware';
import { metricsMiddleware } from './middlewares/metrics.middleware';

dotenv.config();

const app = express();
const httpServer = createServer(app);

// ─── Socket.IO ──────────────────────────────────────────────────
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
  },
});

// Disponibiliza a instância do socket.io para os controllers
app.set('io', io);

// ─── Middleware de Autenticação do Socket.IO ────────────────────
io.use((socket, next) => {
  const handshake = socket.handshake as any;
  const token = handshake.auth?.token || handshake.headers?.['authorization'];

  if (!token) {
    return next(new Error('Erro de autenticação: Token não fornecido'));
  }

  const tokenLimpo = token.replace('Bearer ', '');

  try {
    const decoded = jwt.verify(tokenLimpo, process.env.JWT_SECRET as string);
    (socket as any).user = decoded;
    next();
  } catch (err) {
    return next(new Error('Erro de autenticação: Token inválido'));
  }
});

// ─── Eventos do Socket.IO ───────────────────────────────────────
io.on('connection', (socket) => {
  logger.info({ socketId: socket.id }, '[Socket.IO] Cliente conectado');

  // LÓGICA DE SALAS PARA KANBAN
  socket.on('kanban:join', (kanbanId) => {
    const roomName = `kanban_${kanbanId}`;
    socket.join(roomName);
    logger.debug({ socketId: socket.id, roomName }, '[Socket.IO] Entrou na sala');
  });

  socket.on('kanban:leave', (kanbanId) => {
    const roomName = `kanban_${kanbanId}`;
    socket.leave(roomName);
    logger.debug({ socketId: socket.id, roomName }, '[Socket.IO] Saiu da sala');
  });

  socket.on('card:move', (data) => {
    const { kanbanId } = data;
    if (kanbanId) {
      const roomName = `kanban_${kanbanId}`;
      socket.to(roomName).emit('card:moved', data);
    } else {
      logger.warn('[Socket.IO] Evento card:move recebido sem kanbanId!');
    }
  });

  // LÓGICA DE SALAS PARA REUNIÕES
  socket.on('reuniao:join', (reuniaoId) => {
    const roomName = `reuniao_${reuniaoId}`;
    socket.join(roomName);
    logger.debug({ socketId: socket.id, roomName }, '[Socket.IO] Entrou na sala');
  });

  socket.on('reuniao:leave', (reuniaoId) => {
    const roomName = `reuniao_${reuniaoId}`;
    socket.leave(roomName);
    logger.debug({ socketId: socket.id, roomName }, '[Socket.IO] Saiu da sala');
  });

  socket.on('reuniao:atualizar_status', (data) => {
    const { reuniaoId } = data;
    if (reuniaoId) {
      socket.to(`reuniao_${reuniaoId}`).emit('reuniao:status_atualizado', data);
    }
  });

  // DESCONEXÃO
  socket.on('disconnect', () => {
    logger.info({ socketId: socket.id }, '[Socket.IO] Cliente desconectado');
  });
});

const PORT = parseInt(process.env.PORT as string, 10) || parseInt(process.env.API_PORT as string, 10) || 8080;

// ─── Middlewares globais (ORDEM IMPORTA) ────────────────────────
// 1) Correlation ID PRIMEIRO, para todo log ter o id.
app.use(correlationIdMiddleware);
// 2) Pino-http já lê o req.id gerado acima.
app.use(httpLogger);
// 3) Métricas: timer começa cedo, mas só finaliza no res.on('finish').
app.use(metricsMiddleware);
// 4) Demais middlewares
app.use(cors());
app.use(express.json());
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// ─── Rotas de Observabilidade ───────────────────────────────────
app.use('/health', healthRoutes);
app.use('/metrics', metricsRoutes);

// ─── Rotas de Negócio ───────────────────────────────────────────
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/reunioes', reuniaoRoutes);
app.use('/api/v1/kanban', kanbanRoutes);
app.use('/api/v1/version', versionRoutes);

app.get('/', (_req, res) => {
  res.json({ status: 'ok', message: 'API a correr!' });
});

// ─── Inicialização do Servidor e Serviços ───────────────────────
if (process.env.NODE_ENV !== 'test') {
  (async () => {
    try {
      // 1. Conecta o serviço de cache genérico
      await redisService.redisConnect();
      logger.info('[Redis] Conectado para cache!');

      // 2. Configuração do Redis para o Socket.io (Pub/Sub)
      const redisOptions: any = process.env.REDIS_URL
        ? { url: process.env.REDIS_URL }
        : (process.env.REDIS_HOST?.startsWith('redis://') || process.env.REDIS_HOST?.startsWith('rediss://')
           ? { url: process.env.REDIS_HOST }
           : {
               password: process.env.REDIS_PASSWORD || undefined,
               socket: {
                 host: process.env.REDIS_HOST || '127.0.0.1',
                 port: parseInt(process.env.REDIS_PORT as string) || 6379,
               }
             });
      const pubClient = createClient(redisOptions);
      const subClient = pubClient.duplicate();

      await Promise.all([pubClient.connect(), subClient.connect()]);

      io.adapter(createAdapter(pubClient, subClient));
      logger.info('[Redis] Socket.io Adapter configurado com sucesso!');

      // 3. Inicia o servidor HTTP
      httpServer.listen(PORT, '0.0.0.0', () => {
        logger.info({ port: PORT }, `Servidor a correr na porta ${PORT}`);
      });

      // 4. Inicia o Consumer do RabbitMQ (Bridge com Socket.io)
      await iniciarConsumer(io);
    } catch (error) {
      logger.error({ err: error }, '[Servidor] Erro ao iniciar');
    }
  })();
}

export default app;
