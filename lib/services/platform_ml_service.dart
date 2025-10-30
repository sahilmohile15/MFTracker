import 'package:flutter/services.dart';

/// Platform channel ML service that uses native TFLite via Kotlin
class PlatformMLService {
  static final PlatformMLService _instance = PlatformMLService._internal();
  factory PlatformMLService() => _instance;
  PlatformMLService._internal();

  static const platform = MethodChannel('com.mftracker.app/tflite');
  bool _isInitialized = false;

  /// Initialize ML models via platform channel
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[PlatformML] Models already initialized');
      return;
    }

    try {
      print('[PlatformML] Initializing models via Kotlin...');
      final bool success = await platform.invokeMethod('initialize');
      
      if (success) {
        _isInitialized = true;
        print('[PlatformML] ✅ Models loaded successfully via platform channel');
      } else {
        print('[PlatformML] ❌ Failed to load models');
        throw Exception('Model initialization failed');
      }
    } catch (e, stackTrace) {
      print('[PlatformML] Error loading models: $e');
      print('[PlatformML] Stack trace: $stackTrace');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Classify SMS using platform channel
  /// Returns true if financial, false if non-financial
  Future<bool> isFinancialSMS(String smsText) async {
    print('[PlatformML] isFinancialSMS called - _isInitialized=$_isInitialized');
    
    if (!_isInitialized) {
      print('[PlatformML] Models not initialized - returning false');
      return false;
    }

    try {
      // Preprocess text (128 tokens)
      print('[PlatformML] Preprocessing text for classifier (128 tokens)...');
      final tokens = _preprocessTextClassifier(smsText);
      print('[PlatformML] Tokens prepared: ${tokens.length} tokens');
      
      // Call Kotlin classifier
      print('[PlatformML] Calling Kotlin classifier...');
      final List<dynamic> output = await platform.invokeMethod('classifySMS', {
        'tokens': tokens,
      });
      
      // Extract probabilities
      final nonFinancialProb = output[0] as double;
      final financialProb = output[1] as double;
      
      print('[PlatformML] Classifier result: non-financial=$nonFinancialProb, financial=$financialProb');
      
      // Return true if financial probability is higher
      return financialProb > nonFinancialProb;
    } catch (e, stackTrace) {
      print('[PlatformML] Error in classifier inference: $e');
      print('[PlatformML] Stack trace: $stackTrace');
      return false; // Default to non-financial on error
    }
  }

  /// Extract entities using NER model via platform channel
  Future<Map<String, dynamic>?> extractEntities(String smsText) async {
    print('[PlatformML] extractEntities called - _isInitialized=$_isInitialized');
    
    if (!_isInitialized) {
      print('[PlatformML] Models not initialized - returning null');
      return null;
    }

    try {
      // Preprocess text (256 tokens)
      print('[PlatformML] Preprocessing text for NER (256 tokens)...');
      final tokens = _preprocessTextNER(smsText);
      print('[PlatformML] Tokens prepared: ${tokens.length} tokens');
      
      // Call Kotlin NER
      print('[PlatformML] Calling Kotlin NER...');
      final List<dynamic> output = await platform.invokeMethod('extractEntities', {
        'tokens': tokens,
      });
      
      // Parse NER output (output is flattened [256 * 11])
      final result = _parseNEROutput(smsText, output.cast<double>());
      
      print('[PlatformML] NER result: $result');
      return result;
    } catch (e, stackTrace) {
      print('[PlatformML] Error during NER inference: $e');
      print('[PlatformML] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Preprocess SMS text for classifier model (128 tokens)
  List<int> _preprocessTextClassifier(String text) {
    final lowerText = text.toLowerCase();
    final List<int> tokens = [];
    
    for (int i = 0; i < lowerText.length && i < 128; i++) {
      tokens.add(lowerText.codeUnitAt(i));
    }
    
    while (tokens.length < 128) {
      tokens.add(0);
    }
    
    return tokens.sublist(0, 128);
  }

  /// Preprocess SMS text for NER model (256 tokens)
  List<int> _preprocessTextNER(String text) {
    final lowerText = text.toLowerCase();
    final List<int> tokens = [];
    
    for (int i = 0; i < lowerText.length && i < 256; i++) {
      tokens.add(lowerText.codeUnitAt(i));
    }
    
    while (tokens.length < 256) {
      tokens.add(0);
    }
    
    return tokens.sublist(0, 256);
  }

  /// Parse NER model output to extract entities
  Map<String, dynamic> _parseNEROutput(String originalText, List<double> output) {
    // NER labels: O, B-AMOUNT, I-AMOUNT, B-MERCHANT, I-MERCHANT, B-DATE, I-DATE, 
    //             B-ACCOUNT, I-ACCOUNT, B-TYPE, I-TYPE
    final Map<String, dynamic> result = {};
    
    // output is flattened [256 * 11], reshape to [256][11]
    final predictions = <List<double>>[];
    for (int i = 0; i < 256; i++) {
      final tokenPreds = <double>[];
      for (int j = 0; j < 11; j++) {
        tokenPreds.add(output[i * 11 + j]);
      }
      predictions.add(tokenPreds);
    }
    
    // Get predicted label for each token
    final labels = <int>[];
    for (final tokenPreds in predictions) {
      int maxIndex = 0;
      double maxValue = tokenPreds[0];
      for (int i = 1; i < tokenPreds.length; i++) {
        if (tokenPreds[i] > maxValue) {
          maxValue = tokenPreds[i];
          maxIndex = i;
        }
      }
      labels.add(maxIndex);
    }
    
    // Extract entities based on BIO tags
    final lowerText = originalText.toLowerCase();
    String? currentEntity;
    StringBuffer entityBuffer = StringBuffer();
    
    for (int i = 0; i < labels.length && i < lowerText.length; i++) {
      final label = labels[i];
      final char = lowerText[i];
      
      if (label == 1) { // B-AMOUNT
        if (currentEntity == 'amount') {
          result['amount'] = entityBuffer.toString().trim();
        }
        currentEntity = 'amount';
        entityBuffer = StringBuffer(char);
      } else if (label == 2 && currentEntity == 'amount') { // I-AMOUNT
        entityBuffer.write(char);
      } else if (label == 3) { // B-MERCHANT
        if (currentEntity == 'merchant') {
          result['merchant'] = entityBuffer.toString().trim();
        }
        currentEntity = 'merchant';
        entityBuffer = StringBuffer(char);
      } else if (label == 4 && currentEntity == 'merchant') { // I-MERCHANT
        entityBuffer.write(char);
      } else if (label == 9) { // B-TYPE
        if (currentEntity == 'type') {
          result['transactionType'] = entityBuffer.toString().trim();
        }
        currentEntity = 'type';
        entityBuffer = StringBuffer(char);
      } else if (label == 10 && currentEntity == 'type') { // I-TYPE
        entityBuffer.write(char);
      } else {
        // O tag or other - finalize current entity
        if (currentEntity != null) {
          if (currentEntity == 'amount') {
            result['amount'] = entityBuffer.toString().trim();
          } else if (currentEntity == 'merchant') {
            result['merchant'] = entityBuffer.toString().trim();
          } else if (currentEntity == 'type') {
            result['transactionType'] = entityBuffer.toString().trim();
          }
          currentEntity = null;
          entityBuffer = StringBuffer();
        }
      }
    }
    
    // Finalize any remaining entity
    if (currentEntity != null) {
      if (currentEntity == 'amount') {
        result['amount'] = entityBuffer.toString().trim();
      } else if (currentEntity == 'merchant') {
        result['merchant'] = entityBuffer.toString().trim();
      } else if (currentEntity == 'type') {
        result['transactionType'] = entityBuffer.toString().trim();
      }
    }
    
    return result;
  }

  void dispose() {
    _isInitialized = false;
  }
}
