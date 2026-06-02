import { Router } from 'express';
import { versionController } from '../controllers/version.controller';

const router = Router();

/**
 * @swagger
 * /api/v1/version:
 *   get:
 *     summary: Retorna informações da versão atual do backend
 *     tags: [Config]
 *     responses:
 *       200:
 *         description: Informações de versão retornadas com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 version:
 *                   type: string
 *                   example: 1.0.0
 *                 environment:
 *                   type: string
 *                   example: development
 *                 buildDate:
 *                   type: string
 *                   format: date-time
 *                   example: 2026-05-29T22:00:00.000Z
 */
router.get('/', versionController.getVersion);

export default router;
