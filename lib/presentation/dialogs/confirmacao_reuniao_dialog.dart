import 'package:flutter/material.dart';
import '/widgets/dados_reuniao_widget.dart';

void openDialogDadosReuniao(BuildContext context, Map<String, dynamic> dados, Function onConfirm) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Revisar Agendamento"),
      content: DadosReuniaoWidget(
        assunto: dados['assunto'], local: dados['local'], data: dados['data'],
        horaInicio: dados['horaInicio'], horaFim: dados['horaFim'],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Editar")),
        ElevatedButton(onPressed: () { Navigator.pop(context); onConfirm(); }, child: const Text("Confirmar")),
      ],
    ),
  );
}