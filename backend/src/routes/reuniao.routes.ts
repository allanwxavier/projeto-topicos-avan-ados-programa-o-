import { Router } from 'express';
import { ReuniaoController } from '../controllers/reuniao.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();
const reuniaoController = new ReuniaoController();

/**
 * @swagger
 * /api/v1/reunioes:
 *   get:
 *     summary: Lista todas as reuniões
 *     tags: [Reuniões]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de reuniões retornada com sucesso
 *   post:
 *     summary: Cria uma nova reunião
 *     tags: [Reuniões]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               assunto:
 *                 type: string
 *               local:
 *                 type: string
 *               data:
 *                 type: string
 *               horaInicio:
 *                 type: string
 *               horaFim:
 *                 type: string
 */

router.get('/', reuniaoController.listar);

router.get('/', authMiddleware, reuniaoController.listar);
router.post('/', authMiddleware, reuniaoController.criar);
router.post('/participantes/adicionar', reuniaoController.adicionarParticipante);
router.post('/participantes/listar', reuniaoController.listarParticipantes);
router.get('/:id', reuniaoController.buscarPorId);
router.put('/:id', authMiddleware, reuniaoController.atualizar);
router.delete('/:id', authMiddleware, reuniaoController.deletar);
router.patch('/:id/status', authMiddleware, reuniaoController.atualizarStatus);

export default router;