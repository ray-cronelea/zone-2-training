abstract class DeviceDataProvider {

  Future<void> connect();
  Future<void> disconnect();
  Stream<int> getHeartRateStream();
  Stream<int> getPowerStream();
  void setPower(int power);

}