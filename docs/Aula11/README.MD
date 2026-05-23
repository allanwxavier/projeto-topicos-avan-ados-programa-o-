# Documentação — Aula 11: Observabilidade e Resiliência

Esta documentação detalha a implementação dos mecanismos de **observabilidade** e **resiliência** na arquitetura de microsserviços CQRS do projeto, abrangendo a infraestrutura de monitoramento, o backend Node.js (Write Model) e o backend Laravel (Read Model).

---

## 🎯 Objetivos da Aula
1. **Infraestrutura**: Configuração centralizada do Prometheus e Grafana via Docker Compose.
2. **Logs estruturados**: Logs estruturados em formato JSON com propagação de Correlation ID (`X-Correlation-Id`) entre os serviços.
3. **Health Checks**: Endpoints de Liveness e Readiness monitorando conexões com serviços externos (PostgreSQL, MySQL, Redis, RabbitMQ) e saúde operacional básica.
4. **Métricas expostas**: Coleta de métricas técnicas (taxa de requisições, latência) e métricas de negócio no formato Prometheus.
5. **Políticas de Resiliência**: Implementação de Retry e Circuit Breaker para tolerância a falhas temporárias nas integrações críticas.

---

## 🏗️ 1. Infraestrutura de Monitoramento (Dev 1)

A infraestrutura foi integrada ao arquivo central [docker-compose.yml](file:///mnt/hdd/projeto-topicos-avan-ados-programa-o-/docker-compose.yml), adicionando o Prometheus e o Grafana à mesma rede dos microsserviços (`cqrs-net`).

### Prometheus
Configurado no arquivo [prometheus.yml](file:///mnt/hdd/projeto-topicos-avan-ados-programa-o-/prometheus.yml) para coletar métricas a cada 15 segundos dos seguintes alvos:
*   `node-api:8081/metrics`
*   `laravel-webserver:80/prometheus`

### Grafana
Acessível na porta `3000`, o Grafana consome os dados do Prometheus e fornece visualizações em tempo real. Foi configurado um dashboard contendo três painéis principais:
1.  **Taxa de Requisições por Segundo**: `rate(http_requests_total[1m])`
2.  **Latência P95 (segundos)**: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`
3.  **Métricas de Negócio**: `reunioes_criadas_total` e `usuarios_registrados_total`

---

## 🟢 2. Backend Node.js — Write Model (Dev 2)

O serviço Node.js (`node-api`) centraliza as mutações de dados e foi robustecido com recursos avançados de observabilidade e resiliência.

### Logs Estruturados & Correlation ID
*   **Pino & Pino-HTTP**: Substituição dos logs comuns por logs JSON estruturados, ideais para ferramentas de agregação de logs (ex: Elasticsearch, Loki).
*   **Correlation ID**: Um middleware intercepta todas as requisições HTTP e injeta/propaga o header `X-Correlation-Id`. Isso permite rastrear a jornada completa de uma requisição mesmo que ela transite por múltiplos serviços.

### Health Checks (`/health`)
*   **Liveness (`/health/live`)**: Valida se o processo da aplicação está ativo.
*   **Readiness (`/health/ready`)**: Verifica a integridade de todas as conexões externas de banco de dados e mensageria (PostgreSQL, Redis, RabbitMQ). Caso alguma conexão caia, retorna status `503 Service Unavailable`.

### Métricas customizadas com `prom-client`
*   Exposição do endpoint `/metrics` com métricas padrão do Node.js, mais métricas customizadas do domínio:
    *   `http_requests_total` (Contador de requisições)
    *   `http_request_duration_seconds` (Histograma de latência)
    *   `reunioes_criadas_total` e `usuarios_registrados_total` (Métricas de negócio)
    *   `circuit_breaker_state_changes_total` (Estado do circuit breaker)
    *   `rabbitmq_publish_total` (Fila de integração)

### Resiliência com `Cockatiel`
Foi implementada uma política combinada de resiliência ao tentar publicar eventos no RabbitMQ:
1.  **Retry**: 3 tentativas de reenvio utilizando backoff exponencial.
2.  **Circuit Breaker**: Abre após 5 falhas consecutivas. Permanece aberto por 10 segundos antes de passar para o estado *half-open* e testar novamente a saúde da integração.

---

## 🔴 3. Backend Laravel — Read Model (Dev 3)

O serviço Laravel consome eventos do RabbitMQ e expõe a API de consulta. Ele recebeu as devidas atualizações para se integrar ao fluxo de observabilidade.

### Logs Estruturados
*   Uso do driver Monolog configurado para saídas estruturadas em JSON.
*   Middleware de injeção de Correlation ID integrado à pipeline HTTP.

### Health Checks
*   Integração do pacote `spatie/laravel-health`.
*   Monitoramento configurado para:
    *   Conexão com o Banco de Dados MySQL (`DatabaseCheck`)
    *   Conexão com o Redis (`RedisCheck`)
    *   Espaço disponível em disco do container (`UsedDiskSpaceCheck`)
*   Endpoints mapeados em `/api/health/live` e `/api/health/ready`.

### Métricas
*   Integração do pacote `spatie/laravel-prometheus` respondendo na rota padrão `/prometheus`.
*   Adicionados gauges customizados para monitoramento da volumetria dos boards e cards cadastrados.

---

## 🧪 4. Guia de Testes e Validação

### Execução da Stack
Certifique-se de iniciar o ambiente usando o Docker Compose na raiz do projeto:
```bash
docker compose up --build -d
```

### Validação 1: Containers Ativos
Rode o comando abaixo para verificar se todos os 9 containers estão ativos e saudáveis:
```bash
docker compose ps
```
> [!NOTE]
> Você pode conferir o status esperado na captura de tela: [docker-compose-ps.png](./docker-compose-ps.png).

### Validação 2: Health Checks (Node.js & Laravel)
Use o `curl` para testar os endpoints de prontidão e liveness dos dois microsserviços.

*   **Node.js Liveness**:
    ```bash
    curl -i http://localhost:8081/health/live
    ```
*   **Node.js Readiness**:
    ```bash
    curl -i http://localhost:8081/health/ready
    ```
*   **Laravel Liveness**:
    ```bash
    curl -i http://localhost:8000/api/health/live
    ```
*   **Laravel Readiness**:
    ```bash
    curl -i http://localhost:8000/api/health/ready
    ```
> [!NOTE]
> Veja as saídas bem-sucedidas registradas no arquivo de evidência: [health-check.png](./health-check.png).

### Validação 3: Resiliência em Ação (Retry & Circuit Breaker)
1.  **Simular falha na integração**: Pare o serviço do RabbitMQ:
    ```bash
    docker compose stop rabbitmq
    ```
2.  **Disparar requisição com falha**: Tente realizar uma ação que dependa do RabbitMQ (como criar uma nova reunião através da API Node.js).
3.  **Observar as tentativas de Retry nos logs**:
    ```bash
    docker compose logs node-api | grep "Retry"
    ```
4.  **Confirmar a abertura do Circuito**: Repita a chamada 5 vezes e consulte os logs ou o endpoint de métricas para ver a mudança de estado do Circuit Breaker para `open`.
5.  **Restabelecer serviço**: Suba o RabbitMQ novamente:
    ```bash
    docker compose start rabbitmq
    ```
6.  **Validar fechamento do circuito**: Aguarde 10 segundos, faça uma nova requisição e verifique nos logs o estado transitando para `half-open` e depois fechando (`closed`).

### Validação 4: Métricas no Prometheus & Painel Grafana
*   Acesse a lista de targets no Prometheus em: [http://localhost:9090/targets](http://localhost:9090/targets) e confirme que ambos os jobs (`node-api` e `laravel-backend`) estão em estado **UP**.
*   Acesse o Grafana em [http://localhost:3000](http://localhost:3000) com usuário `admin` / `admin` e visualize o painel montado.
> [!NOTE]
> O visual do painel preenchido com dados reais de requisições e métricas de negócio está documentado em: [grafana-dashboard.png](./grafana-dashboard.png).

---

## 📂 Arquivos de Evidências (Aula 11)
Para facilitar a correção, as evidências geradas durante os testes estão salvas nos links abaixo:
1.  **Status dos Containers**: [docker-compose-ps.png](./docker-compose-ps.png)
2.  **Validação dos Health Checks**: [health-check.png](./health-check.png)
3.  **Visualização do Grafana Dashboard**: [grafana-dashboard.png](./grafana-dashboard.png)
