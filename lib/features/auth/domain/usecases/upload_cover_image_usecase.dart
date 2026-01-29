import 'dart:io';

import 'package:chautari_kurakani/core/error/failures.dart';
import 'package:chautari_kurakani/core/usecase/app_usecase.dart';
import 'package:chautari_kurakani/features/auth/data/repositories/auth_repository.dart';
import 'package:chautari_kurakani/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final uploadCoverImageUsecaseProvider = Provider<UploadCoverImageUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UploadCoverImageUsecase(repository: repository);
});

class UploadCoverImageUsecase implements UsecaseWithParams<String, File> {
  final IAuthRepository _repository;
  UploadCoverImageUsecase({required IAuthRepository repository})
    : _repository = repository;
  @override
  Future<Either<Failure, String>> call(File params) {
    return _repository.coverImageUpload(params);
  }
}
