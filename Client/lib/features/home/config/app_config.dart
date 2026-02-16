enum Environment { dev, prod }

class AppConfig {
  static Environment _environment = Environment.dev;
  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        // Android Emulator loopback or local IP
        return 'http://127.0.0.1:8000/api'; 
      case Environment.prod:
        // Placeholder for production URL
        return 'https://api.geminiwrapped.com/api';
    }
  }

  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static bool get isDev => _environment == Environment.dev;
}
