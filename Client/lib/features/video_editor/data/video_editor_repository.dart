import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/shared_providers.dart';
import 'dart:convert';

class VideoProject {
  final int id;
  final String title;
  final String ideaDescription;
  final String generatedScript;

  VideoProject({
    required this.id,
    required this.title,
    required this.ideaDescription,
    required this.generatedScript,
  });

  factory VideoProject.fromJson(Map<String, dynamic> json) {
    return VideoProject(
      id: json['id'],
      title: json['title'],
      ideaDescription: json['idea_description'],
      generatedScript: json['generated_script'] ?? '',
    );
  }
}

class StoryboardScene {
  final int sceneNumber;
  final String visualDescription;
  final String audioText;
  final int duration;
  String? svgCode; // Populated later

  StoryboardScene({
    required this.sceneNumber,
    required this.visualDescription,
    required this.audioText,
    required this.duration,
    this.svgCode,
  });

  factory StoryboardScene.fromJson(Map<String, dynamic> json) {
    return StoryboardScene(
      sceneNumber: json['scene_number'],
      visualDescription: json['visual_description'],
      audioText: json['audio_text'],
      duration: json['duration'],
    );
  }
}

class VideoEditorRepository {
  final ApiClient _apiClient;

  VideoEditorRepository(this._apiClient);

  Future<VideoProject> generateScript(String idea) async {
    // keeping legacy or removing it? let's keep it for now but the UI will use stream
    try {
      final response = await _apiClient.post(
        '/video-editor/generate-script/',
        data: {'idea': idea},
      );
      return VideoProject.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to generate script: $e');
    }
  }

  Stream<String> generateScriptStream(String idea) async* {
    try {
      final response = await _apiClient.postStream(
        '/video-editor/generate-script/',
        data: {'idea': idea},
      );

      final stream = response.data!.stream;
      await for (final chunk in stream) {
        yield String.fromCharCodes(chunk);
      }
    } catch (e) {
      throw Exception('Video script streaming failed: $e');
    }
  }

  Future<List<StoryboardScene>> generateStoryboard(int projectId) async {
    try {
      final response = await _apiClient.post(
        '/video-editor/generate-storyboard/',
        data: {'project_id': projectId},
      );
      final List<dynamic> storyboardData = jsonDecode(response.data['storyboard']);
      return storyboardData.map((e) => StoryboardScene.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to generate storyboard: $e');
    }
  }

  Future<String> visualizeScene(String visualDescription) async {
    try {
      final response = await _apiClient.post(
        '/video-editor/visualize-scene/',
        data: {'visual_description': visualDescription},
      );
      return response.data['svg_code'];
    } catch (e) {
      throw Exception('Failed to visualize scene: $e');
    }
  }

  Future<List<VideoProject>> getProjects() async {
    try {
      final response = await _apiClient.get('/video-editor/projects/');
      final List<dynamic> data = response.data;
      return data.map((e) => VideoProject.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }
}

final videoEditorRepositoryProvider = Provider<VideoEditorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VideoEditorRepository(apiClient);
});
