class ChatBotContext {
  static bool isLoggedIn = false;
  static Map<String, dynamic>? currentCar;

  static void setLoggedIn(bool value) {
    isLoggedIn = value;
  }

  static void updateCarHistory(Map<String, dynamic> car) {
    currentCar = car;
  }

  static void clearCar() {
    currentCar = null;
  }

  static bool hasCar() => currentCar != null;
}
