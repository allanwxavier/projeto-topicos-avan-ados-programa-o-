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
    required this.checked,
  });

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'texto': texto,
      'idSetor': idSetor,
      'nomeSetor': nomeSetor,
      'checked': checked,
    };
  }
}