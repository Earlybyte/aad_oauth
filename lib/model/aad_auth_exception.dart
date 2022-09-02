class AadAuthException implements Exception {
  final String error;
  final String? errorSubcode;

  const AadAuthException({
    required this.error,
    this.errorSubcode,
  });
}
