# Sistema de Gestão de Reuniões e Kanban (TAC)

[![CI](https://github.com/allanwxavier/projeto-topicos-avan-ados-programa-o-/actions/workflows/ci.yml/badge.svg)](https://github.com/allanwxavier/projeto-topicos-avan-ados-programa-o-/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=<project-key>&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=<project-key>)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=<project-key>&metric=coverage)](https://sonarcloud.io/summary/new_code?id=<project-key>)

Este projeto foi desenvolvido como parte da 2ª Avaliação da disciplina de **Tópicos Avançados em Computação**, focando-se em Arquitetura Moderna de Software e sistemas distribuídos utilizando uma abordagem Full Cycle.

## 🚀 Visão Geral
A solução materializa um sistema de microsserviços para gestão colaborativa, permitindo o agendamento de reuniões e a organização de tarefas via quadro Kanban, garantindo robustez e escalabilidade através de tecnologias contemporâneas.

## 🛠️ Stack Tecnológica

### Backend (Microsserviços)
- **Runtime:** Node.js com TypeScript
- **Framework:** Express
- **ORM:** Prisma (PostgreSQL)
- **Mensajeria:** RabbitMQ (Comunicação assíncrona entre serviços)
- **Documentação:** Swagger (OpenAPI)
- **Testes:** Jest

### Frontend & Mobile
- **Framework:** Flutter (Dart)
- **Gerenciamento de Estado:** Provider
- **Real-time:** Socket.io-client

### Infraestrutura & DevOps
- **Containerização:** Docker & Docker Compose
- **CI/CD:** GitHub Actions (workflows configurados)

## 📦 Estrutura do Repositório
- `/backend`: Contém a lógica de microsserviços, modelos de dados Prisma e controladores.
- `/lib`: Código fonte da aplicação Flutter (Interface, modelos de Kanban e agendamento).
- `docker-compose.yml`: Orquestração da base de dados, RabbitMQ e serviços da aplicação.

## 🔧 Como Executar

### Pré-requisitos
- Docker e Docker Compose instalados.
- Flutter SDK (para execução do cliente).

### Execução com Docker
Para subir todo o ambiente distribuído (Base de Dados, RabbitMQ e API):
```bash
docker-compose up -d
```