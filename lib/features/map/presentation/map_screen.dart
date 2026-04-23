import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/event_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/event_service.dart';
import '../../../services/events_notifier.dart';
import '../../../services/location_service.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _citySearchController = TextEditingController();
  EventModel? _selectedEvent;
  String? _activeCityFilter; // null → user's saved city

  @override
  void dispose() {
    _citySearchController.dispose();
    super.dispose();
  }

  void _moveToCity(String city) {
    final coords = LocationService.coordsForCity(city);
    if (coords != null) {
      _mapController.move(LatLng(coords.$1, coords.$2), 12.0);
    }
    setState(() {
      _activeCityFilter = city;
      _selectedEvent = null;
    });
    // Trigger API fetch for this city
    ref.read(eventsQueryProvider.notifier).updateParameters(
          city: city,
          clearCoords: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Determine map center
    final userCity = currentUser?.city;
    final displayCity = _activeCityFilter ?? userCity;

    // We don't want to snap the map center reactively if the user is dragging,
    // so we only use this for initial state or explicit moves.
    // However, for simplicity in this implementation, we define a point to show.
    LatLng? initialCenter;
    if (displayCity != null) {
      final coords = LocationService.coordsForCity(displayCity);
      if (coords != null) {
        initialCenter = LatLng(coords.$1, coords.$2);
      }
    }

    final double lat = initialCenter?.latitude ?? currentUser?.latitude ?? 0;
    final double lng = initialCenter?.longitude ?? currentUser?.longitude ?? 0;
    final LatLng center = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingLarge,
              0,
              AppConstants.paddingLarge,
              AppConstants.paddingMedium,
            ),
            child: TextField(
              controller: _citySearchController,
              onSubmitted: (v) {
                final trimmed = v.trim();
                if (trimmed.isNotEmpty) {
                  _moveToCity(trimmed);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search city (e.g. Lahore, London…)',
                prefixIcon: const Icon(Icons.place, color: AppColors.primary),
                contentPadding: EdgeInsets.zero,
                suffixIcon: _citySearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _citySearchController.clear();
                          setState(() {
                            _activeCityFilter = null;
                            _selectedEvent = null;
                          });
                          // Reset query to user's location
                          ref.read(eventsQueryProvider.notifier).updateQuery(EventsQuery(
                            city: userCity,
                            lat: currentUser?.latitude,
                            lng: currentUser?.longitude,
                          ));
                          if (userCity != null) {
                            final coords =
                                LocationService.coordsForCity(userCity);
                            if (coords != null) {
                              _mapController.move(
                                  LatLng(coords.$1, coords.$2), 12.0);
                            }
                          }
                        },
                      )
                    : const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),
        ),
      ),
      body: eventsAsync.when(
        data: (displayedEvents) => _buildMap(context, currentUser, displayedEvents, center, displayCity),
        loading: () => const Stack(
          children: [
            Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.refresh(eventsNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context, UserModel? currentUser,
      List<EventModel> displayedEvents, LatLng center, String? displayCity) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12.0,
            onTap: (_, __) => setState(() => _selectedEvent = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.acara',
            ),
            MarkerLayer(
              markers: [
                // ── User location pin (blue) ─────────
                if (currentUser?.latitude != null &&
                    currentUser?.longitude != null)
                  Marker(
                    point: LatLng(
                        currentUser!.latitude!, currentUser.longitude!),
                    width: 48,
                    height: 48,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.blue.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 18),
                    ),
                  ),

                // ── Event pins ───────────────────────
                ...displayedEvents.map((event) {
                  final isSelected = _selectedEvent?.id == event.id;
                  return Marker(
                    point: LatLng(event.latitude, event.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedEvent = event);
                        _mapController.move(
                            LatLng(event.latitude, event.longitude),
                            14.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        // City filter info badge
        if (displayCity != null)
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '$displayCity (${displayedEvents.length})',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

        // Re-center on user button
        Positioned(
          bottom: AppConstants.paddingLarge + 80 + 60,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'map_my_loc_2',
            backgroundColor: Colors.white,
            onPressed: () {
              if (currentUser?.latitude != null) {
                _mapController.move(
                  LatLng(
                      currentUser!.latitude!, currentUser.longitude!),
                  12.0,
                );
                _citySearchController.clear();
                setState(() => _activeCityFilter = null);
                // Reset query
                ref.read(eventsQueryProvider.notifier).updateQuery(EventsQuery(
                  city: currentUser?.city,
                  lat: currentUser?.latitude,
                  lng: currentUser?.longitude,
                ));
              }
            },
            child: const Icon(Icons.my_location,
                color: AppColors.primary, size: 20),
          ),
        ),

        // Selected event preview card
        if (_selectedEvent != null)
          Positioned(
            left: AppConstants.paddingLarge,
            right: AppConstants.paddingLarge,
            bottom: AppConstants.paddingLarge + 80,
            child: Dismissible(
              key: ValueKey(_selectedEvent!.id),
              direction: DismissDirection.down,
              onDismissed: (_) =>
                  setState(() => _selectedEvent = null),
              child: Container(
                padding:
                    const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedEvent!.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place,
                            size: 14,
                            color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${_selectedEvent!.city}, ${_selectedEvent!.country}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('EEE, d MMM').format(_selectedEvent!.date)} • ${_selectedEvent!.venue}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context
                                .push('/event/${_selectedEvent!.id}'),
                            child: const Text('View Details'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Directions to ${_selectedEvent!.venue}, ${_selectedEvent!.city}',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Get Directions'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

