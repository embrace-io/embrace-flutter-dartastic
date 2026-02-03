class DemoException implements Exception {
  final String message;
  const DemoException(this.message);

  @override
  String toString() => 'DemoException: $message';
}
