import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/controllers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  String _selectedCountry = 'India';
  String? _selectedAvatarUrl;

  // Initial values for dirty check
  late String _initialName;
  late String _initialEmail;
  late String _initialPhone;
  late String _initialDob;
  late String _initialCountry;
  String? _initialAvatarUrl;

  bool _isDirty = false;

  final List<String> _countries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'Singapore',
    'United Arab Emirates',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;

    _initialName = user?.name ?? 'Alex Johnson';
    _initialEmail = user?.email ?? 'alex.johnson@example.com';
    _initialPhone = user?.phone ?? '+91 9876543210';
    _initialDob = user?.dateOfBirth ?? '15 May 1998';
    _initialCountry = user?.country ?? 'India';
    _initialAvatarUrl = user?.avatarUrl;

    if (!_countries.contains(_initialCountry)) {
      _countries.insert(0, _initialCountry);
    }

    _nameController = TextEditingController(text: _initialName);
    _emailController = TextEditingController(text: _initialEmail);
    _phoneController = TextEditingController(text: _initialPhone);
    _dobController = TextEditingController(text: _initialDob);
    _selectedCountry = _initialCountry;
    _selectedAvatarUrl = _initialAvatarUrl;

    _nameController.addListener(_checkIfDirty);
    _emailController.addListener(_checkIfDirty);
    _phoneController.addListener(_checkIfDirty);
    _dobController.addListener(_checkIfDirty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _checkIfDirty() {
    final isDirty = _nameController.text.trim() != _initialName ||
        _emailController.text.trim() != _initialEmail ||
        _phoneController.text.trim() != _initialPhone ||
        _dobController.text.trim() != _initialDob ||
        _selectedCountry != _initialCountry ||
        _selectedAvatarUrl != _initialAvatarUrl;

    if (isDirty != _isDirty) {
      setState(() {
        _isDirty = isDirty;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 24, 5, 15);
    final firstDate = DateTime(now.year - 80);
    final lastDate = DateTime(now.year - 13);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final formatted = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      _dobController.text = formatted;
      _checkIfDirty();
    }
  }

  void _showChangePhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.l,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Open camera to capture new photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedAvatarUrl = 'camera_photo';
                    });
                    _checkIfDirty();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mock photo captured from camera')),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.photo_library_rounded, color: Colors.blue.shade700),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pick an existing photo from gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedAvatarUrl = 'gallery_photo';
                    });
                    _checkIfDirty();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mock photo selected from gallery')),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                  subtitle: const Text('Revert to initial avatar placeholder'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedAvatarUrl = null;
                    });
                    _checkIfDirty();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved edits. Are you sure you want to discard them?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate() || !_isDirty) return;

    ref.read(authControllerProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
          country: _selectedCountry,
          avatarUrl: _selectedAvatarUrl,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppColors.success,
        duration: Duration(milliseconds: 1800),
      ),
    );

    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.pop();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _nameController.text.trim();
    final avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () async {
              if (await _onWillPop() && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Avatar Card with Edit Badge
                  Center(
                    child: GestureDetector(
                      onTap: _showChangePhotoSheet,
                      child: Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                avatarLetter,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.accentDark,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _showChangePhotoSheet,
                      child: const Text(
                        'Change Photo',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // 2. Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. Alex Johnson',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // 3. Email Address
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'alex.johnson@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: 'Used for security alerts and payout receipts',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter email';
                      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // 4. Phone Number
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+91 9876543210',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().length < 8 ? 'Enter valid phone number' : null,
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // 5. Date of Birth
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDateOfBirth,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'Select your birth date',
                      prefixIcon: Icon(Icons.cake_outlined),
                      suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // 6. Country Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country / Region',
                      prefixIcon: Icon(Icons.public_rounded),
                    ),
                    items: _countries.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCountry = val;
                        });
                        _checkIfDirty();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 7. Save Changes Button
                  ElevatedButton(
                    onPressed: _isDirty ? _handleSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.divider,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isDirty ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
