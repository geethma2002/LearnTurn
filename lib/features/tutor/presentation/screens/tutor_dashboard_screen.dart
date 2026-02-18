import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';

class TutorDashboardScreen extends ConsumerWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final theme = Theme.of(context);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnTurn Tutor'),
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => context.push('/tutor/chats')),
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
          Text('Welcome, ${user.displayName ?? user.email}', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Manage your profile and sessions.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          _DashboardCard(
            icon: Icons.person_outline,
            title: 'My profile',
            subtitle: 'Bio, subjects, rate, availability',
            onTap: () => context.push('/tutor/profile/edit'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            icon: Icons.event_note,
            title: 'Booking requests',
            subtitle: 'Accept or reject session requests',
            onTap: () => context.push('/tutor/bookings'),
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
              CircleAvatar(radius: 28, child: Icon(icon, size: 28)),
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
