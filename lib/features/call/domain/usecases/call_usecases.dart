import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/call/data/repositories/call_repository.dart';
import 'package:chautari_kurakani/features/call/domain/entities/call_entities.dart';
import 'package:chautari_kurakani/features/call/domain/repositories/call_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListMyCallsParams extends Equatable {
  final int page;
  final int size;

  const ListMyCallsParams({this.page = 1, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

final listMyCallsUsecaseProvider = Provider<ListMyCallsUsecase>((ref) {
  return ListMyCallsUsecase(repository: ref.read(callRepositoryProvider));
});

class ListMyCallsUsecase
    implements UsecaseWithParams<List<CallLogEntity>, ListMyCallsParams> {
  final ICallRepository _repository;

  ListMyCallsUsecase({required ICallRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<CallLogEntity>>> call(ListMyCallsParams params) {
    return _repository.listMyCalls(page: params.page, size: params.size);
  }
}
