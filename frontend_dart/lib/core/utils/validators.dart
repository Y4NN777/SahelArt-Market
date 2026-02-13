class Validators {
  const Validators._();

  static String? requiredField(String value, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName est requis.';
    return null;
  }
}
