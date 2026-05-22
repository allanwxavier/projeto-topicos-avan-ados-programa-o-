import pino from 'pino';

/**
 * Logger global da aplicação.
 *
 * Em PRODUÇÃO: emite JSON puro no stdout (formato ideal para ingestão em
 * Loki / Datadog / ELK).
 * Em DEV: usa pino-pretty para deixar legível no terminal.
 *
 * Por que JSON?
 *  - Cada linha vira um documento estruturado, com campos pesquisáveis
 *    (level, msg, time, correlationId, req.method, etc.).
 *  - Console.log "solto" não permite filtrar por requisição nem
 *    correlacionar logs entre serviços.
 */
const isProd = process.env.NODE_ENV === 'production';

export const logger = pino({
  level: process.env.LOG_LEVEL || (isProd ? 'info' : 'debug'),
  base: {
    service: 'meetsync-backend',
    env: process.env.NODE_ENV || 'development',
  },
  // formatadores garantem que o nível venha como string ("info"), e não
  // como número (30), facilitando a leitura em ferramentas externas.
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  // pino-pretty só é carregado fora de produção
  transport: isProd
    ? undefined
    : {
        target: 'pino-pretty',
        options: {
          colorize: true,
          translateTime: 'SYS:HH:MM:ss.l',
          ignore: 'pid,hostname,service,env',
        },
      },
});
