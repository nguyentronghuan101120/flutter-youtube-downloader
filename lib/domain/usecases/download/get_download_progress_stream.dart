import 'package:injectable/injectable.dart';
import 'dart:developer' as developer;
import '../../../domain/repositories/download_repository.dart';
import '../../../domain/entities/download_progress.dart';
import '../../../core/usecases/base_usecase.dart';

@injectable
class GetDownloadProgressStream
    implements BaseUseCase<Stream<DownloadProgress>, String> {
  final DownloadRepository _downloadRepository;

  GetDownloadProgressStream({required DownloadRepository downloadRepository})
    : _downloadRepository = downloadRepository;

  @override
  Future<Stream<DownloadProgress>> execute(String taskId) async {
    developer.log(
      '[get_download_progress_stream.dart] - Getting progress stream for task: $taskId',
    );
    return _downloadRepository.getDownloadProgressStream(taskId);
  }
}
