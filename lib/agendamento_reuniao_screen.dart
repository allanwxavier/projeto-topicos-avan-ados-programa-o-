import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meu_projeto_faculdade/providers/auth_provider.dart';
import 'package:meu_projeto_faculdade/repositories/reuniao_api_repository.dart';

import 'package:meu_projeto_faculdade/dtos/user_dto.dart';
import 'package:meu_projeto_faculdade/reuniao/checkbox_model.dart';
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
  final ReuniaoApiRepository _repo = ReuniaoApiRepository();

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

  final List<CheckBoxModel> _listaParticipantes = [];
  List<dynamic> _selectProjeto = [];

  // --- Estado da listagem ---
  List<dynamic> _reunioes = [];
  bool _loadingReunioes = true;
  bool _showForm = false;

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
    _horaFimController.text = DateFormat(
      'HH:mm',
    ).format(agora.add(const Duration(hours: 1)));
  }

  Future<void> _carregarDadosIniciais() async {
    await _getUser();
    await getProjetos();
    await _carregarReunioes();
  }

  Future<void> _carregarReunioes() async {
    setState(() => _loadingReunioes = true);
    try {
      final lista = await _repo.getReunioes();
      if (mounted) {
        setState(() {
          _reunioes = lista;
          _loadingReunioes = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar reuniões: $e');
      if (mounted) {
        setState(() => _loadingReunioes = false);
      }
    }
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
            Text(
              'Reuniões',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Gerencie suas reuniões",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarReunioes,
            tooltip: 'Atualizar lista',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header curvado
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF537686),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),

            // --- Seção de Listagem ---
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da seção
                    const Padding(
                      padding: EdgeInsets.only(left: 5, bottom: 10),
                      child: Text(
                        'Reuniões Agendadas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF537686),
                        ),
                      ),
                    ),

                    // Lista de reuniões
                    _buildListaReunioes(),

                    const SizedBox(height: 15),

                    // Botão para mostrar/esconder formulário
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _showForm = !_showForm);
                        },
                        icon: Icon(
                          _showForm ? Icons.expand_less : Icons.add,
                          size: 20,
                        ),
                        label: Text(
                          _showForm
                              ? 'Esconder Formulário'
                              : 'Nova Reunião',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF537686),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // --- Formulário de Criação (colapsável) ---
                    if (_showForm) _buildFormularioCriacao(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widget da lista ----------
  Widget _buildListaReunioes() {
    if (_loadingReunioes) {
      return const Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF537686),
            ),
          ),
        ),
      );
    }

    if (_reunioes.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'Nenhuma reunião agendada',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Clique em "Nova Reunião" para criar uma.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reunioes.length,
      itemBuilder: (context, index) {
        final reuniao = _reunioes[index];
        return _buildReuniaoCard(reuniao);
      },
    );
  }

  Widget _buildReuniaoCard(dynamic reuniao) {
    final assunto = reuniao['assunto'] ?? 'Sem assunto';
    final local = reuniao['local'] ?? 'Sem local';
    final data = reuniao['data'] ?? '';
    final horaInicio = reuniao['horaInicio'] ?? '';
    final horaFim = reuniao['horaFim'] ?? '';
    final status = reuniao['status'] ?? 'agendada';

    Color statusColor;
    switch (status.toString().toLowerCase()) {
      case 'em andamento':
        statusColor = Colors.orange;
        break;
      case 'finalizada':
      case 'concluida':
        statusColor = Colors.green;
        break;
      case 'cancelada':
        statusColor = Colors.red;
        break;
      default:
        statusColor = const Color(0xFF537686);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha 1: Assunto + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    assunto,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (String novoStatus) {
                    final int id = reuniao['id'] is int ? reuniao['id'] : int.tryParse(reuniao['id'].toString()) ?? 0;
                    _atualizarStatus(id, novoStatus);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'agendada',
                      child: Text('Agendada'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'em andamento',
                      child: Text('Em Andamento'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'concluida',
                      child: Text('Concluída'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'cancelada',
                      child: Text('Cancelada'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusColor.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          status.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 14, color: statusColor),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: () => _showEditDialog(reuniao),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  onPressed: () {
                    final int id = reuniao['id'] is int ? reuniao['id'] : int.tryParse(reuniao['id'].toString()) ?? 0;
                    _confirmarExclusao(id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Linha 2: Local
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  local,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Linha 3: Data + Horário
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  data,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(width: 15),
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  '$horaInicio - $horaFim',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widget do formulário ----------
  Widget _buildFormularioCriacao() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Nova Reunião',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF537686),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              DropdownCustomer(
                label: "Projeto",
                hinttext: "Selecione um projeto",
                icon: const Icon(Icons.search, size: 18),
                itens: _selectProjeto.isEmpty
                    ? [
                        {
                          'projeto_id': 0,
                          'projeto_nome_format':
                              'Projeto Acadêmico X',
                        },
                      ]
                    : _selectProjeto,
                onselect: (val) => _idProjetoController.text = val,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _assuntoController,
                maxLines: 3,
                decoration: _inputDecoration(
                  "Assunto",
                  "Descreva o que será discutido",
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Informe o assunto' : null,
              ),
              const SizedBox(height: 15),
              DropdownCustomer(
                label: "Local",
                hinttext: "Selecione um local",
                itens: _selectLocal,
                onselect: (val) {
                  final item = _selectLocal.firstWhere(
                    (e) => e['projeto_id'].toString() == val,
                  );
                  _localController.text =
                      item['projeto_nome_format'];
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
                      ontap: () => _selectTime(
                        context,
                        _horaInicioController,
                      ),
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
                      ontap: () =>
                          _selectTime(context, _horaFimController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionParticipantes(),
              const SizedBox(height: 20),
              // Botão de criar
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF537686),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text(
                  "Criar Reunião",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) setReuniao();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionParticipantes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Adicionar participantes:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: openDialogAddParticipante,
              icon: const Icon(Icons.add_circle, color: Color(0xFF537686)),
            ),
          ],
        ),
        _listaParticipantes.isEmpty
            ? const Center(
                child: Text(
                  "Nenhum participante adicionado",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )
            : Wrap(
                spacing: 8,
                children: _listaParticipantes
                    .map(
                      (p) => Chip(
                        label: Text(
                          p.texto,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onDeleted: () =>
                            setState(() => _listaParticipantes.remove(p)),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFE7E9ED)),
      ),
    );
  }

  Future<void> _atualizarStatus(int id, String novoStatus) async {
    final resultado = await _repo.atualizarStatusReuniao(id, novoStatus);
    if (resultado != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para $novoStatus')),
      );
      _carregarReunioes();
    }
  }

  Future<void> _confirmarExclusao(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Reunião'),
        content: const Text('Tem certeza que deseja excluir esta reunião? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _repo.deletarReuniao(id);
      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reunião excluída com sucesso!')),
        );
        _carregarReunioes();
      }
    }
  }

  void _showEditDialog(dynamic reuniao) {
    final int id = reuniao['id'] is int ? reuniao['id'] : int.tryParse(reuniao['id'].toString()) ?? 0;
    final editAssuntoCtrl = TextEditingController(text: reuniao['assunto']);
    final editLocalCtrl = TextEditingController(text: reuniao['local']);
    final editDataCtrl = TextEditingController(text: reuniao['data']);
    final editHoraInicioCtrl = TextEditingController(text: reuniao['horaInicio']);
    final editHoraFimCtrl = TextEditingController(text: reuniao['horaFim']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Reunião'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: editAssuntoCtrl,
                  decoration: const InputDecoration(labelText: 'Assunto'),
                ),
                TextFormField(
                  controller: editLocalCtrl,
                  decoration: const InputDecoration(labelText: 'Local'),
                ),
                TextFormField(
                  controller: editDataCtrl,
                  decoration: const InputDecoration(labelText: 'Data (dd/mm/aaaa)'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: editHoraInicioCtrl,
                        decoration: const InputDecoration(labelText: 'Início'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: editHoraFimCtrl,
                        decoration: const InputDecoration(labelText: 'Fim'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await _repo.atualizarReuniao(
                  id: id,
                  assunto: editAssuntoCtrl.text,
                  local: editLocalCtrl.text,
                  data: editDataCtrl.text,
                  horaInicio: editHoraInicioCtrl.text,
                  horaFim: editHoraFimCtrl.text,
                );
                if (result != null && mounted) {
                  Navigator.pop(context);
                  _carregarReunioes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reunião atualizada com sucesso')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(
        () => _dataReuniaoController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked),
      );
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(
        () => controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}",
      );
    }
  }

  Future<void> getProjetos() async {
    setState(() {
      _selectProjeto = [
        {'projeto_id': 1, 'projeto_nome_format': 'Projeto Integrador I'},
        {'projeto_id': 2, 'projeto_nome_format': 'Desenvolvimento Mobile'},
      ];
    });
  }

  Future<void> setReuniao() async {
    final resultado = await _repo.criarReuniao(
      assunto: _assuntoController.text,
      local: _localController.text,
      data: _dataReuniaoController.text,
      horaInicio: _horaInicioController.text,
      horaFim: _horaFimController.text,
    );

    if (!mounted) return;

    if (resultado != null) {
      // Limpa o formulário
      _assuntoController.clear();
      _localController.clear();
      _preencherCamposIniciais();

      // Recarrega a lista de reuniões
      await _carregarReunioes();

      // Fecha o formulário
      setState(() => _showForm = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sucesso!"),
          content: const Text("Reunião agendada com sucesso."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o dialog
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao criar reunião. Verifique a conexão.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void openDialogAddParticipante() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Adicionar Participante",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _buscaParticipanteController,
              decoration: const InputDecoration(
                labelText: "Nome do aluno/colaborador",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _listaParticipantes.add(
                    CheckBoxModel(
                      idUsuario: 99,
                      texto: _buscaParticipanteController.text,
                      idSetor: 1,
                      nomeSetor: "Geral",
                      checked: true,
                    ),
                  );
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.tryAutoLogin();

    if (mounted) {
      setState(() => user = authProvider.user);
    }
  }
}
