import 'package:flutter/material.dart';
import '../models/calm_spot.dart';
import '../theme/app_theme.dart';

class CalmFilterBar extends StatelessWidget {
  final int selectedMinScore;
  final SpotType? selectedType;
  final ValueChanged<int> onScoreChanged;
  final ValueChanged<SpotType?> onTypeChanged;

  const CalmFilterBar({
    super.key,
    required this.selectedMinScore,
    required this.selectedType,
    required this.onScoreChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.95),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Row(
          children: [
            // Calm score filter
            _calmScoreDropdown(),
            const SizedBox(width: 8),

            // Divider
            Container(width: 1, height: 28, color: AppTheme.divider),
            const SizedBox(width: 8),

            // Type filters
            _typeChip(null, '🗺️ Hepsi'),
            _typeChip(SpotType.quietPark, '🌿 Park'),
            _typeChip(SpotType.offLeashArea, '🐾 Tasmasız'),
            _typeChip(SpotType.trailPath, '🌲 Yol'),
            _typeChip(SpotType.beach, '🏖️ Plaj'),
            _typeChip(SpotType.trainingCenter, '🎓 Eğitim'),
          ],
        ),
      ),
    );
  }

  Widget _calmScoreDropdown() {
    return GestureDetector(
      onTap: () {}, // TODO: Show score picker
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.spa_outlined, size: 14, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(
              'Min: ${AppTheme.calmLevelLabel(selectedMinScore)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(SpotType? type, String label) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
