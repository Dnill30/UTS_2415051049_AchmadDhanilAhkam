import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _nim;
  late final TextEditingController _kelas;
  late final TextEditingController _bio;
  late int _color;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>().profile;
    _name = TextEditingController(text: p.name);
    _nim = TextEditingController(text: p.nim);
    _kelas = TextEditingController(text: p.kelas);
    _bio = TextEditingController(text: p.bio);
    _color = p.avatarColor;
  }

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _kelas.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final profile = Profile(
      name: _name.text.trim(),
      nim: _nim.text.trim(),
      kelas: _kelas.text.trim(),
      bio: _bio.text.trim(),
      avatarColor: _color,
    );

    final error = await context.read<ProfileProvider>().save(profile);

    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Profile disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _name,
                    builder: (context, value, _) => ProfileAvatar(
                      name: value.text,
                      colorIndex: _color,
                      radius: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Warna avatar', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < ProfileAvatar.colors.length; i++)
                      GestureDetector(
                        onTap: () => setState(() => _color = i),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ProfileAvatar.colors[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == i
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Nama tidak boleh kosong';
                    if (t.length < 3) return 'Nama minimal 3 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nim,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'NIM',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'NIM tidak boleh kosong';
                    if (!RegExp(r'^\d+$').hasMatch(t)) {
                      return 'NIM hanya boleh angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _kelas,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Kelas tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bio,
                  maxLines: 3,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Bio (opsional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}