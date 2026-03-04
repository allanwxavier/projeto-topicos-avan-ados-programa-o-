import 'package:flutter/material.dart';

class DropdownCustomer extends StatelessWidget {
  final String label;
  final String hinttext;
  final Icon? icon;
  final List<dynamic> itens;
  final Function(String) onselect;

  const DropdownCustomer({
    super.key,
    required this.label,
    required this.hinttext,
    this.icon,
    required this.itens,
    required this.onselect,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hinttext,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 91, 98, 106), fontSize: 12),
        prefixIcon: icon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE7E9ED), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE7E9ED), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      // Mapeando a lista dinâmica para as opções do Dropdown
      items: itens.map<DropdownMenuItem<String>>((dynamic item) {
        // Pega o ID e o Nome baseado na estrutura de dados que você definiu
        String value = item['projeto_id'].toString();
        String description = item['projeto_nome_format'] ?? 'Sem nome';

        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onselect(newValue);
        }
      },
      validator: (value) => value == null ? 'Por favor, selecione uma opção' : null,
    );
  }
}