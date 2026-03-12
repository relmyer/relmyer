import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/walk_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/walk_provider.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  UserModel? _friendToCompare;
  bool _isLoading = false;

  // This week vs last week data
  double _thisWeekDistance = 0;
  double _lastWeekDistance = 0;
  int _thisWeekSteps = 0;
  int _lastWeekSteps = 0;
  List<double> _dailyDistances = List.filled(7, 0.0); // Mon-Sun

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _friendToCompare =
          ModalRoute.of(context)?.settings.arguments as UserModel?;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = context.read<AuthProvider>().currentUser!.id;
    final repo = WalkRepository();

    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));

    final thisWeekWalks = await repo.getUserWalksInDateRange(
      userId,
      from: DateTime(
          startOfWeek.year, startOfWeek.month, startOfWeek.day),
      to: now,
    );

    final lastWeekWalks = await repo.getUserWalksInDateRange(
      userId,
      from: DateTime(startOfLastWeek.year, startOfLastWeek.month,
          startOfLastWeek.day),
      to: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
          .subtract(const Duration(seconds: 1)),
    );

    // Compute daily data (Mon=0, Sun=6)
    final daily = List.filled(7, 0.0);
    for (final w in thisWeekWalks) {
      final dayIndex = w.startTime.weekday - 1;
      daily[dayIndex] += w.distanceM;
    }

    setState(() {
      _thisWeekDistance =
          thisWeekWalks.fold(0.0, (s, w) => s + w.distanceM);
      _lastWeekDistance =
          lastWeekWalks.fold(0.0, (s, w) => s + w.distanceM);
      _thisWeekSteps =
          thisWeekWalks.fold(0, (s, w) => s + w.steps);
      _lastWeekSteps =
          lastWeekWalks.fold(0, (s, w) => s + w.steps);
      _dailyDistances = daily;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final me = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_friendToCompare != null
            ? '${_friendToCompare!.name.split(' ').first} ile Karşılaştır'
            : AppStrings.compare),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week vs last week card
                  _SectionHeader(
                    title: 'Bu Hafta vs Geçen Hafta',
                    icon: Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _CompareCard(
                          label: 'Bu Hafta',
                          value: DistanceCalculator.formatDistance(
                              _thisWeekDistance),
                          subValue:
                              '${FormatUtils.formatNumber(_thisWeekSteps)} adım',
                          color: AppColors.primary,
                          isHigher: _thisWeekDistance >= _lastWeekDistance,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CompareCard(
                          label: 'Geçen Hafta',
                          value: DistanceCalculator.formatDistance(
                              _lastWeekDistance),
                          subValue:
                              '${FormatUtils.formatNumber(_lastWeekSteps)} adım',
                          color: AppColors.soloWalk,
                          isHigher: _lastWeekDistance > _thisWeekDistance,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress message
                  if (_thisWeekDistance > 0 || _lastWeekDistance > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _thisWeekDistance >= _lastWeekDistance
                            ? AppColors.primarySurface
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _thisWeekDistance >= _lastWeekDistance
                                ? '🚀'
                                : '💪',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _thisWeekDistance >= _lastWeekDistance
                                ? AppStrings.improved
                                : AppStrings.keepGoing,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _thisWeekDistance >= _lastWeekDistance
                                  ? AppColors.primary
                                  : AppColors.warning,
                            ),
                          ),
                          if (_lastWeekDistance > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              _thisWeekDistance >= _lastWeekDistance
                                  ? '+${((_thisWeekDistance - _lastWeekDistance) / _lastWeekDistance * 100).toStringAsFixed(0)}%'
                                  : '-${((_lastWeekDistance - _thisWeekDistance) / _lastWeekDistance * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: _thisWeekDistance >= _lastWeekDistance
                                    ? AppColors.primary
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Daily chart
                  _SectionHeader(
                    title: 'Bu Haftanın Günlük Mesafesi',
                    icon: Icons.bar_chart_rounded,
                  ),
                  const SizedBox(height: 12),

                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _dailyDistances.isEmpty
                            ? 1000
                            : (_dailyDistances.reduce(
                                        (a, b) => a > b ? a : b) *
                                    1.3)
                                .clamp(500, double.infinity),
                        barGroups: List.generate(7, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: _dailyDistances[i],
                                color: _dailyDistances[i] > 0
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 18,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                const days = [
                                  'Pzt',
                                  'Sal',
                                  'Çar',
                                  'Per',
                                  'Cum',
                                  'Cmt',
                                  'Paz'
                                ];
                                return Text(
                                  days[v.toInt()],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData:
                            const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),

                  // Friend comparison
                  if (_friendToCompare != null && me != null) ...[
                    const SizedBox(height: 24),

                    _SectionHeader(
                      title: 'Arkadaşınla Karşılaştırma',
                      icon: Icons.people_rounded,
                    ),
                    const SizedBox(height: 12),

                    _FriendComparisonCard(me: me, friend: _friendToCompare!),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CompareCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final Color color;
  final bool isHigher;

  const _CompareCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.color,
    required this.isHigher,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHigher ? color.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isHigher ? color.withOpacity(0.3) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isHigher) ...[
                const Spacer(),
                Icon(Icons.arrow_upward_rounded, color: color, size: 14),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isHigher ? color : AppColors.textPrimary,
            ),
          ),
          Text(
            subValue,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FriendComparisonCard extends StatelessWidget {
  final UserModel me;
  final UserModel friend;

  const _FriendComparisonCard(
      {required this.me, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _PersonHeader(user: me, label: 'Sen'),
              const Text('VS',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint)),
              _PersonHeader(user: friend, label: friend.name.split(' ').first),
            ],
          ),
          const SizedBox(height: 16),
          _CompareRow(
            label: 'Toplam Adım',
            myValue: FormatUtils.formatNumber(me.totalSteps),
            friendValue: FormatUtils.formatNumber(friend.totalSteps),
            iAmHigher: me.totalSteps >= friend.totalSteps,
          ),
          const Divider(height: 16),
          _CompareRow(
            label: 'Toplam Mesafe',
            myValue: DistanceCalculator.formatDistance(me.totalDistanceM),
            friendValue:
                DistanceCalculator.formatDistance(friend.totalDistanceM),
            iAmHigher: me.totalDistanceM >= friend.totalDistanceM,
          ),
          const Divider(height: 16),
          _CompareRow(
            label: 'Keşfedilen Alan',
            myValue: FormatUtils.formatArea(me.totalAreaM2),
            friendValue: FormatUtils.formatArea(friend.totalAreaM2),
            iAmHigher: me.totalAreaM2 >= friend.totalAreaM2,
          ),
        ],
      ),
    );
  }
}

class _PersonHeader extends StatelessWidget {
  final UserModel user;
  final String label;

  const _PersonHeader({required this.user, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySurface,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String myValue;
  final String friendValue;
  final bool iAmHigher;

  const _CompareRow({
    required this.label,
    required this.myValue,
    required this.friendValue,
    required this.iAmHigher,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            myValue,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: iAmHigher ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            friendValue,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: !iAmHigher ? AppColors.soloWalk : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
