/// Sealed error types for domain-level error handling.
sealed class AppError {
  const AppError(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class CameraError extends AppError {
  const CameraError(super.message);
}

class StorageError extends AppError {
  const StorageError(super.message);
}

class ProcessingError extends AppError {
  const ProcessingError(super.message);
}

class NativeError extends AppError {
  const NativeError(super.message);
}

class UnknownError extends AppError {
  const UnknownError([super.message = 'An unknown error occurred']);
}
