import { Router } from "express";
import { authController } from '../controllers/auth.controller';
import { CreateUserController } from '../controllers/create-user.controller';

const router = Router();
const createUserController = new CreateUserController();

router.post('/login', authController.login);

router.post('/register', (req, res) => createUserController.handle(req, res));

export default router;
