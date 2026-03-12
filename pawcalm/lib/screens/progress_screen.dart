import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dog.dart';
import '../models/trigger_log.dart';
import '../theme/app_theme.dart';
import 'log_trigger_screen.dart';

class ProgressScreen extends StatefulWidget {
  final Dog dog;
  final List<TriggerLog> logs;

  const ProgressScreen({super.key, required this.dog, required this.logs});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _selectedTrigger;
  DateTimeRange? _selectedRange;

  List<TriggerLog> get _filteredLogs {
    var logs = widget.logs;
    if (_selectedTrigger != null) {
      logs = logs.where((l) => l.trigger == _selectedTrigger).toList();
    }
    if (_selectedRange != null) {
      logs = logs.where((l) =>
        l.date.isAfter(_selectedRange!.start) &&
        l.date.isBefore(_selectedRange!.end)
      ).toList();
    }
    return logs..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dog.name}\'in İlerlemesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logNewSession,
        icon: const Icon(Icons.add),
        label: const Text('Oturum Kaydet'),
        backgroundColor: AppTheme.primary,
      ),
      body: widget.logs.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trigger filter chips
                  _buildTriggerFilter(),
                  const SizedBox(height: 20),

                  // Intensity trend chart
                  _buildIntensityChart(),
                  const SizedBox(height: 20),

                  // Threshold distance chart (key metric!)
                  _buildThresholdChart(),
                  const SizedBox(height: 20),

                  // Trigger breakdown
                  _buildTriggerBreakdown(),
                  const SizedBox(height: 20),

                  // Streak & achievements
                  _buildAchievements(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_chart_outlined, size: 80,
                color: AppTheme.primary.withOpacity(0.3)),
            const SizedBox(height: 20),
            const Text(
              'Henüz Oturum Yok',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk eğitim oturumunu kaydet ve ${widget.dog.name}\'in '
              'ilerlemesini takip et!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _logNewSession,
              icon: const Icon(Icons.add),
              label: const Text('İlk Oturumu Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerFilter() {
    final triggers = widget.logs.map((l) => l.trigger).toSet().toList();
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('Tümü', null),
          ...triggers.map((t) => _filterChip(t, t)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final isSelected = _selectedTrigger == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTrigger = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildIntensityChart() {
    final logs = _filteredLogs;
    if (logs.isEmpty) return const SizedBox.shrink();

    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.intensity.index.toDouble());
    }).toList();

    return _ChartCard(
      title: 'Tepki Yoğunluğu',
      subtitle: 'Düşen eğri = İlerleme 🎉',
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.divider,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, _) {
                  const labels = ['Yok', 'Hafif', 'Orta', 'Şiddetli', 'Çok Şiddetli'];
                  final idx = value.round();
                  if (idx < 0 || idx >= labels.length) return const SizedBox();
                  return Text(labels[idx],
                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.round();
                  if (idx >= logs.length) return const SizedBox();
                  return Text(
                    logs[idx].date.toString().substring(5, 10),
                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 4,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 5,
                  color: AppTheme.calmLevelColor(spot.y.round() + 1),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdChart() {
    final logs = _filteredLogs;
    if (logs.isEmpty) return const SizedBox.shrink();

    final spots = logs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.distanceToTrigger);
    }).toList();

    return _ChartCard(
      title: 'Eşik Mesafesi',
      subtitle: 'Azalan mesafe = Daha büyük ilerleme 🐾',
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.divider,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text(
                  '${value.round()}m',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.round();
                  if (idx >= logs.length) return const SizedBox();
                  return Text(
                    logs[idx].date.toString().substring(5, 10),
                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.secondary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.secondary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerBreakdown() {
    final triggerCounts = <String, int>{};
    for (final log in widget.logs) {
      triggerCounts[log.trigger] = (triggerCounts[log.trigger] ?? 0) + 1;
    }
    final sorted = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tetikleyici Dağılımı',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...sorted.take(5).map((e) {
          final pct = e.value / widget.logs.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    e.key,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAchievements() {
    final totalSessions = widget.logs.length;
    final noReactionCount = widget.logs
        .where((l) => l.intensity == ReactionIntensity.none)
        .length;
    final fastRecoveries = widget.logs
        .where((l) => l.recoveryTime == RecoveryTime.under1min)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Başarılar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _AchievementBadge(
              emoji: '🌟',
              title: '$totalSessions',
              subtitle: 'Oturum',
              unlocked: totalSessions > 0,
            ),
            const SizedBox(width: 12),
            _AchievementBadge(
              emoji: '🧘',
              title: '$noReactionCount',
              subtitle: 'Tepkisiz',
              unlocked: noReactionCount > 0,
            ),
            const SizedBox(width: 12),
            _AchievementBadge(
              emoji: '⚡',
              title: '$fastRecoveries',
              subtitle: 'Hızlı İyileşme',
              unlocked: fastRecoveries > 0,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (range != null) setState(() => _selectedRange = range);
  }

  void _logNewSession() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogTriggerScreen(dog: widget.dog),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          Text(subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: child),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _AchievementBadge extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool unlocked;

  const _AchievementBadge({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unlocked
              ? AppTheme.accent.withOpacity(0.1)
              : AppTheme.divider.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unlocked
                ? AppTheme.accent.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(emoji,
              style: TextStyle(
                fontSize: 24,
                color: unlocked ? null : Colors.transparent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
