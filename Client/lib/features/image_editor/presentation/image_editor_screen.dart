import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_theme.dart';
import '../data/image_editor_repository.dart';
import 'image_editor_view_model.dart';

class ImageEditorScreen extends ConsumerWidget {
  const ImageEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorViewModelProvider);
    final viewModel = ref.read(imageEditorViewModelProvider.notifier);
    
    final currentState = state.value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Image Studio',
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
                  // Cinematic Image Preview
                  GlassContainer(
                    height: 350,
                    padding: EdgeInsets.zero,
                    opacity: 0.1,
                    blur: 25,
                    child: currentState?.selectedImagePath == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, size: 80, color: Colors.white.withValues(alpha: 0.4)),
                                const Gap(20),
                                FilledButton.icon(
                                  onPressed: () => _pickImage(viewModel),
                                  icon: const Icon(Icons.rocket_launch),
                                  label: const Text('Ignite Design'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(currentState!.selectedImagePath!), fit: BoxFit.cover),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: IconButton.filled(
                                    onPressed: currentState.isBusy == true ? null : () => _pickImage(viewModel),
                                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const Gap(32),

                  // Smart Action Grid
                  _buildSectionHeader(context, 'Smart Actions'),
                  const Gap(16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                       _QuickActionButton(
                        icon: Icons.auto_fix_normal, 
                        label: 'Remove BG', 
                        onTap: currentState?.isBusy == true ? () {} : () => viewModel.smartEdit('Remove the background and return a transparent or clean white background mask'),
                        disabled: currentState?.isBusy ?? false,
                      ),
                       _QuickActionButton(
                        icon: Icons.movie_filter_outlined, 
                        label: 'B&W', 
                        onTap: currentState?.isBusy == true ? () {} : () => viewModel.smartEdit('Convert the image to cinematic black and white'),
                        disabled: currentState?.isBusy ?? false,
                      ),
                       _QuickActionButton(
                        icon: Icons.flare_rounded, 
                        label: 'Vibrant', 
                        onTap: currentState?.isBusy == true ? () {} : () => viewModel.smartEdit('Enhance colors and brightness to make it look vibrant and professional'),
                        disabled: currentState?.isBusy ?? false,
                      ),
                       _QuickActionButton(
                        icon: Icons.center_focus_strong, 
                        label: 'Smart Crop', 
                        onTap: currentState?.isBusy == true ? () {} : () => viewModel.smartEdit('Analyze the subject and crop the image to focus perfectly on the main subject'),
                        disabled: currentState?.isBusy ?? false,
                      ),
                       _QuickActionButton(
                        icon: Icons.high_quality_rounded, 
                        label: 'Sharpen', 
                        onTap: currentState?.isBusy == true ? () {} : () => viewModel.smartEdit('Apply a professional sharpening filter to enhance details'),
                        disabled: currentState?.isBusy ?? false,
                      ),
                      _QuickActionButton(
                        icon: Icons.auto_awesome, 
                        label: 'Custom', 
                        onTap: currentState?.isBusy == true ? () {} : () => viewModel.toggleCustomPrompt(),
                        isActive: currentState?.showCustomPrompt ?? false,
                        disabled: currentState?.isBusy ?? false,
                      ),
                    ],
                  ),

                  if (currentState?.showCustomPrompt ?? false) ...[
                    const Gap(20),
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      color: Colors.black,
                      opacity: 0.3,
                      blur: 10,
                      borderRadius: BorderRadius.circular(30),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.psychology_outlined, color: Colors.white70),
                          hintText: 'Describe your edit...',
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                        ),
                        readOnly: currentState?.isBusy ?? false,
                        onSubmitted: (value) {
                          if (value.isNotEmpty && currentState?.isBusy == false) {
                             viewModel.smartEdit(value);
                          }
                        },
                      ),
                    ),
                  ],

                  const Gap(32),

                  // High-End Artistic Styles
                  _buildSectionHeader(context, 'Artistic Styles'),
                  const Gap(16),
                  const _TemplateSelector(),
                  const Gap(40),

                  // Magic Result Canvas
                  if (currentState?.isBusy ?? false)
                    Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: JewelLoadingIndicator(message: currentState?.statusMessage),
                    ))
                  else if (currentState?.generatedContent != null || currentState?.generatedImageData != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader(context, 'Gemini Result'),
                        const Gap(16),
                        GlassContainer(
                          padding: const EdgeInsets.all(4), // Thin border feel
                          opacity: 0.2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (currentState?.generatedImageData != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    base64Decode(currentState!.generatedImageData!),
                                    fit: BoxFit.contain,
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    currentState!.generatedContent!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('${state.error}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
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

  Future<void> _pickImage(ImageEditorViewModel viewModel) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      viewModel.selectImage(result.files.single.path!);
    }
  }
}

class _TemplateSelector extends ConsumerWidget {
  const _TemplateSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(imageTemplatesProvider);

    return templatesAsync.when(
      data: (templates) => SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: templates.length,
          separatorBuilder: (_, _) => const Gap(16),
          itemBuilder: (context, index) {
            final template = templates[index];
            return InkWell(
              onTap: (ref.read(imageEditorViewModelProvider).value?.isBusy ?? false) 
                  ? null 
                  : () {
                ref.read(imageEditorViewModelProvider.notifier).generateContent(template.id);
              },
              borderRadius: BorderRadius.circular(24),
              child: GlassContainer(
                width: 120,
                padding: const EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(24),
                opacity: 0.15,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (ref.read(imageEditorViewModelProvider).value?.isBusy ?? false) ? 0.4 : 1.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.palette_outlined, color: Colors.white, size: 28),
                      ),
                      const Gap(12),
                      Text(
                        template.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool disabled;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.4 : 1.0,
        child: GlassContainer(
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(24),
          color: isActive ? Colors.white : Colors.white,
          opacity: isActive ? 0.3 : 0.1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                color: Colors.white,
                size: 28,
              ),
              const Gap(8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
