import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_theme.dart';
import '../data/writer_repository.dart';
import 'writer_view_model.dart';

class WriterScreen extends ConsumerStatefulWidget {
  const WriterScreen({super.key});

  @override
  ConsumerState<WriterScreen> createState() => _WriterScreenState();
}

class _WriterScreenState extends ConsumerState<WriterScreen> {
  final TextEditingController _customPromptController = TextEditingController();

  @override
  void dispose() {
    _customPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final writerStateAsync = ref.watch(writerViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Writer',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              writerStateAsync.value?.isPreviewMode == true ? Icons.edit_note : Icons.auto_stories,
              color: Colors.white,
            ),
            onPressed: writerStateAsync.value?.isBusy == true ? null : () {
              ref.read(writerViewModelProvider.notifier).togglePreviewMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_edu, color: Colors.white),
            onPressed: writerStateAsync.value?.isBusy == true ? null : () {}, 
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.white),
            onPressed: writerStateAsync.value?.isBusy == true ? null : () {
              final currentState = writerStateAsync.value;
              if (currentState == null || currentState.textController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nothing to save')),
                );
                return;
              }
              _showSaveDialog(context, ref);
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: writerStateAsync.value?.isBusy == true ? null : () async {
              final currentState = writerStateAsync.value;
              if (currentState == null || currentState.textController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nothing to export')),
                );
                return;
              }
              
              try {
                final bytes = await ref.read(writerViewModelProvider.notifier).exportDocument('Document');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF Exported: ${bytes.length} bytes received')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
          ),
          const Gap(8),
        ],
      ),
      body: Stack(
        children: [
          // Premium Background
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.premiumGradient),
          ),
          // Animated Mesh-like overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Gap(8),
                  Expanded(
                    child: GlassContainer(
                      blur: 20,
                      opacity: 0.1,
                      padding: const EdgeInsets.all(20),
                      child: writerStateAsync.when(
                        data: (state) => Stack(
                          children: [
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: state.textController,
                              builder: (context, value, child) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: state.isPreviewMode 
                                    ? Markdown(
                                        key: const ValueKey('markdown_preview'),
                                        data: state.textController.text,
                                        styleSheet: MarkdownStyleSheet(
                                          p: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 18, height: 1.6),
                                          h1: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                          h2: GoogleFonts.outfit(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                          h3: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                          code: GoogleFonts.firaCode(
                                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                                            color: Colors.amberAccent,
                                          ),
                                          codeblockDecoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          blockquoteDecoration: BoxDecoration(
                                            border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 4)),
                                          ),
                                        ),
                                      )
                                    : TextField(
                                        key: const ValueKey('editor_field'),
                                        controller: state.textController,
                                        maxLines: null,
                                        expands: true,
                                        readOnly: state.isBusy,
                                        decoration: const InputDecoration(
                                          hintText: 'Ignite your creativity...',
                                          hintStyle: TextStyle(color: Colors.white38),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(bottom: 120),
                                        ),
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          height: 1.6,
                                        ),
                                        cursorColor: Colors.white,
                                      ),
                                );
                              },
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: state.textController,
                                    builder: (context, value, child) {
                                      final selection = value.selection;
                                      final isSelected = selection.isValid && !selection.isCollapsed;
                                      
                                      return AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: isSelected ? _SmartActionToolbar(
                                          key: const ValueKey('selection_toolbar'),
                                          isBusy: state.isBusy,
                                          onParaphrase: () => _handleSmartAction(context, ref, 'Paraphrase', selection),
                                          onFixGrammar: () => _handleSmartAction(context, ref, 'Fix Grammar', selection),
                                          onSummarize: () => _handleSmartAction(context, ref, 'Summarize', selection),
                                          onToneShift: () => _showToneShiftOptions(context, ref, selection, state.isBusy),
                                          onExpand: () => _handleSmartAction(context, ref, 'Expand Selection', selection),
                                          onPoetic: () => _handleSmartAction(context, ref, 'Make it Poetic', selection),
                                        ) : _IdleActionToolbar(
                                          key: const ValueKey('idle_toolbar'),
                                          isBusy: state.isBusy,
                                          onExpandDoc: () => _handleGeneralAction(context, ref, 'Expand Doc'),
                                          onRandomStory: () => _handleGeneralAction(context, ref, 'Random Story'),
                                          onRandomLetter: () => _handleGeneralAction(context, ref, 'Random Letter'),
                                          onRandomPoetry: () => _handleGeneralAction(context, ref, 'Random Poetry'),
                                        ),
                                      );
                                    },
                                  ),
                                  const Gap(12),
                                  if (state.showCustomPrompt) ...[
                                    GlassContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      color: Colors.black,
                                      opacity: 0.3,
                                      blur: 10,
                                      borderRadius: BorderRadius.circular(30),
                                      child: TextField(
                                        controller: _customPromptController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Whisper to Gemini...',
                                          hintStyle: const TextStyle(color: Colors.white30),
                                          border: InputBorder.none,
                                          icon: const Icon(Icons.auto_awesome, color: Colors.white70),
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.circle_notifications_outlined, color: Colors.white),
                                            onPressed: () {
                                              if (_customPromptController.text.isNotEmpty) {
                                                ref.read(writerViewModelProvider.notifier).generateCustomContent(_customPromptController.text);
                                                _customPromptController.clear();
                                              }
                                            },
                                          ),
                                        ),
                                        onSubmitted: (val) {
                                          if (val.isNotEmpty) {
                                             ref.read(writerViewModelProvider.notifier).generateCustomContent(val);
                                             _customPromptController.clear();
                                          }
                                        },
                                      ),
                                    ),
                                    const Gap(12),
                                    if (state.isBusy)
                                      JewelLoadingIndicator(message: state.statusMessage),
                                    const Gap(12),
                                  ],
                                  GestureDetector(
                                    onTap: state.isBusy ? null : () => ref.read(writerViewModelProvider.notifier).toggleCustomPrompt(),
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 200),
                                      opacity: state.isBusy ? 0.3 : 1.0,
                                      child: GlassContainer(
                                        width: 160,
                                        height: 36,
                                        opacity: 0.2,
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(state.showCustomPrompt ? Icons.close : Icons.keyboard, size: 14, color: Colors.white),
                                            const Gap(8),
                                            Text(
                                              state.showCustomPrompt ? 'Close Prompt' : 'Custom Action',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Document'),
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Document Title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context);
                try {
                  await ref.read(writerViewModelProvider.notifier).saveDocument(titleController.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document saved successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleSmartAction(BuildContext context, WidgetRef ref, String actionTitle, TextSelection selection) async {
    final templates = await ref.read(templatesProvider.future);
    try {
      final template = templates.firstWhere(
        (t) => t.title == actionTitle,
        orElse: () => throw Exception('Template "$actionTitle" not found'),
      );
      
      final text = ref.read(writerViewModelProvider).value!.textController.text;
      final selectedText = text.substring(selection.start, selection.end);
      
      ref.read(writerViewModelProvider.notifier).generateContent(
        template.id, 
        {'selection': selectedText},
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _handleGeneralAction(BuildContext context, WidgetRef ref, String actionTitle) async {
    final templates = await ref.read(templatesProvider.future);
    try {
      final template = templates.firstWhere(
        (t) => t.title == actionTitle,
        orElse: () => throw Exception('Template "$actionTitle" not found'),
      );
      
      final text = ref.read(writerViewModelProvider).value!.textController.text;
      
      ref.read(writerViewModelProvider.notifier).generateContent(
        template.id, 
        {'text': text}, // Using 'text' instead of 'selection' for doc-level actions
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _showToneShiftOptions(BuildContext context, WidgetRef ref, TextSelection selection, bool isBusy) {
    if (isBusy) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        color: Colors.white,
        opacity: 0.95,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Make Professional'), 
              onTap: isBusy ? null : () { Navigator.pop(context); _handleSmartAction(context, ref, 'Make Professional', selection); }
            ),
            ListTile(
              title: const Text('Make Witty'), 
              onTap: isBusy ? null : () { Navigator.pop(context); _handleSmartAction(context, ref, 'Make Witty', selection); }
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartActionToolbar extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onParaphrase;
  final VoidCallback onFixGrammar;
  final VoidCallback onSummarize;
  final VoidCallback onToneShift;
  final VoidCallback onExpand;
  final VoidCallback onPoetic;

  const _SmartActionToolbar({
    super.key,
    required this.isBusy,
    required this.onParaphrase,
    required this.onFixGrammar,
    required this.onSummarize,
    required this.onToneShift,
    required this.onExpand,
    required this.onPoetic,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isBusy ? 0.3 : 1.0,
      child: GlassContainer(
        height: 70,
        width: double.infinity,
        color: Colors.white,
        opacity: 0.9,
        borderRadius: BorderRadius.circular(35),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: isBusy ? const NeverScrollableScrollPhysics() : null,
          children: [
            Row(
              children: [
                _ActionButton(icon: Icons.refresh, label: 'Paraphrase', onTap: isBusy ? () {} : onParaphrase, disabled: isBusy),
                _ActionButton(icon: Icons.spellcheck, label: 'Grammar', onTap: isBusy ? () {} : onFixGrammar, disabled: isBusy),
                _ActionButton(icon: Icons.compress, label: 'Summarize', onTap: isBusy ? () {} : onSummarize, disabled: isBusy),
                _ActionButton(icon: Icons.tune, label: 'Tone', onTap: isBusy ? () {} : onToneShift, disabled: isBusy),
                _ActionButton(icon: Icons.format_indent_increase, label: 'Expand', onTap: isBusy ? () {} : onExpand, disabled: isBusy),
                _ActionButton(icon: Icons.auto_awesome_motion, label: 'Poetic', onTap: isBusy ? () {} : onPoetic, disabled: isBusy),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleActionToolbar extends StatelessWidget {
  final bool isBusy;
  final VoidCallback onExpandDoc;
  final VoidCallback onRandomStory;
  final VoidCallback onRandomLetter;
  final VoidCallback onRandomPoetry;

  const _IdleActionToolbar({
    super.key,
    required this.isBusy,
    required this.onExpandDoc,
    required this.onRandomStory,
    required this.onRandomLetter,
    required this.onRandomPoetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isBusy ? 0.3 : 1.0,
      child: GlassContainer(
        height: 60,
        width: double.infinity,
        color: Colors.white,
        opacity: 0.9,
        borderRadius: BorderRadius.circular(30),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(icon: Icons.add_circle_outline, label: 'Expand', onTap: isBusy ? () {} : onExpandDoc, disabled: isBusy),
            _ActionButton(icon: Icons.book_outlined, label: 'Story', onTap: isBusy ? () {} : onRandomStory, disabled: isBusy),
            _ActionButton(icon: Icons.mail_outline, label: 'Letter', onTap: isBusy ? () {} : onRandomLetter, disabled: isBusy),
            _ActionButton(icon: Icons.auto_stories, label: 'Poetry', onTap: isBusy ? () {} : onRandomPoetry, disabled: isBusy),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  const _ActionButton({
    required this.icon, 
    required this.label, 
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: disabled ? Colors.grey : AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                color: disabled ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
