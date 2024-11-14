import 'dart:math' as math;

import 'package:flutter/services.dart';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class LeafDetectionService {
  final Interpreter interpreter;
  final labels = [
    "Scab",
    "Black_Rot",
    "Rust",
    "Healthy",
    "Background_without_leaves",
    "Healthy",
    "Powdery_Mildew",
    "Healthy",
    "Leaf_Spot",
    "Common_Rust",
    "Leaf_Blight",
    "Healthy",
    "Black_Rot",
    "Black_Measles",
    "Leaf_Blight",
    "Healthy",
    "Haunglongbing",
    "Bacterial_Spot",
    "Healthy",
    "Bacterial_Spot",
    "Healthy",
    "Early_Blight",
    "Healthy",
    "Late_Blight",
    "Healthy",
    "Healthy",
    "Powdery_Mildew",
    "Healthy",
    "Leaf_Scorch",
    "Bacterial_Spot",
    "Early_Blight",
    "Healthy",
    "Late_Blight",
    "Leaf_mMld",
    "Leaf_spot",
    "Spider_mites_two-spotted_spider_mite",
    "Target_spot",
    "Mosaic_virus",
  ];

  LeafDetectionService({required this.interpreter});

  Future<Map<String, double>> detectLeaf(Uint8List bytes) async {
    // Load and preprocess the image
    final image = img.decodeImage(bytes)!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Convert image to float32 array and normalize
    var input = List.generate(
      1, // batch size
      (_) => List.generate(
        224, // height
        (y) => List.generate(
          224, // width
          (x) => List.generate(
            3, // channels (RGB)
            (c) {
              final pixel = resizedImage.getPixel(x, y);
              // Get RGB values
              return c == 0
                  ? pixel.r / 255.0
                  : c == 1
                      ? pixel.g / 255.0
                      : pixel.b / 255.0;
            },
          ),
        ),
      ),
    );

    // Prepare output tensor
    var output =
        List.filled(1 * 38, 0.0).reshape([1, 38]); // 38 classes as per model

    // Run inference
    interpreter.run(input, output);

    // Process results
    // Apply softmax to get probabilities
    final List<double> probabilities = _softmax(output[0]);

    final confidence = probabilities.map((prob) {
      return prob * 100;
    }).toList();

    // Create map of label to probability
    final results = Map.fromIterables(
      labels,
      confidence,
    );

    // Sort by probability in descending order
    final sortedResults = Map.fromEntries(
        results.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

    return sortedResults;
  }

  // Helper function to compute softmax
  List<double> _softmax(List<double> values) {
    double max = values.reduce((curr, next) => curr > next ? curr : next);
    List<double> exp = values.map((val) => math.exp(val - max)).toList();
    double sum = exp.reduce((curr, next) => curr + next);
    return exp.map((val) => val / sum).toList();
  }
}
