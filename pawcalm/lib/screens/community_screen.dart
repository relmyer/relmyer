import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<_Post> _posts = _samplePosts;
  final List<_SupportGroup> _groups = _sampleGroups;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topluluk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _createPost,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Akış'),
            Tab(text: 'Gruplar'),
            Tab(text: 'Başarılar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildGroupsTab(),
          _buildAchievementsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.add),
        label: const Text('Paylaş'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildFeedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // "Today's Challenge" card - unique feature
        _DailyChallengeBanner()
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.1),

        const SizedBox(height: 16),

        // Posts
        ..._posts.asMap().entries.map((entry) =>
          _PostCard(post: entry.value)
              .animate(delay: (entry.key * 80).ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05),
        ),
      ],
    );
  }

  Widget _buildGroupsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (context, i) => _GroupCard(group: _groups[i])
          .animate(delay: (i * 80).ms)
          .fadeIn(duration: 300.ms),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topluluk Başarıları',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bu hafta en çok ilerleme kaydeden sahipler',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (i) => _LeaderboardItem(
            rank: i + 1,
            name: ['Ayşe & Pamuq', 'Mehmet & Karabaş', 'Zeynep & Luna',
                   'Can & Max', 'Selin & Boncuk'][i],
            dogBreed: ['Labrador', 'Kangal', 'Border Collie', 'Beagle', 'Poodle'][i],
            sessions: [12, 10, 9, 8, 7][i],
            improvement: ['+68%', '+55%', '+42%', '+38%', '+31%'][i],
          ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: -0.05)),
        ],
      ),
    );
  }

  void _createPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım oluştur - Yakında!')),
    );
  }
}

// ─── DATA MODELS ────────────────────────────────────────────────────────────

class _Post {
  final String author;
  final String dogName;
  final String breed;
  final String text;
  final String? imageUrl;
  final String time;
  final int likes;
  final int comments;
  final List<String> tags;

  const _Post({
    required this.author,
    required this.dogName,
    required this.breed,
    required this.text,
    this.imageUrl,
    required this.time,
    required this.likes,
    required this.comments,
    this.tags = const [],
  });
}

class _SupportGroup {
  final String name;
  final String description;
  final int memberCount;
  final String emoji;
  final String specialty;

  const _SupportGroup({
    required this.name,
    required this.description,
    required this.memberCount,
    required this.emoji,
    required this.specialty,
  });
}

final _samplePosts = [
  _Post(
    author: 'Ayşe K.',
    dogName: 'Pamuq',
    breed: 'Labrador',
    text: 'Bugün tarihi bir an! Pamuq, 3 metre mesafeden geçen bisikletçiyi fark etti ama "bak" komutunu yapıp bana döndü! 6 aydır çalışıyoruz bu an için 😭❤️',
    time: '2 saat önce',
    likes: 47,
    comments: 12,
    tags: ['İlerleme', 'Bisiklet reaktivitesi'],
  ),
  _Post(
    author: 'Mehmet T.',
    dogName: 'Karabaş',
    breed: 'Kangal',
    text: 'BAT 2.0 ile çalışmaya başladık. İlk hafta sonunda Karabaş diğer köpeklere olan mesafeyi 30 metreden 20 metreye düşürdü. Küçük adımlar ama büyük zafer!',
    time: '5 saat önce',
    likes: 31,
    comments: 8,
    tags: ['BAT 2.0', 'Köpek reaktivitesi', 'Haftalık rapor'],
  ),
  _Post(
    author: 'Zeynep A.',
    dogName: 'Luna',
    breed: 'Border Collie',
    text: 'PawCalm\'daki "Sakin Mekânlar" haritası sayesinde Luna ile 3 saatlik stressiz bir yürüyüş yaptık. Kadıköy\'de bu kadar sakin bir sahil kolu olduğunu bilmiyordum! 🌊',
    time: '1 gün önce',
    likes: 58,
    comments: 19,
    tags: ['Sakin Mekân', 'Stressiz Yürüyüş'],
  ),
];

final _sampleGroups = [
  _SupportGroup(
    name: 'Köpek Reaktivitesi TR',
    description: 'Leash reactive köpek sahipleri için destek grubu. Deneyim paylaşımı ve pratik öneriler.',
    memberCount: 1240,
    emoji: '🐕',
    specialty: 'Leash reaktivite',
  ),
  _SupportGroup(
    name: 'Korku & Kaygı',
    description: 'Ayrılık kaygısı ve korku temelli davranış sorunlarıyla mücadele eden sahipler burada.',
    memberCount: 876,
    emoji: '💙',
    specialty: 'Ayrılık kaygısı',
  ),
  _SupportGroup(
    name: 'Gürültü Fobisi',
    description: 'Havai fişek, gök gürültüsü ve diğer gürültülere karşı köpek yönetimi.',
    memberCount: 654,
    emoji: '🌩️',
    specialty: 'Gürültü fobisi',
  ),
  _SupportGroup(
    name: 'Kurtarılan Köpekler',
    description: 'Kurtarılan veya ihmal/istismar geçmişi olan köpeklerin rehabilitasyonu.',
    memberCount: 2103,
    emoji: '🤍',
    specialty: 'Travma rehabilitasyonu',
  ),
];

// ─── WIDGETS ────────────────────────────────────────────────────────────────

class _DailyChallengeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF7BAFD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🎯', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Günün Meydan Okuma',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '"Bugün yürüyüşte köpeğinin vücut diline odaklan. Gerilme belirtilerini gördüğünde duraksama dene."',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              const Text(
                '234 kişi bugün denedi',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Ben de denerim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final _Post post;

  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: Text(
                  widget.post.author[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.post.author} & ${widget.post.dogName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${widget.post.breed} • ${widget.post.time}',
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
          const SizedBox(height: 10),

          // Post text
          Text(
            widget.post.text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 10),

          // Tags
          if (widget.post.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              children: widget.post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _liked = !_liked),
                child: Row(
                  children: [
                    Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: _liked ? AppTheme.danger : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.likes + (_liked ? 1 : 0)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: _liked ? AppTheme.danger : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.comment_outlined, size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.post.comments}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, size: 18, color: AppTheme.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final _SupportGroup group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(group.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  group.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${group.memberCount} üye',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Katıl'),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final String dogBreed;
  final int sessions;
  final String improvement;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.dogBreed,
    required this.sessions,
    required this.improvement,
  });

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final color = rank <= 3 ? rankColors[rank - 1] : AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rank <= 3 ? color.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank <= 3 ? color.withOpacity(0.3) : AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
                Text(dogBreed, style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                improvement,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondary,
                  fontSize: 15,
                ),
              ),
              Text(
                '$sessions oturum',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
