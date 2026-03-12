import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    userProvider.loadFriends(auth.currentUser?.friendIds ?? []);
    userProvider.loadPendingRequests(auth.currentUser?.id ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.friends),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(
              text:
                  'Arkadaşlar (${userProvider.friends.length})',
            ),
            Tab(
              text: userProvider.pendingRequests.isEmpty
                  ? 'İstekler'
                  : 'İstekler (${userProvider.pendingRequests.length})',
            ),
            const Tab(text: 'Ara'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Friends list
          _FriendsList(
            friends: userProvider.friends,
            currentUserId: auth.currentUser?.id ?? '',
          ),

          // Pending requests
          _PendingRequestsList(
            requests: userProvider.pendingRequests,
          ),

          // Search
          _SearchTab(searchController: _searchController),
        ],
      ),
    );
  }
}

class _FriendsList extends StatelessWidget {
  final List<UserModel> friends;
  final String currentUserId;

  const _FriendsList(
      {required this.friends, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👥', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text(
              AppStrings.noFriends,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.noFriendsDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      itemBuilder: (_, i) {
        final friend = friends[i];
        return _FriendCard(friend: friend, currentUserId: currentUserId);
      },
    );
  }
}

class _FriendCard extends StatelessWidget {
  final UserModel friend;
  final String currentUserId;

  const _FriendCard(
      {required this.friend, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: friend.photoUrl != null
                ? NetworkImage(friend.photoUrl!)
                : null,
            child: friend.photoUrl == null
                ? Text(
                    friend.name.isNotEmpty
                        ? friend.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${FormatUtils.formatNumber(friend.totalSteps)} adım • ${DistanceCalculator.formatDistance(friend.totalDistanceM)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'remove') {
                context.read<UserProvider>().removeFriend(
                      currentUserId,
                      friend.id,
                    );
              } else if (val == 'compare') {
                Navigator.pushNamed(
                  context,
                  '/comparison',
                  arguments: friend,
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'compare',
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Karşılaştır'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove_rounded,
                        size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(AppStrings.remove,
                        style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingRequestsList extends StatelessWidget {
  final requests;

  const _PendingRequestsList({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'Bekleyen arkadaşlık isteği yok',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final req = requests[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primarySurface,
                backgroundImage: req.fromUserPhotoUrl != null
                    ? NetworkImage(req.fromUserPhotoUrl!)
                    : null,
                child: req.fromUserPhotoUrl == null
                    ? Text(
                        req.fromUserName[0].toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.fromUserName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Arkadaşlık isteği gönderdi',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.read<UserProvider>().acceptRequest(req),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context
                        .read<UserProvider>()
                        .declineRequest(req.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.error, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchTab extends StatelessWidget {
  final TextEditingController searchController;

  const _SearchTab({required this.searchController});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final auth = context.read<AuthProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'İsme göre ara...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => userProvider.searchUsers(v),
          ),
        ),
        Expanded(
          child: userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: userProvider.searchResults.length,
                  itemBuilder: (_, i) {
                    final user = userProvider.searchResults[i];
                    final isAlreadyFriend = auth.currentUser?.friendIds
                            .contains(user.id) ??
                        false;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                    color: AppColors.primary),
                              )
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                          '${FormatUtils.formatNumber(user.totalSteps)} adım'),
                      trailing: isAlreadyFriend
                          ? const Chip(label: Text('Arkadaş'))
                          : TextButton(
                              onPressed: () {
                                userProvider.sendFriendRequest(
                                  fromUserId: auth.currentUser!.id,
                                  fromUserName: auth.currentUser!.name,
                                  fromUserPhotoUrl:
                                      auth.currentUser!.photoUrl,
                                  toUserId: user.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Arkadaşlık isteği gönderildi'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text(AppStrings.addFriend),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
