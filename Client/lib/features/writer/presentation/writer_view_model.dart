import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/writer_repository.dart';

class WriterState {
  final TextEditingController textController;
  final bool showCustomPrompt;
  final bool isBusy;
  final String? statusMessage;
  final bool isPreviewMode;
  
  WriterState({
    required this.textController,
    this.showCustomPrompt = false,
    this.isBusy = false,
    this.statusMessage,
    this.isPreviewMode = false,
  });

  WriterState copyWith({
    bool? showCustomPrompt,
    bool? isBusy,
    String? statusMessage,
    bool? isPreviewMode,
  }) {
    return WriterState(
      textController: textController,
      showCustomPrompt: showCustomPrompt ?? this.showCustomPrompt,
      isBusy: isBusy ?? this.isBusy,
      statusMessage: statusMessage ?? this.statusMessage,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
    );
  }
}

class WriterViewModel extends AsyncNotifier<WriterState> {
  @override
  FutureOr<WriterState> build() {
    return WriterState(textController: TextEditingController());
  }

  Future<void> generateContent(int templateId, Map<String, String> variables) async {
    final repository = ref.read(writerRepositoryProvider);
    final currentState = state.value;
    if (currentState == null) return;

    final controller = currentState.textController;
    
    // Determine location to append
    final selection = controller.selection;
    final isSelected = selection.isValid && !selection.isCollapsed;
    
    if (controller.text.isNotEmpty && !isSelected) {
      controller.text += '\n\n';
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }

    state = AsyncValue.data(currentState.copyWith(
      isBusy: true,
      statusMessage: 'Gemini is weaving words...',
      showCustomPrompt: false,
    ));
    
    try {
      final stream = repository.generateContentStream(
        templateId: templateId,
        variables: variables,
      );

      await for (final chunk in stream) {
        if (chunk.startsWith('[ERROR]')) {
          throw Exception(chunk.replaceAll('[ERROR] ', ''));
        }
        
        final currentText = controller.text;
        final newText = currentText + chunk;
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
      }
      
      state = AsyncValue.data(currentState.copyWith(isBusy: false, statusMessage: null));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> generateCustomContent(String prompt) async {
    final templates = await ref.read(templatesProvider.future);
    final directPrompt = templates.firstWhere(
      (t) => t.title == 'Direct Prompt',
      orElse: () => throw Exception('Direct Prompt template not found'),
    );
    
    await generateContent(directPrompt.id, {'prompt': prompt});
  }

  void toggleCustomPrompt() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(showCustomPrompt: !currentState.showCustomPrompt));
    }
  }

  void togglePreviewMode() {
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(isPreviewMode: !currentState.isPreviewMode));
    }
  }

  Future<void> saveDocument(String title) async {
    final repository = ref.read(writerRepositoryProvider);
    final currentState = state.value;
    
    if (currentState == null || currentState.textController.text.isEmpty) {
      throw Exception('Nothing to save');
    }

    state = AsyncValue.data(currentState.copyWith(isBusy: true, statusMessage: 'Archiving document...'));
    
    try {
      await repository.saveDocument(title, currentState.textController.text);
      state = AsyncValue.data(currentState.copyWith(isBusy: false, statusMessage: null));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<List<int>> exportDocument(String title) async {
    final repository = ref.read(writerRepositoryProvider);
    final currentState = state.value;
    
    if (currentState == null || currentState.textController.text.isEmpty) {
      throw Exception('Nothing to export');
    }

    state = AsyncValue.data(currentState.copyWith(isBusy: true, statusMessage: 'Exporting PDF...'));
    try {
      final bytes = await repository.exportToPdf(title, currentState.textController.text);
      state = AsyncValue.data(currentState.copyWith(isBusy: false, statusMessage: null));
      return bytes;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final writerViewModelProvider = AsyncNotifierProvider.autoDispose<WriterViewModel, WriterState>(WriterViewModel.new);
