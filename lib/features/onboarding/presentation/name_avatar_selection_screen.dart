import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';

class NameAvatarSelectionScreen extends ConsumerStatefulWidget {
  const NameAvatarSelectionScreen({super.key});

  @override
  ConsumerState<NameAvatarSelectionScreen> createState() =>
      _NameAvatarSelectionScreenState();
}

class _NameAvatarSelectionScreenState
    extends ConsumerState<NameAvatarSelectionScreen> {
  final _nameController = TextEditingController();
  String? _selectedAvatar;
  bool _isLoading = false;

  final List<String> _avatars = List.generate(
    18,
    (index) => 'assets/avatars/avatar_$index.png',
  );

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.name;
      _selectedAvatar = user.profileImageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (_selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an avatar')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(currentUserProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            avatarUrl: _selectedAvatar,
          );
      if (mounted) {
        context.go('/interests');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final bool isOnboarding = user?.name == null || user?.name == 'User' || user?.name == user?.email.split('@').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: isOnboarding 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
              ),
        title: Text(isOnboarding ? 'Profile Setup' : 'Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: AppColors.surface,
                        backgroundImage: _selectedAvatar != null 
                            ? AssetImage(_selectedAvatar!) 
                            : null,
                        child: _selectedAvatar == null
                            ? const Icon(Icons.person, size: 64, color: Colors.white24)
                            : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                
                // Name Input with Luxe border
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Your Distinguished Name',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white10),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                    fillColor: Colors.transparent,
                    filled: false,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Avatar Selection Grid
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SELECT AN AVATAR',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 2,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = _selectedAvatar == avatar;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = avatar),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.accent : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppColors.surface,
                          backgroundImage: AssetImage(avatar),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : Text(isOnboarding ? 'ESTABLISH IDENTITY' : 'UPDATE IDENTITY'),
                ),
                const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
