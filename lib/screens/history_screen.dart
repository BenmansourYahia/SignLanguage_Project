import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/detection_result.dart';
import '../services/firebase_service.dart';
import '../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<DetectionResult> _detections = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final detections = await _firebaseService.getRecentDetections(limit: 100);
      setState(() {
        _detections = detections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load history: $e';
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.lightGreen;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text(
          'Detection History',
          style: TextStyle(
            color: AppColors.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.charcoal,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.charcoal,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadHistory,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.charcoal,
                          foregroundColor: AppColors.cream,
                        ),
                      ),
                    ],
                  ),
                )
              : _detections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: AppColors.charcoal.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No detections yet',
                            style: TextStyle(
                              color: AppColors.charcoal.withOpacity(0.6),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start detecting ASL signs to see history',
                            style: TextStyle(
                              color: AppColors.charcoal.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      color: AppColors.charcoal,
                      child: Column(
                        children: [
                          // Stats Summary
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Total Scans',
                                  _detections.length.toString(),
                                  Icons.analytics,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.charcoal.withOpacity(0.2),
                                ),
                                _buildStatItem(
                                  'Avg Confidence',
                                  '${(_detections.map((d) => d.confidence).reduce((a, b) => a + b) / _detections.length).toStringAsFixed(1)}%',
                                  Icons.trending_up,
                                ),
                              ],
                            ),
                          ),
                          // History List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _detections.length,
                              itemBuilder: (context, index) {
                                final detection = _detections[index];
                                return _buildHistoryItem(detection);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.charcoal, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.charcoal,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.charcoal.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(DetectionResult detection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getConfidenceColor(detection.confidence).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getConfidenceColor(detection.confidence).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              detection.detectedSign,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getConfidenceColor(detection.confidence),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Sign: ${detection.detectedSign}',
              style: const TextStyle(
                color: AppColors.charcoal,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getConfidenceColor(detection.confidence).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${detection.confidence.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getConfidenceColor(detection.confidence),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatTimestamp(detection.timestamp),
            style: TextStyle(
              color: AppColors.charcoal.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.charcoal.withOpacity(0.3),
        ),
      ),
    );
  }
}
