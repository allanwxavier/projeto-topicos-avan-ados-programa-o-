import { GenericContainer, StartedTestContainer } from 'testcontainers';
import { redisService } from '../src/services/redis.service';

describe('ProdutoCacheServiceTests (Reuniao Cache Service Integration Tests)', () => {
  let container: StartedTestContainer;

  beforeAll(async () => {
    
    container = await new GenericContainer('redis:7-alpine')
      .withExposedPorts(6379)
      .start();

    
    process.env.REDIS_HOST = container.getHost();
    process.env.REDIS_PORT = container.getMappedPort(6379).toString();
    delete process.env.REDIS_PASSWORD; 

    
    await redisService.redisConnect();
  }, 60000); 

  afterAll(async () => {
    
    if (container) {
      await container.stop();
    }
  });

  it('Deve retornar MISS quando a chave não existe, gravar (SET), e depois dar HIT (GET)', async () => {
    const chave = 'reuniao:teste:123';
    const valorSimulado = JSON.stringify({ id: 123, status: 'agendada' });

    
    const cacheVazio = await redisService.get(chave);
    expect(cacheVazio).toBeNull();

    
    await redisService.set(chave, valorSimulado, 60);

    
    const cachePreenchido = await redisService.get(chave);
    expect(cachePreenchido).toBe(valorSimulado);
  });

  it('Deve invalidar o cache (DEL)', async () => {
    const chave = 'reuniao:teste:deletar';
    const valorSimulado = 'teste de exclusao';

    
    await redisService.set(chave, valorSimulado, 60);
    expect(await redisService.get(chave)).toBe(valorSimulado);

    
    await redisService.del(chave);
    expect(await redisService.get(chave)).toBeNull();
  });
});
