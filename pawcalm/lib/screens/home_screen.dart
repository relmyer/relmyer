import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dog.dart';
import '../models/trigger_log.dart';
import '../theme/app_theme.dart';
import 'ai_coach_screen.dart';
import 'progress_screen.dart';
import 'log_trigger_screen.dart';

class HomeScreen extends StatelessWidget {
  final Dog dog;
  final List<TriggerLog> recentLogs;

  const HomeScreen({
    super.key,
    required this.dog,
    required this.recentLogs,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Günaydın' : hour < 17 ? 'İyi öğleden sonralar' : 'İyi akşamlar';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting! 👋',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        dog.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${dog.breed} • ${dog.reactivityLabel}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Dog avatar
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                    ),
                    child: dog.photoUrl != null
                        ? ClipOval(
                            child: Image.network(dog.photoUrl!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Text(
                              dog.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // Quick actions grid
          _buildQuickActions(context),

          const SizedBox(height: 24),

          // Today's tip
          _buildTodaysTip(),

          const SizedBox(height: 24),

          // Recent activity
          _buildRecentActivity(context),

          const SizedBox(height: 24),

          // Streak
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _QuickActionCard(
          emoji: '📝',
          title: 'Oturum Kaydet',
          subtitle: 'Bugünkü tepkileri logla',
          color: AppTheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LogTriggerScreen(dog: dog),
            ),
          ),
        ),
        _QuickActionCard(
          emoji: '🤖',
          title: 'AI Koç',
          subtitle: 'Kişisel eğitim planı al',
          color: AppTheme.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AiCoachScreen(dog: dog, recentLogs: recentLogs),
            ),
          ),
        ),
        _QuickActionCard(
          emoji: '📊',
          title: 'İlerleme',
          subtitle: '${recentLogs.length} oturum kaydı',
          color: AppTheme.accent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProgressScreen(dog: dog, logs: recentLogs),
            ),
          ),
        ),
        _QuickActionCard(
          emoji: '🆘',
          title: 'Acil Yardım',
          subtitle: 'Şu an yardıma ihtiyacım var',
          color: AppTheme.danger,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AiCoachScreen(
                dog: dog,
                recentLogs: recentLogs,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildTodaysTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.08),
            AppTheme.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Günün İpucu',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Köpeğin tetikleyiciyi fark etmeden önce bile ödüllendirmek, güvenlik hissini artırır.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Son Aktivite',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgressScreen(dog: dog, logs: recentLogs),
                ),
              ),
              child: const Text('Tümü'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Center(
              child: Text(
                'Henüz oturum kaydedilmedi.\nİlk eğitim oturumunu kaydet!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
              ),
            ),
          )
        else
          ...recentLogs.take(3).map((log) => _RecentLogItem(log: log)),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildStreakCard() {
    final currentStreak = _calculateStreak();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak günlük seri!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Harika gidiyorsun! Yarın da egzersiz yap.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  int _calculateStreak() {
    if (recentLogs.isEmpty) return 0;
    final sorted = recentLogs.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i - 1].date.difference(sorted[i].date).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentLogItem extends StatelessWidget {
  final TriggerLog log;

  const _RecentLogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.calmLevelColor(log.intensity.index + 1);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    log.trigger,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  log.intensityLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  log.date.toString().substring(5, 10),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
