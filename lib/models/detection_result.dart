class DetectionResult {
  final String detectedSign;
  final double confidence;
  final DateTime timestamp;
  final String? sessionId;

  DetectionResult({
    required this.detectedSign,
    required this.confidence,
    required this.timestamp,
    this.sessionId,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'detectedSign': detectedSign,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
    };
  }

  // Create from Firebase Map
  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      detectedSign: map['detectedSign'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      sessionId: map['sessionId'],
    );
  }
}
