import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// {@template bad_request_exception}
/// A bad request was made to the server.
/// {@endtemplate}
class BadRequestException implements Exception {
  /// {@macro bad_request_exception}
  const BadRequestException({
    this.statusCode = HttpStatus.badRequest,
    this.message = 'Bad request',
    this.payload,
  });

  /// A request was made without authentication.
  const BadRequestException.unauthenticated(
    this.message, {
    this.payload,
  }) : statusCode = HttpStatus.unauthorized;

  /// An authenticated request was made without proper permissions.
  const BadRequestException.forbidden({
    this.payload,
  })  : statusCode = HttpStatus.forbidden,
        message =
            'User is not authorized to perform actions for this merchant.';

  /// A request was made with an invalid argument.
  const BadRequestException.invalidArgument(
    String name,
    String type,
    dynamic value, {
    this.payload,
  })  : statusCode = HttpStatus.badRequest,
        message =
            'Invalid argument: the $type `$name` has an invalid value: $value';

  /// A request was made with an unset argument.
  const BadRequestException.unsetArgument(
    String name,
    String type, {
    this.payload,
  })  : statusCode = HttpStatus.badRequest,
        message = 'Invalid argument: the $type `$name` must be set';

  /// A request was made with an invalid argument type
  /// (ie a [String] instead of an [int]).
  const BadRequestException.invalidArgumentType(
    String name,
    String argumentType,
    Type type, {
    this.payload,
  })  : statusCode = HttpStatus.badRequest,
        message = 'Invalid argument: the $argumentType`$name` must be a $type';

  /// A request was made to a method that wasn't allowed.
  /// (ie a GET when only POST is allowed)
  BadRequestException.methodNotAllowed(
    Request request, {
    this.payload,
  })  : statusCode = HttpStatus.methodNotAllowed,
        message = 'Method ${request.method.name.toUpperCase()} not allowed '
            'for ${request.uri.path}';

  /// The status code to be sent in the [Response]. Between 400-499.
  final int statusCode;

  /// The message to be sent in the [Response] and logged.
  final String message;

  /// An optional payload to be sent in the [Response] and logged.
  final Object? payload;

  /// The constructed [Response] to return when this error is thrown.
  Response get response => Response(statusCode: statusCode, body: message);
}
