import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Importando as rotas (ajuste o caminho se necessário)
import authRoutes from './routes/auth.routes';
import reuniaoRoutes from './routes/reuniao.routes';

dotenv.config();

const app = express();
// Garante que a porta seja tratada como número
const PORT = parseInt(process.env.API_PORT as string, 10) || 8080;

app.use(cors());
app.use(express.json());

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