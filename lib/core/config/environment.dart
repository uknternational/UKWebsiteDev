enum Environment { staging, production }

class EnvironmentConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String apiBaseUrl;
  final String environmentName;

  const EnvironmentConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.apiBaseUrl,
    required this.environmentName,
  });

  static EnvironmentConfig get current => _current;
  static late EnvironmentConfig _current;

  static void initialize(Environment env) {
    _current = _getConfig(env);
  }

  static EnvironmentConfig _getConfig(Environment env) {
    switch (env) {
      case Environment.staging:
        return const EnvironmentConfig(
          supabaseUrl: 'https://hefmjgtblqxclbbtvckb.supabase.co',
          supabaseAnonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhlZm1qZ3RibHF4Y2xiYnR2Y2tiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4MDQ3MTIsImV4cCI6MjA2NDM4MDcxMn0.tuP2qrfy9eMAKLSLe4DLov5xx5QBIKhZZxYRiZHQ63E',
          apiBaseUrl: 'https://staging-api.ukinternationalperfumes.com',
          environmentName: 'Staging',
        );
      case Environment.production:
        return const EnvironmentConfig(
          supabaseUrl: 'https://ubeipwoxlrbtttvswkbp.supabase.co',
          supabaseAnonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InViZWlwd294bHJidHR0dnN3a2JwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5MjgyOTgsImV4cCI6MjA2NDUwNDI5OH0.opltCZxguL1VW7bc0ljvdAirZmqZQ8-OgwjS9Afwq5s',
          apiBaseUrl: 'https://api.ukinternationalperfumes.com',
          environmentName: 'Production',
        );
    }
  }
}
