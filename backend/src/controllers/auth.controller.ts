import { Request, Response } from 'express';
import {AuthService} from '../services/auth.service';

const authService = new AuthService();

export const authController = {
    login: async (req: Request, res: Response) => {
        try {
            const {name, password} = req.body;

            if (!name || !password) {
                return res.status(400).json({
                    status:'error',
                    message: 'Nome e senha são obrigatórios.'
                });
            }

            const resultado = await authService.login(name, password);  

            if (!resultado) {
                return res.status(401).json({
                    status: 'error',
                    message: 'Credenciais inválidas.'
                });
            }

            res.json({ status: 'ok', data:resultado });
        }   catch (error) {
            res.status(500).json({status:'error', message: 'Erro no login'});       
        }
    }
}