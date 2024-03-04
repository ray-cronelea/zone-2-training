abstract class HeartRateDevice {

  Future<void> connect();
  Future<void> disconnect();
  Stream<int> getListener();

}