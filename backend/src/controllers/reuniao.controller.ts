import { Request, Response } from 'express';
import { ReuniaoService } from '../services/reuniao.service';
import { RabbitMQService } from '../services/rabbitmq.service';
import crypto from 'crypto';
import { logger } from '../config/logger';
import {
  reunioesCriadasTotal,
  participantesAdicionadosTotal,
} from '../config/metrics';

const reuniaoService = new ReuniaoService();

export class ReuniaoController {
  async listar(req: Request, res: Response) {
    try {
      const reunioes = await reuniaoService.listarTodas();
      res.json({ status: 'ok', data: reunioes });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao listar reuniões');
      res.status(500).json({ status: 'error', message: 'Erro ao listar reuniões' });
    }
  }

  async criar(req: Request, res: Response) {
    const { assunto, local, data, horaInicio, horaFim } = req.body;

    if (!assunto || !local || !data || !horaInicio || !horaFim) {
      return res.status(400).json({
        status: 'error',
        message: 'Campos obrigatórios ausentes.',
      });
    }

    try {
      // PASSO 1: Gravar no Write Database (Node)
      const reuniao = await reuniaoService.criar(req.body);

      // PASSO 2: Montar a estrutura Padrão do Evento (Idempotência)
      const evento = {
        eventId: crypto.randomUUID(),
        tipo: 'ReuniaoCriadaEvent',
        dataPublicacao: new Date().toISOString(),
        payload: {
          id: reuniao.id,
          titulo: reuniao.assunto,
          descricao: reuniao.local,
          data: reuniao.data,
          horaInicio: reuniao.horaInicio,
          horaFim: reuniao.horaFim,
        },
      };

      await RabbitMQService.enviarParaFila('reuniao_events', evento);

      // MÉTRICA DE NEGÓCIO
      reunioesCriadasTotal.inc();

      return res.status(201).json({ status: 'ok', data: reuniao });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao criar reunião');
      return res.status(500).json({ status: 'error', message: 'Erro ao criar reunião' });
    }
  }

  async atualizar(req: Request, res: Response) {
    const id = Number(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        status: 'error',
        message: 'ID inválido.',
      });
    }

    try {
      const reuniao = await reuniaoService.atualizar(id, req.body);
      return res.json({ status: 'ok', data: reuniao });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao atualizar reunião');
      return res.status(500).json({ status: 'error', message: 'Erro ao atualizar reunião' });
    }
  }

  async deletar(req: Request, res: Response) {
    const id = Number(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        status: 'error',
        message: 'ID inválido.',
      });
    }

    try {
      await reuniaoService.deletar(id);
      return res.json({ status: 'ok', message: 'Reunião deletada com sucesso' });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao deletar reunião');
      return res.status(500).json({ status: 'error', message: 'Erro ao deletar reunião' });
    }
  }

  async adicionarParticipante(req: Request, res: Response) {
    const { idReuniao, idParticipante } = req.body;

    if (!idReuniao || !idParticipante) {
      return res.status(400).json({
        status: 'error',
        message: 'idReuniao e idParticipante são obrigatórios.',
      });
    }

    try {
      await reuniaoService.adicionarParticipante(idReuniao, idParticipante);

      const evento = {
        eventId: crypto.randomUUID(),
        tipo: 'ParticipanteAdicionadoEvent',
        dataPublicacao: new Date().toISOString(),
        payload: {
          idReuniao,
          idParticipante,
        },
      };

      await RabbitMQService.enviarParaFila('reuniao_events', evento);

      // MÉTRICA DE NEGÓCIO
      participantesAdicionadosTotal.inc();

      return res.json({ status: 'ok', message: 'Participante adicionado' });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao adicionar participante');
      return res
        .status(500)
        .json({ status: 'error', message: 'Erro ao adicionar participante' });
    }
  }

  async listarParticipantes(req: Request, res: Response) {
    const { idReuniao } = req.body;

    if (!idReuniao) {
      return res.status(400).json({
        status: 'error',
        message: 'idReuniao é obrigatório',
      });
    }

    try {
      const participantes = await reuniaoService.listarParticipantes(idReuniao);
      res.json({ status: 'ok', data: participantes });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao listar participantes');
      res
        .status(500)
        .json({ status: 'error', message: 'Erro ao listar participantes' });
    }
  }

  async buscarPorId(req: Request, res: Response) {
    const id = Number(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        status: 'error',
        message: 'ID inválido.',
      });
    }

    try {
      const reuniao = await reuniaoService.buscarPorId(id);

      if (!reuniao) {
        return res.status(404).json({
          status: 'error',
          message: 'Reunião não encontrada.',
        });
      }

      res.json({ status: 'ok', data: reuniao });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao buscar reunião');
      res.status(500).json({ status: 'error', message: 'Erro ao buscar reunião' });
    }
  }

  async atualizarStatus(req: Request, res: Response) {
    const id = Number(req.params.id);
    const { status } = req.body;

    if (isNaN(id)) {
      return res.status(400).json({
        status: 'error',
        message: 'ID inválido.',
      });
    }

    if (!status) {
      return res.status(400).json({
        status: 'error',
        message: 'O campo status é obrigatório.',
      });
    }

    try {
      const reuniao = await reuniaoService.atualizarStatus(id, status);
      return res.json({ status: 'ok', data: reuniao });
    } catch (error) {
      (req as any).log?.error({ err: error }, 'Erro ao atualizar status da reunião');
      return res
        .status(500)
        .json({ status: 'error', message: 'Erro ao atualizar o status da reunião' });
    }
  }
}
