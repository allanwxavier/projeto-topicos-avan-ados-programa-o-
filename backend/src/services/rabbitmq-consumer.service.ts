import amqp from 'amqplib';
import { Server } from 'socket.io';

export async function iniciarConsumer(io: Server) {
  try {
    const connection = await amqp.connect({
      hostname: process.env.RABBITMQ_HOST || 'localhost',
      port: Number(process.env.RABBITMQ_PORT) || 5672,
      username: process.env.RABBITMQ_USER || 'guest',
      password: process.env.RABBITMQ_PASSWORD || 'guest',
      vhost: process.env.RABBITMQ_VHOST || '/',
    });

    const channel = await connection.createChannel();
    const fila = 'reuniao_events';

    await channel.assertQueue(fila, { durable: true });
    console.log(`[RabbitMQ Consumer] Aguardando mensagens na fila: ${fila}`);

    channel.consume(fila, (msg) => {
      if (msg !== null) {
        try {
          const evento = JSON.parse(msg.content.toString());

          console.log(`[RabbitMQ Consumer] Mensagem recebida:`, evento.tipo);

          if (evento.tipo === 'ReuniaoStatusAtualizadoEvent') {
            const payload = evento.payload;
            const roomName = `reuniao_${payload.id}`;
            
            // Dispara para a sala do Socket.io
            io.to(roomName).emit('reuniao:status_atualizado', payload);
            console.log(`[RabbitMQ Consumer] Evento disparado para a sala: ${roomName}`);
          }

          channel.ack(msg);
        } catch (error) {
          console.error('[RabbitMQ Consumer] Erro ao processar mensagem:', error);
          
          channel.nack(msg, false, false);
        }
      }
    });
  } catch (error) {
    console.error('[RabbitMQ Consumer] Erro ao iniciar o consumer:', error);
  }
}
