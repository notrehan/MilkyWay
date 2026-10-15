
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_screen.dart';
import 'data/profile_repository.dart';
import 'data/alien_repository.dart';
import 'data/planet_repository.dart';
import 'models/alien_profile.dart';
import 'models/human_profile.dart';
import 'models/planet.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  final supabaseKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY']?.trim() ?? '';
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty ||
      supabaseUrl.contains('YOUR_PROJECT_REF') ||
      supabaseKey.contains('YOUR_SUPABASE_')) {
    throw StateError(
      'Configure SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY in the .env file.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(const AfterNetApp());
}

// ─── THEME ───────────────────────────────────────────────────────

const bg = Color(0xFFFAFAF8);
const ink = Color(0xFF252622);
const muted = Color(0xFF777873);
const accent = Color(0xFF8B80B5);
const border = Color(0xFFE8E8E3);
const panel = Colors.white;

class AfterNetApp extends StatelessWidget {
  const AfterNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MilkyWay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          surface: panel,
          onSurface: ink,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: panel,
          indicatorColor: accent.withValues(alpha: 0.14),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              color: selected ? ink : muted,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) return const MainShell();
        return const AuthScreen();
      },
    );
  }
}

// ─── PLANET MODEL & SAMPLE DATA ───────────────────────────────────

// ─── MAIN NAVIGATION ─────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  HumanProfile? humanProfile;
  bool _loadingProfile = true;
  late final ProfileRepository _profiles;

  @override
  void initState() {
    super.initState();
    _profiles = ProfileRepository(Supabase.instance.client);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profiles.loadMyProfile();
      if (mounted) setState(() => humanProfile = profile);
    } catch (error) {
      debugPrint('Could not load profile: $error');
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _saveProfile(HumanProfile profile, XFile? newPhoto) async {
    final saved = await _profiles.saveMyProfile(profile, newPhoto: newPhoto);
    if (!mounted) return;
    setState(() {
      humanProfile = saved;
      index = 2;
    });
  }

  void openProfile() {
    setState(() => index = 3);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          HomeScreen(
            onNavigate: (i) => setState(() => index = i),
          ),
          const PlanetScreen(),
          AlienScreen(
            profile: humanProfile,
            onCreateProfile: openProfile,
          ),
          ProfileScreen(
            key: ValueKey(humanProfile?.name ?? 'new-profile'),
            initialProfile: humanProfile,
            onComplete: _saveProfile,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Planets',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Aliens',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── HOME ────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        children: [
          SizedBox(
            height: 76,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MILKYWAY',
                      style: TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.5,
                        fontSize: 21,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'INTERGALACTIC DATING',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    tooltip: 'Log out',
                    onPressed: () async {
                      try {
                        await Supabase.instance.client.auth.signOut();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not log out. Try again.'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Somewhere out there,\nsomeone gets you.',
            style: TextStyle(
              color: ink,
              fontSize: 29,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your next connection is written in the stars.',
            style: TextStyle(color: muted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 26),
          FeatureCard(
            title: 'Find your new home',
            subtitle: 'Planets worth relocating for.',
            action: 'EXPLORE PLANETS',
            icon: Icons.public,
            colors: const [Color(0xFFE6EBE4), Color(0xFFD7E0D6)],
            onTap: () => onNavigate(1),
          ),
          const SizedBox(height: 16),
          FeatureCard(
            title: 'Meet your cosmic match',
            subtitle: 'Love has no planetary boundaries.',
            action: 'MEET ALIENS',
            icon: Icons.favorite_outline,
            colors: const [Color(0xFFEAE8F0), Color(0xFFDFDCE9)],
            onTap: () => onNavigate(2),
          ),
          const SizedBox(height: 16),
          FeatureCard(
            title: 'Build your profile',
            subtitle: 'Tell the galaxy what keeps you alive.',
            action: 'MY PROFILE',
            icon: Icons.person_outline,
            colors: const [Color(0xFFF0E8DB), Color(0xFFE7DDCD)],
            onTap: () => onNavigate(3),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 174,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -12,
                top: -18,
                child: Icon(
                  icon,
                  size: 155,
                  color: ink.withValues(alpha: 0.06),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: ink, size: 27),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: ink.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$action  ↗',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SHARED EXPLORE / MATCHES TABS ───────────────────────────────

class SectionTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SectionTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Explore',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _Tab(
            label: 'Matches',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? ink : muted,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PLANETS SCREEN WITH SWIPE ANIMATION ─────────────────────────

class PlanetScreen extends StatefulWidget {
  const PlanetScreen({super.key});

  @override
  State<PlanetScreen> createState() => _PlanetScreenState();
}

class _PlanetScreenState extends State<PlanetScreen>
    with SingleTickerProviderStateMixin {
  int tab = 0;
  int currentIndex = 0;
  bool _loading = true;
  String? _error;
  List<Planet> _planets = [];
  late final PlanetRepository _repository;

  Offset dragOffset = Offset.zero;
  bool isAnimatingOut = false;
  bool isReturning = false;

  late final AnimationController _controller;
  Animation<Offset>? _animation;

  final Set<String> liked = {};
  final Set<String> passed = {};

  List<Planet> get matches =>
      _planets.where((p) => liked.contains(p.id)).toList();

  @override
  void initState() {
    super.initState();
    _repository = PlanetRepository(Supabase.instance.client);
    _loadPlanets();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_animation != null) {
          setState(() => dragOffset = _animation!.value);
        }
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isAnimatingOut) {
          _finishSwipe();
        } else if (isReturning) {
          setState(() {
            dragOffset = Offset.zero;
            isReturning = false;
          });
        }
      }
    });
  }

  Future<void> _loadPlanets() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loaded = await _repository.loadPlanets();
      if (!mounted) return;
      setState(() {
        _planets = loaded;
        currentIndex = 0;
        dragOffset = Offset.zero;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Could not load planets: $error');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load planets. Check your connection and Supabase policies.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(Offset destination, {required bool dismiss}) {
    if (isAnimatingOut || currentIndex >= _planets.length) return;

    _controller.stop();
    _controller.reset();

    isAnimatingOut = dismiss;
    isReturning = !dismiss;

    _animation = Tween<Offset>(
      begin: dragOffset,
      end: destination,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  void _finishSwipe() {
    if (!mounted || currentIndex >= _planets.length) return;

    final planet = _planets[currentIndex];
    final wasLiked = dragOffset.dx > 0;

    setState(() {
      if (wasLiked) {
        liked.add(planet.id);
      } else {
        passed.add(planet.id);
      }

      currentIndex++;
      dragOffset = Offset.zero;
      isAnimatingOut = false;
      isReturning = false;
      _animation = null;
    });

    if (wasLiked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${planet.name} added to your likes!'),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _swipe(bool like) {
    if (isAnimatingOut || isReturning ||
        currentIndex >= _planets.length) {
      return;
    }

    final width = MediaQuery.sizeOf(context).width;

    _animateTo(
      Offset(like ? width * 1.4 : -width * 1.4, 40),
      dismiss: true,
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (isAnimatingOut || isReturning) return;
    setState(() => dragOffset += details.delta);
  }

  void _onDragEnd(DragEndDetails details) {
    if (isAnimatingOut || isReturning) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final width = MediaQuery.sizeOf(context).width;

    if (dragOffset.dx > width * 0.25 || velocity > 850) {
      _animateTo(
        Offset(width * 1.4, dragOffset.dy + 50),
        dismiss: true,
      );
    } else if (dragOffset.dx < -width * 0.25 || velocity < -850) {
      _animateTo(
        Offset(-width * 1.4, dragOffset.dy + 50),
        dismiss: true,
      );
    } else {
      _animateTo(Offset.zero, dismiss: false);
    }
  }

  void reset() {
    setState(() {
      currentIndex = 0;
      dragOffset = Offset.zero;
      liked.clear();
      passed.clear();
      isAnimatingOut = false;
      isReturning = false;
      _animation = null;
    });

    _controller.stop();
    _controller.reset();
  }

  void details(Planet p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                p.name,
                style: const TextStyle(
                  color: ink,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                p.description,
                style: const TextStyle(color: muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              const Text(
                'THE GOOD',
                style: TextStyle(
                  color: Color(0xFF548A70),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ...p.pros.map((s) => DetailRow(
                    icon: Icons.check_circle_outline,
                    text: s,
                  )),
              const SizedBox(height: 18),
              const Text(
                'THE RED FLAGS',
                style: TextStyle(
                  color: Color(0xFFB55E55),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              ...p.cons.map((s) => DetailRow(
                    icon: Icons.flag_outlined,
                    text: s,
                  )),
              const SizedBox(height: 22),
              Text(
                'Atmosphere: ${p.atmosphere}\n'
                'Climate: ${p.climate}\n'
                'Gravity: ${p.gravity}g\n'
                'Demo habitability: ${p.habitability.toInt()}%',
                style: const TextStyle(color: ink, height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = currentIndex < _planets.length
        ? _planets[currentIndex]
        : null;

    final next = currentIndex + 1 < _planets.length
        ? _planets[currentIndex + 1]
        : null;

    final rotation = (dragOffset.dx /
            (MediaQuery.sizeOf(context).width * 1.5))
        .clamp(-0.18, 0.18);

    final opacity =
        (dragOffset.dx.abs() / 100).clamp(0.0, 1.0);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 44, color: muted),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: muted)),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadPlanets, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Your Planet',
                  style: TextStyle(
                    color: ink,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                SectionTabs(
                  selectedIndex: tab,
                  onChanged: (v) => setState(() => tab = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: tab == 1
                ? MatchesView(planets: matches, onTap: details)
                : current == null
                    ? FinishedView(onReset: reset)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20, 20, 20, 12,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  if (next != null)
                                    Positioned.fill(
                                      child: Transform.scale(
                                        scale: 0.95,
                                        child: PlanetCard(
                                          key: ValueKey('next-${next.id}'),
                                          planet: next,
                                        ),
                                      ),
                                    ),
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onPanUpdate: _onDragUpdate,
                                      onPanEnd: _onDragEnd,
                                      child: Transform.translate(
                                        offset: dragOffset,
                                        child: Transform.rotate(
                                          angle: rotation,
                                          child: PlanetCard(
                                            key: ValueKey(current.id),
                                            planet: current,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 28,
                                    left: 22,
                                    child: IgnorePointer(
                                      child: Opacity(
                                        opacity: dragOffset.dx > 0
                                            ? opacity
                                            : 0,
                                        child: Transform.rotate(
                                          angle: -0.15,
                                          child: const _SwipeStamp(
                                            label: 'LIKE',
                                            color: Color(0xFF548A70),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 28,
                                    right: 22,
                                    child: IgnorePointer(
                                      child: Opacity(
                                        opacity: dragOffset.dx < 0
                                            ? opacity
                                            : 0,
                                        child: Transform.rotate(
                                          angle: 0.15,
                                          child: const _SwipeStamp(
                                            label: 'NOPE',
                                            color: Color(0xFFC45F65),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ActionButton(
                                  icon: Icons.close,
                                  color: const Color(0xFFC45F65),
                                  onTap: () => _swipe(false),
                                ),
                                ActionButton(
                                  icon: Icons.info_outline,
                                  color: ink,
                                  onTap: () => details(current),
                                ),
                                ActionButton(
                                  icon: Icons.favorite,
                                  color: const Color(0xFF548A70),
                                  onTap: () => _swipe(true),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  final String label;
  final Color color;

  const _SwipeStamp({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 23,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class PlanetCard extends StatelessWidget {
  final Planet planet;

  const PlanetCard({super.key, required this.planet});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (planet.image.isNotEmpty)
                    Image.network(
                      planet.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFF252525),
                        child: Center(
                          child: Icon(
                            Icons.public,
                            size: 120,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    )
                  else
                    const ColoredBox(
                      color: Color(0xFF252525),
                      child: Center(
                        child: Icon(
                          Icons.public,
                          size: 120,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: ImageBadge(
                      icon: Icons.public,
                      text: planet.classification.split('·').first.trim(),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ImageBadge(
                      icon: Icons.star,
                      text: '${planet.habitability.toInt()}% match',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: Text(
                      planet.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      TraitChip(
                        icon: Icons.thermostat_outlined,
                        label: planet.climate,
                      ),
                      TraitChip(
                        icon: Icons.air,
                        label: planet.atmosphere,
                      ),
                      TraitChip(
                        icon: Icons.public,
                        label: '${planet.gravity}g',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const ImageBadge({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TraitChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const TraitChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          child: Icon(icon, size: 25, color: color),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const DetailRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: ink, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class MatchesView extends StatelessWidget {
  final List<Planet> planets;
  final ValueChanged<Planet> onTap;

  const MatchesView({
    super.key,
    required this.planets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (planets.isEmpty) {
      return const EmptyState(
        icon: Icons.public,
        title: 'No planets liked yet',
        subtitle:
            'Explore the galaxy and find a world that feels like home.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: planets.length,
      itemBuilder: (context, i) {
        final p = planets[i];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                p.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.public, size: 48),
              ),
            ),
            title: Text(
              p.name,
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${p.habitability.toInt()}% demo habitability',
              style: const TextStyle(color: muted),
            ),
            trailing: const Icon(Icons.chevron_right, color: muted),
            onTap: () => onTap(p),
          ),
        );
      },
    );
  }
}

class FinishedView extends StatelessWidget {
  final VoidCallback onReset;

  const FinishedView({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore, size: 56, color: accent),
            const SizedBox(height: 16),
            const Text(
              'You explored the galaxy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ink,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Try again to revisit the planets.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onReset,
              child: const Text('Explore again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ALIENS SCREEN: SUPABASE DISCOVERY + SWIPING ──────────────────

class AlienScreen extends StatefulWidget {
  final HumanProfile? profile;
  final VoidCallback onCreateProfile;

  const AlienScreen({
    super.key,
    required this.profile,
    required this.onCreateProfile,
  });

  @override
  State<AlienScreen> createState() => _AlienScreenState();
}

class _AlienScreenState extends State<AlienScreen> {
  int tab = 0;
  bool _loading = true;
  String? _error;
  List<AlienProfile> _aliens = [];
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  final Set<String> _likedIds = {};
  final Set<String> _passedIds = {};
  late final AlienRepository _repository;

  List<AlienProfile> get _likedAliens =>
      _aliens.where((alien) => _likedIds.contains(alien.id)).toList();

  @override
  void initState() {
    super.initState();
    _repository = AlienRepository(Supabase.instance.client);
    _loadAliens();
  }

  @override
  void didUpdateWidget(covariant AlienScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile == null && widget.profile != null) {
      _loadAliens();
    }
  }

  Future<void> _loadAliens() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final aliens = await _repository.loadAliens();
      if (!mounted) return;
      setState(() {
        _aliens = aliens;
        _currentIndex = 0;
        _dragOffset = Offset.zero;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load alien profiles. Check your connection and Supabase policies.';
        _loading = false;
      });
      debugPrint('Could not load alien profiles: $error');
    }
  }

  void _swipe(bool like) {
    if (_currentIndex >= _aliens.length) return;
    final alien = _aliens[_currentIndex];
    setState(() {
      if (like) {
        _likedIds.add(alien.id);
        _passedIds.remove(alien.id);
      } else {
        _passedIds.add(alien.id);
        _likedIds.remove(alien.id);
      }
      _currentIndex++;
      _dragOffset = Offset.zero;
    });
    if (like && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You liked ${alien.name}!'),
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _dragOffset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (_dragOffset.dx > width * 0.22 || velocity > 800) {
      _swipe(true);
    } else if (_dragOffset.dx < -width * 0.22 || velocity < -800) {
      _swipe(false);
    } else {
      setState(() => _dragOffset = Offset.zero);
    }
  }

  void _resetDiscovery() {
    setState(() {
      _currentIndex = 0;
      _dragOffset = Offset.zero;
      _likedIds.clear();
      _passedIds.clear();
      tab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = widget.profile != null;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Your Alien',
                  style: TextStyle(
                    color: ink,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasProfile
                      ? 'Welcome back, ${widget.profile!.name}.'
                      : 'Meet someone from another world.',
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SectionTabs(
                  selectedIndex: tab,
                  onChanged: (v) => setState(() => tab = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: !hasProfile
                ? _buildProfilePrompt()
                : _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildError()
                        : tab == 1
                            ? _buildLikedList()
                            : _buildDiscovery(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePrompt() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEAE6F0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.face_6_outlined, color: accent, size: 52),
            ),
            const SizedBox(height: 24),
            const Text(
              'First, introduce yourself.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create your human profile and tell us what you need to survive on another planet before meeting the local dating population.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: widget.onCreateProfile,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Create my profile'),
                style: FilledButton.styleFrom(
                  backgroundColor: ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: accent, size: 54),
            const SizedBox(height: 14),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: muted, height: 1.5)),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: _loadAliens, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscovery() {
    if (_aliens.isEmpty) {
      return _alienEmptyState(
        title: 'No alien profiles yet',
        subtitle: 'Add a couple of alien profiles in Supabase to start testing discovery.',
        buttonLabel: 'Refresh profiles',
        onPressed: _loadAliens,
      );
    }
    if (_currentIndex >= _aliens.length) {
      return _alienEmptyState(
        title: 'You explored the galaxy.',
        subtitle: 'You have seen every alien profile available right now.',
        buttonLabel: 'Explore again',
        onPressed: _resetDiscovery,
      );
    }

    final alien = _aliens[_currentIndex];
    final next = _currentIndex + 1 < _aliens.length ? _aliens[_currentIndex + 1] : null;
    final rotation = (_dragOffset.dx / (MediaQuery.sizeOf(context).width * 1.5)).clamp(-0.18, 0.18);
    final stampOpacity = (_dragOffset.dx.abs() / 90).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (next != null)
                  Positioned.fill(
                    child: Transform.scale(
                      scale: 0.95,
                      child: _AlienCard(alien: next),
                    ),
                  ),
                Positioned.fill(
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: Transform.rotate(
                        angle: rotation,
                        child: _AlienCard(alien: alien),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 20,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _dragOffset.dx > 0 ? stampOpacity : 0,
                      child: const _SwipeStamp(label: 'LIKE', color: Color(0xFF548A70)),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  right: 20,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _dragOffset.dx < 0 ? stampOpacity : 0,
                      child: const _SwipeStamp(label: 'NOPE', color: Color(0xFFC45F65)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(icon: Icons.close, color: const Color(0xFFC45F65), onTap: () => _swipe(false)),
              ActionButton(icon: Icons.refresh, color: ink, onTap: _resetDiscovery),
              ActionButton(icon: Icons.favorite, color: const Color(0xFF548A70), onTap: () => _swipe(true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLikedList() {
    final liked = _likedAliens;
    if (liked.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        title: 'No aliens liked yet',
        subtitle: 'Swipe right on an alien to add them to this list.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: liked.length,
      itemBuilder: (context, index) {
        final alien = liked[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: border)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: _AlienAvatar(alien: alien, width: 64, height: 64),
            title: Text(alien.age == null ? alien.name : '${alien.name}, ${alien.age}', style: const TextStyle(color: ink, fontWeight: FontWeight.bold)),
            subtitle: Text([alien.species, alien.homePlanet].whereType<String>().where((s) => s.isNotEmpty).join(' · '), style: const TextStyle(color: muted)),
            trailing: const Icon(Icons.favorite, color: Color(0xFF548A70)),
          ),
        );
      },
    );
  }

  Widget _alienEmptyState({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore, color: accent, size: 56),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: muted, height: 1.5)),
            const SizedBox(height: 20),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}

class _AlienCard extends StatelessWidget {
  final AlienProfile alien;
  const _AlienCard({required this.alien});

  @override
  Widget build(BuildContext context) {
    final details = [alien.species, alien.homePlanet].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF17151E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _AlienAvatar(alien: alien, width: double.infinity, height: double.infinity, cover: true),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: ImageBadge(icon: Icons.auto_awesome, text: alien.species?.isNotEmpty == true ? alien.species! : 'ALIEN'),
                  ),
                  if (alien.homePlanet?.isNotEmpty == true)
                    Positioned(top: 16, right: 16, child: ImageBadge(icon: Icons.public, text: alien.homePlanet!)),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 90,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x99000000)]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alien.age == null ? alien.name : '${alien.name}, ${alien.age}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w700, letterSpacing: -0.7)),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(details.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFD5CFE7), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 9),
                  Expanded(child: Text(alien.bio.isEmpty ? 'This cosmic profile is still a mystery.' : alien.bio, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45))),
                  const SizedBox(height: 8),
                  const Row(children: [Icon(Icons.swipe, color: Colors.white60, size: 16), SizedBox(width: 6), Text('Swipe to decide their fate', style: TextStyle(color: Colors.white60, fontSize: 11))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlienAvatar extends StatelessWidget {
  final AlienProfile alien;
  final double width;
  final double height;
  final bool cover;
  const _AlienAvatar({required this.alien, required this.width, required this.height, this.cover = false});

  @override
  Widget build(BuildContext context) {
    final url = alien.photoUrl;
    if (url != null && url.trim().isNotEmpty) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: cover ? BoxFit.cover : BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF55476F), Color(0xFF24202F), Color(0xFF7E6B94)]),
        ),
        child: Center(
          child: Icon(Icons.face_6_outlined, size: cover ? 110 : 36, color: Colors.white70),
        ),
      );
}

// ─── EMPTY STATE ─────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: accent),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ink,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
