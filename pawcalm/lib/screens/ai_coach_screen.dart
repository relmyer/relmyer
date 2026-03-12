import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/dog.dart';
import '../models/trigger_log.dart';
import '../models/training_plan.dart';
import '../services/claude_service.dart';
import '../theme/app_theme.dart';

/// AI Coach screen powered by Claude claude-opus-4-6
/// Provides personalized training plans, progress analysis, and real-time coaching
class AiCoachScreen extends StatefulWidget {
  final Dog dog;
  final List<TriggerLog> recentLogs;

  const AiCoachScreen({
    super.key,
    required this.dog,
    required this.recentLogs,
  });

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen>
    with SingleTickerProviderStateMixin {
  final ClaudeService _claude = ClaudeService();
  late TabController _tabController;

  // Chat state
  final List<ChatMessage> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSendingMessage = false;

  // Plan generation state
  String? _selectedTrigger;
  bool _isGeneratingPlan = false;
  String? _generatedPlanJson;
  String? _progressAnalysis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgressAnalysis();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: 'Merhaba! Ben ${widget.dog.name}\'in AI koçuyum 🐾\n\n'
          'Sana şunlarda yardımcı olabilirim:\n'
          '• Kişiselleştirilmiş eğitim planı\n'
          '• Anlık koçluk desteği\n'
          '• Sakinleştirme teknikleri\n'
          '• İlerleme analizi\n\n'
          'Ne hakkında konuşmak istersin?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _loadProgressAnalysis() async {
    try {
      final analysis = await _claude.analyzeProgress(
        dog: widget.dog,
        logs: widget.recentLogs,
        targetTrigger: widget.dog.triggers.isNotEmpty
            ? widget.dog.triggers.first
            : 'genel',
      );
      if (mounted) setState(() => _progressAnalysis = analysis);
    } catch (e) {
      // Silently fail - show placeholder
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Koç',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${widget.dog.name} için kişisel koç',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Sohbet'),
            Tab(text: 'Eğitim Planı'),
            Tab(text: 'İlerleme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildTrainingPlanTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  // ─── CHAT TAB ───────────────────────────────────────────────────────────────
  Widget _buildChatTab() {
    return Column(
      children: [
        // Quick action chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _quickChip('🚨 Şu an yürüyüşteyim, yardım!', _onUrgentHelp),
              _quickChip('😰 Sakinleştirme teknikleri', _onCalmingTechniques),
              _quickChip('📊 Bu hafta nasıl gidiyor?', _onWeeklyCheck),
              _quickChip('🎯 Egzersiz öner', _onExerciseSuggestion),
            ],
          ),
        ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, i) => _buildMessageBubble(_messages[i]),
          ),
        ),

        // Input bar
        _buildChatInput(),
      ],
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppTheme.primary.withOpacity(0.08),
        side: const BorderSide(color: AppTheme.primary, width: 1),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isStreaming
                  ? _StreamingText(text: message.text)
                  : Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: message.isUser ? 0.1 : -0.1,
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: const InputDecoration(
                hintText: 'Koçuna bir şey sor...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: _isSendingMessage
                  ? AppTheme.textSecondary
                  : AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _isSendingMessage ? null : _sendMessage,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isSendingMessage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isSendingMessage) return;

    _chatController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isSendingMessage = true;
    });
    _scrollToBottom();

    // Add streaming response placeholder
    final responseMsg = ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    setState(() => _messages.add(responseMsg));

    try {
      final buffer = StringBuffer();
      await for (final chunk in _claude.streamClaude(
        '${widget.dog.name} hakkında: ${widget.dog.breed}, ${widget.dog.reactivityLabel}. '
        'Tetikleyiciler: ${widget.dog.triggers.join(", ")}. '
        'Kullanıcı sorusu: $text',
      )) {
        buffer.write(chunk);
        setState(() {
          _messages.last = ChatMessage(
            text: buffer.toString(),
            isUser: false,
            timestamp: responseMsg.timestamp,
            isStreaming: true,
          );
        });
        _scrollToBottom();
      }

      setState(() {
        _messages.last = ChatMessage(
          text: buffer.toString(),
          isUser: false,
          timestamp: responseMsg.timestamp,
        );
        _isSendingMessage = false;
      });
    } catch (e) {
      setState(() {
        _messages.last = ChatMessage(
          text: 'Üzgünüm, bir hata oluştu. Lütfen tekrar dene.',
          isUser: false,
          timestamp: responseMsg.timestamp,
        );
        _isSendingMessage = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onUrgentHelp() {
    _chatController.text =
        'Şu an yürüyüşteyim ve ${widget.dog.name} ${widget.dog.triggers.isNotEmpty ? widget.dog.triggers.first : "bir şey"} gördü. Ne yapmalıyım?';
    _sendMessage();
  }

  void _onCalmingTechniques() {
    _chatController.text = '${widget.dog.name} için sakinleştirme teknikleri neler?';
    _sendMessage();
  }

  void _onWeeklyCheck() {
    _chatController.text = 'Bu hafta nasıl ilerliyoruz? Nelere dikkat etmeliyim?';
    _sendMessage();
  }

  void _onExerciseSuggestion() {
    _chatController.text = 'Bugün için 5 dakikalık bir egzersiz önerir misin?';
    _sendMessage();
  }

  // ─── TRAINING PLAN TAB ──────────────────────────────────────────────────────
  Widget _buildTrainingPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Kişisel Eğitim Planı',
            subtitle: 'Claude AI ile özel hazırlanmış plan',
            icon: Icons.auto_awesome,
          ),
          const SizedBox(height: 16),

          // Trigger selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hangi tetikleyici için plan istiyorsun?',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.dog.triggers.map((trigger) {
                    final isSelected = _selectedTrigger == trigger;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTrigger = trigger),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          trigger,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedTrigger != null && !_isGeneratingPlan
                  ? _generatePlan
                  : null,
              icon: _isGeneratingPlan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGeneratingPlan
                  ? 'Plan hazırlanıyor...'
                  : 'AI ile Plan Oluştur'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.primary,
              ),
            ),
          ),

          if (_isGeneratingPlan) ...[
            const SizedBox(height: 24),
            _GeneratingPlanIndicator(),
          ],

          if (_generatedPlanJson != null && !_isGeneratingPlan) ...[
            const SizedBox(height: 24),
            _PlanPreviewCard(
              planJson: _generatedPlanJson!,
              dogName: widget.dog.name,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generatePlan() async {
    if (_selectedTrigger == null) return;
    setState(() => _isGeneratingPlan = true);

    try {
      final planData = await _claude.generateTrainingPlan(
        dog: widget.dog,
        targetTrigger: _selectedTrigger!,
        recentLogs: widget.recentLogs,
      );
      if (mounted) {
        setState(() {
          _generatedPlanJson = planData.toString();
          _isGeneratingPlan = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingPlan = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan oluşturulamadı: $e')),
        );
      }
    }
  }

  // ─── PROGRESS TAB ───────────────────────────────────────────────────────────
  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'İlerleme Analizi',
            subtitle: 'AI destekli değerlendirme',
            icon: Icons.insights,
          ),
          const SizedBox(height: 16),

          if (_progressAnalysis != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.05),
                    AppTheme.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI Değerlendirmesi',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _progressAnalysis!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms)
          else
            const _ProgressAnalysisShimmer(),

          const SizedBox(height: 20),

          // Stats grid
          _buildStatsGrid(),

          const SizedBox(height: 20),

          // Recent sessions list
          const Text(
            'Son Oturumlar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          ...widget.recentLogs.take(5).map(_buildLogItem),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final totalSessions = widget.recentLogs.length;
    final avgIntensity = totalSessions > 0
        ? widget.recentLogs
                .map((l) => l.intensity.index)
                .reduce((a, b) => a + b) /
            totalSessions
        : 0.0;
    final improvementCount = widget.recentLogs
        .where((l) => l.intensity == ReactionIntensity.none ||
            l.intensity == ReactionIntensity.mild)
        .length;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          value: '$totalSessions',
          label: 'Toplam Oturum',
          icon: Icons.timeline,
          color: AppTheme.primary,
        ),
        _StatCard(
          value: avgIntensity < 2 ? 'İyi' : avgIntensity < 3 ? 'Orta' : 'Gelişiyor',
          label: 'Ortalama Tepki',
          icon: Icons.trending_down,
          color: avgIntensity < 2 ? AppTheme.secondary : AppTheme.accent,
        ),
        _StatCard(
          value: '$improvementCount',
          label: 'Başarılı Oturum',
          icon: Icons.emoji_events,
          color: AppTheme.secondary,
        ),
        _StatCard(
          value: widget.dog.triggers.length.toString(),
          label: 'Takip Edilen Tetikleyici',
          icon: Icons.track_changes,
          color: AppTheme.accent,
        ),
      ],
    );
  }

  Widget _buildLogItem(TriggerLog log) {
    final color = AppTheme.calmLevelColor(log.intensity.index + 1);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.trigger,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${log.intensityLabel} • ${log.date.toString().substring(0, 10)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.recoveryLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPER WIDGETS ─────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  });
}

class _StreamingText extends StatefulWidget {
  final String text;
  const _StreamingText({required this.text});

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
        FadeTransition(
          opacity: _blinkController,
          child: Container(
            width: 2,
            height: 16,
            margin: const EdgeInsets.only(left: 2, bottom: 1),
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _GeneratingPlanIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'AI koçun köpeğin için özel plan hazırlıyor...',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu 10-15 saniye sürebilir',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class _PlanPreviewCard extends StatelessWidget {
  final String planJson;
  final String dogName;

  const _PlanPreviewCard({required this.planJson, required this.dogName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary.withOpacity(0.1),
            AppTheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.secondary),
              const SizedBox(width: 8),
              Text(
                '$dogName için Plan Hazır!',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '4 haftalık kişisel eğitim planın oluşturuldu. '
            'Her hafta özel egzersizler ve koç notları içeriyor.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
              ),
              child: const Text('Planı Görüntüle ve Kaydet'),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }
}

class _ProgressAnalysisShimmer extends StatelessWidget {
  const _ProgressAnalysisShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 160,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          )),
        ],
      ),
    ).animate(
      onPlay: (c) => c.repeat(reverse: true),
    ).shimmer(duration: 1.5.seconds, color: Colors.white60);
  }
}
