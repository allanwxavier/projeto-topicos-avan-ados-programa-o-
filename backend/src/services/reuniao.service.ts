import { ReuniaoRepository } from '../repositories/reuniao.repository';
import { redisService } from './redis.service';
import { RabbitMQService } from './rabbitmq.service';
import crypto from 'crypto';

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
    const chave = 'reuniao:lista';
    const cache = await redisService.get(chave);

    if (cache) {
      console.log(`[Cache] HIT para ${chave}`);
      return JSON.parse(cache);
    }

    console.log(`[Cache] MISS para ${chave}`);
    const reunioes = await reuniaoRepository.findAll();
    await redisService.set(chave, JSON.stringify(reunioes), 300);
    return reunioes;
  }

  async criar(dados: CriarReuniaoData) {
    const reuniao = await reuniaoRepository.create(dados);

    await redisService.del('reuniao:lista');

    return reuniao;
  }

  async adicionarParticipante(idReuniao: number, idParticipante: number) {
    const resultado = await reuniaoRepository.addParticipante(idReuniao, idParticipante);

    await redisService.del(`reuniao:item:${idReuniao}`);
    await redisService.del('reuniao:lista');

    return resultado;
  }

  async listarParticipantes(idReuniao: number) {
    return await reuniaoRepository.findParticipantes(idReuniao);
  }

  async buscarPorId(id:number){
    const chave = `reuniao:item:${id}`;

    const cache = await
    redisService.get(chave);

    if (cache) {
      console.log(`[Cache] HIT para ${chave}`);
      return JSON.parse(cache);
    }

    console.log(`[Cache] MISS para ${chave}`);
    
    const reuniao = await reuniaoRepository.findById(id);
    if (reuniao) {
      await redisService.set(chave, JSON.stringify(reuniao), 300);
    }

    return reuniao;


  }

  async atualizarStatus(id: number, status: string) {
    const reuniaoAtualizada = await reuniaoRepository.updateStatus(id, status);

    
    await redisService.del(`reuniao:item:${id}`);
    await redisService.del('reuniao:lista');

    
    const evento = {
      eventId: crypto.randomUUID(),
      tipo: 'ReuniaoStatusAtualizadoEvent',
      dataPublicacao: new Date().toISOString(),
      payload: {
        id: reuniaoAtualizada.id,
        status: reuniaoAtualizada.status
      }
    };

    await RabbitMQService.enviarParaFila('reuniao_events', evento);

    return reuniaoAtualizada;
  }
}