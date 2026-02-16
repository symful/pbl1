import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'video_editor_view_model.dart';
import '../data/video_editor_repository.dart';

class VideoEditorScreen extends ConsumerStatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  ConsumerState<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends ConsumerState<VideoEditorScreen> {
  final TextEditingController _ideaController = TextEditingController();

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoStateAsync = ref.watch(videoEditorViewModelProvider);
    final viewModel = ref.read(videoEditorViewModelProvider.notifier);

    final currentState = videoStateAsync.value;
    final errorMessage = videoStateAsync.error?.toString();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Director Studio',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Premium Background
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.premiumGradient),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(12),
                  _buildSectionHeader(context, 'AI Vision Engine'),
                  const Gap(8),
                  Text(
                    'Orchestrate cinematic experiences purely with Gemini',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                  ),
                  const Gap(24),
                  GlassContainer(
                     padding: const EdgeInsets.all(20),
                     opacity: 0.1,
                     blur: 20,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: [
                         TextField(
                          controller: _ideaController,
                          style: const TextStyle(color: Colors.white),
                          readOnly: currentState?.isBusy ?? false,
                          decoration: InputDecoration(
                            labelText: 'Video Concept',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'e.g. A cyberpunk rain-soaked alley...',
                            hintStyle: const TextStyle(color: Colors.white24),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            fillColor: Colors.black.withValues(alpha: 0.2),
                            filled: true,
                          ),
                          maxLines: 3,
                        ),
                        const Gap(20),
                        FilledButton.icon(
                          onPressed: (currentState?.isBusy ?? false)
                              ? null
                              : () {
                                  if (_ideaController.text.isNotEmpty) {
                                    viewModel.generateScript(_ideaController.text);
                                  }
                                },
                          icon: (currentState?.isBusy ?? false)
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.movie_creation_outlined),
                          label: const Text('Design Cinematic Script'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        if (currentState?.isBusy ?? false) ...[
                          const Gap(20),
                          JewelLoadingIndicator(message: currentState?.statusMessage),
                        ],
                       ],
                     ),
                  ),
                  
                  if (errorMessage != null) ...[
                    const Gap(16),
                    Text('Error: $errorMessage', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],

                  if (currentState?.currentProject != null) ...[
                    const Gap(32),
                    _buildSectionHeader(context, 'The Script'),
                    const Gap(16),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      opacity: 0.05,
                      child: Text(
                        currentState!.currentProject!.generatedScript,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const Gap(24),
                    
                    if (currentState.storyboard == null && !currentState.isBusy)
                      FilledButton.icon(
                        onPressed: () => viewModel.generateStoryboard(),
                        icon: const Icon(Icons.auto_awesome_motion_rounded),
                        label: const Text('Synthesize Visual Timeline'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      )
                    else if (currentState.isBusy && currentState.storyboard == null)
                      Center(child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: JewelLoadingIndicator(message: currentState.statusMessage),
                      )),

                    if (currentState.storyboard != null) ...[
                      const Gap(32),
                      _buildSectionHeader(context, 'Visual Storyboard'),
                      const Gap(16),
                      SizedBox(
                        height: 400,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: currentState.storyboard!.length,
                          separatorBuilder: (_, _) => const Gap(20),
                          itemBuilder: (context, index) {
                            final scene = currentState.storyboard![index];
                            return _SceneCard(
                              scene: scene, 
                              isBusy: currentState.isBusy,
                              onVisualize: () => viewModel.visualizeScene(index),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                  const Gap(80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  final StoryboardScene scene;
  final bool isBusy;
  final VoidCallback onVisualize;

  const _SceneCard({
    required this.scene, 
    required this.isBusy,
    required this.onVisualize,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: 300,
      padding: const EdgeInsets.all(16),
      opacity: 0.15,
      blur: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scene ${scene.sceneNumber}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${scene.duration}s',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ),
            ],
          ),
          const Gap(12),
          Expanded(
            child: GlassContainer(
              color: Colors.black,
              opacity: 0.2,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              child: scene.svgCode != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SvgPicture.string(
                        scene.svgCode!,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white54)),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_outlined, size: 48, color: Colors.white24),
                          const Gap(12),
                          TextButton(
                            onPressed: isBusy ? null : onVisualize,
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            child: const Text('Render Concept'),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const Gap(16),
          Text(
            scene.visualDescription,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.mic_none_rounded, size: 16, color: Colors.white70),
                const Gap(8),
                Expanded(
                  child: Text(
                    scene.audioText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
