import { Options } from 'amqplib';

/**
 * Helper centralizado para configurar a conexão com o RabbitMQ.
 *
 * Estratégia: prioriza `RABBITMQ_URL` (forma moderna/padrão, já fornecida
 * pelo docker-compose) e cai para variáveis separadas como fallback.
 *
 * Por que isso é importante?
 *  - A lib `amqplib` aceita tanto uma string URL quanto um objeto de config.
 *  - Em deploys reais (Kubernetes/Docker Swarm), o padrão é injetar uma
 *    única string de conexão (`amqp://user:pass@host:port/vhost`).
 *  - Variáveis separadas só ajudam em dev/local quando você quer
 *    sobrescrever pontualmente algum campo.
 */
export function getRabbitMQConfig(): string | Options.Connect {
  if (process.env.RABBITMQ_URL) {
    return process.env.RABBITMQ_URL;
  }

  return {
    hostname: process.env.RABBITMQ_HOST || 'localhost',
    port: Number(process.env.RABBITMQ_PORT) || 5672,
    username: process.env.RABBITMQ_USER || 'guest',
    password: process.env.RABBITMQ_PASSWORD || 'guest',
    vhost: process.env.RABBITMQ_VHOST || '/',
  };
}
