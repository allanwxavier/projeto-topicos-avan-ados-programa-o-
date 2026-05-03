import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_projeto_faculdade/agendamento_reuniao_screen.dart';
import 'package:meu_projeto_faculdade/theme/app_theme.dart';
import 'package:meu_projeto_faculdade/providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..mockLogin()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Reuniões',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CreateReuniaoScreen(idCardAnterior: 0),
    );
  }
}
