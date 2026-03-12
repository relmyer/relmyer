import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/dog.dart';
import 'models/trigger_log.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/community_screen.dart';
import 'screens/progress_screen.dart';
import 'theme/app_theme.dart';

class PawCalmApp extends StatelessWidget {
  const PawCalmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawCalm',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  // Demo dog for development — replace with real auth + Firestore data
  final Dog _demoDog = Dog(
    id: 'demo-dog-1',
    ownerId: 'demo-user-1',
    name: 'Pamuq',
    breed: 'Labrador Retriever',
    ageMonths: 36,
    size: DogSize.large,
    reactivityLevel: DogReactivityLevel.moderate,
    triggers: ['Diğer köpekler', 'Bisiklet', 'Koşucu'],
    fears: ['Gök gürültüsü', 'Havai fişek'],
    notes: 'Kurtarıldı, başlangıçta çok korkaktı. İyi ilerleme kaydediyor.',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  );

  // Demo logs for development
  final List<TriggerLog> _demoLogs = [
    TriggerLog(
      id: '1', dogId: 'demo-dog-1', ownerId: 'demo-user-1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      trigger: 'Diğer köpekler',
      intensity: ReactionIntensity.mild,
      recoveryTime: RecoveryTime.onetofive,
      distanceToTrigger: 8,
      usedCalming: true,
      calmingTechnique: 'U-dönüşü',
      treatUsed: true,
      moodBefore: 3,
      moodAfter: 4,
    ),
    TriggerLog(
      id: '2', dogId: 'demo-dog-1', ownerId: 'demo-user-1',
      date: DateTime.now().subtract(const Duration(days: 3)),
      trigger: 'Bisiklet',
      intensity: ReactionIntensity.moderate,
      recoveryTime: RecoveryTime.onetofive,
      distanceToTrigger: 12,
      usedCalming: true,
      calmingTechnique: 'Yem saçma',
      treatUsed: true,
      moodBefore: 3,
      moodAfter: 3,
    ),
    TriggerLog(
      id: '3', dogId: 'demo-dog-1', ownerId: 'demo-user-1',
      date: DateTime.now().subtract(const Duration(days: 5)),
      trigger: 'Diğer köpekler',
      intensity: ReactionIntensity.severe,
      recoveryTime: RecoveryTime.fivetoFifteen,
      distanceToTrigger: 5,
      usedCalming: false,
      moodBefore: 2,
      moodAfter: 2,
    ),
    TriggerLog(
      id: '4', dogId: 'demo-dog-1', ownerId: 'demo-user-1',
      date: DateTime.now().subtract(const Duration(days: 7)),
      trigger: 'Diğer köpekler',
      intensity: ReactionIntensity.moderate,
      recoveryTime: RecoveryTime.onetofive,
      distanceToTrigger: 10,
      usedCalming: true,
      calmingTechnique: 'Uzaklaş',
      moodBefore: 3,
      moodAfter: 3,
    ),
    TriggerLog(
      id: '5', dogId: 'demo-dog-1', ownerId: 'demo-user-1',
      date: DateTime.now().subtract(const Duration(days: 10)),
      trigger: 'Bisiklet',
      intensity: ReactionIntensity.mild,
      recoveryTime: RecoveryTime.under1min,
      distanceToTrigger: 15,
      usedCalming: true,
      calmingTechnique: 'Odak eğitimi',
      treatUsed: true,
      moodBefore: 4,
      moodAfter: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(dog: _demoDog, recentLogs: _demoLogs),
      const MapScreen(),
      CommunityScreen(),
      ProgressScreen(dog: _demoDog, logs: _demoLogs),
    ];

    return Scaffold(
      appBar: _currentIndex == 1
          ? null
          : AppBar(
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.pets, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('PawCalm'),
                ],
              ),
              actions: [
                if (_currentIndex == 0)
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                if (_currentIndex == 0)
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {},
                  ),
              ],
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primary),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppTheme.primary),
            label: 'Harita',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppTheme.primary),
            label: 'Topluluk',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: AppTheme.primary),
            label: 'İlerleme',
          ),
        ],
      ),
    );
  }
}
