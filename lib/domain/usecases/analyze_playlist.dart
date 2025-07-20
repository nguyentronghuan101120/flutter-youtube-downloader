import 'package:injectable/injectable.dart';
import '../entities/playlist_info.dart';
import '../repositories/video_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

@injectable
class AnalyzePlaylist {
  final VideoRepository repository;

  AnalyzePlaylist(this.repository);

  Future<Either<Failure, PlaylistInfo>> call(String url) async {
    try {
      // Validate URL trước
      final isValid = await repository.isValidYouTubeUrl(url);
      if (!isValid) {
        return const Left(InvalidInputFailure('Invalid YouTube URL'));
      }

      // Phân tích playlist
      final playlistInfo = await repository.getPlaylistInfo(url);
      return Right(playlistInfo);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
