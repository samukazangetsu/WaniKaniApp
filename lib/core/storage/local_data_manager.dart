import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gerenciador de armazenamento local seguro para dados sensíveis.
///
/// Utiliza [FlutterSecureStorage] para criptografar dados no dispositivo:
/// - Android: EncryptedSharedPreferences
/// - iOS: Keychain
class LocalDataManager {
  final FlutterSecureStorage _secureStorage;

  /// Chave utilizada para armazenar o token da API WaniKani.
  static const String _tokenKey = 'wanikani_api_token';

  /// Cria uma instância de [LocalDataManager].
  ///
  /// [secureStorage] pode ser injetado para facilitar testes (mock).
  LocalDataManager({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Salva o token de API do WaniKani de forma segura.
  ///
  /// Exemplo:
  /// ```dart
  /// await localDataManager.saveToken('abc12345-1234-1234-1234-123456789012');
  /// ```
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Recupera o token de API armazenado.
  ///
  /// Retorna `null` se nenhum token foi salvo anteriormente.
  ///
  /// Exemplo:
  /// ```dart
  /// final token = await localDataManager.getToken();
  /// if (token != null) {
  ///   // Usuário já fez login
  /// }
  /// ```
  Future<String?> getToken() async => await _secureStorage.read(key: _tokenKey);

  /// Remove o token de API armazenado (logout).
  ///
  /// Exemplo:
  /// ```dart
  /// await localDataManager.deleteToken();
  /// ```
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Verifica se existe um token armazenado.
  ///
  /// Útil para determinar se o usuário já fez login.
  ///
  /// Exemplo:
  /// ```dart
  /// final hasToken = await localDataManager.hasToken();
  /// final initialRoute = hasToken ? '/home' : '/login';
  /// ```
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
