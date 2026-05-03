import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';
import authRoutes from './routes/auth.routes';
import reuniaoRoutes from './routes/reuniao.routes';

dotenv.config();

const app = express();

const PORT = parseInt(process.env.API_PORT as string, 10) || 8080;

app.use(cors());
app.use(express.json());
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/reunioes', reuniaoRoutes);

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'API rodando!' });
});

if (process.env.NODE_ENV !== 'test') {
  
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor rodando na porta ${PORT}`);
  });
}

export default app;