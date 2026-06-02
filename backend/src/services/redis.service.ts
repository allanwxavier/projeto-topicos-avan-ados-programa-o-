import { createClient } from 'redis';
import { logger } from '../config/logger';

/**
 * Serviço estático de Redis usado para cache da aplicação.
 *
 * Mantemos como classe estática (singleton) para compatibilidade com
 * o código já existente. O método novo `ping()` é consumido pela rota
 * /health/ready.
 */
export class redisService {
  private static client: ReturnType<typeof createClient>;

  static async redisConnect() {
    const client = createClient({
      password: process.env.REDIS_PASSWORD || undefined,
      socket: {
        host: process.env.REDIS_HOST || '127.0.0.1',
        port: parseInt(process.env.REDIS_PORT as string) || 6379,
      },
    });

    client.on('error', (err) =>
      logger.error({ err }, '[Redis Cache] Erro de conexão'),
    );

    await client.connect();
    redisService.client = client;
  }

  static async get(chave: string) {
    if (!redisService.client) return null;
    return await redisService.client.get(chave);
  }

  static async set(chave: string, valor: string, ttl: number) {
    if (!redisService.client) return;
    await redisService.client.set(chave, valor, { EX: ttl });
  }

  static async del(chave: string) {
    if (!redisService.client) return;
    await redisService.client.del(chave);
  }

  /**
   * Health-check: PING ao servidor Redis.
   * Lança erro se não houver client conectado ou se a resposta não vier.
   */
  static async ping(): Promise<string> {
    if (!redisService.client) {
      throw new Error('Redis client não inicializado');
    }
    return await redisService.client.ping();
  }
}
