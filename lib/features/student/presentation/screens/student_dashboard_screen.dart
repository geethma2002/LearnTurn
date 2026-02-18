import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final theme = Theme.of(context);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnTurn'),
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => context.push('/student/chats')),
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {
              final mode = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') ref.read(authServiceProvider).signOut();
            },
            itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text('Sign out'))],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hi, ${user.displayName ?? user.email}!', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Find a tutor and start learning.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          _DashboardCard(
            icon: Icons.person_outline,
            title: 'My profile',
            subtitle: 'Edit your grade, subjects, and goals',
            onTap: () => context.push('/student/profile/edit'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            icon: Icons.search,
            title: 'Find tutors',
            subtitle: 'Search by subject, price, and availability',
            onTap: () => context.push('/student/search'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            icon: Icons.event_note,
            title: 'My bookings',
            subtitle: 'View pending and past sessions',
            onTap: () => context.push('/student/bookings'),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
