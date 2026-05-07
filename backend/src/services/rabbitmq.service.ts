import amqp from 'amqplib';

export class RabbitMQService {
  static async enviarParaFila(fila: string, mensagem: any) {
    try {
      // Conecta ao container do RabbitMQ definido no docker-compose
      const connection = await amqp.connect({
        hostname: process.env.RABBITMQ_HOST,
        port: Number(process.env.RABBITMQ_PORT),
        username: process.env.RABBITMQ_USER,
        password: process.env.RABBITMQ_PASSWORD,
        vhost: process.env.RABBITMQ_VHOST,
      });

      const channel = await connection.createChannel();

      await channel.assertQueue(fila, { durable: true });
      
      channel.sendToQueue(fila, Buffer.from(JSON.stringify(mensagem)), {
        persistent: true
      });

      console.log(`[RabbitMQ] Mensagem enviada para a fila: ${fila}`);
      
      setTimeout(() => connection.close(), 500);
    } catch (error) {
      console.error("[RabbitMQ] Erro ao enviar mensagem:", error);
    }
  }
}