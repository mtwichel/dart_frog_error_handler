import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_error_handler/dart_frog_error_handler.dart';
import 'package:dart_frog_request_logger/dart_frog_request_logger.dart';
import 'package:shelf/shelf.dart' show HijackException;

/// A [Middleware] that catches errors throw during a [Handler] and
/// 1. Logs them using the [RequestLogger].
/// 2. Returns the appropriate response.
Middleware errorHandlerMiddleware({
  required FutureOr<RequestLogger> Function(RequestContext context)
      loggerGetter,
  Response? Function(Object error, RequestLogger logger)? customErrorHandler,
}) {
  return (handler) {
    return (context) async {
      final completer = Completer<Response>.sync();
      final logger = await loggerGetter(context);

      Zone.current.fork(
        specification: ZoneSpecification(
          handleUncaughtError: (self, parent, zone, error, stackTrace) {
            if (error is HijackException) {
              completer.completeError(error, stackTrace);
            }
            if (completer.isCompleted) {
              return;
            }

            if (customErrorHandler != null) {
              final response = customErrorHandler(error, logger);
              if (response != null) {
                completer.complete(response);
                return;
              }
            }
            if (error is BadRequestException) {
              logger.log(
                Severity.warning,
                error.message,
                payload: error.payload,
                stackTrace: stackTrace,
                includeStacktrace: true,
              );
              completer.complete(error.response);
              return;
            }
            if (error is ServerError) {
              logger.log(
                Severity.error,
                error.message?.trim() ?? error.toString().trim(),
                stackTrace: stackTrace,
                includeStacktrace: true,
                isError: true,
                payload: error.payload,
                labels: error.labels,
              );
              completer.complete(
                Response(
                  statusCode: HttpStatus.internalServerError,
                  body: 'Internal Server Error',
                ),
              );
              return;
            }

            logger.log(
              Severity.error,
              error.toString().trim(),
              stackTrace: stackTrace,
              includeStacktrace: true,
              isError: true,
            );
            completer.complete(
              Response(
                statusCode: HttpStatus.internalServerError,
                body: 'Internal Server Error',
              ),
            );
          },
        ),
      ).runGuarded(
        () async {
          final response = await handler(context);
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        },
      );

      return completer.future;
    };
  };
}
