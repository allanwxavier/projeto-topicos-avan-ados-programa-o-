import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dtos/user_dto.dart';

Future getParticipantes(idReuniao) async {
  var preferences = await SharedPreferences.getInstance();
  final userJson = preferences.getString('user');
  if (userJson == null) return null;

  final user = User.fromJson(json.decode(userJson));
  var url = Uri.parse('http://10.0.2.2:8080/api/v1/reuniao/participantes/listar');
  
  var resposta = await http.post(url, body: {
    'idReuniao': idReuniao.toString(),
    'token': user.token,
  });

  if (resposta.statusCode == 200) {
    var decoded = jsonDecode(resposta.body);
    if (decoded['status'] == 'ok') return decoded['data'];
  }
  return null;
}
