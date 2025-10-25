import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyDu7QDOWOi0pUVGETGJSvJjwfCXhJnhLAA';
  final GenerativeModel model;

  GeminiService() : model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

  Future<String> analyzeFishImage(File imageFile) async {
    try {
      final prompt = """
Analyze this fish image and provide ONLY the following information in this exact format without any additional text, symbols, or formatting:

Species: [species name]
Count: [number]
Confidence: [percentage]
Individual Weight: [weight in grams]
Total Weight: [weight in grams]
Health Status: [Fresh/Not Fresh]

Be concise and accurate.
""";

      final imageBytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: Failed to analyze image';
    }
  }

  Map<String, dynamic> parseResponse(String response) {
    try {
      final lines = response.split('\n');
      Map<String, dynamic> result = {
        'species': 'Unknown',
        'count': 1,
        'confidence': 0.0,
        'individualWeight': 0.0,
        'totalWeight': 0.0,
        'healthStatus': 'Unknown'
      };

      for (var line in lines) {
        if (line.contains('Species:')) {
          result['species'] = line.replaceAll('Species:', '').trim();
        } else if (line.contains('Count:')) {
          result['count'] = int.tryParse(line.replaceAll('Count:', '').trim()) ?? 1;
        } else if (line.contains('Confidence:')) {
          final confText = line.replaceAll('Confidence:', '').replaceAll('%', '').trim();
          result['confidence'] = double.tryParse(confText) ?? 0.0;
        } else if (line.contains('Individual Weight:')) {
          final weightText = line.replaceAll('Individual Weight:', '').replaceAll('grams', '').trim();
          result['individualWeight'] = double.tryParse(weightText) ?? 0.0;
        } else if (line.contains('Total Weight:')) {
          final weightText = line.replaceAll('Total Weight:', '').replaceAll('grams', '').trim();
          result['totalWeight'] = double.tryParse(weightText) ?? 0.0;
        } else if (line.contains('Health Status:')) {
          result['healthStatus'] = line.replaceAll('Health Status:', '').trim();
        }
      }

      return result;
    } catch (e) {
      return {
        'species': 'Unknown',
        'count': 1,
        'confidence': 0.0,
        'individualWeight': 0.0,
        'totalWeight': 0.0,
        'healthStatus': 'Unknown'
      };
    }
  }
}