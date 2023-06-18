/// {@template server_error}
/// An internal server error.
/// {@endtemplate}
class ServerError implements Exception {
  /// {@macro server_error}
  const ServerError({
    this.message,
    this.payload,
    this.labels,
  });

  /// An internal server error produced by a value being `null` when it was
  /// expected to have a value.
  ServerError.expectNonNull(
    String variable, {
    this.labels,
    this.payload,
  }) : message = '$variable expected to be not null';

  /// A message to be logged for this error.
  final String? message;

  /// A payload to be logged for this error.
  final Object? payload;

  /// Labels to log for this error.
  final Map<String, dynamic>? labels;
}
