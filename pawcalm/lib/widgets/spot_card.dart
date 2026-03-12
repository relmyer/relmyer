import 'package:flutter/material.dart';
import '../models/calm_spot.dart';
import '../theme/app_theme.dart';

class SpotCard extends StatelessWidget {
  final CalmSpot spot;
  final double? distanceKm;
  final VoidCallback? onTap;

  const SpotCard({
    super.key,
    required this.spot,
    this.distanceKm,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentCalm = spot.currentCalmScore;
    final displayScore = currentCalm ?? spot.avgCalmScore;
    final level = displayScore.round().clamp(1, 5);
    final color = AppTheme.calmLevelColor(level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Calm score indicator
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(spot.typeEmoji, style: const TextStyle(fontSize: 20)),
                  Text(
                    displayScore.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Spot info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spot.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (currentCalm != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'CANLI',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spot.typeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _miniStat('🔊', spot.noiseLevel),
                      const SizedBox(width: 8),
                      _miniStat('👥', spot.crowdLevel),
                      const SizedBox(width: 8),
                      _miniStat('🐕', spot.dogEncounterLevel),
                      const Spacer(),
                      if (distanceKm != null)
                        Text(
                          distanceKm! < 1
                              ? '${(distanceKm! * 1000).round()} m'
                              : '${distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String emoji, int level) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 2),
        ...List.generate(5, (i) => Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < level
                ? AppTheme.calmLevelColor(level)
                : AppTheme.divider,
          ),
        )),
      ],
    );
  }
}

/// Compact preview card shown on the map when a marker is tapped
class SpotPreviewCard extends StatelessWidget {
  final CalmSpot spot;
  final VoidCallback onClose;
  final VoidCallback onTap;

  const SpotPreviewCard({
    super.key,
    required this.spot,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentCalm = spot.currentCalmScore;
    final displayScore = currentCalm ?? spot.avgCalmScore;
    final level = displayScore.round().clamp(1, 5);
    final color = AppTheme.calmLevelColor(level);

    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 8,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(spot.typeEmoji, style: const TextStyle(fontSize: 24)),
                    Text(
                      displayScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${AppTheme.calmLevelLabel(level)} • ${spot.typeLabel}',
                      style: TextStyle(color: color, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${spot.reviewCount} değerlendirme',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
