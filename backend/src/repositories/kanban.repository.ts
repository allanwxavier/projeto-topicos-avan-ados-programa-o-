import { prisma } from '../config/prisma';

type CreateKanbanCardData = {
  title: string;
  description?: string;
  columnId?: string;
  priority?: number;
  assignee?: string;
  tags?: string[];
};

export class KanbanRepository {
  async findAll() {
    return await prisma.kanbanCard.findMany({
      orderBy: { criadoEm: 'desc' },
    });
  }

  async findById(id: number) {
    return await prisma.kanbanCard.findUnique({ where: { id } });
  }

  async create(dados: CreateKanbanCardData) {
    return await prisma.kanbanCard.create({
      data: {
        title: dados.title,
        description: dados.description ?? '',
        columnId: dados.columnId ?? 'backlog',
        priority: dados.priority ?? 0,
        assignee: dados.assignee,
        tags: dados.tags ?? [],
      },
    });
  }

  async update(id: number, dados: Partial<CreateKanbanCardData>) {
    return await prisma.kanbanCard.update({
      where: { id },
      data: dados,
    });
  }

  async moveToColumn(id: number, columnId: string) {
    return await prisma.kanbanCard.update({
      where: { id },
      data: { columnId },
    });
  }

  async delete(id: number) {
    return await prisma.kanbanCard.delete({ where: { id } });
  }
}
