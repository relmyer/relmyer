import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/calm_spot.dart';
import '../services/spot_service.dart';
import '../theme/app_theme.dart';
import '../widgets/spot_card.dart';
import '../widgets/calm_filter_bar.dart';
import 'spot_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final SpotService _spotService = SpotService();
  GoogleMapController? _mapController;
  Position? _userPosition;
  List<CalmSpot> _spots = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  int _minCalmFilter = 1;
  SpotType? _typeFilter;
  double _radiusKm = 5.0;
  CalmSpot? _selectedSpot;

  // Map style - lighter/calmer map
  static const String _mapStyle = '''[
    {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
    {"featureType": "transit", "stylers": [{"visibility": "simplified"}]},
    {"featureType": "road", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"featureType": "water", "elementType": "geometry.fill", "stylers": [{"color": "#b8d8e8"}]},
    {"featureType": "landscape.natural", "elementType": "geometry", "stylers": [{"color": "#e8f5e9"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final position = await _spotService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userPosition = position;
        _isLoading = false;
      });
      if (position != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14,
          ),
        );
        _loadSpots();
      }
    }
  }

  void _loadSpots() {
    if (_userPosition == null) return;
    _spotService
        .getNearbySpots(
          lat: _userPosition!.latitude,
          lng: _userPosition!.longitude,
          radiusKm: _radiusKm,
          minCalmScore: _minCalmFilter.toDouble() as int,
          type: _typeFilter,
        )
        .listen((spots) {
          if (mounted) {
            setState(() {
              _spots = spots;
              _updateMarkers();
            });
          }
        });
  }

  void _updateMarkers() {
    _markers = _spots.map((spot) {
      final calmScore = spot.currentCalmScore ?? spot.avgCalmScore;
      final level = calmScore.round().clamp(1, 5);
      final color = _calmScoreToHue(level);

      return Marker(
        markerId: MarkerId(spot.id),
        position: spot.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(color),
        infoWindow: InfoWindow(
          title: spot.name,
          snippet: '${spot.typeEmoji} ${AppTheme.calmLevelLabel(level)}',
        ),
        onTap: () => setState(() => _selectedSpot = spot),
      );
    }).toSet();
  }

  double _calmScoreToHue(int level) {
    switch (level) {
      case 1: return BitmapDescriptor.hueGreen;
      case 2: return BitmapDescriptor.hueCyan;
      case 3: return BitmapDescriptor.hueYellow;
      case 4: return BitmapDescriptor.hueOrange;
      case 5: return BitmapDescriptor.hueRed;
      default: return BitmapDescriptor.hueAzure;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          _buildMap(),

          // Top search & filters
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                CalmFilterBar(
                  selectedMinScore: _minCalmFilter,
                  selectedType: _typeFilter,
                  onScoreChanged: (v) {
                    setState(() => _minCalmFilter = v);
                    _loadSpots();
                  },
                  onTypeChanged: (t) {
                    setState(() => _typeFilter = t);
                    _loadSpots();
                  },
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
          ),

          // Live stats bar
          Positioned(
            bottom: _selectedSpot != null ? 220 : 20,
            left: 16,
            right: 16,
            child: _buildLiveStatsBar(),
          ),

          // Selected spot card
          if (_selectedSpot != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: SpotPreviewCard(
                spot: _selectedSpot!,
                onClose: () => setState(() => _selectedSpot = null),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpotDetailScreen(spot: _selectedSpot!),
                  ),
                ),
              ).animate().slideY(begin: 1, duration: 300.ms, curve: Curves.easeOut),
            ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_spot',
            backgroundColor: AppTheme.secondary,
            onPressed: _addNewSpot,
            child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'my_location',
            backgroundColor: AppTheme.primary,
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_userPosition == null && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 64, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'Konum erişimi gerekli',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Yakınındaki sakin yerleri bulmak için konum iznini aç.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initLocation,
                child: const Text('Konumu Etkinleştir'),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
        controller.setMapStyle(_mapStyle);
      },
      initialCameraPosition: CameraPosition(
        target: _userPosition != null
            ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
            : const LatLng(41.0082, 28.9784), // Istanbul default
        zoom: 13,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onTap: (_) => setState(() => _selectedSpot = null),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black12,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Sakin yer ara...',
            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatsBar() {
    final calmSpots = _spots.where((s) => s.avgCalmScore >= 4).length;
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('${_spots.length}', 'Yer Bulundu', Icons.place_outlined),
            Container(width: 1, height: 32, color: AppTheme.divider),
            _statItem('$calmSpots', 'Sakin Yer', Icons.spa_outlined),
            Container(width: 1, height: 32, color: AppTheme.divider),
            _statItem('${_radiusKm.round()} km', 'Yarıçap', Icons.radar),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  void _goToMyLocation() {
    if (_userPosition == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        15,
      ),
    );
  }

  void _addNewSpot() {
    // Navigate to add spot screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni sakin yer ekle - Yakında!')),
    );
  }
}
