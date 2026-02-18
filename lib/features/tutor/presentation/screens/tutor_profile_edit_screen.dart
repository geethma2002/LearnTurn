import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../domain/tutor_profile_model.dart';

class TutorProfileEditScreen extends ConsumerStatefulWidget {
  const TutorProfileEditScreen({super.key});

  @override
  ConsumerState<TutorProfileEditScreen> createState() => _TutorProfileEditScreenState();
}

class _TutorProfileEditScreenState extends ConsumerState<TutorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _bio, _qualifications, _rate;
  List<String> _subjects = [];
  List<AvailabilitySlot> _availability = [];
  int _experienceYears = 0;
  bool _verified = false;
  bool _loading = true;
  bool _saving = false;
  File? _pickedImage;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _bio = TextEditingController();
    _qualifications = TextEditingController();
    _rate = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _qualifications.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _load(WidgetRef ref) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final repo = ref.read(firestoreRepositoryProvider);
    final profile = await repo.getTutorProfile(uid);
    if (profile != null && mounted) {
      _name.text = profile.displayName ?? '';
      _bio.text = profile.bio ?? '';
      _qualifications.text = profile.qualifications ?? '';
      _rate.text = profile.hourlyRate > 0 ? profile.hourlyRate.toString() : '';
      _subjects = List.from(profile.subjects);
      _availability = List.from(profile.availability);
      _experienceYears = profile.experienceYears;
      _verified = profile.verified;
      _photoUrl = profile.photoUrl;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (x != null && mounted) setState(() => _pickedImage = File(x.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    final repo = ref.read(firestoreRepositoryProvider);
    final storage = ref.read(storageRepositoryProvider);
    String? photoUrl = _photoUrl;
    if (_pickedImage != null) photoUrl = await storage.uploadProfilePhoto(uid, _pickedImage!, isTutor: true);
    final rate = double.tryParse(_rate.text) ?? 0.0;
    await repo.setTutorProfile(TutorProfile(
      userId: uid,
      displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      photoUrl: photoUrl,
      bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      subjects: _subjects,
      qualifications: _qualifications.text.trim().isEmpty ? null : _qualifications.text.trim(),
      experienceYears: _experienceYears,
      hourlyRate: rate,
      availability: _availability,
      verified: _verified,
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
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_photoUrl != null ? NetworkImage(_photoUrl!) : null),
                    child: _pickedImage == null && _photoUrl == null ? const Icon(Icons.add_a_photo, size: 40) : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bio,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualifications,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Qualifications'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _experienceYears,
                decoration: const InputDecoration(labelText: 'Years of experience'),
                items: List.generate(21, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                onChanged: (v) => setState(() => _experienceYears = v ?? 0),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Hourly rate (\$)'),
                validator: (v) {
                  if (v != null && v.isNotEmpty && (double.tryParse(v) == null || double.tryParse(v)! < 0)) return 'Enter a valid rate';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Subjects taught', style: theme.textTheme.titleSmall),
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
                      content: TextField(controller: tc, decoration: const InputDecoration(hintText: 'e.g. Mathematics')),
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
              Text('Availability', style: theme.textTheme.titleSmall),
              ..._availability.asMap().entries.map((e) => ListTile(
                    title: Text('${e.value.day} ${e.value.startTime}-${e.value.endTime}'),
                    trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(() => _availability.removeAt(e.key))),
                  )),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add slot'),
                onPressed: () async {
                  final day = await showDialog<String>(context: context, builder: (c) {
                    return AlertDialog(
                      title: const Text('Day'),
                      content: DropdownButtonFormField<String>(
                        items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) => Navigator.pop(c, v),
                      ),
                    );
                  });
                  if (day != null) {
                    setState(() => _availability.add(AvailabilitySlot(day: day, startTime: '09:00', endTime: '17:00')));
                  }
                },
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
