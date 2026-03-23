-- CreateTable
CREATE TABLE "usuarios" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "token" TEXT,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reunioes" (
    "id" SERIAL NOT NULL,
    "assunto" TEXT NOT NULL,
    "local" TEXT NOT NULL,
    "data" TEXT NOT NULL,
    "horaInicio" TEXT NOT NULL,
    "horaFim" TEXT NOT NULL,
    "criadoEm" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reunioes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "participantes_reuniao" (
    "id" SERIAL NOT NULL,
    "idReuniao" INTEGER NOT NULL,
    "idParticipante" INTEGER NOT NULL,

    CONSTRAINT "participantes_reuniao_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "participantes_reuniao" ADD CONSTRAINT "participantes_reuniao_idReuniao_fkey" FOREIGN KEY ("idReuniao") REFERENCES "reunioes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "participantes_reuniao" ADD CONSTRAINT "participantes_reuniao_idParticipante_fkey" FOREIGN KEY ("idParticipante") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
