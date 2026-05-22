import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

export const CORRELATION_HEADER = 'x-correlation-id';

/**
 * Middleware de Correlation ID.
 *
 * Toda requisição que chega na API recebe (ou propaga) um UUID único.
 * Esse ID é colocado em:
 *  - req.id           → para uso no pino-http (vira o campo `req.id` no log)
 *  - response header  → para o cliente conseguir referenciar a chamada
 *
 * Por que isso importa?
 *  Em uma arquitetura com múltiplos serviços (Node + Laravel + RabbitMQ),
 *  conseguir "rastrear" uma única operação de ponta a ponta exige um ID
 *  comum. Sem isso, debugar erros distribuídos é praticamente um chute.
 */
export function correlationIdMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  const incoming = req.header(CORRELATION_HEADER);
  const correlationId = incoming && incoming.trim().length > 0 ? incoming : uuidv4();

  // O pino-http (configurado adiante) lê `req.id` automaticamente.
  (req as any).id = correlationId;

  res.setHeader(CORRELATION_HEADER, correlationId);
  next();
}
