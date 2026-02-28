import 'chatbot_context.dart';

class ChatBotService {
  String reply(String input) {
    final raw = input.trim().toLowerCase();
    String cmd = raw;

    // keyword → command mapping
    if (raw.contains("login")) cmd = "login";
    if (raw.contains("register")) cmd = "register";
    if (raw.contains("history")) cmd = "history";
    if (raw.contains("safe") || raw.contains("risk")) cmd = "1";
    if (raw.contains("owner")) cmd = "2";
    if (raw.contains("accident") || raw.contains("damage")) cmd = "3";
    if (raw.contains("lease")) cmd = "4";
    if (raw.contains("buy")) cmd = "5";

    //  NOT LOGGED IN 
    if (!ChatBotContext.isLoggedIn) {
      if (cmd == "login") {
        return "🔐 How to login:\n"
            "• Enter your email\n"
            "• Enter your password\n"
            "• Click Login";
      }

      if (cmd == "register") {
        return "📝 How to register:\n"
            "• Click Create account\n"
            "• Enter email & password\n"
            "• Submit to register";
      }

      return "👋 Hi! I’m your Car Assistant.\n\n"
          "To get started, please login or register:\n"
          "• Type `login`\n"
          "• Type `register`";
    }

    // LOGGED IN BUT NO CAR 
    if (!ChatBotContext.hasCar()) {
      if (cmd == "history") {
        return "👉 Please enter a VIN on the screen and click **Check Car History**.";
      }

      return "✅ You are logged in!\n\n"
          "Next step:\n"
          "👉 First check a car’s history using VIN.\n\n"
          "After that, I can help with:\n"
          "• Safety & risk\n"
          "• Accidents\n"
          "• Lease advice";
    }

    // CAR HISTORY AVAILABLE 
    final car = ChatBotContext.currentCar!;

    final int year =
        int.tryParse(car['year']?.toString() ?? '') ??
            DateTime.now().year;

    final int owners =
        int.tryParse(car['owners']?.toString() ?? '') ?? 0;

    final bool accident =
        car['accidental'] == true;

    final bool flood =
        car['flood_damage'] == true;

    final int claims =
        int.tryParse(car['insurance_claims']?.toString() ?? '') ?? 0;

    final String status =
        car['status']?.toString() ?? "Unknown";

    final int age = DateTime.now().year - year;

    if (cmd == "1") {
      return "🔍 Safety & Risk:\n$status";
    }

    if (cmd == "2") {
      return "👥 Ownership:\n$owners previous owners.";
    }

    if (cmd == "3") {
      return "🚧 Accident & Damage:\n"
          "• Accident: ${accident ? "Yes" : "No"}\n"
          "• Flood: ${flood ? "Yes" : "No"}\n"
          "• Insurance claims: $claims";
    }

    if (cmd == "4") {
      if (age > 10) {
        return "⚠️ Lease Advice:\n"
            "Car is $age years old.\nLeasing not recommended.";
      }
      return "✅ Lease Advice:\n"
          "Suitable for leasing (24–36 months).";
    }

    if (cmd == "5") {
      return status.contains("Clean")
          ? "👍 Buy Advice:\nCar looks safe to buy."
          : "⚠️ Buy Advice:\nInspection recommended.";
    }

    return "What would you like to know?\n"
        "1️⃣ Safety & risk\n"
        "2️⃣ Ownership\n"
        "3️⃣ Accident history\n"
        "4️⃣ Lease advice\n"
        "5️⃣ Buy advice";
  }
}
