import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const GarbageApp());

class WasteReport {
  WasteReport({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.severity,
    required this.createdAt,
    this.status = 'Submitted',
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final String severity;
  final DateTime createdAt;
  final String status;
}

class GarbageApp extends StatefulWidget {
  const GarbageApp({super.key});

  @override
  State<GarbageApp> createState() => _GarbageAppState();
}

class _GarbageAppState extends State<GarbageApp> {
  ThemeMode themeMode = ThemeMode.light;
  final List<WasteReport> reports = [];
  final navigatorKey = GlobalKey<NavigatorState>();

  static const seed = Color(0xFF17834B);

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: dark ? const Color(0xFF13241C) : const Color(0xFFFFFFFF),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF0D1712)
          : const Color(0xFFF4F7F3),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF17271F) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: dark ? const Color(0xFF294137) : const Color(0xFFE2E9E4),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF17271F) : const Color(0xFFF9FBF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF355044) : const Color(0xFFDDE6DE),
          ),
        ),
      ),
      textTheme: const TextTheme(),
    );
  }

  void addReport(WasteReport report) =>
      setState(() => reports.insert(0, report));

  void openRoleSelection() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => RoleSelectionScreen(
          reports: reports,
          onAddReport: addReport,
          isDark: themeMode == ThemeMode.dark,
          onThemeChanged: (dark) => setState(
            () => themeMode = dark ? ThemeMode.dark : ThemeMode.light,
          ),
          onSignOut: () => navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => AuthScreen(onContinue: openRoleSelection),
            ),
            (_) => false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart City Garbage Management',
      navigatorKey: navigatorKey,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: themeMode,
      home: AuthScreen(onContinue: openRoleSelection),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool signup = false;
  bool obscure = true;
  bool remember = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;
    return Scaffold(
      body: Row(
        children: [
          if (wide)
            Expanded(
              child: Container(
                color: const Color(0xFF123D29),
                padding: const EdgeInsets.all(64),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.recycling_rounded,
                      color: Colors.white,
                      size: 72,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'SMART CITY',
                      style: TextStyle(color: Colors.white70, letterSpacing: 4),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Build a cleaner,\nsmarter city together.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Report waste, track progress, and earn demo rewards.',
                      style: TextStyle(color: Color(0xFFC9DDD3), fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!wide) ...[
                          const Icon(
                            Icons.recycling_rounded,
                            size: 56,
                            color: Color(0xFF17834B),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          signup ? 'Create your account' : 'Welcome back',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          signup
                              ? 'Join the cleaner-city demo.'
                              : 'Sign in to continue.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (signup) ...[
                          TextFormField(
                            controller: name,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v!.trim().isEmpty
                                ? 'Please enter your name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Please enter your email';
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(v))
                              return 'Enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: password,
                          obscureText: obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => obscure = !obscure),
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please enter your password';
                            if (signup && v.length < 8)
                              return 'Use at least 8 characters';
                            return null;
                          },
                        ),
                        if (!signup)
                          CheckboxListTile(
                            value: remember,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Remember me'),
                            onChanged: (v) =>
                                setState(() => remember = v ?? false),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              widget.onContinue();
                            },
                            child: Text(signup ? 'CREATE ACCOUNT' : 'SIGN IN'),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            signup = !signup;
                            formKey.currentState?.reset();
                          }),
                          child: Center(
                            child: Text(
                              signup
                                  ? 'Already have an account? Sign in'
                                  : 'New here? Create an account',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: widget.onContinue,
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text('EXPLORE DEMO DASHBOARD'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({
    super.key,
    required this.reports,
    required this.onAddReport,
    required this.isDark,
    required this.onThemeChanged,
    required this.onSignOut,
  });
  final List<WasteReport> reports;
  final ValueChanged<WasteReport> onAddReport;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_city_rounded,
                  size: 68,
                  color: Color(0xFF17834B),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to Smart City',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the role for this demo session.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _roleCard(
                      context,
                      'Citizen',
                      'Report waste, find bins and earn rewards',
                      Icons.person_outline_rounded,
                      false,
                    ),
                    _roleCard(
                      context,
                      'Driver',
                      'Manage collection tasks and routes',
                      Icons.local_shipping_outlined,
                      true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool driver,
  ) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 48)
        .clamp(0, 300)
        .toDouble();
    return SizedBox(
      width: cardWidth,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => driver
                  ? DriverShell(
                      onSignOut: onSignOut,
                      isDark: isDark,
                      onThemeChanged: onThemeChanged,
                    )
                  : CitizenShell(
                      reports: reports,
                      onAddReport: onAddReport,
                      isDark: isDark,
                      onThemeChanged: onThemeChanged,
                      onSignOut: onSignOut,
                    ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE2F3E9),
                  child: Icon(icon, color: const Color(0xFF17834B)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(subtitle, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CitizenShell extends StatefulWidget {
  const CitizenShell({
    super.key,
    required this.reports,
    required this.onAddReport,
    required this.isDark,
    required this.onThemeChanged,
    required this.onSignOut,
  });
  final List<WasteReport> reports;
  final ValueChanged<WasteReport> onAddReport;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onSignOut;

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int index = 0;
  final titles = const [
    'Home',
    'Nearby Bins',
    'Report Waste',
    'Upload Waste',
    'Rewards',
    'Knowledge',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      CitizenDashboard(
        reports: widget.reports,
        onNavigate: (i) => setState(() => index = i),
      ),
      const BinsScreen(),
      ReportScreen(
        reports: widget.reports,
        onSubmit: widget.onAddReport,
        onSubmitted: () => setState(() {}),
      ),
      const UploadScreen(),
      const RewardsScreen(),
      const KnowledgeScreen(),
      ProfileScreen(
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
        onSignOut: widget.onSignOut,
      ),
    ];
    return Scaffold(
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1180,
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: const Padding(
                padding: EdgeInsets.only(top: 18, bottom: 14),
                child: Icon(
                  Icons.recycling_rounded,
                  color: Color(0xFF17834B),
                  size: 34,
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.location_on_outlined),
                  selectedIcon: Icon(Icons.location_on),
                  label: Text('Bins'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.report_outlined),
                  selectedIcon: Icon(Icons.report),
                  label: Text('Report'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.camera_alt_outlined),
                  selectedIcon: Icon(Icons.camera_alt),
                  label: Text('Upload'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: Text('Rewards'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: Text('Knowledge'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(titles[index]),
                  actions: [
                    IconButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Demo notifications: 2 new updates',
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.notifications_none),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                Expanded(child: pages[index]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index > 5 ? 6 : index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.location_on_outlined),
                  label: 'Bins',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Report',
                ),
                NavigationDestination(
                  icon: Icon(Icons.camera_alt_outlined),
                  label: 'Upload',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  label: 'Rewards',
                ),
              ],
            ),
    );
  }
}

class CitizenDashboard extends StatelessWidget {
  const CitizenDashboard({
    super.key,
    required this.reports,
    required this.onNavigate,
  });
  final List<WasteReport> reports;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Good morning, Alex',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F4EA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '240 eco coins',
                style: TextStyle(
                  color: Color(0xFF17834B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '“A cleaner city begins with the choices we make today.”',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _statCard(
              context,
              'Reports',
              '${3 + reports.length}',
              Icons.assignment_outlined,
              const Color(0xFF17834B),
            ),
            _statCard(
              context,
              'Resolved',
              '2',
              Icons.check_circle_outline,
              const Color(0xFF2D7DB6),
            ),
            _statCard(
              context,
              'Pending',
              '${1 + reports.length}',
              Icons.schedule,
              const Color(0xFFD68A2C),
            ),
            _statCard(
              context,
              'Eco coins',
              '240',
              Icons.monetization_on_outlined,
              const Color(0xFF8068B1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: wide ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: wide ? 2.0 : 1.25,
          children: [
            _quickAction(
              context,
              'Report waste',
              Icons.report_gmailerrorred_outlined,
              () => onNavigate(2),
            ),
            _quickAction(
              context,
              'Upload photo',
              Icons.add_a_photo_outlined,
              () => onNavigate(3),
            ),
            _quickAction(
              context,
              'Find bins',
              Icons.location_on_outlined,
              () => onNavigate(1),
            ),
            _quickAction(
              context,
              'View rewards',
              Icons.card_giftcard_outlined,
              () => onNavigate(4),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: wide ? 620 : double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly contribution',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 150,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [4, 7, 5, 9, 6, 11, 8].asMap().entries.map((
                            e,
                          ) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      height: e.value * 10.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF17834B),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      [
                                        'M',
                                        'T',
                                        'W',
                                        'T',
                                        'F',
                                        'S',
                                        'S',
                                      ][e.key],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: wide ? 300 : double.infinity,
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent activity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        title: Text('Report resolved'),
                        subtitle: Text('Central Market • demo'),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.monetization_on_outlined,
                          color: Colors.amber,
                        ),
                        title: Text('8 coins earned'),
                        subtitle: Text('Daily contribution'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Environmental impact',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  'Illustrative demo estimates',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  children: [
                    _Impact('12 kg', 'Waste diverted'),
                    _Impact('28 kg', 'CO₂ estimated avoided'),
                    _Impact('6 hours', 'Cleaner streets'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width < 700 ? 165 : 210,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _quickAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF17834B)),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Impact extends StatelessWidget {
  const _Impact(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 130,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.reports,
    required this.onSubmit,
    required this.onSubmitted,
  });
  final List<WasteReport> reports;
  final ValueChanged<WasteReport> onSubmit;
  final VoidCallback onSubmitted;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  final key = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  String category = 'Mixed waste';
  String severity = 'Medium';
  bool showHistory = false;
  Uint8List? imageBytes;
  bool submitting = false;

  Future<void> pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => imageBytes = bytes);
    } on PlatformException catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to access the selected image source.'),
          ),
        );
    }
  }

  Future<void> submit() async {
    if (!key.currentState!.validate()) return;
    setState(() => submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final report = WasteReport(
      id: 'WST-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      title: titleController.text.trim(),
      category: category,
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      severity: severity,
      createdAt: DateTime.now(),
    );
    widget.onSubmit(report);
    if (!mounted) return;
    setState(() {
      submitting = false;
      showHistory = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Demo report ${report.id} saved locally')),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('New report')),
              ButtonSegment(value: true, label: Text('Complaint history')),
            ],
            selected: {showHistory},
            onSelectionChanged: (v) => setState(() => showHistory = v.first),
          ),
        ),
        Expanded(
          child: showHistory
              ? ComplaintHistoryScreen(reports: widget.reports)
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Report details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Report title',
                                  hintText: 'e.g. Overflowing bin near library',
                                ),
                                validator: (v) => v!.trim().isEmpty
                                    ? 'Enter a report title'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                initialValue: category,
                                decoration: const InputDecoration(
                                  labelText: 'Waste category',
                                ),
                                items:
                                    const [
                                          'Mixed waste',
                                          'Wet / biodegradable',
                                          'Dry / recyclable',
                                          'Plastic',
                                          'Paper and cardboard',
                                          'Glass',
                                          'Metal',
                                          'E-waste',
                                          'Hazardous / sanitary',
                                        ]
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) => setState(() => category = v!),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: descriptionController,
                                minLines: 4,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  alignLabelWithHint: true,
                                ),
                                validator: (v) => v!.trim().isEmpty
                                    ? 'Describe the waste issue'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: locationController,
                                decoration: const InputDecoration(
                                  labelText: 'Location or address',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                                validator: (v) => v!.trim().isEmpty
                                    ? 'Enter a location'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                initialValue: severity,
                                decoration: const InputDecoration(
                                  labelText: 'Urgency',
                                ),
                                items: const ['Low', 'Medium', 'High']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => severity = v!),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: pickImage,
                                      icon: const Icon(
                                        Icons.photo_library_outlined,
                                      ),
                                      label: Text(
                                        imageBytes == null
                                            ? 'Attach photo'
                                            : 'Replace photo',
                                      ),
                                    ),
                                  ),
                                  if (imageBytes != null)
                                    IconButton(
                                      onPressed: () =>
                                          setState(() => imageBytes = null),
                                      tooltip: 'Remove photo',
                                      icon: const Icon(Icons.close),
                                    ),
                                ],
                              ),
                              if (imageBytes != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    imageBytes!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  FilledButton.icon(
                                    onPressed: submitting ? null : submit,
                                    icon: submitting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.send_outlined),
                                    label: Text(
                                      submitting
                                          ? 'Saving...'
                                          : 'Submit report',
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: submitting
                                        ? null
                                        : () {
                                            key.currentState?.reset();
                                            titleController.clear();
                                            descriptionController.clear();
                                            locationController.clear();
                                            setState(() {
                                              category = 'Mixed waste';
                                              severity = 'Medium';
                                              imageBytes = null;
                                            });
                                          },
                                    child: const Text('Reset'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class ComplaintHistoryScreen extends StatefulWidget {
  const ComplaintHistoryScreen({super.key, this.reports = const []});
  final List<WasteReport> reports;
  @override
  State<ComplaintHistoryScreen> createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> {
  final query = TextEditingController();
  String status = 'All';
  String sort = 'Newest';
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ...widget.reports,
      WasteReport(
        id: 'WST-1048',
        title: 'Overflowing bin',
        category: 'Mixed waste',
        description: 'Bin near the market entrance is overflowing.',
        location: 'Central Market, Gate 2',
        severity: 'High',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'In Progress',
      ),
      WasteReport(
        id: 'WST-1032',
        title: 'Plastic bags on pavement',
        category: 'Plastic',
        description: 'Several plastic bags are beside the walkway.',
        location: 'Lake Road',
        severity: 'Medium',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Resolved',
      ),
      WasteReport(
        id: 'WST-1019',
        title: 'Damaged collection point',
        category: 'Dry / recyclable',
        description: 'The collection point lid is broken.',
        location: 'Green Park',
        severity: 'Low',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        status: 'Under Review',
      ),
    ];
    final filtered = items
        .where(
          (r) =>
              (status == 'All' || r.status == status) &&
              ('${r.id} ${r.title}'.toLowerCase().contains(
                query.text.toLowerCase(),
              )),
        )
        .toList();
    if (sort == 'Newest')
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: query,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search report ID or title',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items:
                    const [
                          'All',
                          'Submitted',
                          'Under Review',
                          'Assigned',
                          'In Progress',
                          'Resolved',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) => setState(() => status = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: sort,
                decoration: const InputDecoration(labelText: 'Sort'),
                items: const ['Newest', 'Oldest']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => sort = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 52),
                  SizedBox(height: 8),
                  Text('No reports match your filters'),
                ],
              ),
            ),
          )
        else
          ...filtered.map(
            (r) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  r.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${r.id} • ${r.category}\n${r.location}'),
                isThreeLine: true,
                trailing: _statusChip(r.status),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(r.title),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.description),
                          const SizedBox(height: 12),
                          Text('Location: ${r.location}'),
                          Text('Category: ${r.category}'),
                          const SizedBox(height: 16),
                          const Text(
                            'Demo progress',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(value: .65),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final map = {
      'Submitted': Colors.blue,
      'Under Review': Colors.amber,
      'Assigned': Colors.deepPurple,
      'In Progress': Colors.orange,
      'Resolved': Colors.green,
    };
    final color = map[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? bytes;
  String category = 'Dry / recyclable';
  bool scanning = false;
  bool result = false;

  Future<void> pick(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );
      if (file == null) return;
      final selectedBytes = await file.readAsBytes();
      if (mounted)
        setState(() {
          bytes = selectedBytes;
          result = false;
        });
    } on PlatformException catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera or gallery access is unavailable.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guidance = {
      'Wet / biodegradable': (
        'Compost bin',
        'Drain excess liquid and use a compost or food-waste bin.',
      ),
      'Dry / recyclable': (
        'Clean recycling',
        'Empty and rinse packaging before placing it in recycling.',
      ),
      'Plastic': (
        'Plastic recycling',
        'Clean containers, remove food residue, and keep lids separate if required locally.',
      ),
      'Paper and cardboard': (
        'Paper recycling',
        'Keep dry, flatten cardboard, and remove plastic wrapping.',
      ),
      'Glass': (
        'Glass collection',
        'Rinse the container and place it in the designated glass stream.',
      ),
      'Metal': (
        'Metal recycling',
        'Clean cans and keep sharp items securely wrapped.',
      ),
      'E-waste': (
        'Authorized e-waste point',
        'Do not mix with household waste. Use an approved collection point.',
      ),
      'Hazardous / sanitary': (
        'Special collection',
        'Keep separate and use a hazardous-waste or designated sanitary service.',
      ),
      'Other or unclassified': (
        'Check local guidance',
        'Identify local rules before disposal.',
      ),
    };
    final info = guidance[category] ?? guidance['Other or unclassified']!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload & identify waste',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manual demo categorization. No AI recognition is performed.',
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: bytes == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 54),
                            SizedBox(height: 10),
                            Text('Add a waste photo'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(bytes!, fit: BoxFit.cover),
                        ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose image'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Take photo'),
                    ),
                    if (bytes != null)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          bytes = null;
                          result = false;
                        }),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm waste category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: guidance.keys
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    category = v!;
                    result = false;
                  }),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: scanning
                        ? null
                        : () async {
                            setState(() => scanning = true);
                            await Future<void>.delayed(
                              const Duration(milliseconds: 500),
                            );
                            if (mounted)
                              setState(() {
                                scanning = false;
                                result = true;
                              });
                          },
                    child: Text(
                      scanning
                          ? 'Preparing guidance...'
                          : 'Show segregation result',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (result) ...[
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.eco_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.$1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(info.$2),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo result saved to this session'),
                      ),
                    ),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save demo result'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class BinsScreen extends StatefulWidget {
  const BinsScreen({super.key});
  @override
  State<BinsScreen> createState() => _BinsScreenState();
}

class _BinsScreenState extends State<BinsScreen> {
  String filter = 'All';
  final bins = const [
    ('BIN-CM-12', 'Central Market', 0.4, 42, ['Mixed', 'Recyclable']),
    ('BIN-LR-08', 'Lake Road', 0.8, 78, ['Plastic', 'Paper']),
    ('BIN-GP-04', 'Green Park', 1.2, 96, ['Mixed']),
  ];

  @override
  Widget build(BuildContext context) {
    final items = bins
        .where((b) => filter == 'All' || b.$5.any((t) => t == filter))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Container(
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 110,
                  color: Color(0xFF93BDA7),
                ),
                ...List.generate(
                  items.length,
                  (i) => Transform.translate(
                    offset: Offset(
                      (i - 1) * 90.0,
                      (i.isEven ? -40 : 35).toDouble(),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 42,
                      color: Color(0xFF17834B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sample locations and availability — not live data',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.orange),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: filter,
          decoration: const InputDecoration(labelText: 'Waste type filter'),
          items: const [
            'All',
            'Mixed',
            'Recyclable',
            'Plastic',
            'Paper',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => filter = v!),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (b) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE2F3E9),
                child: Text(
                  '${b.$4}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17834B),
                  ),
                ),
              ),
              title: Text(
                '${b.$1} • ${b.$2}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${b.$3} km • ${b.$5.join(', ')}\n${b.$4 >= 90
                    ? 'Full'
                    : b.$4 >= 70
                    ? 'Almost full'
                    : 'Available'} • Demo status',
              ),
              isThreeLine: true,
              trailing: IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Directions service can be connected later.'),
                  ),
                ),
                tooltip: 'Directions',
                icon: const Icon(Icons.directions_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int coins = 240;
  final rewards = const [
    ('City Garden Kit', 300),
    ('Transit Voucher', 500),
    ('Recycling Starter Set', 180),
  ];
  bool referralExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: const Color(0xFF123D29),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo eco coin balance',
                  style: TextStyle(color: Color(0xFFC9DDD3)),
                ),
                const SizedBox(height: 8),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: coins / 300,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF91D5AA),
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(height: 8),
                Text(
                  '${300 - coins} coins to the next demo reward',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Available rewards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...rewards.map(
          (r) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE2F3E9),
                child: Icon(
                  Icons.card_giftcard_outlined,
                  color: Color(0xFF17834B),
                ),
              ),
              title: Text(
                r.$1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${r.$2} eco coins • Demo benefit only'),
              trailing: FilledButton(
                onPressed: coins >= r.$2
                    ? () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Redeem ${r.$1}?'),
                            content: const Text(
                              'This is a simulated demo redemption. No real benefit will be issued.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() => coins -= r.$2);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${r.$1} redeemed locally'),
                                    ),
                                  );
                                },
                                child: const Text('Redeem demo'),
                              ),
                            ],
                          ),
                        );
                      }
                    : null,
                child: const Text('Redeem'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ExpansionTile(
            initiallyExpanded: referralExpanded,
            onExpansionChanged: (v) => setState(() => referralExpanded = v),
            leading: const Icon(
              Icons.group_add_outlined,
              color: Color(0xFF17834B),
            ),
            title: const Text(
              'Refer a friend',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Demo referral code: ALEX-CITY-42'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Both participants may receive demo rewards after a verified qualifying action in a future backend.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              const ClipboardData(text: 'ALEX-CITY-42'),
                            );
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Demo referral code copied'),
                                ),
                              );
                          },
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text('Copy code'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Demo share action is ready for platform sharing later',
                                  ),
                                ),
                              ),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('M')),
                      title: Text('Maya K.'),
                      trailing: Text(
                        'Rewarded',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('R')),
                      title: Text('Ravi P.'),
                      trailing: Text('Invited'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});
  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  String category = 'All';
  final articles = const [
    (
      'A practical guide to home waste segregation',
      'Education',
      'Separate wet, dry and hazardous waste to keep recyclable material cleaner.',
    ),
    (
      'How clean recycling protects collection workers',
      'Safety',
      'Empty containers and follow local collection instructions before disposal.',
    ),
    (
      'Building smarter, more sustainable neighborhoods',
      'Smart city',
      'Sample overview of connected bins, reporting and community programs.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final filtered = category == 'All'
        ? articles
        : articles.where((a) => a.$2 == category).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: const Color(0xFFEAF5ED),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF17834B)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Daily tip: Rinse and dry recyclable packaging before placing it in a recycling bin.',
                    style: TextStyle(color: Color(0xFF123D29)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                [
                  'All',
                  'Education',
                  'Safety',
                  'Smart city',
                  'Sustainability',
                ].map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.map(
          (a) => Card(
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(a.$1),
                  content: Text(
                    '${a.$3}\n\nSample educational content only — not a live news publication.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        size: 50,
                        color: Color(0xFF17834B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      a.$2.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF17834B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.$1,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(a.$3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
    required this.onSignOut,
  });
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onSignOut;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  final name = TextEditingController(text: 'Alex Morgan');
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0xFFE2F3E9),
                  child: Text(
                    'AM',
                    style: TextStyle(
                      color: Color(0xFF17834B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('alex@example.com'),
                      const Text(
                        'Citizen • Demo account',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Edit profile'),
                        content: TextField(
                          controller: name,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Dark theme'),
                subtitle: const Text('Apply theme across the app'),
                value: widget.isDark,
                onChanged: widget.onThemeChanged,
              ),
              SwitchListTile(
                title: const Text('Demo notifications'),
                value: notifications,
                onChanged: (v) => setState(() => notifications = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.military_tech_outlined),
                title: Text('Badges & achievements'),
                subtitle: Text('First Report • Recycling Champion'),
              ),
              ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Privacy information'),
                subtitle: Text('Demo data remains local to this session'),
              ),
              ListTile(
                leading: Icon(Icons.accessibility_new_outlined),
                title: Text('Accessibility'),
                subtitle: Text(
                  'Readable contrast and reduced-motion-friendly controls',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Sign out?'),
                content: const Text('Return to the demo sign-in screen.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSignOut();
                    },
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ),
      ],
    );
  }
}

class DriverShell extends StatefulWidget {
  const DriverShell({
    super.key,
    required this.onSignOut,
    required this.isDark,
    required this.onThemeChanged,
  });
  final VoidCallback onSignOut;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int index = 0;
  final tasks = [
    DriverTask('T-2041', 'Central Market', [
      'Mixed waste',
      'Plastic',
    ], 'Assigned'),
    DriverTask('T-2038', 'Lake Road', ['Recyclables'], 'In Progress'),
    DriverTask('T-2029', 'Green Park', ['Garden waste'], 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      DriverDashboard(tasks: tasks),
      DriverTaskScreen(tasks: tasks),
      DriverHistoryScreen(tasks: tasks),
      ProfileScreen(
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
        onSignOut: widget.onSignOut,
      ),
    ];
    return Scaffold(
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              extended: MediaQuery.sizeOf(context).width >= 1180,
              leading: const Padding(
                padding: EdgeInsets.all(18),
                child: Icon(
                  Icons.recycling_rounded,
                  size: 34,
                  color: Color(0xFF17834B),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  label: Text('Assigned tasks'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  label: Text('History'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  label: Text('Profile'),
                ),
              ],
            ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    const [
                      'Dashboard',
                      'Assigned tasks',
                      'Collection history',
                      'Profile',
                    ][index],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demo driver notifications'),
                            ),
                          ),
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
                Expanded(child: pages[index]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}

class DriverTask {
  DriverTask(this.id, this.location, this.types, this.status);
  final String id;
  final String location;
  final List<String> types;
  String status;
}

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key, required this.tasks});
  final List<DriverTask> tasks;
  @override
  Widget build(BuildContext context) {
    final active = tasks.where((t) => t.status != 'Completed').length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Good morning, Jordan',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Demo collection route overview'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _driverStat(context, '$active', 'Active tasks'),
            _driverStat(context, '${tasks.length}', 'Today\'s tasks'),
            _driverStat(context, '3 stops', 'Planned route'),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Today\'s route',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...tasks.map(
          (t) => Card(
            child: ListTile(
              title: Text(t.location),
              subtitle: Text('${t.id} • ${t.types.join(', ')}'),
              trailing: Text(
                t.status,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _driverStat(BuildContext context, String value, String label) =>
      SizedBox(
        width: 180,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label),
              ],
            ),
          ),
        ),
      );
}

class DriverTaskScreen extends StatefulWidget {
  const DriverTaskScreen({super.key, required this.tasks});
  final List<DriverTask> tasks;
  @override
  State<DriverTaskScreen> createState() => _DriverTaskScreenState();
}

class _DriverTaskScreenState extends State<DriverTaskScreen> {
  @override
  Widget build(BuildContext context) {
    final active = widget.tasks.where((t) => t.status != 'Completed').toList();
    if (active.isEmpty)
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 56),
            SizedBox(height: 8),
            Text('No active tasks'),
          ],
        ),
      );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: active
          .map(
            (t) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.location,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${t.id} • ${t.types.join(', ')}'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: t.status,
                      decoration: const InputDecoration(
                        labelText: 'Demo status',
                      ),
                      items: const ['Assigned', 'In Progress', 'Completed']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => t.status = v!),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key, required this.tasks});
  final List<DriverTask> tasks;
  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t.status == 'Completed').toList();
    if (completed.isEmpty)
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_outlined, size: 56),
            SizedBox(height: 8),
            Text('No completed collections yet'),
          ],
        ),
      );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: completed
          .map(
            (t) => Card(
              child: ListTile(
                title: Text(t.location),
                subtitle: Text('${t.id} • ${t.types.join(', ')}'),
                trailing: const Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
