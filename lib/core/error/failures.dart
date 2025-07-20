import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class DownloadFailure extends Failure {
  const DownloadFailure(super.message);
}

class ConversionFailure extends Failure {
  const ConversionFailure(super.message);
}

class VideoNotFoundFailure extends Failure {
  const VideoNotFoundFailure(super.message);
}

class PlaylistNotFoundFailure extends Failure {
  const PlaylistNotFoundFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
