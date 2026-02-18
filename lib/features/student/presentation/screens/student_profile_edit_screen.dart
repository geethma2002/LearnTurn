import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/student_profile_model.dart';

class StudentProfileEditScreen extends ConsumerStatefulWidget {
  const StudentProfileEditScreen({super.key});

  @override
  ConsumerState<StudentProfileEditScreen> createState() => _StudentProfileEditScreenState();
}

class _StudentProfileEditScreenState extends ConsumerState<StudentProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _grade, _schedule, _budget, _goals;
  List<String> _subjects = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _grade = TextEditingController();
    _schedule = TextEditingController();
    _budget = TextEditingController();
    _goals = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _grade.dispose();
    _schedule.dispose();
    _budget.dispose();
    _goals.dispose();
    super.dispose();
  }

  Future<void> _load(WidgetRef ref) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final repo = ref.read(firestoreRepositoryProvider);
    final profile = await repo.getStudentProfile(uid);
    if (profile != null && mounted) {
      _name.text = profile.displayName ?? '';
      _grade.text = profile.gradeLevel ?? '';
      _schedule.text = profile.preferredSchedule ?? '';
      _budget.text = profile.budget ?? '';
      _goals.text = profile.learningGoals ?? '';
      setState(() => _subjects = List.from(profile.subjectsNeeded));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    await ref.read(firestoreRepositoryProvider).setStudentProfile(StudentProfile(
          userId: uid,
          displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
          gradeLevel: _grade.text.trim().isEmpty ? null : _grade.text.trim(),
          subjectsNeeded: _subjects,
          preferredSchedule: _schedule.text.trim().isEmpty ? null : _schedule.text.trim(),
          budget: _budget.text.trim().isEmpty ? null : _budget.text.trim(),
          learningGoals: _goals.text.trim().isEmpty ? null : _goals.text.trim(),
        ));
    if (mounted) {
      setState(() => _saving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid != null && _loading) {
      Future.microtask(() => _load(ref));
      return Scaffold(appBar: AppBar(title: const Text('Edit profile')), body: const Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _grade,
                decoration: const InputDecoration(labelText: 'Grade / Level'),
              ),
              const SizedBox(height: 16),
              Text('Subjects needed', style: theme.textTheme.titleSmall),
              Wrap(
                spacing: 8,
                children: _subjects.map((s) => Chip(label: Text(s), onDeleted: () => setState(() => _subjects.remove(s)))).toList(),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add subject'),
                onPressed: () async {
                  final v = await showDialog<String>(context: context, builder: (c) {
                    final tc = TextEditingController();
                    return AlertDialog(
                      title: const Text('Add subject'),
                      content: TextField(controller: tc, decoration: const InputDecoration(hintText: 'e.g. Math')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(c, tc.text), child: const Text('Add')),
                      ],
                    );
                  });
                  if (v != null && v.trim().isNotEmpty && !_subjects.contains(v.trim())) setState(() => _subjects.add(v.trim()));
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schedule,
                decoration: const InputDecoration(labelText: 'Preferred schedule'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budget,
                decoration: const InputDecoration(labelText: 'Budget (e.g. \$30/hour)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _goals,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Learning goals'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
