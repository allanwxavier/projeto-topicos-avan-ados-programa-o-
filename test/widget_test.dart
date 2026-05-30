import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:meu_projeto_faculdade/main.dart';
import 'package:meu_projeto_faculdade/providers/auth_provider.dart';
import 'package:meu_projeto_faculdade/providers/kanban_provider.dart';
import 'package:meu_projeto_faculdade/providers/reuniao_provider.dart';

void main() {
  testWidgets('Smoke test da tela de Login', (WidgetTester tester) async {
    // Pede pro Flutter "desenhar" o nosso app inteiro na memória com os Providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => KanbanProvider()),
          ChangeNotifierProvider(create: (_) => ReuniaoProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Espera um pouco para a tela renderizar, mas não usamos pumpAndSettle
    // porque o GradientBackground tem uma animação infinita (repeat), o que
    // causa timeout no pumpAndSettle.
    await tester.pump(const Duration(seconds: 2));

    // Procura por textos que sabemos que existem na tela de Login
    expect(find.text('MeetSync'), findsWidgets);
    expect(find.text('Entrar'), findsWidgets);
    expect(find.text('Usuário'), findsWidgets);
  });
}