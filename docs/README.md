# Entrega — AULA 09 · Frontend / Reatividade



## Conteúdo desta pasta
- `websocket-ativo.png` — print da aba **Network → WS** mostrando a
  conexão Socket.IO ativa com as mensagens de status trafegando
  (`kanban:join`, `card:moved`, `reuniao:status_atualizado`).

## Tarefas entregues (Missões do Ghabriel)
1. **Socket Client** — `socket_io_client` com reconexão automática e
   indicador visual de queda de conexão.
2. **Assinatura dinâmica de salas** — join ao abrir a tela, leave ao
   sair; re-inscrição automática após reconexão.
3. **Atualização reativa** — `ReuniaoProvider`/`KanbanProvider` escutam
   o socket e redesenham a UI sem reload.

## Como reproduzir o print
1. Subir a stack: `docker compose up --build`
2. `flutter run -d chrome`
3. Login → abrir o Board → F12 → Network → filtro WS → aba Messages
4. Mover um card / disparar mudança de status → mensagens aparecem