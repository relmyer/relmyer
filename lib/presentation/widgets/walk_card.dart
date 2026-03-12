import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/distance_calculator.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/walk_model.dart';

class WalkCard extends StatelessWidget {
  final WalkModel walk;
  final VoidCallback? onTap;

  const WalkCard({super.key, required this.walk, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGroup = walk.type == WalkType.group;
    final color = isGroup ? AppColors.groupWalk : AppColors.soloWalk;
    final gradient = isGroup ? AppColors.groupGradient : AppColors.soloGradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isGroup ? Icons.group_rounded : Icons.person_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGroup ? 'Grup Yürüyüşü' : 'Solo Yürüyüş',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        FormatUtils.formatDate(walk.startTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DistanceCalculator.formatDistance(walk.distanceM),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.timer_outlined,
                  text: DistanceCalculator.formatDuration(walk.durationSeconds),
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.directions_walk_rounded,
                  text: '${walk.steps} adım',
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.local_fire_department_rounded,
                  text: '${walk.calories.toStringAsFixed(0)} kcal',
                  color: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
