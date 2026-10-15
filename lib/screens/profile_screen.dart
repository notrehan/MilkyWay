
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/human_profile.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<HumanProfile> onComplete;
  final HumanProfile? initialProfile;

  const ProfileScreen({
    super.key,
    required this.onComplete,
    this.initialProfile,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();

  String _breathingGas = 'Oxygen';
  String _pressure = 'Earth-like';
  String _temperature = 'Temperate';
  String _gravity = 'Earth-like';
  String _climate = 'Temperate';

  bool _needsWater = true;
  bool _lifeSupport = false;

  XFile? _photo;
  bool _submitting = false;

  static const _ink = Color(0xFF252622);
  static const _muted = Color(0xFF777873);
  static const _accent = Color(0xFF8B80B5);
  static const _border = Color(0xFFE8E8E3);

  @override
  void initState() {
    super.initState();

    final profile = widget.initialProfile;
    if (profile == null) return;

    _nameController.text = profile.name;
    _ageController.text = profile.age.toString();
    _bioController.text = profile.bio;

    _breathingGas = profile.breathingGas;
    _needsWater = profile.needsLiquidWater;
    _lifeSupport = profile.canUseLifeSupport;
    _climate = profile.preferredClimate;

    _pressure = profile.minPressure < 0.8
        ? 'Low pressure'
        : profile.maxPressure > 1.2
            ? 'High pressure'
            : 'Earth-like';

    _temperature = profile.minTemperature < -10
        ? 'Cold-adapted'
        : profile.maxTemperature > 40
            ? 'Heat-adapted'
            : 'Temperate';

    _gravity = profile.minGravity < 0.7
        ? 'Low gravity'
        : profile.maxGravity > 1.3
            ? 'High gravity'
            : 'Earth-like';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() => _photo = image);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not select the photo. Try again.'),
        ),
      );
    }
  }

  double get _minPressure {
    switch (_pressure) {
      case 'Low pressure':
        return 0.3;
      case 'High pressure':
        return 1.3;
      default:
        return 0.8;
    }
  }

  double get _maxPressure {
    switch (_pressure) {
      case 'Low pressure':
        return 0.8;
      case 'High pressure':
        return 2.0;
      default:
        return 1.2;
    }
  }

  double get _minTemperature {
    switch (_temperature) {
      case 'Cold-adapted':
        return -60;
      case 'Heat-adapted':
        return 10;
      default:
        return -10;
    }
  }

  double get _maxTemperature {
    switch (_temperature) {
      case 'Cold-adapted':
        return 10;
      case 'Heat-adapted':
        return 60;
      default:
        return 40;
    }
  }

  double get _minGravity {
    switch (_gravity) {
      case 'Low gravity':
        return 0.3;
      case 'High gravity':
        return 1.0;
      default:
        return 0.7;
    }
  }

  double get _maxGravity {
    switch (_gravity) {
      case 'Low gravity':
        return 0.8;
      case 'High gravity':
        return 2.0;
      default:
        return 1.3;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final profile = HumanProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      bio: _bioController.text.trim(),
      photoPath: _photo?.path ??
          widget.initialProfile?.photoPath,
      breathingGas: _breathingGas,
      minPressure: _minPressure,
      maxPressure: _maxPressure,
      minTemperature: _minTemperature,
      maxTemperature: _maxTemperature,
      minGravity: _minGravity,
      maxGravity: _maxGravity,
      needsLiquidWater: _needsWater,
      canUseLifeSupport: _lifeSupport,
      preferredClimate: _climate,
    );

    widget.onComplete(profile);
  }

  @override
  Widget build(BuildContext context) {
    final existingPhoto = widget.initialProfile?.photoPath;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
            children: [
              const Text(
                'Your cosmic profile',
                style: TextStyle(
                  color: _ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell the galaxy who you are and what you need to survive.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),

              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE6F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD9D1E7),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildPhoto(existingPhoto),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Tap to choose a profile photo',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),

              _heading('01', 'About you'),
              const SizedBox(height: 16),

              _textField(
                controller: _nameController,
                label: 'Display name',
                hint: 'What should aliens call you?',
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _ageController,
                label: 'Age',
                hint: '18 or older',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final age = int.tryParse(value ?? '');
                  if (age == null || age < 18 || age > 120) {
                    return 'Enter a valid age (18–120)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _textField(
                controller: _bioController,
                label: 'About me',
                hint: 'Space enthusiast, professional napper...',
                maxLines: 3,
                validator: (value) =>
                    value != null && value.length > 250
                        ? 'Keep your bio under 250 characters'
                        : null,
              ),
              const SizedBox(height: 30),

              _heading('02', 'Survival requirements'),
              const SizedBox(height: 8),
              const Text(
                'These settings help determine which planets '
                'are suitable for you.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              _dropdown(
                label: 'Breathing gas',
                value: _breathingGas,
                items: const [
                  'Oxygen',
                  'Methane',
                  'Carbon dioxide',
                  'Ammonia',
                  'Other',
                ],
                onChanged: (v) =>
                    setState(() => _breathingGas = v!),
              ),
              const SizedBox(height: 14),

              _dropdown(
                label: 'Atmospheric pressure tolerance',
                value: _pressure,
                items: const [
                  'Low pressure',
                  'Earth-like',
                  'High pressure',
                ],
                onChanged: (v) =>
                    setState(() => _pressure = v!),
              ),
              const SizedBox(height: 14),

              _dropdown(
                label: 'Temperature tolerance',
                value: _temperature,
                items: const [
                  'Cold-adapted',
                  'Temperate',
                  'Heat-adapted',
                ],
                onChanged: (v) =>
                    setState(() => _temperature = v!),
              ),
              const SizedBox(height: 14),

              _dropdown(
                label: 'Gravity tolerance',
                value: _gravity,
                items: const [
                  'Low gravity',
                  'Earth-like',
                  'High gravity',
                ],
                onChanged: (v) =>
                    setState(() => _gravity = v!),
              ),
              const SizedBox(height: 16),

              _switchTile(
                title: 'I need liquid water',
                subtitle:
                    'Prefer worlds with accessible liquid water.',
                value: _needsWater,
                onChanged: (v) =>
                    setState(() => _needsWater = v),
              ),
              const SizedBox(height: 10),

              _switchTile(
                title: 'I can use life-support equipment',
                subtitle:
                    'I may tolerate unbreathable environments '
                    'if suitable equipment is available.',
                value: _lifeSupport,
                onChanged: (v) =>
                    setState(() => _lifeSupport = v),
              ),
              const SizedBox(height: 30),

              _heading('03', 'Your ideal world'),
              const SizedBox(height: 16),

              _dropdown(
                label: 'Preferred climate',
                value: _climate,
                items: const [
                  'Temperate',
                  'Tropical',
                  'Cold',
                  'Desert',
                  'Oceanic',
                  'Any climate',
                ],
                onChanged: (v) =>
                    setState(() => _climate = v!),
              ),
              const SizedBox(height: 26),

              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.initialProfile == null
                        ? 'Create my profile'
                        : 'Save profile',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Your profile is stored locally for this prototype.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(String? existingPhoto) {
    if (_photo != null) {
      return Image.file(File(_photo!.path), fit: BoxFit.cover);
    }

    if (existingPhoto != null && existingPhoto.isNotEmpty) {
      return Image.file(
        File(existingPhoto),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(),
      );
    }

    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 32,
          color: Color(0xFF71658F),
        ),
        SizedBox(height: 7),
        Text(
          'Add photo',
          style: TextStyle(
            color: Color(0xFF71658F),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _heading(String number, String title) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAE6F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF71658F),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF999A94)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _accent),
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(color: _ink, fontSize: 14),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: _accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
