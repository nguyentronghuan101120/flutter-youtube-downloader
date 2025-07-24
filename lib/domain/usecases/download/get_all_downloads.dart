import 'package:injectable/injectable.dart';
import '../../entities/download_task.dart';
import '../../repositories/download_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/result/result.dart' as result;
import 'package:dartz/dartz.dart';

@injectable
class GetAllDownloads {
  final DownloadRepository repository;

  GetAllDownloads(this.repository);

  Future<Either<Failure, List<DownloadTask>>> call() async {
    try {
      final result = await repository.getAllDownloads();
      if (result.isSuccess) {
        return Right(result.data!);
      } else {
        return Left(CacheFailure(result.errorMessage!));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
