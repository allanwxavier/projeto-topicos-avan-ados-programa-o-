import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class ReuniaoRepository {
  async findAll() {
    return await prisma.reuniao.findMany();
  }

  async create(dados: any) {
    return await prisma.reuniao.create({ data: dados });
  }

  async addParticipante(idReuniao: number, idParticipante: number) {
    return await prisma.participanteReuniao.create({
      data: { idReuniao, idParticipante }
    });
  }

  async findParticipantes(idReuniao: number) {
    return await prisma.participanteReuniao.findMany({
      where: { idReuniao }
    });
  }
}