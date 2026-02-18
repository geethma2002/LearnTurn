import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'LearnTurn',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.9, 0.9)),
                    const SizedBox(height: 8),
                    Text(
                      'Your path to better grades starts here',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 48),
                    _StepCard(
                      step: 1,
                      title: 'Search tutor',
                      subtitle: 'Browse verified tutors by subject, price, and availability.',
                      icon: Icons.search_rounded,
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    _StepCard(
                      step: 2,
                      title: 'Connect',
                      subtitle: 'Send a session request and chat with your tutor before booking.',
                      icon: Icons.handshake_rounded,
                    )
                        .animate()
                        .fadeIn(delay: 450.ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 16),
                    _StepCard(
                      step: 3,
                      title: 'Start learning',
                      subtitle: 'Join live sessions, track progress, and leave reviews.',
                      icon: Icons.school_rounded,
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 40),
                    FilledButton(
                      onPressed: () => context.push('/register'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: const Text('Sign Up'),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/login'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: const Text('Sign In'),
                    )
                        .animate()
                        .fadeIn(delay: 750.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => context.push('/register?role=tutor'),
                      icon: const Icon(Icons.person_add_rounded, size: 20),
                      label: const Text('Become a Tutor'),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text('$step', style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: theme.colorScheme.primary, size: 32),
          ],
        ),
      ),
    );
  }
}
