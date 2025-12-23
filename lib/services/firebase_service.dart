import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/detection_result.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _sessionId = const Uuid().v4();

  // Save a detection result to Firebase
  Future<void> saveDetection({
    required String detectedSign,
    required double confidence,
  }) async {
    try {
      final detection = DetectionResult(
        detectedSign: detectedSign,
        confidence: confidence,
        timestamp: DateTime.now(),
        sessionId: _sessionId,
      );

      await _firestore.collection('detections').add(detection.toMap());
      print('✓ Detection saved: $detectedSign ($confidence%)');
    } catch (e) {
      print('Error saving detection: $e');
      // Don't throw - app should continue even if save fails
    }
  }

  // Get recent detections (optional, for future use)
  Future<List<DetectionResult>> getRecentDetections({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('detections')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => DetectionResult.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching detections: $e');
      return [];
    }
  }

  // Get session ID for tracking
  String get sessionId => _sessionId;
}
