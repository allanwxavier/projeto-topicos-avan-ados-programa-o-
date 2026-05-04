import amqp from 'amqplib';

export class RabbitMQService {
  static async enviarParaFila(fila: string, mensagem: any) {
    try {
      // Conecta ao container do RabbitMQ definido no docker-compose
      const connection = await amqp.connect('amqp://rabbitmq'); 
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