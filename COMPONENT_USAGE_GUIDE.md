# Quick Implementation Guide - Acara UI Components

## How to Use Modern UI Components

### 1. ModernButton
Perfect for all call-to-action buttons with gradient backgrounds and smooth animations.

```dart
import 'package:acara/core/widgets/modern_button.dart';

ModernButton(
  text: 'Continue',
  onPressed: () => handleAction(),
  isPrimary: true,
  isLoading: isLoading,
  icon: Icons.arrow_forward,
)
```

**Properties:**
- `text`: Button label
- `onPressed`: Callback function
- `isPrimary`: Uses gradient (true) or outline (false)
- `isLoading`: Shows loading spinner
- `icon`: Optional leading icon
- `width`: Optional custom width
- `height`: Button height (default 56)
- `padding`: Custom padding

---

### 2. GlassCard
Modern card with glassmorphism effect - great for overlays and floating elements.

```dart
import 'package:acara/core/widgets/glass_card.dart';

GlassCard(
  child: Column(
    children: [
      Text('Glassmorphic Content'),
    ],
  ),
  onTap: () => print('Tapped'),
  borderRadius: 20,
  padding: EdgeInsets.all(16),
  isDark: false,
)
```

**Properties:**
- `child`: Widget inside the card
- `onTap`: Optional tap handler
- `borderRadius`: Border radius value
- `padding`: Internal padding
- `margin`: External margin
- `isDark`: Light or dark variant
- `height`/`width`: Optional sizing

---

### 3. ShimmerLoader
Smooth loading animation for async data.

```dart
import 'package:acara/core/widgets/shimmer_loader.dart';

// For events
EventCardShimmer()

// For lists
ListShimmer(itemCount: 5, itemHeight: 100)

// For custom shapes
ShimmerLoader(
  height: 200,
  width: double.infinity,
  borderRadius: BorderRadius.circular(16),
)
```

---

### 4. AnimatedEventCard
Pre-built event card with all animations included.

```dart
import 'package:acara/core/widgets/animated_event_card.dart';

AnimatedEventCard(
  title: 'Tech Conference 2026',
  subtitle: 'Main Hall',
  date: 'May 15, 2026',
  location: 'Jakarta, Indonesia',
  imageUrl: 'https://example.com/image.jpg',
  price: 50.0,
  attendees: 245,
  isBookmarked: isBookmarked,
  onTap: () => context.push('/event/${event.id}'),
  onBookmarkTap: () => toggleBookmark(),
  delayMs: index * 100,
)
```

---

### 5. GradientBackground
Full-screen gradient with optional floating pattern.

```dart
import 'package:acara/core/widgets/gradient_background.dart';

GradientBackground(
  gradient: AppColors.primaryGradient,
  backgroundOverlay: const FloatingPattern(),
  child: Scaffold(
    body: Center(child: Text('Content over gradient')),
  ),
)
```

**Available Gradients:**
- `AppColors.primaryGradient` - Purple to Blue
- `AppColors.accentGradient` - Pink to Purple
- `AppColors.skyGradient` - Blue gradient
- `AppColors.sunsetGradient` - Red to Pink
- `AppColors.purpleBlueGradient` - Purple to Blue (alternate)
- `AppColors.pinkPurpleGradient` - Pink to Purple (alternate)

---

### 6. ModernAppBar
Gradient AppBar with animations and custom styling.

```dart
import 'package:acara/core/widgets/modern_app_bar.dart';

Scaffold(
  appBar: ModernAppBar(
    title: 'My Page',
    gradient: AppColors.primaryGradient,
    showBackButton: true,
    onBackPressed: () => context.pop(),
    actions: [
      IconButton(
        icon: Icon(Icons.settings, color: Colors.white),
        onPressed: () => print('Settings'),
      ),
    ],
  ),
  body: Container(),
)
```

---

### 7. ProfileCard
Beautiful profile display with gradient background.

```dart
import 'package:acara/core/widgets/profile_card.dart';

ProfileCard(
  name: user.name,
  email: user.email,
  avatarUrl: user.profileImageUrl,
  avatarInitial: 'J',
  onTap: () => context.push('/profile'),
  actions: [
    IconButton(
      icon: Icon(Icons.edit, color: Colors.white),
      onPressed: () => editProfile(),
    ),
  ],
)
```

---

### 8. StatCard
Display statistics with gradient background and icon.

```dart
import 'package:acara/core/widgets/profile_card.dart';

StatCard(
  label: 'Events Attended',
  value: '24',
  icon: Icons.event_note,
  gradient: AppColors.skyGradient,
  onTap: () => showEvents(),
  delayMs: 100,
)
```

---

### 9. ModernLoadingOverlay
Full-screen loading indicator with blur background.

```dart
import 'package:acara/core/widgets/modern_loading_overlay.dart';

ModernLoadingOverlay(
  isLoading: isLoading,
  loadingMessage: 'Processing your request...',
  child: Scaffold(
    body: YourContent(),
  ),
)
```

---

### 10. Animations with flutter_animate

Simple animations for any widget:

```dart
import 'package:flutter_animate/flutter_animate.dart';

Text('Hello')
  .animate()
  .fadeIn(duration: 400.ms)
  .slideY(begin: 0.2),

// With delay
Icon(Icons.check)
  .animate(delay: 200.ms)
  .scaleXY(begin: 0.8)
  .then()
  .rotate(duration: 500.ms)
```

**Common animations:**
- `.fadeIn()` / `.fadeOut()`
- `.slideX()` / `.slideY()`
- `.scale()` / `.scaleXY()`
- `.rotate()`
- `.shake()`
- `.then()` - Chain animations

---

## Color Usage Guide

### For Backgrounds
```dart
// Full screen gradients
background: AppColors.primaryGradient,

// Cards
decoration: BoxDecoration(
  gradient: AppColors.accentGradient,
)
```

### For Text
```dart
// Primary text
color: AppColors.textPrimary,

// Secondary text
color: AppColors.textSecondary,

// Hints/disabled
color: AppColors.textHint,
```

### For Status
```dart
// Success
color: AppColors.success,

// Error
color: AppColors.error,

// Warning
color: AppColors.warning,

// Info
color: AppColors.info,
```

---

## Animation Timing Guide

```dart
// Quick actions (200-300ms)
.animate()
  .fadeIn(duration: 200.ms)

// Normal transitions (400-500ms)
.animate()
  .fadeIn(duration: 400.ms)
  .slideY(begin: 0.2)

// Slower for emphasis (600-800ms)
.animate(delay: 100.ms)
  .fadeIn(duration: 600.ms)
  .scaleXY(begin: 0.8)
```

---

## Loading States Pattern

```dart
// Using shimmer while loading
eventsAsync.when(
  data: (events) => buildEventsList(events),
  loading: () => ListView(
    children: List.generate(5, (_) => EventCardShimmer()),
  ),
  error: (err, stack) => ErrorWidget(error: err),
)
```

---

## Staggered Animations Example

```dart
// Animate list items with stagger
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return YourCard(
      item: items[index],
    )
      .animate(delay: Duration(milliseconds: index * 100))
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.2);
  },
)
```

---

## Dark Mode Support

All components automatically adapt to dark mode. Test with:

```dart
// In MaterialApp, test theme
themeMode: ThemeMode.dark,
darkTheme: AppTheme.darkTheme,
```

---

## Common Patterns

### Button in Loading State
```dart
ModernButton(
  text: isLoading ? 'Processing...' : 'Submit',
  onPressed: isLoading ? null : handleSubmit,
  isLoading: isLoading,
)
```

### Card with Action
```dart
GestureDetector(
  onTap: handleTap,
  child: GlassCard(
    child: Row(
      children: [Icon(...), Text(...)],
    ),
  ),
)
```

### Fade Transition Between States
```dart
AnimatedSwitcher(
  duration: 300.ms,
  child: isLoading
    ? ShimmerLoader()
    : ContentWidget(),
)
```

---

## Performance Tips

1. **Use `const` for static widgets**
   ```dart
   const SizedBox(height: 16),
   ```

2. **Lazy load animations**
   - Don't animate everything
   - Focus on user-critical interactions

3. **Use `SingleChildScrollView`** for overflow
   ```dart
   SingleChildScrollView(
     child: Column(...),
   )
   ```

4. **Cache images**
   ```dart
   CachedNetworkImage(imageUrl: '...')
   ```

---

## Troubleshooting

### Animations not smooth?
- Check animation duration (should be 300-600ms)
- Reduce number of simultaneous animations
- Use `Profile` tool to check performance

### Gradient not visible?
- Ensure parent has fixed height
- Check gradient colors contrast
- Add shadow for depth

### Text not readable over gradient?
- Use `Colors.white` with `withOpacity(0.9)`
- Or use text shadow: `shadows: [Shadow(...)]`

---

**For more examples, check:** `UI_MODERNIZATION_GUIDE.md`

