import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Gemini Studio',
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
                   const Gap(20),
                  // Hero Section
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    opacity: 0.1,
                    blur: 30,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, size: 48, color: Colors.white),
                        ),
                        const Gap(20),
                        Text(
                          'Empower Your Vision',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'Experience the next generation of AI-driven creative tools powered by Gemini 2.5 Flash.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(40),

                  _FeatureCard(
                    title: 'The Writer',
                    description: 'Draft, fix, and expand documents with real-time streaming AI assistance.',
                    icon: Icons.edit_note_rounded,
                    gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                    onTap: () => context.push('/writer'),
                  ),
                  const Gap(20),
                  _FeatureCard(
                    title: 'Image Studio',
                    description: 'Transform images with smart prompts. Remove backgrounds, sharpen, and stylize.',
                    icon: Icons.auto_fix_high_rounded,
                    gradient: const [Color(0xFFff9a9e), Color(0xFFfecfef)],
                    onTap: () => context.push('/image-editor'),
                  ),
                  const Gap(20),
                  _FeatureCard(
                    title: 'Director Engine',
                    description: 'Turn whispers of ideas into detailed scripts and visual storyboards.',
                    icon: Icons.movie_filter_rounded,
                    gradient: const [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
                    onTap: () => context.push('/video-editor'),
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        opacity: 0.1,
        blur: 15,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      description,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white60,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}
