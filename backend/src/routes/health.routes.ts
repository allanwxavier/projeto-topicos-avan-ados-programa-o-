import { Router, Request, Response } from 'express';
import amqp from 'amqplib';
import { prisma } from '../config/prisma';
import { redisService } from '../services/redis.service';
import { logger } from '../config/logger';
import { getRabbitMQConfig } from '../config/rabbitmq';

const router = Router();

/**
 * /health/live  → LIVENESS
 *
 * Único objetivo: provar que o processo Node está VIVO e respondendo.
 * Não testa nada externo. Se isto falhar, o orquestrador (Docker/Kubernetes)
 * deve REINICIAR o container.
 */
router.get('/live', (_req: Request, res: Response) => {
  res.status(200).json({ status: 'alive' });
});

/**
 * /health/ready → READINESS
 *
 * Objetivo: confirmar que a aplicação está pronta para RECEBER tráfego.
 * Testa as dependências críticas. Se qualquer uma falhar, retorna 503
 * para que o load balancer pare de mandar requests para este pod.
 *
 * Checks:
 *  - Postgres via Prisma: SELECT 1
 *  - Redis: PING
 *  - RabbitMQ: abre e fecha uma conexão rápida
 */
router.get('/ready', async (_req: Request, res: Response) => {
  const checks: Record<string, { ok: boolean; error?: string }> = {};

  // 1) Postgres
  try {
    await prisma.$queryRaw`SELECT 1`;
    checks.postgres = { ok: true };
  } catch (err: any) {
    checks.postgres = { ok: false, error: err?.message };
  }

  // 2) Redis
  try {
    await redisService.ping();
    checks.redis = { ok: true };
  } catch (err: any) {
    checks.redis = { ok: false, error: err?.message };
  }

  // 3) RabbitMQ (abrir+fechar é o "PING" oficial para AMQP)
  try {
    const conn = await amqp.connect(getRabbitMQConfig() as any);
    await conn.close();
    checks.rabbitmq = { ok: true };
  } catch (err: any) {
    checks.rabbitmq = { ok: false, error: err?.message };
  }

  const allOk = Object.values(checks).every((c) => c.ok);
  const httpStatus = allOk ? 200 : 503;

  if (!allOk) {
    logger.warn({ checks }, '[Health] Readiness com falha');
  }

  res.status(httpStatus).json({
    status: allOk ? 'ready' : 'not_ready',
    checks,
  });
});

export default router;
