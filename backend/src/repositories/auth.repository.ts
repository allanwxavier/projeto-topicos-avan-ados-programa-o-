import {PrismaClient} from '@prisma/client';

const prisma = new PrismaClient();

export class AuthRepository{
    async findByName(name: String) {
        return await prisma.usuario.findFirst({
            where: {name}
        });
    }

    async salvarToken(idUsuario: number, token: String) {
        return await prisma.usuario.update({
            where: {id: idUsuario},
            data: {token}
        });
    }
}