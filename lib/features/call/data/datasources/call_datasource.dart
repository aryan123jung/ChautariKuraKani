import 'package:chautari_kurakani/features/call/data/models/call_api_models.dart';

abstract class ICallRemoteDatasource {
  Future<List<CallLogApiModel>> listMyCalls({int page = 1, int size = 20});
}
