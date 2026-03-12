import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../core/utils/format_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/walk_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/walk_card.dart';
import '../../widgets/gradient_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<WalkProvider>().loadWalkHistory(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final walkProvider = context.watch<WalkProvider>();
    final user = auth.currentUser;

    // Compute today stats from history
    final today = DateTime.now();
    final todayWalks = walkProvider.walkHistory.where((w) {
      return w.startTime.year == today.year &&
          w.startTime.month == today.month &&
          w.startTime.day == today.day;
    }).toList();

    final todaySteps = todayWalks.fold(0, (s, w) => s + w.steps);
    final todayDistanceM = todayWalks.fold(0.0, (s, w) => s + w.distanceM);
    final todayCalories = todayWalks.fold(0.0, (s, w) => s + w.calories);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${FormatUtils.greeting()},',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                user?.name.split(' ').first ?? 'Sporcu',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/profile'),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white24,
                              backgroundImage: user?.photoUrl != null
                                  ? NetworkImage(user!.photoUrl!)
                                  : null,
                              child: user?.photoUrl == null
                                  ? Text(
                                      user?.name.isNotEmpty == true
                                          ? user!.name[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Today stats row
                      Row(
                        children: [
                          _QuickStat(
                            value: FormatUtils.formatNumber(todaySteps),
                            label: 'Adım',
                            icon: Icons.directions_walk_rounded,
                          ),
                          const SizedBox(width: 24),
                          _QuickStat(
                            value: DistanceCalculator.formatDistance(
                              todayDistanceM,
                            ),
                            label: 'Mesafe',
                            icon: Icons.route_rounded,
                          ),
                          const SizedBox(width: 24),
                          _QuickStat(
                            value:
                                '${todayCalories.toStringAsFixed(0)} kcal',
                            label: 'Kalori',
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Start Walk button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: GradientButton(
                text: AppStrings.startWalk,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => _showWalkTypeDialog(context),
              ),
            ),
          ),

          // All-time stats
          if (user != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tüm Zamanlar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'TOPLAM ADIM',
                            value: FormatUtils.formatNumber(user.totalSteps),
                            unit: '',
                            icon: Icons.directions_walk_rounded,
                            color: AppColors.soloWalk,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'TOPLAM MESAFE',
                            value: DistanceCalculator.formatDistance(
                              user.totalDistanceM,
                            ),
                            unit: '',
                            icon: Icons.route_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'TOPLAM KALORİ',
                            value: user.totalCalories.toStringAsFixed(0),
                            unit: 'kcal',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'KEŞFEDİLEN ALAN',
                            value: FormatUtils.formatArea(user.totalAreaM2),
                            unit: '',
                            icon: Icons.map_rounded,
                            color: AppColors.groupWalk,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Recent walks
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.recentWalks,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/walk-history'),
                    child: const Text('Tümü'),
                  ),
                ],
              ),
            ),
          ),

          if (walkProvider.isLoadingHistory)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (walkProvider.walkHistory.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Text('🥾',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text(
                            AppStrings.noWalksYet,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            AppStrings.noWalksDesc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: WalkCard(
                    walk: walkProvider.walkHistory[i],
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/walk-detail',
                      arguments: walkProvider.walkHistory[i],
                    ),
                  ),
                ),
                childCount: walkProvider.walkHistory.length.clamp(0, 5),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showWalkTypeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WalkTypeSheet(),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _QuickStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white60, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkTypeSheet extends StatelessWidget {
  const _WalkTypeSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Yürüyüş Türü',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _WalkTypeOption(
            icon: Icons.person_rounded,
            title: AppStrings.soloWalk,
            subtitle: 'Tek başına yürü, kendi sphere\'ini oluştur',
            gradient: AppColors.soloGradient,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/active-walk',
                arguments: {'type': 'solo'},
              );
            },
          ),
          const SizedBox(height: 12),
          _WalkTypeOption(
            icon: Icons.group_rounded,
            title: AppStrings.groupWalk,
            subtitle: 'Arkadaşlarınla yürü, birlikte keşfedin',
            gradient: AppColors.groupGradient,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/active-walk',
                arguments: {'type': 'group'},
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _WalkTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _WalkTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
