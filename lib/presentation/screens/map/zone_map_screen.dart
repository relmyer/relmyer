import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/zone_model.dart';
import '../../../data/repositories/walk_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ZoneMapScreen extends StatefulWidget {
  const ZoneMapScreen({super.key});

  @override
  State<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends State<ZoneMapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late TabController _tabController;

  List<ZoneModel> _myZones = [];
  List<ZoneModel> _friendZones = [];
  bool _isLoading = true;
  bool _showFriends = true;
  double _myTotalArea = 0;
  double _friendTotalArea = 0;

  Set<Polygon> _polygons = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadZones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser!.id;
    final friendIds = auth.currentUser!.friendIds;

    final repo = WalkRepository();
    final myZones = await repo.getUserZones(userId);
    final friendZones = await repo.getFriendZones(friendIds);

    final myTotal = myZones.fold(0.0, (s, z) => s + z.areaM2);
    final friendTotal = friendZones.fold(0.0, (s, z) => s + z.areaM2);

    setState(() {
      _myZones = myZones;
      _friendZones = friendZones;
      _myTotalArea = myTotal;
      _friendTotalArea = friendTotal;
      _isLoading = false;
      _buildPolygons();
    });
  }

  void _buildPolygons() {
    final Set<Polygon> polygons = {};

    for (int i = 0; i < _myZones.length; i++) {
      final zone = _myZones[i];
      if (zone.polygon.length >= 3) {
        polygons.add(Polygon(
          polygonId: PolygonId('my_$i'),
          points: zone.polygon,
          fillColor: AppColors.zoneOwn,
          strokeColor: AppColors.primary,
          strokeWidth: 2,
        ));
      }
    }

    if (_showFriends) {
      for (int i = 0; i < _friendZones.length; i++) {
        final zone = _friendZones[i];
        if (zone.polygon.length >= 3) {
          polygons.add(Polygon(
            polygonId: PolygonId('friend_$i'),
            points: zone.polygon,
            fillColor: AppColors.zoneFriend,
            strokeColor: AppColors.soloWalk,
            strokeWidth: 2,
          ));
        }
      }
    }

    _polygons = polygons;
  }

  LatLng? _getCenter() {
    final allPoints = [
      ..._myZones.expand((z) => z.polygon),
      ..._friendZones.expand((z) => z.polygon),
    ];
    if (allPoints.isEmpty) return null;
    final lat = allPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
        allPoints.length;
    final lng = allPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
        allPoints.length;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _getCenter() ?? const LatLng(41.0082, 28.9784),
              zoom: 14,
            ),
            onMapCreated: (c) => _mapController = c,
            polygons: _polygons,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          // Top card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12, blurRadius: 8)
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12, blurRadius: 8)
                              ],
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '🌐',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sphere Haritam',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Toplam: ${FormatUtils.formatArea(_myTotalArea)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                            color: AppColors.primary,
                            label: 'Benim (${_myZones.length})'),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFriends = !_showFriends;
                              _buildPolygons();
                            });
                          },
                          child: _LegendItem(
                            color: AppColors.soloWalk,
                            label:
                                'Arkadaşlar (${_friendZones.length})',
                            active: _showFriends,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom comparison card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 16)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Alan Karşılaştırması',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _AreaCompareCard(
                          label: 'Benim Spherem',
                          area: _myTotalArea,
                          color: AppColors.primary,
                          icon: '🌐',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AreaCompareCard(
                          label: 'Arkadaşlar',
                          area: _friendTotalArea,
                          color: AppColors.soloWalk,
                          icon: '👥',
                        ),
                      ),
                    ],
                  ),

                  if (_myTotalArea > 0 && _friendTotalArea > 0) ...[
                    const SizedBox(height: 12),
                    _AreaBar(
                        myArea: _myTotalArea,
                        friendArea: _friendTotalArea),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool active;

  const _LegendItem(
      {required this.color, required this.label, this.active = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(active ? 1.0 : 0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: active ? color : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaCompareCard extends StatelessWidget {
  final String label;
  final double area;
  final Color color;
  final String icon;

  const _AreaCompareCard({
    required this.label,
    required this.area,
    required this.color,
    required this.icon,
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
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            FormatUtils.formatArea(area),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
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
    );
  }
}

class _AreaBar extends StatelessWidget {
  final double myArea;
  final double friendArea;

  const _AreaBar({required this.myArea, required this.friendArea});

  @override
  Widget build(BuildContext context) {
    final total = myArea + friendArea;
    final myFraction = myArea / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Oran',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Flexible(
                  flex: (myFraction * 100).round(),
                  child: Container(color: AppColors.primary),
                ),
                Flexible(
                  flex: ((1 - myFraction) * 100).round(),
                  child: Container(color: AppColors.soloWalk),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ben: ${(myFraction * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.primary),
            ),
            Text(
              'Arkadaşlar: ${((1 - myFraction) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.soloWalk),
            ),
          ],
        ),
      ],
    );
  }
}
