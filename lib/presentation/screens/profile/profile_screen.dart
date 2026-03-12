import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../core/utils/format_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/stat_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _changePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final userId = auth.currentUser!.id;

    final url = await userProvider.uploadProfilePhoto(
        userId, File(pickedFile.path));

    if (url != null) {
      final updated = auth.currentUser!.copyWith(photoUrl: url);
      await userProvider.updateUser(updated);
      auth.updateCurrentUser(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: _changePhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white24,
                              backgroundImage: user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14,
                                    color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: AppColors.primary,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İstatistikler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatCard(
                        label: 'TOPLAM YÜRÜYÜŞ',
                        value: user.totalWalks.toString(),
                        unit: 'kez',
                        icon: Icons.directions_walk_rounded,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        label: 'TOPLAM ADIM',
                        value: FormatUtils.formatNumber(user.totalSteps),
                        unit: '',
                        icon: Icons.fitness_center_rounded,
                        color: AppColors.soloWalk,
                      ),
                      StatCard(
                        label: 'TOPLAM MESAFE',
                        value: DistanceCalculator.formatDistance(
                            user.totalDistanceM),
                        unit: '',
                        icon: Icons.route_rounded,
                        color: AppColors.accent,
                      ),
                      StatCard(
                        label: 'KEŞFEDİLEN ALAN',
                        value: FormatUtils.formatArea(user.totalAreaM2),
                        unit: '',
                        icon: Icons.map_rounded,
                        color: AppColors.groupWalk,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Kişisel Bilgiler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _InfoCard(
                    icon: Icons.monitor_weight_outlined,
                    label: AppStrings.weight,
                    value: '${user.weightKg} kg',
                    onEdit: () => _editBodyMetrics(context),
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    icon: Icons.height_rounded,
                    label: AppStrings.height,
                    value: '${user.heightCm} cm',
                    onEdit: () => _editBodyMetrics(context),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Ayarlar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _SettingTile(
                    icon: Icons.straighten_rounded,
                    title: 'Birim Sistemi',
                    subtitle: user.isMetric ? 'Metrik (km)' : 'Imperial (mil)',
                    trailing: Switch(
                      value: user.isMetric,
                      activeColor: AppColors.primary,
                      onChanged: (v) async {
                        final updated = user.copyWith(isMetric: v);
                        await context
                            .read<UserProvider>()
                            .updateUser(updated);
                        auth.updateCurrentUser(updated);
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimler',
                    subtitle: 'Günlük hatırlatma',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutConfirm(context),
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.error),
                      label: const Text(
                        AppStrings.logout,
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editBodyMetrics(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;
    final weightCtrl =
        TextEditingController(text: user.weightKg.toString());
    final heightCtrl =
        TextEditingController(text: user.heightCm.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vücut Ölçüleri',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kilo (kg)',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Boy (cm)',
                  suffixText: 'cm',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final w = double.tryParse(weightCtrl.text) ?? user.weightKg;
                  final h = double.tryParse(heightCtrl.text) ?? user.heightCm;
                  final updated =
                      user.copyWith(weightKg: w, heightCm: h);
                  await context.read<UserProvider>().updateUser(updated);
                  auth.updateCurrentUser(updated);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkmak istiyor musun?'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
