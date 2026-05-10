# 🚀 Como rodar o projeto CQRS localmente

Este guia mostra como subir **toda a stack** (Node + Laravel + RabbitMQ + bancos) com **um único comando**.

---

## 📦 Pré-requisitos

- **Docker Desktop** instalado e rodando ([baixar aqui](https://www.docker.com/products/docker-desktop))
- **Git** instalado
- **Flutter** (apenas para o Dev 3)

---

## 🗂️ Estrutura de pastas obrigatória

Os dois repositórios precisam estar **clonados lado a lado** na mesma pasta-mãe:

```
~/projetos/                                      ← (ou C:\projetos\ no Windows)
├── projeto-topicos-avan-ados-programa-o-/       ← repo do Allan (Flutter + Node)
│   ├── docker-compose.yml                       ← orquestrador
│   ├── backend/                                 ← Node.js API
│   ├── lib/                                     ← App Flutter
│   └── README-DOCKER.md                         ← este arquivo
└── MicroSaas_To_do/                             ← repo do Murilo (Laravel)
    └── php-service/                             ← Laravel API
```

### Comandos para clonar tudo certinho:

```bash
mkdir projetos && cd projetos
git clone https://github.com/allanwxavier/projeto-topicos-avan-ados-programa-o-.git
git clone https://github.com/Murilo11/MicroSaas_To_do.git
```

---

## ▶️ Rodando o projeto

A partir da pasta do repo do Allan:

```bash
cd projeto-topicos-avan-ados-programa-o-
docker compose up --build
```

Na primeira vez demora **~3 minutos** (baixa imagens, builda, roda migrations).

Depois é só:

```bash
docker compose up        # subir
docker compose down      # parar (mantém os dados)
docker compose down -v   # parar e APAGAR os bancos (reset total)
```

---

## 🌐 Endpoints disponíveis após subir

| Serviço | URL | Login |
|---|---|---|
| **Node API** (Write) | http://localhost:8081 | — |
| **Laravel API** (Read) | http://localhost:8000 | — |
| **RabbitMQ Web UI** | http://localhost:15672 | admin / admin123 |
| **Swagger Node** | http://localhost:8081/api/docs | — |
| PostgreSQL (Node) | localhost:5433 | meetsync / meetsync123 |
| MySQL (Laravel) | localhost:3307 | laravel / laravel123 |

---

## 🧪 Como verificar se está tudo OK

### 1. Conferir os containers
```bash
docker compose ps
```
Devem aparecer **6 containers** com status `Up` ou `healthy`.

### 2. Testar o Node
```bash
curl http://localhost:8081/
# Esperado: {"status":"ok","message":"API rodando!"}
```

### 3. Testar o Laravel
```bash
curl http://localhost:8000/api/health
# Esperado: {"status":"Microsserviço PHP está rodando!", ...}
```

### 4. Testar o RabbitMQ
Abre http://localhost:15672 no navegador, login `admin` / `admin123`. Vai aparecer a interface do RabbitMQ.

### 5. Testar o Flutter
```bash
cd projeto-topicos-avan-ados-programa-o-
flutter run
```
No app, troque pra "modo real" no provider e verifique se os endpoints respondem.

---

## ⚠️ Pendências por Dev (precisa terminar antes da entrega)

### 🔴 Dev 2 (Murilo — Laravel)

1. **Criar comando artisan `rabbitmq:consume`** que escuta a fila `kanban_events` e dispara os Jobs apropriados.
   - Sem isso, o container `laravel-worker` vai ficar reiniciando.
2. **Criar Job `ProcessarEventoCard`** com idempotência (verificar se `eventId` já foi processado).
3. **Criar migration** `cards_read` desnormalizada (pra ser a read model real, separada da `cards`).
4. **Remover** os métodos `store()`, `update()`, `destroy()` dos controllers — **CQRS exige só leitura** no Laravel.
5. **Corrigir bugs** no Job existente `ProcessarEventoReuniao.php`:
   - Linha 27: `\Db::table` → `\DB::table`
   - Linha 40: `'update_at'` → `'updated_at'`
   - Linha 43: `log::info` → `Log::info`
6. **Instalar pacote** `php-amqplib/php-amqplib` no `composer.json`:
   ```bash
   docker compose exec laravel-app composer require php-amqplib/php-amqplib
   ```

### 🟡 Dev 1 (Node — backend)

1. **Confirmar** que está publicando no exchange/fila com nome `kanban_events` (já está OK no código atual).
2. **Padronizar payload** dos eventos para o formato:
   ```json
   {
     "eventId": "uuid",
     "tipo": "CardCriadoEvent",
     "dataPublicacao": "ISO8601",
     "payload": { ... dados do card ... }
   }
   ```
3. **Resolver incompatibilidade de schema**: alinhar com Murilo se vai usar `columnId` (string) ou `board_id` (int) — preferencialmente `columnId`.

### 🟢 Dev 3 (Allan — Flutter) — ✅ CONCLUÍDO
- ✅ `KanbanCommandRepository` (escrita Node)
- ✅ `KanbanQueryRepository` (leitura Laravel)
- ✅ Optimistic UI com rollback
- ✅ Estados `SyncStatus` (pending → syncing → confirmed → failed)
- ✅ Feedback visual no card

### ⚙️ Dev 4 (DevOps)
1. ✅ `docker-compose.yml` unificado — entregue neste arquivo.
2. **Configurar CI/CD básico** no GitHub Actions (opcional, para a apresentação).

---

## 🛠️ Troubleshooting

**"Network cqrs-net already exists"**
→ Roda `docker network rm cqrs-net` e tenta de novo.

**"Port 8081 is already in use"**
→ Algum outro serviço local tá usando essa porta. Mata o processo ou edita o `docker-compose.yml`.

**Containers do Laravel ficam reiniciando**
→ Provavelmente é o `laravel-worker` esperando o comando artisan que o Dev 2 ainda não criou. Se quiser subir só o necessário pra desenvolvimento agora, comenta o bloco `laravel-worker` no compose.

**Migrations do Laravel não rodaram**
→ Roda manualmente:
```bash
docker compose exec laravel-app php artisan migrate
```

**Flutter não conecta na API**
→ Em emulador Android, use `10.0.2.2` em vez de `localhost`. O `api_config.dart` do projeto já trata isso.

---

## 🎯 Status atual da integração

```
✅ Infraestrutura Docker     → pronta
✅ Front-end Flutter         → pronto (CQRS implementado)
✅ Backend Node.js           → publicando eventos
🟡 Backend Laravel           → falta consumer RabbitMQ
⚙️  Demo end-to-end          → bloqueada pela pendência do Dev 2
```
