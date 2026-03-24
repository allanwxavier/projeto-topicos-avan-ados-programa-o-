import { ReuniaoRepository } from '../repositories/reuniao.repository';

const reuniaoRepository = new ReuniaoRepository();

export class ReuniaoService {
  async listarTodas() {
    return await reuniaoRepository.findAll();
  }

  async criar(dados: any) {
    return await reuniaoRepository.create(dados);
  }

  async adcionarParticipante(idReuniao: number, idParticipante: number) {
    return await reuniaoRepository.addParticipante(idReuniao, idParticipante);
  }

  async listarParticipantes(idReuniao: number) {
    return await reuniaoRepository.findParticipantes(idReuniao);
  }
}