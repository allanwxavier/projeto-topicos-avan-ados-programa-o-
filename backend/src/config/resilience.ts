import {
  ConsecutiveBreaker,
  ExponentialBackoff,
  handleAll,
  retry,
  circuitBreaker,
  wrap,

} from 'cockatiel';
import { logger } from './logger';
import { circuitBreakerStateChanges } from './metrics';

/**
 * PolÃ­ticas de resiliÃªncia usando Cockatiel.
 *
 * Combinamos duas polÃ­ticas via `wrap`:
 *
 *  1) Retry com backoff exponencial:
 *     - Tenta atÃ© 3 vezes em caso de erro.
 *     - Espera ~200ms, ~400ms, ~800ms entre tentativas.
 *
 *  2) Circuit Breaker:
 *     - ApÃ³s 5 falhas consecutivas o circuito ABRE.
 *     - Espera 10s antes de tentar HALF-OPEN.
 *     - Se a primeira tentativa em half-open passa, fecha de novo;
 *       se falha, volta a abrir.
 *
 * Wrap final: retry ROUNDS DENTRO de cada janela do breaker.
 * Ordem importa: wrap(retry, breaker) = a cada chamada externa, o retry
 * Ã© executado; mas se o breaker estiver aberto, o retry sequer comeÃ§a.
 */

const retryPolicy = retry(handleAll, {
  maxAttempts: 3,
  backoff: new ExponentialBackoff({
    initialDelay: 200, // ms
    maxDelay: 800,
    exponent: 2,
  }),
});

retryPolicy.onRetry((info) => {
  logger.warn(
    { attempt: info.attempt, delayMs: info.delay, reason: (info as any).reason },
    '[Resilience] Retry tentativa',
  );
});

const breakerPolicy = circuitBreaker(handleAll, {
  halfOpenAfter: 10_000, // ms
  breaker: new ConsecutiveBreaker(5),
});

breakerPolicy.onBreak(() => {
  logger.error('[Resilience] Circuit breaker ABERTO');
  circuitBreakerStateChanges.inc({ service: 'rabbitmq', state: 'open' });
});
breakerPolicy.onReset(() => {
  logger.info('[Resilience] Circuit breaker FECHADO (resetado)');
  circuitBreakerStateChanges.inc({ service: 'rabbitmq', state: 'closed' });
});
breakerPolicy.onHalfOpen(() => {
  logger.info('[Resilience] Circuit breaker em HALF-OPEN (teste)');
  circuitBreakerStateChanges.inc({ service: 'rabbitmq', state: 'half-open' });
});

/**
 * PolÃ­tica composta exportada para envolver chamadas crÃ­ticas
 * (principalmente RabbitMQService).
 */
export const rabbitResilience= wrap(retryPolicy, breakerPolicy);
