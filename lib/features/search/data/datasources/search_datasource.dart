import 'package:chautari_kurakani/features/search/data/models/search_user_api_model.dart';

abstract interface class ISearchRemoteDatasource {
  Future<List<SearchUserApiModel>> searchUsers({
    required String query,
    int page = 1,
    int size = 10,
  });
}
