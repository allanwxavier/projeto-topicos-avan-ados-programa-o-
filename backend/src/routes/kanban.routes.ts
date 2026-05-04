import { Router } from 'express';
import { KanbanController } from '../controllers/kanban.controller';
import { authMiddleware } from '../middlewares/auth.middleware';

const router = Router();
const kanbanController = new KanbanController();

/**
 * @swagger
 * /api/v1/kanban/cards:
 *   get:
 *     summary: Lista todos os cards do Kanban
 *     tags: [Kanban]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de cards retornada com sucesso
 *   post:
 *     summary: Cria um novo card no Kanban
 *     tags: [Kanban]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               columnId:
 *                 type: string
 *               priority:
 *                 type: integer
 *               assignee:
 *                 type: string
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 */

router.get('/cards', authMiddleware, kanbanController.listar);
router.post('/cards', authMiddleware, kanbanController.criar);

/**
 * @swagger
 * /api/v1/kanban/cards/{id}:
 *   put:
 *     summary: Atualiza um card existente
 *     tags: [Kanban]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 */
router.put('/cards/:id', authMiddleware, kanbanController.atualizar);

/**
 * @swagger
 * /api/v1/kanban/cards/{id}/move:
 *   put:
 *     summary: Move um card para outra coluna
 *     tags: [Kanban]
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               columnId:
 *                 type: string
 */
router.put('/cards/:id/move', authMiddleware, kanbanController.mover);

/**
 * @swagger
 * /api/v1/kanban/cards/{id}:
 *   delete:
 *     summary: Deleta um card
 *     tags: [Kanban]
 */
router.delete('/cards/:id', authMiddleware, kanbanController.deletar);

export default router;
