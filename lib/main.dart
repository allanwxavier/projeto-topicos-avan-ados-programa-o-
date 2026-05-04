import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_projeto_faculdade/theme/app_theme.dart';
import 'package:meu_projeto_faculdade/providers/auth_provider.dart';
import 'package:meu_projeto_faculdade/providers/kanban_provider.dart';
import 'package:meu_projeto_faculdade/presentation/screens/login_screen.dart';
import 'package:meu_projeto_faculdade/presentation/screens/kanban_board_screen.dart';
import 'package:meu_projeto_faculdade/agendamento_reuniao_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KanbanProvider()),
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
      title: 'MeetSync — Gestão de Projetos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/board': (_) => const KanbanBoardScreen(),
        '/reunioes': (_) => const CreateReuniaoScreen(idCardAnterior: 0),
      },
    );
  }
}
