import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:dartz/dartz.dart';

abstract class ICallRepository {
  Future<Either<Failure, List<CallLogEntity>>> listMyCalls({
    int page = 1,
    int size = 20,
    bool bypassCache = false,
  });
}
