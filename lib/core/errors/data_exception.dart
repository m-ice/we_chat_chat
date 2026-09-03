class DataException implements Exception {
  const DataException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'DataException: $message';
}
