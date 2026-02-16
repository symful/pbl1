import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/shared_providers.dart';

// --- Domain/Data Model ---
class PromptTemplate {
  final int id;
  final String title;
  final String description;
  final String category;
  final String templateType;
  final String templateText;

  PromptTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.templateType,
    required this.templateText,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      templateType: json['template_type'] ?? 'generation',
      templateText: json['template_text'],
    );
  }
}

// --- Repository ---
class WriterRepository {
  final ApiClient _apiClient;

  WriterRepository(this._apiClient);

  Future<List<PromptTemplate>> getTemplates() async {
    try {
      final response = await _apiClient.get('/writer/templates/');
      final List<dynamic> data = response.data;
      return data.map((e) => PromptTemplate.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load templates: $e');
    }
  }

  Future<String> generateContent({
    required int templateId,
    Map<String, String>? variables,
  }) async {
    try {
      final response = await _apiClient.post(
        '/writer/generate/',
        data: {
          'template_id': templateId,
          'variables': variables ?? {},
        },
      );
      return response.data['content'] ?? '';
    } catch (e) {
      throw Exception('Failed to generate content: $e');
    }
  }

  Stream<String> generateContentStream({
    required int templateId,
    Map<String, String>? variables,
  }) async* {
    try {
      final response = await _apiClient.postStream(
        '/writer/generate/',
        data: {
          'template_id': templateId,
          'variables': variables ?? {},
        },
      );

      final stream = response.data!.stream;
      await for (final chunk in stream) {
        final text = String.fromCharCodes(chunk);
        yield text;
      }
    } catch (e) {
      throw Exception('Streaming failed: $e');
    }
  }

  Future<List<Document>> getDocuments() async {
    try {
      final response = await _apiClient.get('/writer/documents/');
      final List<dynamic> data = response.data;
      return data.map((e) => Document.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load documents: $e');
    }
  }

  Future<Document> saveDocument(String title, String content) async {
    try {
      final response = await _apiClient.post(
        '/writer/documents/',
        data: {
          'title': title,
          'content': content,
        },
      );
      return Document.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save document: $e');
    }
  }

  Future<List<int>> exportToPdf(String title, String content) async {
    try {
      final response = await _apiClient.postBytes(
        '/writer/export-pdf/',
        data: {
          'title': title,
          'content': content,
        },
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }
}

class Document {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;

  Document({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// --- Providers ---
final writerRepositoryProvider = Provider<WriterRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WriterRepository(apiClient);
});

final templatesProvider = FutureProvider<List<PromptTemplate>>((ref) async {
  final repository = ref.watch(writerRepositoryProvider);
  return await repository.getTemplates();
});
