import 'package:flutter/material.dart';
import '/widgets/flash_reuniao.dart';
import 'package:meu_projeto_faculdade/presentation/dialogs/confirmacao_reuniao_dialog.dart';

class CreateReuniaoScreen extends StatefulWidget {
  final int idCardAnterior;
  const CreateReuniaoScreen({super.key, required this.idCardAnterior});

  @override
  State<CreateReuniaoScreen> createState() => _CreateReuniaoScreenState();
}

class _CreateReuniaoScreenState extends State<CreateReuniaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _assuntoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Reunião"), backgroundColor: const Color(0xFF537686)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _assuntoController, decoration: const InputDecoration(labelText: "Assunto")),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _prosseguir, child: const Text("Agendar")),
          ],
        ),
      ),
    );
  }

  void _prosseguir() {
    if (_formKey.currentState!.validate()) {
      openDialogDadosReuniao(context, {'assunto': _assuntoController.text, 'local': 'Auditório', 'data': '05/03/2026', 'horaInicio': '14:00', 'horaFim': '15:00'}, () {
        FlashReuniao.show(context, "Reunião agendada com sucesso!");
      });
    }
  }
}