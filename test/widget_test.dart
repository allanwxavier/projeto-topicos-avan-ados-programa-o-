import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:meu_projeto_faculdade/main.dart';
import 'package:meu_projeto_faculdade/providers/auth_provider.dart';
import 'package:meu_projeto_faculdade/providers/kanban_provider.dart';
import 'package:meu_projeto_faculdade/providers/reuniao_provider.dart';

void main() {
  testWidgets('Smoke test: o app sobe na tela de login (MeetSync)',
      (WidgetTester tester) async {
    // Reproduz a árvore de main(): MyApp NÃO embrulha os providers sozinho,
    // então precisamos fornecê-los aqui para evitar ProviderNotFoundException.
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

    // IMPORTANTE: não usar pumpAndSettle(). A LoginScreen usa GradientBackground
    // e NeonButton, que têm animações .repeat() (infinitas) — pumpAndSettle
    // ficaria preso esperando elas "assentarem" e estouraria timeout no CI.
    // Avançamos alguns frames manualmente para o fade inicial (1200ms) rodar.
    await tester.pump(); // primeiro frame
    await tester.pump(const Duration(milliseconds: 1300));

    // A tela inicial é a /login, cujo título é "MeetSync".
    expect(find.text('MeetSync'), findsOneWidget);
    expect(find.text('Gerencie seus projetos em tempo real'), findsOneWidget);
  });
}