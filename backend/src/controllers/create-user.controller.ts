import { Request, Response } from 'express';
import { RegisterService } from '../services/create-user.services';

const registerService = new RegisterService();

export class CreateUserController{
    async handle(req: Request, res: Response) {
        try {

            const { name, password } = req.body;

            const user = await registerService.execute(name, password);

            return res.status(201).json(user);

        } catch (error: any) {
            return res.status(400).json({
                message: error.message || "Erro inesperado ao criar usuário. "
            });
        }
    }
}