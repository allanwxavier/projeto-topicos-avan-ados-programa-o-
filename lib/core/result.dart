/// Classe genérica [Result] para padronizar retornos de operações.
/// Encapsula sucesso ou falha, eliminando a necessidade de try/catch em camadas superiores.
sealed class Result<T> {
  const Result();

  /// Cria um resultado de sucesso.
  factory Result.success(T data) = ResultSuccess<T>;

  /// Cria um resultado de falha.
  factory Result.failure(String message, {int? statusCode}) = ResultFailure<T>;

  /// Verifica se o resultado é sucesso.
  bool get isSuccess => this is ResultSuccess<T>;

  /// Verifica se o resultado é falha.
  bool get isFailure => this is ResultFailure<T>;

  /// Retorna os dados (lança exceção se for falha).
  T get data => (this as ResultSuccess<T>).value;

  /// Retorna a mensagem de erro (lança exceção se for sucesso).
  String get errorMessage => (this as ResultFailure<T>).message;

  /// Pattern matching funcional.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) {
    if (this is ResultSuccess<T>) {
      return success((this as ResultSuccess<T>).value);
    } else {
      final fail = this as ResultFailure<T>;
      return failure(fail.message, fail.statusCode);
    }
  }
}

/// Resultado de sucesso contendo o valor retornado.
class ResultSuccess<T> extends Result<T> {
  final T value;
  const ResultSuccess(this.value);
}

/// Resultado de falha contendo mensagem e código HTTP opcional.
class ResultFailure<T> extends Result<T> {
  final String message;
  final int? statusCode;
  const ResultFailure(this.message, {this.statusCode});
}
