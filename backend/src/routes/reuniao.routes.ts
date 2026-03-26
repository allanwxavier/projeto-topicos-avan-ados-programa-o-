import { Router } from 'express';
import { ReuniaoController } from '../controllers/reuniao.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();
const reuniaoController = new ReuniaoController();

router.get('/', reuniaoController.listar);
router.post('/', reuniaoController.criar);
router.post('/participantes/adicionar', reuniaoController.adicionarParticipante);
router.post('/participantes/listar', reuniaoController.listarParticipantes);
router.get('/', authMiddleware, reuniaoController.listar);
router.post('/', authMiddleware, reuniaoController.criar);

export default router;