class ChatBotContext {
  static bool isLoggedIn = false;

  static Map<String, dynamic>? currentCar;
  static int? recordId;

  static void setLoggedIn(bool value) {
    isLoggedIn = value;

    if (!value) {
      clearCar();
    }
  }

  static void updateCarHistory({
    required Map<String, dynamic> car,
    required int record,
  }) {
    currentCar = Map<String, dynamic>.from(car);
    recordId = record;
  }

  static void clearCar() {
    currentCar = null;
    recordId = null;
  }

  static bool hasCar() =>
      currentCar != null && recordId != null;
}
