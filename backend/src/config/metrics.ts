import client from 'prom-client';

/**
 * Registry centralizado de métricas.
 *
 * Por que ter um Registry próprio (em vez de usar o `register` global)?
 *   - Facilita testes (você pode limpar/reiniciar).
 *   - Evita conflito com bibliotecas que possam registrar coisas no
 *     registry default.
 */
export const registry = new client.Registry();

// Métricas padrão de processo Node (CPU, memória, event loop, GC, ...).
// O Grafana adora isso para painéis de saúde.
client.collectDefaultMetrics({ register: registry });

// ─── Métricas TÉCNICAS de HTTP ───────────────────────────────────────────

/**
 * Histogram com a duração das requisições.
 * Labels:
 *   - method   : GET, POST, ...
 *   - route    : rota PADRONIZADA do Express (ex: /api/v1/reunioes/:id),
 *                NUNCA a URL crua, senão o cardinality explode.
 *   - status   : 200, 404, 500, ...
 */
export const httpRequestDurationSeconds = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duração das requisições HTTP em segundos',
  labelNames: ['method', 'route', 'status'] as const,
  // Buckets em segundos. Cobrem desde 5ms até 5s.
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
  registers: [registry],
});

/**
 * Counter de total de requisições — útil para taxa por segundo (RPS)
 * via PromQL: rate(http_requests_total[1m]).
 */
export const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total de requisições HTTP',
  labelNames: ['method', 'route', 'status'] as const,
  registers: [registry],
});

// ─── Métricas de NEGÓCIO ─────────────────────────────────────────────────
//
// Estas são as que o Dev 1 vai consumir nos dashboards do Grafana
// (painel "Negócios" do guia: reuniões agendadas etc.).

export const reunioesCriadasTotal = new client.Counter({
  name: 'reunioes_criadas_total',
  help: 'Total de reuniões criadas no sistema',
  registers: [registry],
});

export const usuariosRegistradosTotal = new client.Counter({
  name: 'usuarios_registrados_total',
  help: 'Total de usuários registrados',
  registers: [registry],
});

export const participantesAdicionadosTotal = new client.Counter({
  name: 'reuniao_participantes_adicionados_total',
  help: 'Total de participantes adicionados em reuniões',
  registers: [registry],
});

export const cardsKanbanCriadosTotal = new client.Counter({
  name: 'kanban_cards_criados_total',
  help: 'Total de cards de Kanban criados',
  registers: [registry],
});

// ─── Métricas de RESILIÊNCIA ─────────────────────────────────────────────

export const rabbitmqPublishTotal = new client.Counter({
  name: 'rabbitmq_publish_total',
  help: 'Total de tentativas de publicação no RabbitMQ',
  labelNames: ['queue', 'outcome'] as const, // outcome: success | failure
  registers: [registry],
});

export const circuitBreakerStateChanges = new client.Counter({
  name: 'circuit_breaker_state_changes_total',
  help: 'Mudanças de estado do circuit breaker',
  labelNames: ['service', 'state'] as const, // state: open | closed | half-open
  registers: [registry],
});
