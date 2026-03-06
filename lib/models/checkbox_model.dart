class CheckBoxModel {
  int idUsuario;
  String texto;
  int idSetor;
  String nomeSetor;
  bool checked;

  CheckBoxModel({
    required this.idUsuario,
    required this.texto,
    required this.idSetor,
    required this.nomeSetor,
    this.checked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'nome': texto,
      'idSetor': idSetor,
      'nomeSetor': nomeSetor,
    };
  }
}