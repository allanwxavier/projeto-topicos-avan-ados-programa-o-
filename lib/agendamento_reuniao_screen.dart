import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// DTOs e Models locais (certifique-se de que os caminhos abaixo existam ou coloque-os na mesma pasta)
import 'package:meu_projeto_faculdade/dtos/user_dto.dart';
import 'package:meu_projeto_faculdade/reuniao/checkBoxModel.dart';
import 'package:meu_projeto_faculdade/widgets/dropdown_customer.dart';
import 'package:meu_projeto_faculdade/widgets/text_form_field.dart';

class CreateReuniaoScreen extends StatefulWidget {
  final int idCardAnterior;
  const CreateReuniaoScreen({super.key, required this.idCardAnterior});

  @override
  State<CreateReuniaoScreen> createState() => _CreateReuniaoScreenState();
}

class _CreateReuniaoScreenState extends State<CreateReuniaoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // URL genérica para fins acadêmicos
  final String baseUrl = 'http://10.0.2.2:8080/api/v1';

  final List<Map<String, dynamic>> _selectLocal = [
    {'projeto_id': 1, 'projeto_nome_format': 'AUDITÓRIO'},
    {'projeto_id': 2, 'projeto_nome_format': 'AQUÁRIO'},
    {'projeto_id': 3, 'projeto_nome_format': 'ENGENHARIA / APOIO'},
    {'projeto_id': 4, 'projeto_nome_format': 'SALA COMERCIAL'},
    {'projeto_id': 5, 'projeto_nome_format': 'SALA SOLICITANTE'},
    {'projeto_id': 6, 'projeto_nome_format': 'OUTROS'},
  ];

  User? user;
  final _idProjetoController = TextEditingController();
  final _localController = TextEditingController();
  final _assuntoController = TextEditingController();
  final _dataReuniaoController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFimController = TextEditingController();
  final _buscaParticipanteController = TextEditingController();
  
  List<dynamic> _listaUsuariosBusca = [];
  final List<CheckBoxModel> _listaParticipantes = [];
  List<dynamic> _selectProjeto = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preencherCamposIniciais();
    _carregarDadosIniciais();
  }

  void _preencherCamposIniciais() {
    DateTime agora = DateTime.now();
    _dataReuniaoController.text = DateFormat('dd/MM/yyyy').format(agora);
    _horaInicioController.text = DateFormat('HH:mm').format(agora);
    _horaFimController.text = DateFormat('HH:mm').format(agora.add(const Duration(hours: 1)));
  }

  Future<void> _carregarDadosIniciais() async {
    await _getUser();
    await getProjetos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF537686),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nova Reunião', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Organize sua próxima reunião", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF537686),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownCustomer(
                            label: "Projeto",
                            hinttext: "Selecione um projeto",
                            icon: const Icon(Icons.search, size: 18),
                            itens: _selectProjeto.isEmpty ? [{'projeto_id': 0, 'projeto_nome_format': 'Projeto Acadêmico X'}] : _selectProjeto,
                            onselect: (val) => _idProjetoController.text = val,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _assuntoController,
                            maxLines: 3,
                            decoration: _inputDecoration("Assunto", "Descreva o que será discutido"),
                            validator: (v) => v!.isEmpty ? 'Informe o assunto' : null,
                          ),
                          const SizedBox(height: 15),
                          DropdownCustomer(
                            label: "Local",
                            hinttext: "Selecione um local",
                            itens: _selectLocal,
                            onselect: (val) {
                              final item = _selectLocal.firstWhere((e) => e['projeto_id'].toString() == val);
                              _localController.text = item['projeto_nome_format'];
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormFieldCustomer(
                            label: "Data da reunião",
                            hinttext: "dd/mm/aaaa",
                            controller: _dataReuniaoController,
                            type: TextInputType.datetime,
                            suffixicon: Icons.calendar_today,
                            ontap: () => _selectDate(context),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormFieldCustomer(
                                  label: "Início",
                                  hinttext: "00:00",
                                  controller: _horaInicioController,
                                  type: TextInputType.datetime,
                                  suffixicon: Icons.access_time,
                                  ontap: () => _selectTime(context, _horaInicioController),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: TextFormFieldCustomer(
                                  label: "Término",
                                  hinttext: "01:00",
                                  controller: _horaFimController,
                                  type: TextInputType.datetime,
                                  suffixicon: Icons.access_time,
                                  ontap: () => _selectTime(context, _horaFimController),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _sectionParticipantes(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _sectionParticipantes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Adicionar participantes:", style: TextStyle(fontWeight: FontWeight.bold)),
            IconButton(onPressed: openDialogAddParticipante, icon: const Icon(Icons.add_circle, color: Color(0xFF537686))),
          ],
        ),
        _listaParticipantes.isEmpty
            ? const Center(child: Text("Nenhum participante adicionado", style: TextStyle(fontSize: 12, color: Colors.grey)))
            : Wrap(
                spacing: 8,
                children: _listaParticipantes.map((p) => Chip(
                  label: Text(p.texto, style: const TextStyle(fontSize: 11)),
                  onDeleted: () => setState(() => _listaParticipantes.remove(p)),
                )).toList(),
              ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF537686),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        icon: const Icon(Icons.calendar_today_outlined),
        label: const Text("Criar Reunião", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () {
          if (_formKey.currentState!.validate()) setReuniao();
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFFE7E9ED))),
    );
  }

  // --- Lógica de Data e Hora ---

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (picked != null) setState(() => _dataReuniaoController.text = DateFormat('dd/MM/yyyy').format(picked));
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
  }

  // --- Chamadas de API (Com Mock para Fallback) ---

  Future<void> getProjetos() async {
    // Simulação para o trabalho da faculdade não quebrar sem internet/backend
    setState(() {
      _selectProjeto = [
        {'projeto_id': 1, 'projeto_nome_format': 'Projeto Integrador I'},
        {'projeto_id': 2, 'projeto_nome_format': 'Desenvolvimento Mobile'},
      ];
    });
  }

  Future<void> setReuniao() async {
    // Aqui você faria o POST. Para a faculdade, vamos apenas simular o sucesso:
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sucesso!"),
        content: const Text("Reunião agendada com sucesso."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  void openDialogAddParticipante() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Adicionar Participante", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _buscaParticipanteController,
              decoration: const InputDecoration(labelText: "Nome do aluno/colaborador"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _listaParticipantes.add(CheckBoxModel(
                    idUsuario: 99, 
                    texto: _buscaParticipanteController.text, 
                    idSetor: 1, 
                    nomeSetor: "Geral", 
                    checked: true
                  ));
                });
                _buscaParticipanteController.clear();
                Navigator.pop(context);
              },
              child: const Text("Adicionar"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _getUser() async {
    var preferences = await SharedPreferences.getInstance();
    final userShard = preferences.getString('user');
    if (userShard != null) {
      setState(() => user = User.fromJson(json.decode(userShard)));
    }
  }
}