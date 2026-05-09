import * as amqp from 'amqplib';

async function debugPublish() {
  try {
    console.log('Conectando ao RabbitMQ...');
    // Forçando o IP local para não ter erro de .env
    const connection = await amqp.connect('amqp://guest:guest@rabbitmq:5672');
    const channel = await connection.createChannel();
    
    const queue = 'reuniao_criada';
    await channel.assertQueue(queue, { durable: true });

    // Mensagem em formato Simples (O Laravel RabbitMQ costuma aceitar)
    const msg = {
    "uuid": "sync-test-" + Date.now(),
    "displayName": "App\\Jobs\\ProcessarEventoReuniao",
    "job": "Illuminate\\Queue\\CallQueuedHandler@call",
    "data": {
        "commandName": "App\\Jobs\\ProcessarEventoReuniao",
        "command": "O:31:\"App\\Jobs\\ProcessarEventoReuniao\":1:{s:4:\"data\";a:3:{s:6:\"titulo\";s:14:\"Teste de FluxO\";s:9:\"descricao\";s:10:\"Final Test\";s:4:\"data\";s:10:\"2026-05-10\";}}"
    }
};

channel.sendToQueue('reuniao_criada', Buffer.from(JSON.stringify(msg)), { persistent: true });
    
    console.log('✓ Mensagem enviada! Verifique o painel do RabbitMQ agora.');
    console.log('Aguardando 2 segundos antes de fechar...');

    setTimeout(async () => {
      await connection.close();
      console.log('Conexão fechada.');
      process.exit(0);
    }, 2000);

  } catch (err) {
    console.error('ERRO AO ENVIAR:', err);
  }
}

debugPublish();