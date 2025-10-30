// lib/src/data/mock_repository.dart
// Re-exporta a implementação apropriada conforme a plataforma (web vs io).
export 'mock_repository_io.dart' if (dart.library.html) 'mock_repository_web.dart';
