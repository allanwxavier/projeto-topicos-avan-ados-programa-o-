import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';
import authRoutes from './routes/auth.routes';
import reuniaoRoutes from './routes/reuniao.routes';
import kanbanRoutes from './routes/kanban.routes';

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

io.on('connection', (socket) => {
  console.log(`[Socket.IO] Cliente conectado: ${socket.id}`);

  // Escuta movimentação de card vinda do client
  socket.on('card:move', (data) => {
    // Rebroadcast para todos os outros clientes
    socket.broadcast.emit('card:moved', data);
  });

  socket.on('disconnect', () => {
    console.log(`[Socket.IO] Cliente desconectado: ${socket.id}`);
  });
});

const PORT = parseInt(process.env.API_PORT as string, 10) || 8080;

app.use(cors());
app.use(express.json());
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/reunioes', reuniaoRoutes);
app.use('/api/v1/kanban', kanbanRoutes);

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'API rodando!' });
});

if (process.env.NODE_ENV !== 'test') {
  
  httpServer.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor rodando na porta ${PORT}`);
    console.log(`Socket.IO ativo na porta ${PORT}`);
  });
}

export default app;