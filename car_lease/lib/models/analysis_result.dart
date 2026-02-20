class AnalysisResult {
  final int id;
  final String vin;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? analysisData;

  final double? monthlyPayment;
  final double? fairnessScore;

  AnalysisResult({
    required this.id,
    required this.vin,
    required this.status,
    required this.createdAt,
    this.analysisData,
    this.monthlyPayment,
    this.fairnessScore,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final analysis = json['analysis_data'];

    return AnalysisResult(
      id: json['id'],
      vin: json['vin'] ?? 'Unknown VIN',
      status: json['status'] ??
          json['analysis_status'] ??
          'processed',
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'],
      ),
      analysisData: analysis,

      monthlyPayment: (analysis?['monthly_payment'] as num?)?.toDouble(),
      fairnessScore: (analysis?['fairness_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "record_id": id,
      "vin": vin,
      "status": status,
      "created_at": createdAt.toIso8601String(),

      "analysis_result": analysisData?["analysis_result"],
      "fairness_analysis": analysisData?["fairness_analysis"],
      "price_estimation": analysisData?["price_estimation"],
      "car_full_history": analysisData?["car_full_history"],
    };
  }
}
