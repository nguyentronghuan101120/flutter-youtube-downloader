import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class DownloadFailure extends Failure {
  const DownloadFailure(String message) : super(message);
}

class ConversionFailure extends Failure {
  const ConversionFailure(String message) : super(message);
}

class VideoNotFoundFailure extends Failure {
  const VideoNotFoundFailure(String message) : super(message);
}

class PlaylistNotFoundFailure extends Failure {
  const PlaylistNotFoundFailure(String message) : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}
