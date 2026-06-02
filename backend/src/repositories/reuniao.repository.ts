import { prisma } from '../config/prisma';

type CriarReuniaoData = {
  assunto: string;
  local: string;
  data: string;
  horaInicio: string;
  horaFim: string;
}
export class ReuniaoRepository {
  async findAll() {
    return await prisma.reuniao.findMany();
  }

  async findById(id: number) {
    return await prisma.reuniao.findUnique({ where: { id } });
  }

  async create(dados: CriarReuniaoData ) {
    return await prisma.reuniao.create({ data: dados });
  }

  async update(id: number, dados: Partial<CriarReuniaoData>) {
    return await prisma.reuniao.update({
      where: { id },
      data: dados
    });
  }

  async delete(id: number) {
    // Delete os participantes vinculados primeiro para evitar erro de Foreign Key
    await prisma.participanteReuniao.deleteMany({
      where: { idReuniao: id }
    });

    return await prisma.reuniao.delete({
      where: { id }
    });
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

  async updateStatus(id: number, status: string){
    return await prisma.reuniao.update({
      where: { id },
      data: { status }
    });
  }
}