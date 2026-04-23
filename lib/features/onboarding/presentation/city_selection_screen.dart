import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_preferences_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';

class CitySelectionScreen extends ConsumerStatefulWidget {
  const CitySelectionScreen({super.key});

  @override
  ConsumerState<CitySelectionScreen> createState() =>
      _CitySelectionScreenState();
}

class _CitySelectionScreenState extends ConsumerState<CitySelectionScreen> {
  final _searchController = TextEditingController();
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;

  static const _popularCities = [
    ('Lahore', 'Pakistan', 31.5497, 74.3436, 'PK'),
    ('Karachi', 'Pakistan', 24.8607, 67.0011, 'PK'),
    ('Islamabad', 'Pakistan', 33.6844, 73.0479, 'PK'),
    ('London', 'United Kingdom', 51.5074, -0.1278, 'GB'),
    ('Dubai', 'UAE', 25.2048, 55.2708, 'AE'),
    ('New York', 'USA', 40.7128, -74.0060, 'US'),
    ('Jakarta', 'Indonesia', -6.2088, 106.8456, 'ID'),
    ('Singapore', 'Singapore', 1.3521, 103.8198, 'SG'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await ref.read(locationServiceProvider).searchCities(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _selectLocation(double lat, double lng, String city, String country, String code) async {
    // Save to preferences
    await ref.read(appPreferencesProvider.notifier).setManualLocation(
      city: city,
      country: country,
      countryCode: code,
      latitude: lat,
      longitude: lng,
    );

    // Update user profile in Supabase if logged in
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(currentUserProvider.notifier).updateLocation(lat, lng, city, country, code);
    }

    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Find events in your city',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search city or country...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? _buildSearchResults()
                  : _buildPopularCities(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Results',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return _LocationTile(
                title: result.city,
                subtitle: result.country,
                onTap: () => _selectLocation(
                  result.latitude,
                  result.longitude,
                  result.city,
                  result.country,
                  result.countryCode,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Cities',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _popularCities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final city = _popularCities[index];
              return _LocationTile(
                title: city.$1,
                subtitle: city.$2,
                onTap: () => _selectLocation(city.$3, city.$4, city.$1, city.$2, city.$5),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LocationTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.location_on, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}
