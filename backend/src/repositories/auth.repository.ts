import { prisma } from '../config/prisma';

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

    async create (dados: { name: string; password: string}) {

        return await prisma.usuario.create({
            data: {
                name: dados.name,
                password: dados.password
            }
        });
    }
}