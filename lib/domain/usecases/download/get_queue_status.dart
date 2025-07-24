import 'package:injectable/injectable.dart';
import '../../repositories/download_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/result/result.dart' as result;
import 'package:dartz/dartz.dart';

@injectable
class GetQueueStatus {
  final DownloadRepository repository;

  GetQueueStatus(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    try {
      final result = await repository.getQueueStatus();
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
