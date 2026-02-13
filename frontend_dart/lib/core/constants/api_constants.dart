class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String auth = '/auth';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String payments = '/payments';
}
