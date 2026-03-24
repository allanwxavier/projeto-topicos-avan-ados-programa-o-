import { Request, Response, NextFunction } from "express";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function authMiddleware(
    req: Request,
    res: Response,
    next: NextFunction
){
    const token = req.body.token || req.headers.authorization;

    if (!token) {
        return res.status(401).json({
            status: 'error',
            message: 'Token não informado.'
        });
    }

    const usuario = await prisma.usuario.findFirst({
        where: {token}
    });
    
    if (!usuario) {
        return res.status(401).json({
            status: 'error',
            message: 'Token inválido ou expirado.'
        });
    }

    next();
}
