import { Router } from 'express';
import { ReuniaoController } from '../controllers/reuniao.controller';

const router = Router();
const reuniaoController = new ReuniaoController();

router.get('/', reuniaoController.listar);
router.post('/', reuniaoController.criar);
router.post('/participantes/adicionar', reuniaoController.adicionarParticipante);
router.post('/participantes/listar', reuniaoController.listarParticipantes);

export default router;