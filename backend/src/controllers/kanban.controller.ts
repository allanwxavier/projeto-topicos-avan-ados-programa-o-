import { Request, Response } from 'express';
import { KanbanService } from '../services/kanban.service';
import { RabbitMQService } from '../services/rabbitmq.service'; 
import crypto from 'crypto'; 

const kanbanService = new KanbanService();

type KanbanCardRecord = {
  id: number;
  title: string;
  description: string;
  columnId: string;
  priority: number;
  assignee: string | null;
  tags: string[];
  criadoEm: Date;
  atualizadoEm: Date;
};

export class KanbanController {
  async listar(req: Request, res: Response) {
    try {
      const cards = await kanbanService.listarTodos();

      const formatted = cards.map((card: KanbanCardRecord) => ({
        id: card.id.toString(),
        title: card.title,
        description: card.description,
        columnId: card.columnId,
        priority: card.priority,
        assignee: card.assignee,
        tags: card.tags,
        createdAt: card.criadoEm.toISOString(),
        updatedAt: card.atualizadoEm.toISOString(),
      }));

      res.json({ status: 'ok', data: formatted });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Erro ao listar cards' });
    }
  }

  async criar(req: Request, res: Response) {
    const { title, description, columnId, priority, assignee, tags } = req.body;

    if (!title) {
      return res.status(400).json({
        status: 'error',
        message: 'O campo title é obrigatório.',
      });
    }

    try {
      const card = await kanbanService.criar({
        title,
        description,
        columnId,
        priority,
        assignee,
        tags,
      });

      const formatted = {
        id: card.id.toString(),
        title: card.title,
        description: card.description,
        columnId: card.columnId,
        priority: card.priority,
        assignee: card.assignee,
        tags: card.tags,
        createdAt: card.criadoEm.toISOString(),
        updatedAt: card.atualizadoEm.toISOString(),
      };

      
      const io = req.app.get('io');
      if (io) {
        io.emit('card:created', formatted);
      }

      
      const evento = {
        eventId: crypto.randomUUID(),
        tipo: 'CardCriadoEvent',
        dataPublicacao: new Date().toISOString(),
        payload: formatted
      };
      await RabbitMQService.enviarParaFila('kanban_events', JSON.stringify(evento));


      res.status(201).json({ status: 'ok', data: formatted });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Erro ao criar card' });
    }
  }

  async atualizar(req: Request, res: Response) {
    const id = parseInt(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({ status: 'error', message: 'ID inválido' });
    }

    try {
      const card = await kanbanService.atualizar(id, req.body);

      const formatted = {
        id: card.id.toString(),
        title: card.title,
        description: card.description,
        columnId: card.columnId,
        priority: card.priority,
        assignee: card.assignee,
        tags: card.tags,
        createdAt: card.criadoEm.toISOString(),
        updatedAt: card.atualizadoEm.toISOString(),
      };

      const io = req.app.get('io');
      if (io) {
        io.emit('card:updated', formatted);
      }


      const evento = {
        eventId: crypto.randomUUID(),
        tipo: 'CardAtualizadoEvent',
        dataPublicacao: new Date().toISOString(),
        payload: formatted
      };
      await RabbitMQService.enviarParaFila('kanban_events', JSON.stringify(evento));

      res.json({ status: 'ok', data: formatted });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Erro ao atualizar card' });
    }
  }

  async mover(req: Request, res: Response) {
    const id = parseInt(req.params.id);
    const { columnId } = req.body;

    if (isNaN(id) || !columnId) {
      return res.status(400).json({
        status: 'error',
        message: 'ID e columnId são obrigatórios.',
      });
    }

    try {
      const card = await kanbanService.moverParaColuna(id, columnId);

      const io = req.app.get('io');
      if (io) {
        io.emit('card:moved', { cardId: card.id.toString(), columnId });
      }

      const formatted = {
        id: card.id.toString(),
        title: card.title,
        description: card.description,
        columnId: card.columnId,
        priority: card.priority,
        assignee: card.assignee,
        tags: card.tags,
        createdAt: card.criadoEm.toISOString(),
        updatedAt: card.atualizadoEm.toISOString(),
      };

      
      const evento = {
        eventId: crypto.randomUUID(),
        tipo: 'CardMovidoEvent',
        dataPublicacao: new Date().toISOString(),
        payload: { cardId: formatted.id, newColumnId: columnId }
      };
      await RabbitMQService.enviarParaFila('kanban_events', JSON.stringify(evento));

      res.json({ status: 'ok', data: formatted });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Erro ao mover card' });
    }
  }

  async deletar(req: Request, res: Response) {
    const id = parseInt(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({ status: 'error', message: 'ID inválido' });
    }

    try {
      await kanbanService.deletar(id);

      const io = req.app.get('io');
      if (io) {
        io.emit('card:deleted', { cardId: id.toString() });
      }


      const evento = {
        eventId: crypto.randomUUID(),
        tipo: 'CardDeletadoEvent',
        dataPublicacao: new Date().toISOString(),
        payload: { cardId: id.toString() }
      };
      await RabbitMQService.enviarParaFila('kanban_events', JSON.stringify(evento));

      res.json({ status: 'ok', message: 'Card deletado' });
    } catch (error) {
      res.status(500).json({ status: 'error', message: 'Erro ao deletar card' });
    }
  }
}