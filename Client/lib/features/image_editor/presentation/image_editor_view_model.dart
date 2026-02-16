import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/image_editor_repository.dart';

class ImageEditorState {
  final String? selectedImagePath;
  final int? uploadedImageId;
  final String? generatedContent;
  final String? generatedImageData; // Base64 string
  final bool showCustomPrompt;
  final bool isBusy;
  final String? statusMessage;

  ImageEditorState({
    this.selectedImagePath,
    this.uploadedImageId,
    this.generatedContent,
    this.generatedImageData,
    this.showCustomPrompt = false,
    this.isBusy = false,
    this.statusMessage,
  });

  ImageEditorState copyWith({
    String? selectedImagePath,
    int? uploadedImageId,
    String? generatedContent,
    String? generatedImageData,
    bool? showCustomPrompt,
    bool? isBusy,
    String? statusMessage,
  }) {
    return ImageEditorState(
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      uploadedImageId: uploadedImageId ?? this.uploadedImageId,
      generatedContent: generatedContent ?? this.generatedContent,
      generatedImageData: generatedImageData ?? this.generatedImageData,
      showCustomPrompt: showCustomPrompt ?? this.showCustomPrompt,
      isBusy: isBusy ?? this.isBusy,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class ImageEditorViewModel extends AsyncNotifier<ImageEditorState> {
  @override
  FutureOr<ImageEditorState> build() {
    return ImageEditorState();
  }

  Future<void> selectImage(String path) async {
    final repository = ref.read(imageEditorRepositoryProvider);
    final currentState = state.value ?? ImageEditorState();
    
    state = AsyncValue.data(currentState.copyWith(isBusy: true, statusMessage: 'Ingesting image...'));
    
    try {
      final id = await repository.uploadImage(path);
      state = AsyncValue.data(ImageEditorState(
        selectedImagePath: path,
        uploadedImageId: id,
        isBusy: false,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> generateContent(int templateId) async {
    final currentState = state.value;
    if (currentState == null || currentState.uploadedImageId == null) {
      return;
    }
    
    final repository = ref.read(imageEditorRepositoryProvider);
    state = AsyncValue.data(currentState.copyWith(isBusy: true, statusMessage: 'Gemini is analyzing vision...'));

    try {
      final content = await repository.generateContent(templateId, currentState.uploadedImageId!);
      state = AsyncValue.data(currentState.copyWith(
        generatedContent: content, 
        generatedImageData: null, 
        showCustomPrompt: false,
        isBusy: false,
        statusMessage: null,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void toggleCustomPrompt() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(showCustomPrompt: !currentState.showCustomPrompt));
    }
  }

  Future<void> smartEdit(String prompt) async {
    final currentState = state.value;
    if (currentState == null || currentState.uploadedImageId == null) {
      return;
    }

    final repository = ref.read(imageEditorRepositoryProvider);
    state = AsyncValue.data(currentState.copyWith(isBusy: true, statusMessage: 'Synthesizing transformation...'));

    try {
      final imageData = await repository.smartEdit(currentState.uploadedImageId!, prompt);
      state = AsyncValue.data(currentState.copyWith(
        generatedImageData: imageData, 
        generatedContent: null, 
        showCustomPrompt: false,
        isBusy: false,
        statusMessage: null,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final imageEditorViewModelProvider = AsyncNotifierProvider.autoDispose<ImageEditorViewModel, ImageEditorState>(ImageEditorViewModel.new);
