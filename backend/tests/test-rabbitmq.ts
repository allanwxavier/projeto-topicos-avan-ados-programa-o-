/// <reference types="node" />
require('dotenv').config();
const amqplib = require('amqplib');

async function testPublish() {
  try {
    const conn = await amqplib.connect({
      hostname: process.env.RABBITMQ_HOST,
      port:     process.env.RABBITMQ_PORT,
      username: process.env.RABBITMQ_USER,
      password: process.env.RABBITMQ_PASSWORD,
      vhost:    process.env.RABBITMQ_VHOST,
    });
    const ch = await conn.createChannel();
    await ch.assertQueue(process.env.RABBITMQ_QUEUE, { durable: true });

    const msg = {
      teste: 'Integracao Laravel-NodeJS via RabbitMQ',
      timestamp: new Date().toISOString(),
      id: Math.floor(Math.random() * 10000),
    };

    ch.sendToQueue(
      process.env.RABBITMQ_QUEUE,
      Buffer.from(JSON.stringify(msg)),
      { persistent: true }
    );

    console.log('Mensagem de teste enviada:', msg);
    await ch.close();
    await conn.close();
   } catch (err) {
     if (err instanceof Error) {
       console.error('Falha ao enviar mensagem:', err.message);
     } else {
       console.error('Falha ao enviar mensagem:', String(err));
     }
   }
}

testPublish();
