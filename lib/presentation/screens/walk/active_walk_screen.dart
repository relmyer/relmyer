import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/distance_calculator.dart';
import '../../../core/utils/format_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/walk_provider.dart';
import '../../../data/models/walk_model.dart';

class ActiveWalkScreen extends StatefulWidget {
  const ActiveWalkScreen({super.key});

  @override
  State<ActiveWalkScreen> createState() => _ActiveWalkScreenState();
}

class _ActiveWalkScreenState extends State<ActiveWalkScreen> {
  GoogleMapController? _mapController;
  bool _isStarted = false;
  bool _showSummary = false;
  WalkModel? _completedWalk;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWalk());
  }

  Future<void> _startWalk() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final typeStr = args?['type'] ?? 'solo';
    final walkType =
        typeStr == 'group' ? WalkType.group : WalkType.solo;

    final user = context.read<AuthProvider>().currentUser!;
    final success = await context.read<WalkProvider>().startWalk(
          type: walkType,
          userId: user.id,
          weightKg: user.weightKg,
        );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.errorLocationPermission),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _isStarted = true);
  }

  Future<void> _finishWalk() async {
    final confirmed = await _showStopConfirmDialog();
    if (!confirmed) return;

    final userId = context.read<AuthProvider>().currentUser!.id;
    final walk = await context.read<WalkProvider>().finishWalk(userId: userId);

    if (walk != null) {
      setState(() {
        _completedWalk = walk;
        _showSummary = true;
      });
    }
  }

  Future<bool> _showStopConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Yürüyüşü Bitir'),
            content:
                const Text('Yürüyüşü bitirmek ve kaydetmek istiyor musun?'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hayır'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Evet, Bitir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_showSummary && _completedWalk != null) {
      return _WalkSummaryScreen(walk: _completedWalk!);
    }

    return Scaffold(
      body: Consumer<WalkProvider>(
        builder: (_, provider, __) {
          final route = provider.routePoints;

          return Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: route.isNotEmpty
                      ? route.last
                      : const LatLng(41.0082, 28.9784), // Istanbul default
                  zoom: 16,
                ),
                onMapCreated: (c) => _mapController = c,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                polylines: {
                  if (route.length >= 2)
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: route,
                      color: AppColors.primary,
                      width: 5,
                      jointType: JointType.round,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                    ),
                },
                markers: {
                  if (route.isNotEmpty)
                    Marker(
                      markerId: const MarkerId('start'),
                      position: route.first,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      infoWindow: const InfoWindow(title: 'Başlangıç'),
                    ),
                },
                zoomControlsEnabled: false,
                mapType: MapType.normal,
              ),

              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final cancel = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Yürüyüşü İptal Et'),
                                content: const Text(
                                    'İlerleme kaydedilmeyecek. Devam et?'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Hayır'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('İptal Et',
                                        style: TextStyle(
                                            color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                            if (cancel == true && mounted) {
                              provider.cancelWalk();
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: provider.walkType == WalkType.group
                                ? AppColors.groupGradient
                                : AppColors.soloGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                provider.walkType == WalkType.group
                                    ? Icons.group_rounded
                                    : Icons.person_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                provider.walkType == WalkType.group
                                    ? 'Grup'
                                    : 'Solo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom stats card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main timer
                      Text(
                        DistanceCalculator.formatDuration(
                            provider.durationSeconds),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -2,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _LiveStat(
                            value: DistanceCalculator.formatDistance(
                                provider.distanceM),
                            label: AppStrings.distance,
                            icon: Icons.route_rounded,
                            color: AppColors.primary,
                          ),
                          _LiveStat(
                            value: provider.steps.toString(),
                            label: AppStrings.steps,
                            icon: Icons.directions_walk_rounded,
                            color: AppColors.soloWalk,
                          ),
                          _LiveStat(
                            value:
                                '${provider.calories.toStringAsFixed(0)}',
                            label: AppStrings.calories,
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.accent,
                          ),
                          _LiveStat(
                            value: DistanceCalculator.formatPace(
                                provider.distanceM, provider.durationSeconds),
                            label: AppStrings.pace,
                            icon: Icons.speed_rounded,
                            color: AppColors.groupWalk,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Pause / Stop buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (provider.isPaused) {
                                  provider.resumeWalk();
                                } else {
                                  provider.pauseWalk();
                                }
                              },
                              icon: Icon(provider.isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded),
                              label: Text(provider.isPaused
                                  ? AppStrings.resumeWalk
                                  : AppStrings.pauseWalk),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _finishWalk,
                              icon: const Icon(Icons.stop_rounded),
                              label: const Text(AppStrings.stopWalk),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _LiveStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Walk summary after completion
class _WalkSummaryScreen extends StatelessWidget {
  final WalkModel walk;

  const _WalkSummaryScreen({required this.walk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                AppStrings.walkCompleted,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                FormatUtils.formatDateFull(walk.startTime),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 32),

              // Main distance card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.route_rounded,
                        color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DistanceCalculator.formatDistance(walk.distanceM),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _SummaryCard(
                    label: AppStrings.steps,
                    value: FormatUtils.formatNumber(walk.steps),
                    unit: 'adım',
                    icon: Icons.directions_walk_rounded,
                    color: AppColors.soloWalk,
                  ),
                  _SummaryCard(
                    label: AppStrings.calories,
                    value: walk.calories.toStringAsFixed(0),
                    unit: 'kcal',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.accent,
                  ),
                  _SummaryCard(
                    label: AppStrings.duration,
                    value: DistanceCalculator.formatDuration(
                        walk.durationSeconds),
                    unit: '',
                    icon: Icons.timer_outlined,
                    color: AppColors.primary,
                  ),
                  _SummaryCard(
                    label: AppStrings.pace,
                    value: DistanceCalculator.formatPace(
                        walk.distanceM, walk.durationSeconds),
                    unit: 'dk/km',
                    icon: Icons.speed_rounded,
                    color: AppColors.groupWalk,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Area explored card
              if (walk.areaM2 > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded,
                          color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keşfedilen Alan',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            FormatUtils.formatArea(walk.areaM2),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Sphere\'ine Eklendi!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/main'));
                },
                child: const Text('Ana Sayfaya Dön'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/zone-map'),
                icon: const Icon(Icons.map_rounded),
                label: const Text('Sphere Haritamı Gör'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
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
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: ' $unit',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
