import 'package:flutter/material.dart';
import 'package:meu_projeto_faculdade/agendamento_reuniao_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Reuniões',
      debugShowCheckedModeBanner: false, // Tira aquela faixa de "DEBUG" da tela
      theme: ThemeData(
        primaryColor: Colors.white,
        // Cor principal usada nos botões e cabeçalhos no seu design
        secondaryHeaderColor: const Color(0xFF537686), 
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          labelMedium: TextStyle(fontSize: 14, color: Colors.black87),
          labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF537686)),
        useMaterial3: true,
      ),
      // Inicia o app direto na sua tela. Passando 0 como ID inicial genérico.
      home: const CreateReuniaoScreen(idCardAnterior: 0),
    );
  }
}