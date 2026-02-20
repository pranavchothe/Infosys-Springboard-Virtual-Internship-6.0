class LeaseHistoryItem {
  final int id;
  final String filename;
  final String vin;
  final String? maker;
  final String? model;
  final int? fairnessScore;
  final DateTime createdAt;

  LeaseHistoryItem({
    required this.id,
    required this.filename,
    required this.vin,
    required this.createdAt,
    this.maker,
    this.model,
    this.fairnessScore,
  });

  factory LeaseHistoryItem.fromJson(Map<String, dynamic> json) {
  return LeaseHistoryItem(
    id: json["id"],
    filename: json["filename"],
    vin: json["vin"] ?? "Unknown VIN",
    maker: json["maker"],
    model: json["model"],
    fairnessScore: json["fairness_score"],
    createdAt: DateTime.parse(json["created_at"]),
  );
}

}
