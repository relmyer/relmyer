import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/calm_spot.dart';
import '../theme/app_theme.dart';

class SpotDetailScreen extends StatefulWidget {
  final CalmSpot spot;

  const SpotDetailScreen({super.key, required this.spot});

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  bool _isReporting = false;
  int _liveReportScore = 3;

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    final currentCalm = spot.currentCalmScore;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(spot.name),
              background: spot.photos.isNotEmpty
                  ? Image.network(spot.photos.first, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.primary, AppTheme.secondary],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          spot.typeEmoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live calm indicator
                  if (currentCalm != null)
                    _buildLiveCalmBadge(currentCalm)
                  else
                    _buildStaticCalmBadge(spot.avgCalmScore),

                  const SizedBox(height: 20),

                  // Stats row
                  _buildStatsRow(),

                  const SizedBox(height: 20),

                  // Features
                  _buildFeatureChips(),

                  const SizedBox(height: 20),

                  // Live reporting section - unique feature!
                  _buildLiveReportSection(),

                  const SizedBox(height: 20),

                  // Community tips
                  if (spot.tips.isNotEmpty) _buildCommunityTips(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions),
                  label: const Text('Yol Tarifi'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isReporting = !_isReporting),
                  icon: const Icon(Icons.send),
                  label: const Text('Durum Bildir'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCalmBadge(double score) {
    final level = score.round().clamp(1, 5);
    final color = AppTheme.calmLevelColor(level);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (c) => c.repeat())
              .fade(begin: 0.3, end: 1, duration: 1.s),
          const SizedBox(width: 10),
          Text(
            'CANLI: ${AppTheme.calmLevelLabel(level)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            'Son rapor: Az önce',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticCalmBadge(double score) {
    final level = score.round().clamp(1, 5);
    final color = AppTheme.calmLevelColor(level);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                AppTheme.calmLevelLabel(level),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${widget.spot.reviewCount} değerlendirme',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statItem('🔊', 'Gürültü', widget.spot.noiseLevel),
        _statItem('👥', 'Kalabalık', widget.spot.crowdLevel),
        _statItem('🐕', 'Köpek', widget.spot.dogEncounterLevel),
      ],
    );
  }

  Widget _statItem(String emoji, String label, int level) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            _LevelDots(level: level),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChips() {
    final features = <String>[];
    if (widget.spot.isOffLeash) features.add('🐾 Tasmasız');
    if (widget.spot.isFenced) features.add('🔒 Çevrili');
    if (widget.spot.hasFreshWater) features.add('💧 Tatlı su');
    if (widget.spot.isShaded) features.add('🌳 Gölgelik');

    if (features.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
        ),
        child: Text(
          f,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondary,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildLiveReportSection() {
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
          const Row(
            children: [
              Icon(Icons.sensors, color: AppTheme.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Şu Anki Durumu Bildir',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Reactive köpek sahiplerine yardım et!',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (i) {
              final level = i + 1;
              final isSelected = _liveReportScore == level;
              final color = AppTheme.calmLevelColor(level);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _liveReportScore = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      ['😌', '🙂', '😐', '😟', '😰'][i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              AppTheme.calmLevelLabel(6 - _liveReportScore),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.calmLevelColor(6 - _liveReportScore),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitLiveReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Bildir'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reaktif Köpek İpuçları',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Topluluktan öneriler',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        ...widget.spot.tips.take(3).map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        )).animate(interval: 100.ms).fadeIn().slideX(begin: 0.05),
      ],
    );
  }

  void _submitLiveReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Teşekkürler! Durumu bildirdin.'),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }
}

class _LevelDots extends StatelessWidget {
  final int level;

  const _LevelDots({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final isActive = i < level;
        final color = AppTheme.calmLevelColor(level);
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : AppTheme.divider,
          ),
        );
      }),
    );
  }
}
