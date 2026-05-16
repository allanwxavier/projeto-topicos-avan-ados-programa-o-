-- AlterTable
ALTER TABLE "reunioes" ADD COLUMN     "status" TEXT NOT NULL DEFAULT 'Agendada';

-- CreateTable
CREATE TABLE "kanban_cards" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "columnId" TEXT NOT NULL DEFAULT 'backlog',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "assignee" TEXT,
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "kanban_cards_pkey" PRIMARY KEY ("id")
);
