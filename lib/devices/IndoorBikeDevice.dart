abstract class IndoorBikeDevice {
  Future<void> connect();

  Future<void> disconnect();

  Stream<int> getListener();

  Future<void> setTargetPower(int targetPower);
}
