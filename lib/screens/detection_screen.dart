import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import '../utils/app_colors.dart';
import '../widgets/hand_guide_painter.dart';
import '../services/firebase_service.dart';
import '../main.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  CameraController? cameraController;
  String output = "Initializing...";
  double confidence = 0.0;
  bool isBusy = false;
  final FirebaseService _firebaseService = FirebaseService();
  DateTime? _lastSaveTime;  // Track last save time for cooldown

  @override
  void initState() {
    super.initState();
    loadModel().then((_) {
      initCamera();
    });
  }

  // 1. Load the Model and Labels
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      print("Model loaded: $res");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  // 2. Setup Camera Stream
  void initCamera() {
    if (cameras == null || cameras!.isEmpty) return;

    cameraController = CameraController(
      cameras![0], // Use the back camera
      ResolutionPreset.medium,
      enableAudio: false,
    );

    cameraController!
        .initialize()
        .then((_) {
          if (!mounted) return;

          // Start the live frame stream
          cameraController!.startImageStream((CameraImage image) {
            if (!isBusy) {
              isBusy = true;
              runModelOnFrame(image);
            }
          });
          setState(() {});
        })
        .catchError((e) {
          print("Camera init error: $e");
        });
  }

  // 3. Run Inference on Frame
  Future<void> runModelOnFrame(CameraImage image) async {
    try {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 0.0,    // For 0-1 normalization (divide by 255)
        imageStd: 255.0,   // For 0-1 normalization (divide by 255)
        rotation: 90,      // Common for portrait Android devices
        numResults: 2,     // Get top 2 results to compare
        threshold: 0.05,   // Very low threshold to get all predictions
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        final topPrediction = recognitions[0];
        final predictedLabel = topPrediction['label'].toString();
        final predictionConfidence = (topPrediction['confidence'] as double) * 100;
        
        setState(() {
          confidence = predictionConfidence;
          
          // Only show prediction if confidence is high enough
          if (predictionConfidence >= 50.0) {
            // High confidence - show the prediction
            output = predictedLabel;
            
            // Save to Firebase with 5-second cooldown
            final now = DateTime.now();
            if (_lastSaveTime == null || 
                now.difference(_lastSaveTime!).inSeconds >= 5) {
              _firebaseService.saveDetection(
                detectedSign: predictedLabel,
                confidence: predictionConfidence,
              );
              _lastSaveTime = now;  // Update last save time
            }
          } else if (predictionConfidence >= 25.0) {
            // Medium confidence - show but with uncertainty indicator
            output = "$predictedLabel?";
          } else {
            // Low confidence - don't show misleading predictions
            output = "No Clear Sign";
          }
        });
      } else {
        setState(() {
          output = "No Detection";
          confidence = 0.0;
        });
      }
    } catch (e) {
      print("Inference error: $e");
    } finally {
      isBusy = false;
    }
  }

  // Helper method to get color based on confidence
  Color _getConfidenceColor() {
    if (confidence >= 50.0) {
      return Colors.greenAccent; // High confidence
    } else if (confidence >= 25.0) {
      return Colors.orange; // Medium confidence
    } else {
      return Colors.redAccent; // Low confidence
    }
  }

  // Helper method to get icon based on confidence
  IconData _getConfidenceIcon() {
    if (confidence >= 50.0) {
      return Icons.check_circle;
    } else if (confidence >= 25.0) {
      return Icons.help_outline;
    } else {
      return Icons.cancel;
    }
  }

  // Helper method to get user guidance text
  String _getHelperText() {
    if (confidence >= 50.0) {
      return "Good detection! Keep your hand steady.";
    } else if (confidence >= 25.0) {
      return "Uncertain... Try better lighting or clearer gesture.";
    } else {
      return "Show a clear ASL sign in good lighting.";
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    Tflite.close(); // Important: Release memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ASL Detection"),
        backgroundColor: Colors.blueGrey.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera Preview (Full Screen)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(cameraController!),
          ),

          // Result Box
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getConfidenceColor(),
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Detection Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getConfidenceIcon(),
                        color: _getConfidenceColor(),
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          output,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _getConfidenceColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Confidence Bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Confidence",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            "${confidence.toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getConfidenceColor(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: confidence / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Helper Text
                  Text(
                    _getHelperText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
