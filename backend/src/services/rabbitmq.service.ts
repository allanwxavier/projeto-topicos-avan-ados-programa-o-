import amqp from 'amqplib';
import { logger } from '../config/logger';
import { rabbitResilience } from '../config/resilience';
import { rabbitmqPublishTotal } from '../config/metrics';
import { getRabbitMQConfig } from '../config/rabbitmq';

export class RabbitMQService {
  /**
   * Publica uma mensagem em uma fila do RabbitMQ.
   *
   * Toda a operação é envolvida pelas políticas do Cockatiel:
   *   - Retry com backoff exponencial (3 tentativas).
   *   - Circuit Breaker (5 falhas consecutivas → 10s aberto).
   */
  static async enviarParaFila(fila: string, mensagem: any): Promise<void> {
    try {
      await rabbitResilience.execute(() =>
        RabbitMQService.publishOnce(fila, mensagem),
      );
      rabbitmqPublishTotal.inc({ queue: fila, outcome: 'success' });
    } catch (error: any) {
      rabbitmqPublishTotal.inc({ queue: fila, outcome: 'failure' });
      logger.error(
        { err: error, fila },
        '[RabbitMQ] Falha definitiva ao enviar mensagem (retry/circuit esgotados)',
      );
    }
  }

  /**
   * Realiza UMA tentativa de publicação. É essa função que a política
   * de resiliência repete em caso de falha.
   */
  private static async publishOnce(fila: string, mensagem: any): Promise<void> {
    const connection = await amqp.connect(getRabbitMQConfig() as any);

    try {
      const channel = await connection.createChannel();
      await channel.assertQueue(fila, { durable: true });

      const payload =
        typeof mensagem === 'string' ? mensagem : JSON.stringify(mensagem);

      channel.sendToQueue(fila, Buffer.from(payload), { persistent: true });

      logger.info({ fila }, '[RabbitMQ] Mensagem enviada para a fila');

      await channel.close();
    } finally {
      await connection.close().catch(() => {
        /* ignora erro de fechamento — conexão já está sendo derrubada */
      });
    }
  }
}
