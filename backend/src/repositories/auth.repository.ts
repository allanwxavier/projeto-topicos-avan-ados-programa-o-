import {PrismaClient} from '@prisma/client';

const prisma = new PrismaClient();

export class AuthRepository{
    async findByName(name: string) {
        return await prisma.usuario.findFirst({
            where: {name}
        });
    }

    async salvarToken(idUsuario: number, token: string) {
        return await prisma.usuario.update({
            where: {id: idUsuario},
            data: {token}
        });
    }
}