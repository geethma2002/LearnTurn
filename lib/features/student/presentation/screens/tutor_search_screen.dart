import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../tutor/domain/tutor_profile_model.dart';

class TutorSearchScreen extends ConsumerStatefulWidget {
  const TutorSearchScreen({super.key});

  @override
  ConsumerState<TutorSearchScreen> createState() => _TutorSearchScreenState();
}

class _TutorSearchScreenState extends ConsumerState<TutorSearchScreen> {
  String _subjectFilter = '';
  double? _maxPrice;
  double? _minRating;
  List<TutorProfile> _tutors = [];
  bool _loading = false;

  Future<void> _search() async {
    setState(() => _loading = true);
    final repo = ref.read(firestoreRepositoryProvider);
    final list = await repo.searchTutors(
      subject: _subjectFilter.isEmpty ? null : _subjectFilter,
      maxPrice: _maxPrice,
      minRating: _minRating,
    );
    if (mounted) setState(() {
      _tutors = list;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Find tutors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'Subject', prefixIcon: Icon(Icons.search)),
                  onChanged: (v) => setState(() => _subjectFilter = v),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Max price'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() => _maxPrice = double.tryParse(v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Min rating'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() => _minRating = double.tryParse(v)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _loading ? null : _search, child: const Text('Search')),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tutors.isEmpty
                    ? Center(child: Text('No tutors found. Try different filters.', style: theme.textTheme.bodyLarge))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _tutors.length,
                        itemBuilder: (_, i) => _TutorCard(
                          tutor: _tutors[i],
                          onTap: () => context.push('/student/tutor/${_tutors[i].userId}'),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final TutorProfile tutor;
  final VoidCallback onTap;

  const _TutorCard({required this.tutor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: tutor.photoUrl != null ? CachedNetworkImageProvider(tutor.photoUrl!) : null,
                child: tutor.photoUrl == null ? Text((tutor.displayName ?? 'T')[0].toUpperCase()) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(tutor.displayName ?? 'Tutor', style: theme.textTheme.titleMedium),
                        if (tutor.verified) const SizedBox(width: 4),
                        if (tutor.verified) Icon(Icons.verified, size: 18, color: theme.colorScheme.primary),
                      ],
                    ),
                    if (tutor.subjects.isNotEmpty) Text(tutor.subjects.take(3).join(', '), style: theme.textTheme.bodySmall),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        Text(' ${tutor.averageRating?.toStringAsFixed(1) ?? '-'} (${tutor.totalReviews ?? 0})', style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Text('\$${tutor.hourlyRate.toStringAsFixed(0)}/hr', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
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
