import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dtos/user_dto.dart'; 

Future addUsuarioReuniao(idReuniao, idParticipante) async {
  var preferences = await SharedPreferences.getInstance();
  final userJson = preferences.getString('user');
  if (userJson == null) return {'data': false, 'message': 'Sessão expirada'};

  final user = User.fromJson(json.decode(userJson));
  var url = Uri.parse('http://10.0.2.2:8080/api/v1/reuniao/participantes/adicionar');
  
  var resposta = await http.post(url, body: {
    'token': user.token,
    'idReuniao': idReuniao.toString(),
    'idParticipante': idParticipante.toString()
  });

  if (resposta.statusCode == 200) {
    var data = jsonDecode(resposta.body);
    return {'data': data['status'] == 'ok', 'message': data['message'] ?? ''};
  }
  return {'data': false, 'message': 'Erro na conexão'};
}