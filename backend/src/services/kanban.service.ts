import { KanbanRepository } from '../repositories/kanban.repository';

const kanbanRepository = new KanbanRepository();

type CreateKanbanCardData = {
  title: string;
  description?: string;
  columnId?: string;
  priority?: number;
  assignee?: string;
  tags?: string[];
};

export class KanbanService {
  async listarTodos() {
    return await kanbanRepository.findAll();
  }

  async buscarPorId(id: number) {
    return await kanbanRepository.findById(id);
  }

  async criar(dados: CreateKanbanCardData) {
    return await kanbanRepository.create(dados);
  }

  async atualizar(id: number, dados: Partial<CreateKanbanCardData>) {
    return await kanbanRepository.update(id, dados);
  }

  async moverParaColuna(id: number, columnId: string) {
    return await kanbanRepository.moveToColumn(id, columnId);
  }

  async deletar(id: number) {
    return await kanbanRepository.delete(id);
  }
}
