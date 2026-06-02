import { ReuniaoService } from '../../src/services/reuniao.service';
import { ReuniaoRepository } from '../../src/repositories/reuniao.repository';
import { redisService } from '../../src/services/redis.service';
import { RabbitMQService } from '../../src/services/rabbitmq.service';

// Mock do repositório
jest.mock('../../src/repositories/reuniao.repository');

// Mocks do Redis e RabbitMQ
jest.mock('../../src/services/redis.service', () => ({
  redisService: {
    del: jest.fn().mockResolvedValue(true),
    get: jest.fn(),
    set: jest.fn()
  }
}));

jest.mock('../../src/services/rabbitmq.service', () => ({
  RabbitMQService: {
    enviarParaFila: jest.fn().mockResolvedValue(true)
  }
}));

describe('ReuniaoService - Atualizar Status (Teste Unitário)', () => {
  let reuniaoService: ReuniaoService;

  beforeEach(() => {
    jest.clearAllMocks();
    reuniaoService = new ReuniaoService();
  });

  // VALIDAÇÃO 5: Mudança de Status, Cache e Eventos
  it('deve atualizar o status da reunião, invalidar caches e publicar evento no RabbitMQ', async () => {
    const reuniaoMockada = {
      id: 10,
      assunto: 'Planejamento de Sprint',
      local: 'Sala Online Microsoft Teams',
      data: '2026-06-05',
      horaInicio: '09:00',
      horaFim: '10:30',
      criadoEm: new Date(),
      status: 'Realizada'
    };

    (ReuniaoRepository.prototype.updateStatus as jest.Mock).mockResolvedValue(reuniaoMockada);

    const result = await reuniaoService.atualizarStatus(10, 'Realizada');

    // 1. Verifica persistência no repositório
    expect(ReuniaoRepository.prototype.updateStatus).toHaveBeenCalledWith(10, 'Realizada');

    // 2. Verifica se limpou o cache do Redis (tanto o item individual quanto a lista)
    expect(redisService.del).toHaveBeenCalledWith('reuniao:item:10');
    expect(redisService.del).toHaveBeenCalledWith('reuniao:lista');

    // 3. Verifica se o evento foi enviado para a fila no RabbitMQ com a estrutura correta
    expect(RabbitMQService.enviarParaFila).toHaveBeenCalledWith(
      'reuniao_events',
      expect.objectContaining({
        eventId: expect.any(String),
        tipo: 'ReuniaoStatusAtualizadoEvent',
        dataPublicacao: expect.any(String),
        payload: {
          id: 10,
          status: 'Realizada'
        }
      })
    );

    expect(result).toEqual(reuniaoMockada);
  });
});
