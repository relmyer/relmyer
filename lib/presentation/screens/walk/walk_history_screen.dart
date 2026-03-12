import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/walk_provider.dart';
import '../../widgets/walk_card.dart';

class WalkHistoryScreen extends StatelessWidget {
  const WalkHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walks = context.watch<WalkProvider>().walkHistory;
    final isLoading = context.watch<WalkProvider>().isLoadingHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.walkHistory),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : walks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🥾', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.noWalksYet,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppStrings.noWalksDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: walks.length,
                  itemBuilder: (_, i) => WalkCard(walk: walks[i]),
                ),
    );
  }
}
