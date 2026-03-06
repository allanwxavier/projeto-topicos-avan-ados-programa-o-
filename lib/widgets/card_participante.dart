import 'package:flutter/material.dart';

Widget montarCardParticipante(dynamic participante, VoidCallback onRemove) {
  return ListTile(
    leading: const CircleAvatar(child: Icon(Icons.person)),
    title: Text(participante['nome'] ?? 'Participante'),
    subtitle: Text("Setor: ${participante['nomeSetor'] ?? 'Acadêmico'}"),
    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onRemove),
  );
}