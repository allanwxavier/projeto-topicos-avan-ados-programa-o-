# 📅 — Backend API

Sistema de agendamento de reuniões desenvolvido como projeto acadêmico.
Backend construído com **FastAPI** + **PostgreSQL**, consumido pelo app mobile em **Flutter**.

---

## 🗂 Estrutura do Projeto

```
backend/
├── app/
│   ├── main.py               # Ponto de entrada da aplicação
│   ├── core/
│   │   ├── config.py         # Variáveis de ambiente
│   │   ├── security.py       # Geração e validação de token
│   │   └── dependencies.py   # Dependências reutilizáveis (get_current_user)
│   ├── database/
│   │   ├── connection.py     # Conexão com o PostgreSQL
│   │   └── base.py           # Base declarativa dos models
│   ├── models/               # Tabelas do banco (SQLAlchemy ORM)
│   ├── schemas/              # Validação de dados (Pydantic)
│   ├── repositories/         # Acesso ao banco de dados
│   ├── services/             # Regras de negócio
│   └── routers/              # Endpoints da API (/api/v1/...)
├── migrations/               # Migrações do banco (Alembic)
├── tests/                    # Testes automatizados
├── .env.example              # Modelo das variáveis de ambiente
└── requirements.txt          # Dependências do projeto
```

---

## ✅ Pré-requisitos

Antes de começar, certifique-se de ter instalado na sua máquina:

- [Python 3.11+](https://www.python.org/downloads/)
- [PostgreSQL 15+](https://www.postgresql.org/download/)
- [Git](https://git-scm.com/)

---

## 🚀 Como rodar o projeto

### 1. Clone o repositório

```bash
git clone https://github.com/allanwxavier/projeto-topicos-avan-ados-programa-o-.git
cd seu-repositorio/backend
```

### 2. Crie e ative o ambiente virtual

```bash
# Criar o ambiente virtual
python -m venv venv

# Ativar no Windows
venv\Scripts\activate

# Ativar no Linux / macOS
source venv/bin/activate
```

### 3. Instale as dependências

```bash
pip install -r requirements.txt
```

### 4. Configure as variáveis de ambiente

Copie o arquivo de exemplo e preencha com os seus dados:

```bash
cp .env.example .env
```

Abra o arquivo `.env` e preencha os valores:

```env
DATABASE_URL=postgresql://seu_usuario:sua_senha@localhost:5432/nome_do_banco
SECRET_KEY=uma-chave-secreta-qualquer
```

### 5. Crie o banco de dados no PostgreSQL

Acesse o PostgreSQL e crie o banco:

```sql
CREATE DATABASE #Nome da sua escolha;
```

### 6. Execute as migrações

```bash
alembic upgrade head
```

### 7. Inicie o servidor

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

O servidor estará disponível em: `http://localhost:8080`

> **Dica para o emulador Android:** o endereço `http://10.0.2.2:8080` no app Flutter aponta automaticamente para o `localhost` da sua máquina.

---

## 📡 Endpoints disponíveis

Após iniciar o servidor, acesse a documentação interativa gerada automaticamente pelo FastAPI:

| Ferramenta | URL |
|---|---|
| Swagger UI | `http://localhost:8080/docs` |
| Redoc | `http://localhost:8080/redoc` |

### Principais rotas

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Autenticação do usuário |
| `GET` | `/api/v1/usuarios` | Listar usuários |
| `GET` | `/api/v1/reunioes` | Listar reuniões |
| `POST` | `/api/v1/reunioes` | Criar nova reunião |
| `POST` | `/api/v1/reuniao/participantes/adicionar` | Adicionar participante |
| `POST` | `/api/v1/reuniao/participantes/listar` | Listar participantes |

---

## 🧪 Como rodar os testes

```bash
pytest tests/ -v
```

---

## 🛠 Tecnologias utilizadas

| Tecnologia | Versão | Função |
|---|---|---|
| FastAPI | 0.115.0 | Framework web |
| Uvicorn | 0.30.0 | Servidor ASGI |
| SQLAlchemy | 2.0.35 | ORM |
| PostgreSQL | 15+ | Banco de dados |
| Alembic | 1.13.2 | Migrações |
| Pydantic | 2.9.0 | Validação de dados |

---

## 👥 Autores


