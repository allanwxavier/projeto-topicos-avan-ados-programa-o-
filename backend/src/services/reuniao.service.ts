import { ReuniaoRepository } from '../repositories/reuniao.repository';

const reuniaoRepository = new ReuniaoRepository();

type CriarReuniaoData = {
  assunto: string;
  local: string;
  data: string;
  horaInicio: string;
  horaFim: string;
}
export class ReuniaoService {
  async listarTodas() {
    return await reuniaoRepository.findAll();
  }

  async criar(dados: CriarReuniaoData) {
    return await reuniaoRepository.create(dados);
  }

  async adicionarParticipante(idReuniao: number, idParticipante: number) {
    return await reuniaoRepository.addParticipante(idReuniao, idParticipante);
  }

  async listarParticipantes(idReuniao: number) {
    return await reuniaoRepository.findParticipantes(idReuniao);
  }
}