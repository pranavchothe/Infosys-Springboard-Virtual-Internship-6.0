class AnalysisResult {
  final int id;
  final String vin;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? analysisData;

  AnalysisResult({
    required this.id,
    required this.vin,
    required this.status,
    required this.createdAt,
    this.analysisData,
  });
  
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'],
      vin: json['vin'] ?? 'Unknown VIN',
      status: json['status'] ??
          json['analysis_status'] ??
          'processed',
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'],
      ),
      analysisData: json['analysis_data'],
    );
  }
}

