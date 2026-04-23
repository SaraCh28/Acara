import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/location_utils.dart';
import '../../../models/event_model.dart';
import '../../../services/app_preferences_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/event_service.dart';
import '../../../services/events_notifier.dart';
import '../../../widgets/event_card.dart';

// Known cities for quick location filter chips
const _kCityOptions = [
  (city: 'All Cities', countryCode: null),
  (city: 'Jakarta', countryCode: 'ID'),
  (city: 'Lahore', countryCode: 'PK'),
  (city: 'London', countryCode: 'GB'),
  (city: 'Dubai', countryCode: 'AE'),
  (city: 'New York', countryCode: 'US'),
  (city: 'Singapore', countryCode: 'SG'),
];

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 120);
  double _maxDistance = 30;
  String _selectedDate = 'Any time';
  // null = show all cities (global); non-null = filter to that city
  String? _selectedLocationFilter;
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    // Default location filter to user's city
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user?.city != null) {
        setState(() {
          _selectedLocationFilter = user!.city;
          _selectedCountryCode = user.countryCode;
          _locationController.text = user.city!;
        });
        // Set initial query
        ref.read(eventsQueryProvider.notifier).updateQuery(EventsQuery(
          city: user?.city,
          country: user?.countryCode,
        ));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _updateQuery() {
    ref.read(eventsQueryProvider.notifier).updateParameters(
          city: _selectedLocationFilter,
          country: _selectedCountryCode,
          keyword: _searchController.text.trim(),
          category: _selectedCategory,
          clearCity: _selectedLocationFilter == null,
        );
  }

  void _showFilterModal() {
    var tempPriceRange = _priceRange;
    var tempDistance = _maxDistance;
    var tempDate = _selectedDate;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: AppConstants.paddingLarge,
                right: AppConstants.paddingLarge,
                top: AppConstants.paddingLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters',
                          style:
                              Theme.of(context).textTheme.headlineMedium),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempPriceRange = const RangeValues(0, 120);
                            tempDistance = 30;
                            tempDate = 'Any time';
                          });
                        },
                        child: const Text('Clear all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text('Date',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Any time', 'Today', 'This week', 'This month']
                        .map((value) => ChoiceChip(
                              label: Text(value),
                              selected: tempDate == value,
                              onSelected: (_) =>
                                  setModalState(() => tempDate = value),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Text('Maximum distance',
                      style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: tempDistance,
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '${tempDistance.round()} km',
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setModalState(() => tempDistance = v),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text('Price range',
                      style: Theme.of(context).textTheme.titleMedium),
                  RangeSlider(
                    values: tempPriceRange,
                    min: 0,
                    max: 200,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${tempPriceRange.start.round()}',
                      '\$${tempPriceRange.end.round()}',
                    ),
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setModalState(() => tempPriceRange = v),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _priceRange = tempPriceRange;
                        _maxDistance = tempDistance;
                        _selectedDate = tempDate;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final eventsAsync = ref.watch(eventsNotifierProvider);
    final searchHistory = ref.watch(appPreferencesProvider).searchHistory;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore'), centerTitle: false),
      body: Column(
        children: [
          // ── Search + filter row ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (v) {
                      ref.read(appPreferencesProvider.notifier).addSearchTerm(v);
                      _updateQuery();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search events, categories…',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _updateQuery();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: _showFilterModal,
                  ),
                ),
              ],
            ),
          ),

          // ── Location filter field ───────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
            ),
            child: TextField(
              controller: _locationController,
              onSubmitted: (v) {
                setState(() {
                  _selectedLocationFilter = v.trim().isEmpty ? null : v.trim();
                });
                _updateQuery();
              },
              decoration: InputDecoration(
                hintText: 'Filter by city (e.g. Lahore, London…)',
                prefixIcon:
                    const Icon(Icons.place, color: AppColors.primary),
                contentPadding: EdgeInsets.zero,
                suffixIcon: _locationController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _locationController.clear();
                          setState(() => _selectedLocationFilter = null);
                          _updateQuery();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Quick city chips ────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge),
              scrollDirection: Axis.horizontal,
              itemCount: _kCityOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final opt = _kCityOptions[index];
                final isAll = opt.city == 'All Cities';
                final isSelected = isAll
                    ? _selectedLocationFilter == null
                    : _selectedLocationFilter?.toLowerCase() ==
                        opt.city.toLowerCase();
                return ChoiceChip(
                  label: Text(opt.city, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      if (isAll) {
                        _selectedLocationFilter = null;
                        _selectedCountryCode = null;
                        _locationController.clear();
                      } else {
                        _selectedLocationFilter = opt.city;
                        _selectedCountryCode = opt.countryCode;
                        _locationController.text = opt.city;
                      }
                    });
                    _updateQuery();
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Search suggestions ──────────────────────
          if (searchHistory.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final suggestion = searchHistory[index];
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      _searchController.text = suggestion;
                      ref
                          .read(appPreferencesProvider.notifier)
                          .addSearchTerm(suggestion);
                      _updateQuery();
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: searchHistory.length,
              ),
            ),
          const SizedBox(height: AppConstants.paddingSmall),

          // ── Category chips ──────────────────────────
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge),
              scrollDirection: Axis.horizontal,
              itemCount: [
                'All',
                'Music',
                'Sports',
                'Arts',
                'Food',
                'Technology',
                'Wellness'
              ].length,
              itemBuilder: (context, index) {
                final category = [
                  'All',
                  'Music',
                  'Sports',
                  'Arts',
                  'Food',
                  'Technology',
                  'Wellness'
                ][index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                      _updateQuery();
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Results / Loading / Error
          Expanded(
            child: eventsAsync.when(
              data: (allEvents) {
                // local filtering for price & date (TM doesn't always support minPrice easily in Discovery API)
                final filtered = allEvents.where((e) {
                  final matchesPrice = e.price >= _priceRange.start &&
                      e.price <= _priceRange.end;
                  final matchesDate = switch (_selectedDate) {
                    'Today' =>
                      e.date.day == DateTime.now().day &&
                          e.date.month == DateTime.now().month,
                    'This week' => e.date.isBefore(
                        DateTime.now().add(const Duration(days: 7))),
                    'This month' => e.date.month == DateTime.now().month,
                    _ => true,
                  };
                  return matchesPrice && matchesDate;
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge),
                      child: Row(
                        children: [
                          Text(
                            '${filtered.length} event${filtered.length == 1 ? '' : 's'}'
                            '${_selectedLocationFilter != null ? ' in $_selectedLocationFilter' : ''}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingLarge),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final event = filtered[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppConstants.paddingMedium),
                                  child: EventCard(
                                    event: event,
                                    isHorizontal: true,
                                    onTap: () =>
                                        context.push('/event/${event.id}'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error fetching results: $err',
                        textAlign: TextAlign.center),
                    TextButton(
                      onPressed: () => ref.refresh(eventsNotifierProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No events found',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _priceRange = const RangeValues(0, 120);
                _maxDistance = 30;
                _selectedDate = 'Any time';
                _selectedLocationFilter = null;
                _selectedCountryCode = null;
                _searchController.clear();
                _locationController.clear();
              });
              _updateQuery();
            },
            child: const Text('Clear all filters'),
          ),
        ],
      ),
    );
  }
}

