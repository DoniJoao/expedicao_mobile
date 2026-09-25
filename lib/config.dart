class ApiConfig {
  /// URL base da API. Troque AQUI quando for testar em rede local ou servidor real.
  ///
  /// - Windows Desktop / Web: 'http://localhost/expedicao_db'
  /// - Emulador Android: 'http://10.0.2.2/expedicao_db'
  /// - Celular físico na rede local: 'http://192.168.X.X/expedicao_db'
  static const String baseUrl = 'http://localhost/expedicao_db';

  /// Atalho pra montar URLs de endpoint.
  static Uri endpoint(String path) => Uri.parse('$baseUrl/$path');
}