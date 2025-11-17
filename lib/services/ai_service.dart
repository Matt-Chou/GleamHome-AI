/// AI 分析服務
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo_analysis.dart';
import '../models/organization_suggestion.dart';
import 'api_service.dart';

class AIService {
  final ApiService apiService;

  AIService(this.apiService);

  Future<PhotoAnalysis> analyzePhoto({
    required XFile photoFile,
    String? roomType,
    String? roomLabel,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photoFile.path),
        if (roomType != null) 'room_type': roomType,
        if (roomLabel != null) 'label': roomLabel,
      });

      final response = await apiService.post(
        '/api/analyze',
        data: formData,
      );

      return PhotoAnalysis.fromJson(response);
    } catch (e) {
      throw Exception('AI 分析失敗: $e');
    }
  }

  Future<List<OrganizationSuggestion>> generateSuggestions({
    required String analysisId,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      final response = await apiService.post(
        '/api/suggestions',
        data: {
          'analysis_id': analysisId,
          'preferences': userPreferences ?? {},
        },
      );

      final suggestions = (response['suggestions'] as List)
          .map((suggestion) => OrganizationSuggestion.fromJson(suggestion))
          .toList();

      return suggestions;
    } catch (e) {
      throw Exception('生成建議失敗: $e');
    }
  }

  Future<String> sendConversationMessage({
    required String analysisId,
    required String userMessage,
  }) async {
    try {
      final response = await apiService.post(
        '/api/conversation',
        data: {
          'analysis_id': analysisId,
          'user_message': userMessage,
        },
      );

      return response['ai_response'];
    } catch (e) {
      throw Exception('對話失敗: $e');
    }
  }
}
