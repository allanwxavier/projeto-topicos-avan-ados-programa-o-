import amqp from 'amqplib';
import { Server } from 'socket.io';
import { logger } from '../config/logger';
import { getRabbitMQConfig } from '../config/rabbitmq';

export async function iniciarConsumer(io: Server) {
  try {
    const connection = await amqp.connect(getRabbitMQConfig() as any);

    const channel = await connection.createChannel();
    const fila = 'reuniao_events';

    await channel.assertQueue(fila, { durable: true });
    logger.info({ fila }, '[RabbitMQ Consumer] Aguardando mensagens');

    channel.consume(fila, (msg) => {
      if (msg !== null) {
        try {
          const evento = JSON.parse(msg.content.toString());

          logger.info(
            { tipo: evento.tipo, eventId: evento.eventId },
            '[RabbitMQ Consumer] Mensagem recebida',
          );

          if (evento.tipo === 'ReuniaoStatusAtualizadoEvent') {
            const payload = evento.payload;
            const roomName = `reuniao_${payload.id}`;

            io.to(roomName).emit('reuniao:status_atualizado', payload);
            logger.debug({ roomName }, '[RabbitMQ Consumer] Evento disparado');
          }

          channel.ack(msg);
        } catch (error) {
          logger.error({ err: error }, '[RabbitMQ Consumer] Erro ao processar mensagem');
          channel.nack(msg, false, false);
        }
      }
    });
  } catch (error) {
    logger.error({ err: error }, '[RabbitMQ Consumer] Erro ao iniciar o consumer');
  }
}
