abstract class AuthTokenStorage {
  Future<String?> readToken();

  Future<String?> readRefreshToken();

  Future<void> writeToken(String token);

  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearToken();
}
