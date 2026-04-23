import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';

// ─────────────────────────────────────────────────────────────
// Cities the user can choose manually (searchable list)
// ─────────────────────────────────────────────────────────────
const _kCities = [
  (city: 'Jakarta', country: 'Indonesia', countryCode: 'ID', lat: -6.2088, lng: 106.8456),
  (city: 'Bandung', country: 'Indonesia', countryCode: 'ID', lat: -6.9175, lng: 107.6191),
  (city: 'Surabaya', country: 'Indonesia', countryCode: 'ID', lat: -7.2575, lng: 112.7521),
  (city: 'Bali', country: 'Indonesia', countryCode: 'ID', lat: -8.4095, lng: 115.1889),
  (city: 'Singapore', country: 'Singapore', countryCode: 'SG', lat: 1.3521, lng: 103.8198),
  (city: 'Kuala Lumpur', country: 'Malaysia', countryCode: 'MY', lat: 3.1390, lng: 101.6869),
  (city: 'Lahore', country: 'Pakistan', countryCode: 'PK', lat: 31.5497, lng: 74.3436),
  (city: 'Karachi', country: 'Pakistan', countryCode: 'PK', lat: 24.8607, lng: 67.0011),
  (city: 'Islamabad', country: 'Pakistan', countryCode: 'PK', lat: 33.6844, lng: 73.0479),
  (city: 'London', country: 'United Kingdom', countryCode: 'GB', lat: 51.5074, lng: -0.1278),
  (city: 'Dubai', country: 'UAE', countryCode: 'AE', lat: 25.2048, lng: 55.2708),
  (city: 'New York', country: 'USA', countryCode: 'US', lat: 40.7128, lng: -74.0060),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen> {
  // Location state
  double _lat = 0;
  double _lng = 0;
  String _city = '';
  String _country = '';
  String _countryCode = 'PK';
  bool _isLocating = true;
  String? _locationError;

  // UI state
  bool _showCityPicker = false;
  final _searchController = TextEditingController();
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _autoDetectLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── GPS auto-detect ──────────────────────────────────────
  Future<void> _autoDetectLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });
    try {
      final result = await ref
          .read(locationServiceProvider)
          .requestPermissionAndGetLocation();
      if (!mounted) return;
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        _city = result.city;
        _country = result.country;
        _countryCode = result.countryCode;
        _isLocating = false;
      });
      _searchController.text = '${result.city}, ${result.country}';
      _mapController.move(LatLng(_lat, _lng), 13.0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _locationError = e.toString().replaceFirst('Exception: ', '');
        // Fall back to Jakarta
        _lat = -6.2088;
        _lng = 106.8456;
        _city = 'Jakarta';
        _country = 'Indonesia';
        _countryCode = 'ID';
        _searchController.text = 'Jakarta, Indonesia';
      });
    }
  }

  // ── Select a city from the picker list ───────────────────
  void _selectCity(
    String city,
    String country,
    String countryCode,
    double lat,
    double lng,
  ) {
    setState(() {
      _lat = lat;
      _lng = lng;
      _city = city;
      _country = country;
      _countryCode = countryCode;
      _showCityPicker = false;
      _locationError = null;
    });
    _searchController.text = '$city, $country';
    _mapController.move(LatLng(lat, lng), 13.0);
  }

  Future<void> _useThisLocation() async {
    await ref.read(currentUserProvider.notifier).updateProfile(
          lat: _lat,
          lng: _lng,
          city: _city,
          country: _country,
          countryCode: _countryCode,
        );
    if (mounted) context.go('/home');
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filteredCities = _kCities.where((c) {
      final q = _searchController.text.trim().toLowerCase();
      if (!_showCityPicker || q.isEmpty) return true;
      return c.city.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────
            _buildHeader(context),

            // ─── Map or City Picker ──────────────────────
            Expanded(
              child: _showCityPicker
                  ? _buildCityPicker(filteredCities)
                  : _buildMap(),
            ),

            // ─── Bottom Panel ───────────────────────────
            _buildBottomPanel(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Sub-widgets
  // ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
        AppConstants.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Location',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 4),
          Text(
            'We use this to show nearby events. You can change it anytime.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Location search bar
          GestureDetector(
            onTap: () {
              setState(() => _showCityPicker = !_showCityPicker);
            },
            child: AbsorbPointer(
              absorbing: false,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() => _showCityPicker = true),
                onTap: () => setState(() => _showCityPicker = true),
                decoration: InputDecoration(
                  hintText: 'Search city…',
                  prefixIcon: _isLocating
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.location_on, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _showCityPicker = true);
                          },
                        )
                      : const Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ),
          ),
          if (_locationError != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '$_locationError. Showing fallback city.',
                    style:
                        Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
                  ),
                ),
                TextButton(
                  onPressed: _autoDetectLocation,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Retry', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(_lat == 0 ? -6.2088 : _lat, _lng == 0 ? 106.8456 : _lng),
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.acara',
            ),
            if (!_isLocating && _lat != 0)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(_lat, _lng),
                    width: 56,
                    height: 56,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_pin,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        CustomPaint(
                          size: const Size(10, 6),
                          painter: _TrianglePainter(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Locate me button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'locate_me',
            backgroundColor: Colors.white,
            onPressed: _autoDetectLocation,
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),

        // Loading overlay
        if (_isLocating)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Detecting your location…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCityPicker(
    List<({String city, String country, String countryCode, double lat, double lng})> cities,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingLarge,
        vertical: AppConstants.paddingSmall,
      ),
      itemCount: cities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final c = cities[index];
        final isSelected = c.city == _city;
        return ListTile(
          tileColor: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isSelected
                ? const BorderSide(color: AppColors.primary, width: 1.5)
                : BorderSide.none,
          ),
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.location_city,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 18,
            ),
          ),
          title: Text(c.city,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(c.country),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: AppColors.primary)
              : const Icon(Icons.chevron_right),
          onTap: () => _selectCity(c.city, c.country, c.countryCode, c.lat, c.lng),
        );
      },
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLarge,
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
        AppConstants.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_city.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.place, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_city, $_country',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _showCityPicker = !_showCityPicker),
                  child: Text(_showCityPicker ? 'Show map' : 'Change'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
          ],
          ElevatedButton.icon(
            onPressed: _city.isEmpty ? null : _useThisLocation,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Use This Location'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _autoDetectLocation,
            icon: const Icon(Icons.gps_fixed, size: 16),
            label: const Text('Detect my location'),
          ),
        ],
      ),
    );
  }
}

// Triangle painter for marker tail
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
