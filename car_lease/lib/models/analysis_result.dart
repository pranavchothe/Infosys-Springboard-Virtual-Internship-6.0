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
    final analysisResult = json['analysis_result'] ?? {};
    final financials = analysisResult['financials'] ?? {};
    final fairness = json['fairness_analysis'] ?? {};

    return AnalysisResult(
      id: json['record_id'] ?? json['id'],
      vin: json['vin'] ?? 'Unknown VIN',
      status: json['status'] ??
          json['analysis_status'] ??
          'processed',
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'],
      ),

      analysisData: json,

      // FIXED EXTRACTION
      monthlyPayment:
          (financials['total_monthly_payment'] is num)
              ? (financials['total_monthly_payment'] as num).toDouble()
              : null,

      fairnessScore:
          (fairness['fairness_score'] is num)
              ? (fairness['fairness_score'] as num).toDouble()
              : null,
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

  Map<String, dynamic> get _analysisResult =>
      analysisData?['analysis_result'] ?? {};

  Map<String, dynamic> get _financials =>
      _analysisResult['financials'] ?? {};

  Map<String, dynamic> get _leaseDetails =>
      _analysisResult['lease_details'] ?? {};

  Map<String, dynamic> get _vehicleDetails =>
      _analysisResult['vehicle_details'] ?? {};

  Map<String, dynamic> get _fairness =>
      analysisData?['fairness_analysis'] ?? {};

  String get totalMonthly =>
      _financials['total_monthly_payment']?.toString() ?? "N/A";

  String get baseMonthly =>
      _financials['base_monthly_payment']?.toString() ?? "N/A";

  String get totalPayments =>
      _financials['total_of_payments']?.toString() ?? "N/A";

  String get residualValue =>
      _financials['residual_value']?.toString() ?? "N/A";

  String get purchaseOption =>
      _financials['purchase_option_price']?.toString() ?? "N/A";

  String get leaseDuration =>
      _leaseDetails['lease_duration']?.toString() ?? "N/A";

  String get paymentTerms =>
      _leaseDetails['payment_terms']?.toString() ?? "N/A";

  String get maker =>
      _vehicleDetails['maker']?.toString() ??
      _vehicleDetails['make']?.toString() ??
      "N/A";

  String get modelName =>
      _vehicleDetails['model']?.toString() ?? "N/A";

  String get vehicleYear =>
      _vehicleDetails['year']?.toString() ?? "N/A";

  int get redFlagCount =>
      (_fairness['red_flags'] as List?)?.length ?? 0;

}
