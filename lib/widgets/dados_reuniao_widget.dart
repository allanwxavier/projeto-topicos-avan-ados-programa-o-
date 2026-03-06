import 'package:flutter/material.dart';

class DadosReuniaoWidget extends StatelessWidget {
  final String assunto;
  final String local;
  final String data;
  final String horaInicio;
  final String horaFim;

  const DadosReuniaoWidget({
    super.key, required this.assunto, required this.local, 
    required this.data, required this.horaInicio, required this.horaFim
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(Icons.subject, "Assunto", assunto),
        _buildRow(Icons.location_on, "Local", local),
        _buildRow(Icons.calendar_today, "Data", data),
        _buildRow(Icons.access_time, "Horário", "$horaInicio - $horaFim"),
      ],
    );
  }

  Widget _buildRow(IconData icon, String label, String val) {
    return ListTile(leading: Icon(icon), title: Text(label), subtitle: Text(val));
  }
}