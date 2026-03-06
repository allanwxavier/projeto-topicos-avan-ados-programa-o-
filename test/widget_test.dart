import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// O import principal do seu app
import 'package:meu_projeto_faculdade/main.dart';

void main() {
  testWidgets('Smoke test da tela de Nova Reunião', (WidgetTester tester) async {
    // 1. Pede pro Flutter "desenhar" o nosso app inteiro na memória
    await tester.pumpWidget(const MyApp());

    // 2. Espera todas as animações de carregamento terminarem
    await tester.pumpAndSettle();

    // 3. Procura algum texto que sabemos que existe na nossa tela inicial.
    // Baseado no seu código, a AppBar da tela inicial tem o texto "Nova Reunião"
    expect(find.text('Nova Reunião'), findsWidgets);
    
    // Podemos também verificar se o campo de "Assunto" está lá!
    expect(find.text('Assunto'), findsWidgets);
  });
}