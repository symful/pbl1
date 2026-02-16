import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/video_editor_repository.dart';

class VideoEditorState {
  final VideoProject? currentProject;
  final List<StoryboardScene>? storyboard;
  final bool isBusy;
  final String? statusMessage;

  VideoEditorState({
    this.currentProject,
    this.storyboard,
    this.isBusy = false,
    this.statusMessage,
  });

  VideoEditorState copyWith({
    VideoProject? currentProject,
    List<StoryboardScene>? storyboard,
    bool? isBusy,
    String? statusMessage,
  }) {
    return VideoEditorState(
      currentProject: currentProject ?? this.currentProject,
      storyboard: storyboard ?? this.storyboard,
      isBusy: isBusy ?? this.isBusy,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class VideoEditorViewModel extends AsyncNotifier<VideoEditorState> {
  @override
  FutureOr<VideoEditorState> build() {
    return VideoEditorState();
  }

  Future<void> generateScript(String idea) async {
    final repository = ref.read(videoEditorRepositoryProvider);
    final currentState = state.value ?? VideoEditorState();
    
    state = AsyncValue.data(currentState.copyWith(isBusy: true, statusMessage: 'Gemini is drafting your script...'));
    
    try {
      final stream = repository.generateScriptStream(idea);
      
      int? projectId;
      String fullScript = "";
      
      await for (final chunk in stream) {
        if (chunk.startsWith('PROJECT_ID:')) {
          final parts = chunk.split('\n');
          projectId = int.tryParse(parts[0].split(':')[1]);
          if (parts.length > 1) {
            fullScript += parts.sublist(1).join('\n');
          }
        } else if (chunk.startsWith('[ERROR]')) {
          throw Exception(chunk.replaceAll('[ERROR] ', ''));
        } else {
          fullScript += chunk;
        }

        if (projectId != null) {
          state = AsyncValue.data(VideoEditorState(
            currentProject: VideoProject(
              id: projectId,
              title: idea.length > 50 ? idea.substring(0, 50) : idea,
              ideaDescription: idea,
              generatedScript: fullScript,
            ),
            isBusy: true,
            statusMessage: 'Transcribing idea...',
          ));
        }
      }
      
      state = AsyncValue.data(state.value!.copyWith(isBusy: false, statusMessage: null));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> generateStoryboard() async {
    final currentState = state.value;
    if (currentState == null || currentState.currentProject == null) return;

    final repository = ref.read(videoEditorRepositoryProvider);
    state = AsyncValue.data(currentState.copyWith(isBusy: true, statusMessage: 'Vizioning storyboard...'));

    try {
      final storyboard = await repository.generateStoryboard(currentState.currentProject!.id);
      state = AsyncValue.data(currentState.copyWith(
        storyboard: storyboard,
        isBusy: false,
        statusMessage: null,
      ));
      
      // Auto-visualize first few scenes
      for (var i = 0; i < storyboard.length && i < 3; i++) {
        visualizeScene(i);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> visualizeScene(int index) async {
    final currentState = state.value;
    if (currentState == null || currentState.storyboard == null) return;
    if (index >= currentState.storyboard!.length) return;

    final repository = ref.read(videoEditorRepositoryProvider);
    final scene = currentState.storyboard![index];
    if (scene.svgCode != null) return; // Already visualized

    try {
      final svg = await repository.visualizeScene(scene.visualDescription);
      final updatedStoryboard = List<StoryboardScene>.from(currentState.storyboard!);
      updatedStoryboard[index] = StoryboardScene(
        sceneNumber: scene.sceneNumber,
        visualDescription: scene.visualDescription,
        audioText: scene.audioText,
        duration: scene.duration,
        svgCode: svg,
      );
      state = AsyncValue.data(currentState.copyWith(storyboard: updatedStoryboard));
    } catch (e) {
      // Background failure is okay for visualization
    }
  }
}

final videoEditorViewModelProvider = AsyncNotifierProvider.autoDispose<VideoEditorViewModel, VideoEditorState>(VideoEditorViewModel.new);
