import 'package:light/light.dart';

class AmbientLightService {
  final Light _light = Light();

  Stream<int> luxStream() => _light.lightSensorStream;
}
