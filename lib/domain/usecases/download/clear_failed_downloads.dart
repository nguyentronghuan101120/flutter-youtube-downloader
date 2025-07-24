import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/result/result.dart' as result;
import 'package:dartz/dartz.dart';

@injectable
class ClearFailedDownloads {
  final DownloadRepository repository;

  ClearFailedDownloads(this.repository);

  Future<Either<Failure, int>> call() async {
    try {
      final result = await repository.clearFailedDownloads();
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
