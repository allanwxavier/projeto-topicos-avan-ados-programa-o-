import { Router } from "express";
import { authController } from '../controllers/auth.controller';
import { CreateUserController } from '../controllers/create-user.controller';

const router = Router();
const createUserController = new CreateUserController();

/**
 * @swagger
 * /api/v1/auth/login:
 *   post:
 *     summary: Login do usuário
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login realizado com sucesso
 *       401:
 *         description: Credenciais inválidas
 */
router.post('/login', authController.login);

router.post('/register', (req, res) => createUserController.handle(req, res));

export default router;