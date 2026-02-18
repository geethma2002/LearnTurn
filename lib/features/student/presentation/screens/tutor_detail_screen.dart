import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../bookings/domain/booking_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../tutor/domain/tutor_profile_model.dart';

class TutorDetailScreen extends ConsumerStatefulWidget {
  final String tutorId;

  const TutorDetailScreen({super.key, required this.tutorId});

  @override
  ConsumerState<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends ConsumerState<TutorDetailScreen> {
  TutorProfile? _tutor;
  bool _loading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(firestoreRepositoryProvider);
    final tutor = await repo.getTutorProfile(widget.tutorId);
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    bool fav = false;
    if (uid != null) fav = await repo.isFavorite(uid, widget.tutorId);
    if (mounted) setState(() {
      _tutor = tutor;
      _isFavorite = fav;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final repo = ref.read(firestoreRepositoryProvider);
    if (_isFavorite) {
      await repo.removeFavorite(uid, widget.tutorId);
    } else {
      await repo.addFavorite(uid, widget.tutorId);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _sendRequest() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null || _tutor == null) return;
    final subject = await showDialog<String>(context: context, builder: (c) {
      final tc = TextEditingController(text: _tutor!.subjects.isNotEmpty ? _tutor!.subjects.first : null);
      return AlertDialog(
        title: const Text('Request session'),
        content: TextField(controller: tc, decoration: const InputDecoration(labelText: 'Subject')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(c, tc.text),
            child: const Text('Send request'),
          ),
        ],
      );
    });
    if (subject == null || subject.trim().isEmpty) return;
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (time == null) return;
    final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final repo = ref.read(firestoreRepositoryProvider);
    final booking = Booking(
      id: '',
      studentId: uid,
      tutorId: widget.tutorId,
      subject: subject.trim(),
      scheduledAt: scheduledAt,
      agreedPrice: _tutor!.hourlyRate,
      createdAt: DateTime.now(),
    );
    await repo.createBooking(booking);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session request sent')));
      context.push('/student/bookings');
    }
  }

  Future<void> _openChat() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final repo = ref.read(firestoreRepositoryProvider);
    final chatId = await repo.getOrCreateChat(uid, widget.tutorId);
    if (mounted) context.push('/student/chat/$chatId');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Tutor')), body: const Center(child: CircularProgressIndicator()));
    if (_tutor == null) return Scaffold(appBar: AppBar(title: const Text('Tutor')), body: const Center(child: Text('Tutor not found')));
    final t = _tutor!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor profile'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: t.photoUrl != null ? CachedNetworkImageProvider(t.photoUrl!) : null,
                child: t.photoUrl == null ? Text((t.displayName ?? 'T')[0].toUpperCase(), style: theme.textTheme.displaySmall) : null,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.displayName ?? 'Tutor', style: theme.textTheme.headlineSmall),
                if (t.verified) const SizedBox(width: 8),
                if (t.verified) Icon(Icons.verified, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 20, color: Colors.amber[700]),
                Text(' ${t.averageRating?.toStringAsFixed(1) ?? '-'} (${t.totalReviews ?? 0} reviews)', style: theme.textTheme.bodyLarge),
                const SizedBox(width: 16),
                Text('\$${t.hourlyRate.toStringAsFixed(0)}/hr', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
            if (t.bio != null && t.bio!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(t.bio!, style: theme.textTheme.bodyLarge),
            ],
            if (t.subjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Subjects', style: theme.textTheme.titleMedium),
              Wrap(spacing: 8, children: t.subjects.map((s) => Chip(label: Text(s))).toList()),
            ],
            if (t.qualifications != null && t.qualifications!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Qualifications', style: theme.textTheme.titleMedium),
              Text(t.qualifications!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _sendRequest,
              icon: const Icon(Icons.event_available),
              label: const Text('Request session'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Message tutor'),
            ),
          ],
        ),
      ),
    );
  }
}
