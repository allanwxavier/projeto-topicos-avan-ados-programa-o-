import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Importando as rotas (ajuste o caminho se necessário)
import authRoutes from './routes/auth.routes';
import reuniaoRoutes from './routes/reuniao.routes';

dotenv.config();

const app = express();
const PORT = process.env.API_PORT || 8080;

app.use(cors());
app.use(express.json());

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/reunioes', reuniaoRoutes);

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'API rodando!' });
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Servidor rodando em http://localhost:${PORT}`);
  });
}

export default app;