//API 서버의 기본 URL을 정의한 파일이다.
class ApiConfig {
  static const String baseUrl = 'https://dooor.duckdns.org/api';
  static const String login = '$baseUrl/user/login';
  static const int maxRetries = 3;
  static const int connectionTimeout = 30;
  static const int retryDelay = 2;
}
