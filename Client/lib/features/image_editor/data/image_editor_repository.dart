import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/shared_providers.dart';

class ImageTemplate {
  final int id;
  final String title;
  final String description;
  final String promptTemplate;

  ImageTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.promptTemplate,
  });

  factory ImageTemplate.fromJson(Map<String, dynamic> json) {
    return ImageTemplate(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      promptTemplate: json['prompt_template'],
    );
  }
}

class ImageEditorRepository {
  final ApiClient _apiClient;

  ImageEditorRepository(this._apiClient);

  Future<List<ImageTemplate>> getTemplates() async {
    try {
      final response = await _apiClient.get('/image-editor/templates/');
      final List<dynamic> data = response.data;
      return data.map((e) => ImageTemplate.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load templates: $e');
    }
  }

  Future<int> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.postMultipart('/image-editor/upload/', formData: formData);
      return response.data['id'];
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> generateContent(int templateId, int imageId) async {
    try {
      final response = await _apiClient.post(
        '/image-editor/generate/',
        data: {
          'template_id': templateId,
          'image_id': imageId,
        },
      );
      return response.data['content'] ?? '';
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  Future<String> smartEdit(int imageId, String prompt) async {
    try {
      final response = await _apiClient.post(
        '/image-editor/smart-edit/',
        data: {
          'image_id': imageId,
          'prompt': prompt,
        },
      );
      return response.data['image_data'] ?? '';
    } catch (e) {
      throw Exception('Failed to edit image: $e');
    }
  }
}

final imageEditorRepositoryProvider = Provider<ImageEditorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ImageEditorRepository(apiClient);
});

final imageTemplatesProvider = FutureProvider<List<ImageTemplate>>((ref) async {
  final repository = ref.watch(imageEditorRepositoryProvider);
  return await repository.getTemplates();
});
