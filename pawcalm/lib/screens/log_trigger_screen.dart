import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dog.dart';
import '../models/trigger_log.dart';
import '../theme/app_theme.dart';

/// Screen to log a trigger/reaction session
/// This is a core differentiating feature - no other dog app has this
class LogTriggerScreen extends StatefulWidget {
  final Dog dog;
  final String? preselectedTrigger;

  const LogTriggerScreen({
    super.key,
    required this.dog,
    this.preselectedTrigger,
  });

  @override
  State<LogTriggerScreen> createState() => _LogTriggerScreenState();
}

class _LogTriggerScreenState extends State<LogTriggerScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedTrigger;
  String? _customTrigger;
  ReactionIntensity _intensity = ReactionIntensity.moderate;
  RecoveryTime _recoveryTime = RecoveryTime.onetofive;
  double _distanceToTrigger = 10;
  bool _usedCalming = false;
  String? _calmingTechnique;
  bool _treatUsed = false;
  int _moodBefore = 3;
  int _moodAfter = 3;
  String? _notes;
  bool _isSaving = false;

  static const List<String> _commonTriggers = [
    'Diğer köpekler',
    'Bisiklet',
    'Motosiklet',
    'Koşucu',
    'Çocuklar',
    'Arabalar',
    'Gürültü',
    'Havai fişek',
    'Gök gürültüsü',
    'Yabancı insanlar',
    'Diğer',
  ];

  static const List<String> _calmingTechniques = [
    'Yem saçma',
    'U-dönüşü',
    'Uzaklaş',
    'Odak eğitimi',
    'Derin nefes',
    'Masaj',
    'Oyuncak',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTrigger = widget.preselectedTrigger ??
        (widget.dog.triggers.isNotEmpty ? widget.dog.triggers.first : 'Diğer köpekler');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oturum Kaydet'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet',
                    style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dog mood before
              _buildSection(
                'Yürüyüş öncesi ruh hali',
                _buildMoodSelector(_moodBefore, (v) =>
                    setState(() => _moodBefore = v)),
              ),

              // Trigger selection
              _buildSection(
                'Tetikleyici',
                _buildTriggerSelector(),
              ),

              // Reaction intensity
              _buildSection(
                'Tepki yoğunluğu',
                _buildIntensitySelector(),
              ),

              // Distance
              _buildSection(
                'Tetikleyiciye mesafe',
                _buildDistanceSlider(),
              ),

              // Recovery time
              _buildSection(
                'İyileşme süresi',
                _buildRecoverySelector(),
              ),

              // Calming techniques
              _buildSection(
                'Sakinleştirme tekniği kullandın mı?',
                _buildCalmingSection(),
              ),

              // Dog mood after
              _buildSection(
                'Yürüyüş sonrası ruh hali',
                _buildMoodSelector(_moodAfter, (v) =>
                    setState(() => _moodAfter = v)),
              ),

              // Notes
              _buildSection(
                'Notlar (isteğe bağlı)',
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Bugün ne fark ettin? Köpeğin nasıl hissetti?',
                  ),
                  onChanged: (v) => _notes = v,
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSaving
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text('Kaydediliyor...'),
                    ],
                  )
                : const Text('Oturumu Kaydet'),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTriggerSelector() {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonTriggers.map((trigger) {
            final isSelected = _selectedTrigger == trigger;
            return GestureDetector(
              onTap: () => setState(() => _selectedTrigger = trigger),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.divider,
                  ),
                ),
                child: Text(
                  trigger,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedTrigger == 'Diğer') ...[
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(hintText: 'Tetikleyiciyi yaz...'),
            onChanged: (v) => _customTrigger = v,
            validator: (v) =>
                _selectedTrigger == 'Diğer' && (v?.isEmpty ?? true)
                    ? 'Lütfen tetikleyiciyi belirt'
                    : null,
          ),
        ],
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Row(
      children: ReactionIntensity.values.map((intensity) {
        final isSelected = _intensity == intensity;
        final colors = [
          AppTheme.calmLevel1,
          AppTheme.calmLevel2,
          AppTheme.calmLevel3,
          AppTheme.calmLevel4,
          AppTheme.calmLevel5,
        ];
        final color = colors[intensity.index];
        final labels = ['Yok', 'Hafif', 'Orta', 'Şiddetli', 'Aşırı'];

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _intensity = intensity),
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
              child: Column(
                children: [
                  Text(
                    ['😌', '😐', '😟', '😠', '🤯'][intensity.index],
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labels[intensity.index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_distanceToTrigger.round()} metre',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            Text(
              _distanceToTrigger < 5 ? '💪 Harika ilerleme!'
                  : _distanceToTrigger < 15 ? '👍 İyi mesafe'
                  : '📏 Güvenli mesafe',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        Slider(
          value: _distanceToTrigger,
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: AppTheme.primary,
          onChanged: (v) => setState(() => _distanceToTrigger = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('1m', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text('25m', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text('50m', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecoverySelector() {
    final options = [
      (RecoveryTime.under1min, '< 1 dk', '🚀'),
      (RecoveryTime.onetofive, '1-5 dk', '✅'),
      (RecoveryTime.fivetoFifteen, '5-15 dk', '⏳'),
      (RecoveryTime.overFifteen, '15+ dk', '😓'),
    ];
    return Row(
      children: options.map((opt) {
        final isSelected = _recoveryTime == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _recoveryTime = opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(opt.$3, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    opt.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalmingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _usedCalming = false;
                  _calmingTechnique = null;
                }),
                child: _boolCard('Hayır', !_usedCalming),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _usedCalming = true),
                child: _boolCard('Evet', _usedCalming),
              ),
            ),
          ],
        ),
        if (_usedCalming) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _calmingTechniques.map((t) {
              final isSelected = _calmingTechnique == t;
              return GestureDetector(
                onTap: () => setState(() => _calmingTechnique = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.secondary.withOpacity(0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.secondary : AppTheme.divider,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.secondary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _boolCard(String label, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.divider,
          width: selected ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? AppTheme.primary : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMoodSelector(int value, ValueChanged<int> onChanged) {
    const moods = ['😫', '😟', '😐', '🙂', '😄'];
    const labels = ['Çok Kötü', 'Kötü', 'Orta', 'İyi', 'Harika'];
    return Row(
      children: List.generate(5, (i) {
        final isSelected = value == i + 1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i + 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.accent : AppTheme.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(moods[i], style: const TextStyle(fontSize: 22)),
                  Text(
                    labels[i],
                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // TODO: Save to Firestore via TriggerLogService
    await Future.delayed(const Duration(milliseconds: 800)); // Simulated save

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Oturum kaydedildi!'),
          backgroundColor: AppTheme.secondary,
        ),
      );
    }
  }
}
