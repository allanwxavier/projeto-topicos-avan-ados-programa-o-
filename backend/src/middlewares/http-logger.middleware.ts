import pinoHttp from 'pino-http';
import { logger } from '../config/logger';

/**
 * Middleware HTTP do Pino.
 *
 * Loga automaticamente cada request com:
 *   - req.id (Correlation ID, populado pelo correlation-id.middleware)
 *   - método, URL, status, tempo de resposta
 *
 * Customizações importantes:
 *   - genReqId: garante que se `req.id` já existir (caso do nosso middleware),
 *     ele é reaproveitado em vez de gerar outro.
 *   - serializers: enxuga o objeto req/res para não vazar tudo no log.
 *   - customLogLevel: 5xx vira "error", 4xx vira "warn", o resto fica "info".
 */
export const httpLogger = pinoHttp({
  logger,
  genReqId: (req) => (req as any).id, // já preenchido pelo correlationIdMiddleware
  customLogLevel: (_req, res, err) => {
    if (err || res.statusCode >= 500) return 'error';
    if (res.statusCode >= 400) return 'warn';
    return 'info';
  },
  serializers: {
    req(req) {
      return {
        id: req.id,
        method: req.method,
        url: req.url,
      };
    },
    res(res) {
      return { statusCode: res.statusCode };
    },
  },
  customSuccessMessage: (req, res) =>
    `${req.method} ${req.url} -> ${res.statusCode}`,
  customErrorMessage: (req, res, err) =>
    `${req.method} ${req.url} -> ${res.statusCode} (${err.message})`,
});
