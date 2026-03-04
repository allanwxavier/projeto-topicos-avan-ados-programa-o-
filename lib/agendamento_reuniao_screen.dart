import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Necessário para formatar a data

// TODO: Lembre-se de alterar 'meu_projeto_faculdade' para o nome do seu projeto Flutter acadêmico
import 'package:meu_projeto_faculdade/components/functions/errorToken.dart';
import 'package:meu_projeto_faculdade/components/functions/openConfirmacao.dart';
import 'package:meu_projeto_faculdade/components/reuniao/checkBoxModel.dart';
import 'package:meu_projeto_faculdade/components/reuniao/flashReuniao.dart';
import 'package:meu_projeto_faculdade/components/widgets/dropdown_customer.dart';
import 'package:meu_projeto_faculdade/components/widgets/text_form_field.dart';
import 'package:meu_projeto_faculdade/components/widgets/toast.dart';
import 'package:meu_projeto_faculdade/dtos/user_dto.dart';
import 'package:meu_projeto_faculdade/views/eng_processo/reuniao.dart';

class CreateReuniaoScreen extends StatefulWidget {
  final int idCardAnterior;
  const CreateReuniaoScreen({super.key, required this.idCardAnterior});

  @override
  State<CreateReuniaoScreen> createState() => _CreateReuniaoScreenState();
}

class _CreateReuniaoScreenState extends State<CreateReuniaoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // URL base para o emulador Android acessar o localhost da sua máquina onde rodará o Spring Boot
  final String baseUrl = 'http://10.0.2.2:8080/api/v1';

  final List<Map<String, dynamic>> _selectLocal = [
    {'projeto_id': 1, 'projeto_nome_format': 'AUDITORIO'},
    {'projeto_id': 2, 'projeto_nome_format': 'AQUARIO'},
    {'projeto_id': 3, 'projeto_nome_format': 'ENGENHARIA / APOIO'},
    {'projeto_id': 4, 'projeto_nome_format': 'SALA COMERCIAL'},
    {'projeto_id': 5, 'projeto_nome_format': 'SALA SOLICITANTE'},
    {'projeto_id': 6, 'projeto_nome_format': 'OUTROS'},
  ];

  final _projetoController = TextEditingController();
  Map<String, dynamic>? usuariologado;
  User? user;
  final _idProjetoController = TextEditingController();
  final _localController = TextEditingController();
  final _assuntoController = TextEditingController();
  final _dataReuniaoController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFimController = TextEditingController();
  final _colaboradorSetorBuscaController = TextEditingController();
  
  var _listaUsuarios = [];
  var _listaCheckBox = [];
  final _listaParticipantes = [];
  List<dynamic> _selectProjeto = [];
  var inforPesquisaParticipante = '';
  bool _isLoadingColaboradores = false;

  @override
  void initState() {
    init();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _preencherCamposComHoraAtual();
      _adicionarUsuarioLogadoComoParticipante();
      await _getUser();
    });
  }

  Future init() async {
    await getProjetos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova Reunião',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Text(
              "Organize sua próxima reunião",
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        label: Text(
          "Criar Reunião",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(10),
          textStyle: TextStyle(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white10,
          child: Icon(
            Icons.event,
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) validar();
        },
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 20,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                DropdownCustomer(
                                  label: "Projeto",
                                  hinttext: "Selecione um projeto",
                                  icon: const Icon(Icons.circle,
                                      size: 12, color: Color(0xFF2ED573)),
                                  itens: _selectProjeto,
                                  onselect: (value) {
                                    _idProjetoController.text = value;
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  minLines: 3,
                                  maxLines: 3,
                                  controller: _assuntoController,
                                  keyboardType: TextInputType.text,
                                  readOnly: false,
                                  style: Theme.of(context).textTheme.labelMedium,
                                  decoration: InputDecoration(
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    label: Text(
                                      "Assunto",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    hintStyle: const TextStyle(
                                        color: Color.fromARGB(255, 91, 98, 106),
                                        fontSize: 12),
                                    hintText:
                                        "Descreva o que será discutido na reunião",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFE7E9ED),
                                            width: 2)),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE7E9ED), width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE7E9ED), width: 2),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 2)),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe o assunto';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                DropdownCustomer(
                                  label: "Local",
                                  hinttext: "Selecione um local",
                                  itens: _selectLocal,
                                  onselect: (value) {
                                    final selectNameItem =
                                        _selectLocal.firstWhere(
                                      (item) =>
                                          item['projeto_id'] ==
                                          int.parse(value),
                                      orElse: () => {},
                                    );
                                    _localController.text =
                                        selectNameItem['projeto_nome_format'];
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormFieldCustomer(
                                  label: "Data da reunião",
                                  hinttext: "//",
                                  controller: _dataReuniaoController,
                                  type: TextInputType.datetime,
                                  suffixicon: Icons.calendar_month,
                                  ontap: () => _selectDate(context),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextFormFieldCustomer(
                                        label: "Início",
                                        suffixicon: Icons.access_time,
                                        controller: _horaInicioController,
                                        type: TextInputType.datetime,
                                        ontap: () => _selectTimeInicio(context),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: TextFormFieldCustomer(
                                        label: "Término",
                                        suffixicon: Icons.access_time,
                                        controller: _horaFimController,
                                        type: TextInputType.datetime,
                                        ontap: () => _selectTimeInicio(context), // Alterado para timePicker
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Adicionar participantes:",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              openDialogAddParticipante();
                                            },
                                            icon: const Icon(Icons.add))
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Builder(builder: (context) {
                                      List<dynamic> listaParticipantes =
                                          _listaParticipantes.isNotEmpty
                                              ? List.from(
                                                  _listaParticipantes.where(
                                                      (item) => item.checked))
                                              : [];

                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8),
                                        child: listaParticipantes.isNotEmpty
                                            ? Wrap(
                                                spacing: 8,
                                                runSpacing: 10,
                                                children: listaParticipantes
                                                    .map((item) {
                                                  return listChip(
                                                    item,
                                                    (value) {
                                                      setState(() {
                                                        item.checked = value;
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              )
                                            : Center(
                                                child: Text(
                                                  "Nenhum participante adicionado",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                ),
                                              ),
                                      );
                                    }),
                                    const SizedBox(height: 60)
                                  ],
                                ),
                              ],
                            )
                          ],
                        )),
                  )),
            ),
            if (_isLoadingColaboradores)
              Positioned.fill(
                child: Container(
                  color: Colors.white54,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).secondaryHeaderColor),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future validar() async {
    DateTime? horaInicio = _converterParaTimeOfDay(_horaInicioController.text);
    DateTime? horaFim = _converterParaTimeOfDay(_horaFimController.text);

    if (horaInicio == null || horaFim == null) {
      // Implementação local do seu DialogHelper
      return; 
    }

    if (!_horaEhValida(horaInicio, horaFim)) {
       // Implementação local do seu DialogHelper
      return;
    }

    if (_localController.text.isEmpty || _assuntoController.text.isEmpty || _dataReuniaoController.text.isEmpty) {
       // Implementação local do seu DialogHelper
      return;
    }

    return openDialogIniciarReuniao();
  }

  Future openDialogIniciarReuniao() async {
    // A lógica visual do seu modal "Iniciar Reunião" original entra aqui
    // Para simplificar a execução direta, chamamos o setReuniao:
    await setReuniao();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _dataReuniaoController.text =
            "${picked.day.toString().padLeft(2, "0")}/${picked.month.toString().padLeft(2, "0")}/${picked.year}";
      });
    }
  }

  Future<void> _selectTimeInicio(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      setState(() {
        _horaInicioController.text = "${picked.hour.toString().padLeft(2, "0")}:${picked.minute.toString().padLeft(2, "0")}";
        _horaFimController.text = "${((picked.hour + 1) % 24).toString().padLeft(2, "0")}:${picked.minute.toString().padLeft(2, "0")}";
      });
    }
  }

  Future<void> getProjetos() async {
    var preferences = await SharedPreferences.getInstance();
    final userJson = preferences.getString('user');

    if (userJson != null) {
      final user = User.fromJson(json.decode(userJson));
      var url = Uri.parse('$baseUrl/projetos'); 
      
      try {
        var resposta = await http.get(
          url,
          headers: {'Authorization': 'Bearer ${user.token}'},
        );

        if (resposta.statusCode == 200) {
          setState(() {
            _selectProjeto = jsonDecode(resposta.body)['data'];
          });
        }
      } catch (e) {
        print('Erro ao buscar projetos locais: $e');
      }
    }
  }

  Future getUsuarios(String value, Function f) async {
    _listaUsuarios.clear();
    var preferences = await SharedPreferences.getInstance();
    final userJson = preferences.getString('user');

    if (userJson != null) {
      final user = User.fromJson(json.decode(userJson));
      var url = Uri.parse('$baseUrl/usuarios/busca?nome=$value');
      
      try {
        var resposta = await http.get(
          url,
          headers: {'Authorization': 'Bearer ${user.token}'},
        );

        if (resposta.statusCode == 200) {
          setState(() {
            _listaUsuarios = jsonDecode(resposta.body)['data'];
            f(() {
              inforPesquisaParticipante = 'Nenhum Colaborador Encontrado.';
              if (_listaUsuarios.isNotEmpty) {
                _listaCheckBox = _listaUsuarios
                    .where((r) => _listaParticipantes
                        .where((e) => e.idUsuario == r['id'])
                        .isEmpty)
                    .map((r) => CheckBoxModel(
                        idUsuario: r['id'],
                        texto: r['nome'],
                        idSetor: r['setor_id'],
                        nomeSetor: r['setor_nome'],
                        checked: false))
                    .toList();
              }
            });
          });
        }
      } catch (e) {
        print('Erro ao buscar usuários: $e');
      }
    }
  }

  Future<void> setReuniao() async {
    var preferences = await SharedPreferences.getInstance();
    final userJson = preferences.getString('user');
    var listaPart = _listaParticipantes.map((e) => e.toJson()).toList();

    if (userJson != null) {
      final user = User.fromJson(json.decode(userJson));

      String dataReuniaoText = _dataReuniaoController.text;
      DateTime dataReuniao = DateFormat('dd/MM/yyyy').parse(dataReuniaoText);
      String dataReuniaoFormatada = DateFormat('yyyy-MM-dd').format(dataReuniao);

      var url = Uri.parse('$baseUrl/reunioes');

      try {
        var resposta = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${user.token}'
          },
          body: json.encode({
            'projetoId': _idProjetoController.text,
            'dataReuniao': dataReuniaoFormatada,
            'horaInicio': _horaInicioController.text,
            'horaFim': _horaFimController.text,
            'local': _localController.text,
            'assunto': _assuntoController.text,
            'participantes': listaPart,
          }),
        );

        if (resposta.statusCode == 201 || resposta.statusCode == 200) {
            print("Sucesso! Redirecionando...");
            // Navigator.pushReplacement(...)
        } else {
            print("Erro ao criar reunião.");
        }
      } catch (e) {
          print("Erro de conexão: $e");
      }
    }
  }

  Future openDialogAddParticipante() async {
      // Implementação local do seu modal
  }

  InputChip listChip(item, f) {
    return InputChip(
      backgroundColor: item.idUsuario == user?.id ? Colors.green[100] : null,
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.texto ?? "Sem nome",
            style: const TextStyle(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Setor: ${item.nomeSetor}",
            style: const TextStyle(color: Color(0xFF5B626A), fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      avatar: const CircleAvatar(
        radius: 15,
        child: Icon(Icons.person, size: 15), // Modificado para não puxar imagem local sem API pronta
      ),
      deleteIcon: const Icon(Icons.close, size: 18, color: Colors.red),
      onDeleted: () {
        setState(() {
          _listaParticipantes.remove(item);
        });
      },
    );
  }

  DateTime? _converterParaTimeOfDay(String time) {
    if (time.isEmpty) return null;
    try {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  bool _horaEhValida(DateTime inicio, DateTime fim) {
    return inicio.isBefore(fim);
  }

  Future<void> _getUser() async {
    var preferences = await SharedPreferences.getInstance();
    final userShard = preferences.getString('user');
    if (userShard != null) {
      setState(() {
        user = User.fromJson(json.decode(userShard));
      });
    }
  }

  Future<void> _adicionarUsuarioLogadoComoParticipante() async {
    // Lógica para adicionar o criador como participante default
  }

  void _preencherCamposComHoraAtual() {
    DateTime agora = DateTime.now();
    TimeOfDay horaAgora = TimeOfDay(hour: agora.hour, minute: agora.minute);
    TimeOfDay horaFinal = TimeOfDay(hour: (agora.hour + 1) % 24, minute: agora.minute);

    _horaInicioController.text = "${horaAgora.hour.toString().padLeft(2, "0")}:${horaAgora.minute.toString().padLeft(2, "0")}";
    _horaFimController.text = "${horaFinal.hour.toString().padLeft(2, "0")}:${horaFinal.minute.toString().padLeft(2, "0")}";
  }
}