import { Request, Response, NextFunction } from 'express';
import {
  httpRequestDurationSeconds,
  httpRequestsTotal,
} from '../config/metrics';

/**
 * Middleware de coleta de métricas HTTP.
 *
 * Estratégia: ao chegar a requisição, abre um timer no histogram.
 * Quando a resposta é finalizada (evento `finish`), encerra o timer
 * passando as labels reais (status, rota padronizada).
 *
 * Atenção: usamos `req.route?.path` quando disponível, para evitar que
 * IDs (ex.: /reunioes/123, /reunioes/456) virem labels distintas no
 * Prometheus (isso causa "explosão de cardinalidade" e mata o servidor).
 */
export function metricsMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  // Endpoint /metrics não deve poluir as próprias métricas.
  if (req.path === '/metrics') return next();

  const endTimer = httpRequestDurationSeconds.startTimer();

  res.on('finish', () => {
    // Tenta o template do Express (ex: /api/v1/reunioes/:id);
    // se não existir, cai no path original.
    const route =
      (req.route && (req.baseUrl || '') + req.route.path) ||
      req.originalUrl.split('?')[0] ||
      'unknown';

    const labels = {
      method: req.method,
      route,
      status: String(res.statusCode),
    };

    endTimer(labels);
    httpRequestsTotal.inc(labels);
  });

  next();
}
