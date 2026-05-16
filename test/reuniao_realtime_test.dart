import 'package:flutter_test/flutter_test.dart';
import 'package:meu_projeto_faculdade/providers/reuniao_provider.dart';

void main() {
  group('ReuniaoProvider — reatividade de status', () {
    test('atualiza status e notifica ouvintes ao receber o evento', () {
      final provider = ReuniaoProvider();
      var notificacoes = 0;
      provider.addListener(() => notificacoes++);

      provider.entrarNaReuniao(42, token: 'jwt_de_teste');
      expect(provider.statusAtual, 'Aguardando…');

      provider.debugSimularStatusRecebido({'id': 42, 'status': 'Em andamento'});

      expect(provider.statusAtual, 'Em andamento');
      expect(provider.reunioes[42]?.status, 'Em andamento');
      expect(provider.historico.first, contains('reunião 42'));
      expect(
        notificacoes,
        greaterThan(0),
        reason: 'a UI precisa ser notificada para redesenhar',
      );
    });

    test('aceita o campo alternativo novoStatus e ignora payload inválido', () {
      final provider = ReuniaoProvider();
      provider.entrarNaReuniao(7);

      provider.debugSimularStatusRecebido({'id': 7, 'novoStatus': 'Concluída'});
      expect(provider.statusAtual, 'Concluída');

      provider.debugSimularStatusRecebido('lixo');
      expect(provider.statusAtual, 'Concluída');
    });

    test('sairDaReuniao limpa a reunião atual', () {
      final provider = ReuniaoProvider();
      provider.entrarNaReuniao(99);
      expect(provider.reuniaoAtualId, 99);

      provider.sairDaReuniao();
      expect(provider.reuniaoAtualId, isNull);
    });
  });
}
