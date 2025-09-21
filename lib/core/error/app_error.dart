class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError: $message${code != null ? ' (Code: $code)' : ''}';
  }

  factory AppError.network(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      code: 'NETWORK_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.database(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      code: 'DATABASE_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.authentication(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      code: 'AUTH_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.validation(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      code: 'VALIDATION_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  factory AppError.unknown(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      code: 'UNKNOWN_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}
