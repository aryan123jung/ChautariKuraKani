import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ISearchRepository {
  Future<Either<Failure, List<SearchUserEntity>>> searchUsers({
    required String query,
    int page = 1,
    int size = 10,
  });
}
