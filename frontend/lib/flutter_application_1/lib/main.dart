import 'dart:typed_data';
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
  ThemeMode themeMode = ThemeMode.dark;
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

  Widget roleSelectionPage() {
    return RoleSelectionScreen(
      onRoleSelected: (isDriver) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => AuthScreen(
              isDriver: isDriver,
              onContinue: () => openDashboard(isDriver),
              onChangeRole: openRoleSelection,
            ),
          ),
        );
      },
    );
  }

  void openRoleSelection() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => roleSelectionPage()),
      (_) => false,
    );
  }

  void openDashboard(bool isDriver) {
    final isDark = themeMode == ThemeMode.dark;
    final onThemeChanged = (bool dark) => setState(
      () => themeMode = dark ? ThemeMode.dark : ThemeMode.light,
    );

    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => isDriver
            ? DriverShell(
                onSignOut: openRoleSelection,
                isDark: isDark,
                onThemeChanged: onThemeChanged,
              )
            : CitizenShell(
                reports: reports,
                onAddReport: addReport,
                isDark: isDark,
                onThemeChanged: onThemeChanged,
                onSignOut: openRoleSelection,
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
      home: roleSelectionPage(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.isDriver,
    required this.onContinue,
    required this.onChangeRole,
  });
  final bool isDriver;
  final VoidCallback onContinue;
  final VoidCallback onChangeRole;

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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: widget.onChangeRole,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Change role'),
                          ),
                        ),
                        if (!wide) ...[
                          const Icon(
                            Icons.recycling_rounded,
                            size: 56,
                            color: Color(0xFF17834B),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          signup
                              ? 'Create your ${widget.isDriver ? 'driver' : 'citizen'} account'
                              : '${widget.isDriver ? 'Driver' : 'Citizen'} sign in',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          signup
                              ? 'Join the cleaner-city community.'
                              : 'Sign in to continue to your dashboard.',
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
    required this.onRoleSelected,
  });

  final ValueChanged<bool> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_city_rounded,
                    size: 72,
                    color: Color(0xFF17834B),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Welcome to Smart City',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                        'Report waste, find nearby bins and earn rewards',
                        Icons.person_outline_rounded,
                        false,
                      ),
                      _roleCard(
                        context,
                        'Driver',
                        'View collection tasks and manage routes',
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
      ),
    );
  }

  Widget _roleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDriver,
  ) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 48)
        .clamp(0, 320)
        .toDouble();

    return SizedBox(
      width: cardWidth,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onRoleSelected(isDriver),
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
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
    'Track Collection',
    'Knowledge',
    'Profile',
    'Notifications & Feedback',
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
      TrackCollectionScreen(reports: widget.reports),
      const KnowledgeScreen(),
      ProfileScreen(
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
        onSignOut: widget.onSignOut,
      ),
      const NotificationsFeedbackScreen(),
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
                  icon: Icon(Icons.local_shipping_outlined),
                  selectedIcon: Icon(Icons.local_shipping),
                  label: Text('Track Collection'),
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
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_none),
                  selectedIcon: Icon(Icons.notifications),
                  label: Text('Notifications'),
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
                      tooltip: 'Notifications and feedback',
                      onPressed: () => setState(() => index = 8),
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
              selectedIndex: index > 5 ? 5 : index,
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
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  label: 'Track',
                ),
              ],
            ),
    );
  }
}


class NotificationsFeedbackScreen extends StatefulWidget {
  const NotificationsFeedbackScreen({super.key});

  @override
  State<NotificationsFeedbackScreen> createState() =>
      _NotificationsFeedbackScreenState();
}

class _NotificationsFeedbackScreenState
    extends State<NotificationsFeedbackScreen> {
  final reviewController = TextEditingController();
  int rating = 0;
  bool feedbackSubmitted = false;
  bool incompleteReported = false;

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Collection completed',
      'message': 'Your waste collection request REQ-2048 has been completed.',
      'time': 'Today · 5:42 PM',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF17834B),
    },
    {
      'title': 'Driver on the way',
      'message': 'Your assigned driver is on the way to your location.',
      'time': 'Today · 5:10 PM',
      'icon': Icons.local_shipping_outlined,
      'color': Color(0xFF2878B8),
    },
    {
      'title': 'Collection scheduled',
      'message': 'Your collection is scheduled for today, 5:00–6:00 PM.',
      'time': 'Today · 9:00 AM',
      'icon': Icons.calendar_month_outlined,
      'color': Color(0xFFB7791F),
    },
    {
      'title': 'Driver assigned',
      'message': 'Rahul Kumar has been assigned to your collection request.',
      'time': 'Today · 8:45 AM',
      'icon': Icons.person_outline,
      'color': Color(0xFF2878B8),
    },
    {
      'title': 'Complaint submitted successfully',
      'message': 'Your waste report was received and saved.',
      'time': 'Yesterday · 4:20 PM',
      'icon': Icons.assignment_turned_in_outlined,
      'color': Color(0xFF17834B),
    },
    {
      'title': 'Collection schedule updated',
      'message': 'Your collection time has been updated to 5:00 PM.',
      'time': 'Yesterday · 2:15 PM',
      'icon': Icons.update_outlined,
      'color': Color(0xFFB7791F),
    },
  ];

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void submitFeedback() {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating first.')),
      );
      return;
    }
    setState(() => feedbackSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you! Your feedback was saved locally.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Stay updated on your collection requests.',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        const Text('Notifications',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...notifications.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (item['color'] as Color).withOpacity(.12),
                  child: Icon(item['icon'] as IconData,
                      color: item['color'] as Color),
                ),
                title: Text(item['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${item['message']}\n${item['time']}'),
                ),
                isThreeLine: true,
              ),
            )),
        const SizedBox(height: 14),
        const Text('Feedback',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rate your latest collection',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Feedback is available after a collection is completed.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (i) => IconButton(
                    onPressed: feedbackSubmitted ? null : () => setState(() => rating = i + 1),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFE5A323), size: 32),
                  )),
                ),
                TextField(
                  controller: reviewController,
                  enabled: !feedbackSubmitted,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Write a short review',
                    hintText: 'Tell us about your collection experience',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: feedbackSubmitted ? null : submitFeedback,
                    icon: const Icon(Icons.send_outlined),
                    label: Text(feedbackSubmitted ? 'Feedback submitted' : 'Submit feedback'),
                  ),
                ),
                const Divider(height: 28),
                OutlinedButton.icon(
                  onPressed: incompleteReported ? null : () => setState(() => incompleteReported = true),
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(incompleteReported ? 'Incomplete collection reported' : 'Report an incomplete collection'),
                ),
                if (incompleteReported)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Your issue has been recorded locally for review.',
                        style: TextStyle(color: Color(0xFF17834B))),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Previous feedback',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.star_rounded, color: Color(0xFFE5A323)),
            title: Text(feedbackSubmitted ? '$rating / 5 stars' : 'No previous feedback yet'),
            subtitle: Text(feedbackSubmitted
                ? (reviewController.text.trim().isEmpty ? 'No written review added.' : reviewController.text.trim())
                : 'Your submitted reviews will appear here.'),
          ),
        ),
      ],
    );
  }
}

class TrackCollectionScreen extends StatelessWidget {
  const TrackCollectionScreen({super.key, required this.reports});
  final List<WasteReport> reports;

  @override
  Widget build(BuildContext context) {
    final latest = reports.isNotEmpty ? reports.last : null;
    final title = latest?.title ?? 'Household waste collection';
    final location = latest?.location ?? '12th Main Road, Bengaluru';
    final requestId = latest?.id ?? 'REQ-2048';
    final created = latest?.createdAt ?? DateTime.now().subtract(const Duration(hours: 2));
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE4F4EA),
                    child: Icon(Icons.local_shipping_rounded, color: Color(0xFF17834B)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Active collection request', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFFF1D8), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Driver assigned', style: TextStyle(color: Color(0xFF98600B), fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 18),
                Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _trackingInfoRow(context, Icons.confirmation_number_outlined, 'Request ID', requestId),
                _trackingInfoRow(context, Icons.location_on_outlined, 'Collection address', location),
                _trackingInfoRow(context, Icons.delete_outline, 'Waste type', latest?.category ?? 'Mixed household waste'),
                _trackingInfoRow(context, Icons.calendar_today_outlined, 'Requested on', '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Assigned driver', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Row(children: [
                const CircleAvatar(radius: 25, backgroundColor: Color(0xFFE4F4EA), child: Icon(Icons.person, color: Color(0xFF17834B), size: 28)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Rahul Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 3), Text('Collection Driver · Vehicle KA 05 AB 2048', style: TextStyle(fontSize: 12))])),
                IconButton.filledTonal(
                  tooltip: 'Contact driver',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver contact is not connected in this demo.'))),
                  icon: const Icon(Icons.call_outlined),
                ),
              ]),
              const Divider(height: 24),
              _trackingInfoRow(context, Icons.schedule, 'Scheduled collection', 'Today, 5:00 PM – 6:00 PM'),
              _trackingInfoRow(context, Icons.timer_outlined, 'Estimated arrival', 'Around 5:30 PM'),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Driver location', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.map_outlined, size: 38, color: muted),
                  const SizedBox(height: 8),
                  const Text('Live map tracking is not enabled yet', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('Driver location will appear here when available', style: TextStyle(color: muted, fontSize: 12)),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Collection progress', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              _trackingTimelineStep(context, 'Request submitted', 'Your collection request has been received', true, true),
              _trackingTimelineStep(context, 'Driver assigned', 'A collection driver has been assigned', true, true),
              _trackingTimelineStep(context, 'On the way', 'The driver will proceed to your location', false, true),
              _trackingTimelineStep(context, 'Collection completed', 'Your waste has been collected successfully', false, false),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: const Color(0xFFEAF6EE),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, color: Color(0xFF17834B)),
              SizedBox(width: 12),
              Expanded(child: Text('Completion confirmation will be shown here after the driver marks the task as completed and uploads the cleaned-site photo.', style: TextStyle(color: Color(0xFF245B39)))),
            ]),
          ),
        ),
      ],
    );
  }
}

Widget _trackingInfoRow(BuildContext context, IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: 10),
      SizedBox(width: 132, child: Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );
}

Widget _trackingTimelineStep(BuildContext context, String title, String detail, bool done, bool hasNext) {
  return IntrinsicHeight(
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 26, child: Column(children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? const Color(0xFF17834B) : Theme.of(context).colorScheme.outline, size: 20),
        if (hasNext) Expanded(child: Container(width: 2, color: Theme.of(context).colorScheme.outlineVariant)),
      ])),
      const SizedBox(width: 10),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: done ? const Color(0xFF17834B) : null)),
        const SizedBox(height: 3),
        Text(detail, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ]))),
    ]),
  );
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
            _quickAction(
              context,
              'Track collection',
              Icons.local_shipping_outlined,
              () => onNavigate(5),
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
                value: Theme.of(context).brightness == Brightness.dark,
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
  String availability = 'Available';
  final tasks = <DriverTask>[
    DriverTask(
      id: 'T-2041', customer: 'Aarav Sharma', location: 'Central Market',
      address: '12, Central Market Road, Bengaluru', landmark: 'Near City Library',
      types: ['Mixed waste'], quantity: 'Approx. 8 kg', contact: '+91 98765 43210',
      scheduledAt: DateTime.now().add(const Duration(hours: 1)), priority: 'High', status: 'In Progress'),
    DriverTask(
      id: 'T-2038', customer: 'Meera Rao', location: 'Lake Road',
      address: '45, Lake Road, Bengaluru', landmark: 'Opposite Lake Gate',
      types: ['Plastic', 'Recyclables'], quantity: 'Approx. 5 kg', contact: '+91 98765 12340',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)), priority: 'Medium', status: 'In Progress'),
    DriverTask(
      id: 'T-2029', customer: 'Rohan Kumar', location: 'Green Park',
      address: '8, Green Park Layout, Bengaluru', landmark: 'Beside Park Entrance',
      types: ['Garden waste'], quantity: 'Approx. 12 kg', contact: '+91 99887 76655',
      scheduledAt: DateTime.now().subtract(const Duration(minutes: 40)), priority: 'Low', status: 'Completed'),
  ];
  final issues = <DriverIssue>[];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      DriverDashboard(tasks: tasks, availability: availability,
        onAvailabilityChanged: (v) => setState(() => availability = v),
        onOpenTasks: () => setState(() => index = 1)),
      DriverTaskScreen(tasks: tasks),
      DriverIssueScreen(tasks: tasks, issues: issues, onIssueAdded: (issue) => setState(() => issues.insert(0, issue))),
      DriverHistoryScreen(tasks: tasks, issues: issues),
      DriverProfileScreen(tasks: tasks, availability: availability, isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged, onSignOut: widget.onSignOut),
    ];
    const titles = ['Driver Dashboard', 'Assigned Collections', 'Report Collection Issue', 'Work History', 'Driver Profile'];
    return Scaffold(
      body: Row(children: [
        if (wide) NavigationRail(
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
          extended: MediaQuery.sizeOf(context).width >= 1180,
          leading: const Padding(padding: EdgeInsets.all(18), child: Icon(Icons.recycling_rounded, size: 34, color: Color(0xFF17834B))),
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text('Dashboard')),
            NavigationRailDestination(icon: Icon(Icons.assignment_outlined), label: Text('Assigned Collections')),
            NavigationRailDestination(icon: Icon(Icons.report_problem_outlined), label: Text('Report Issue')),
            NavigationRailDestination(icon: Icon(Icons.history_outlined), label: Text('Work History')),
            NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('Profile')),
          ],
        ),
        Expanded(child: Column(children: [
          AppBar(title: Text(titles[index]), actions: [
            Padding(padding: const EdgeInsets.only(right: 14), child: Center(child: Text(availability, style: TextStyle(fontWeight: FontWeight.w600, color: availability == 'Available' ? Colors.green : availability == 'Busy' ? Colors.orange : Colors.grey)))),
          ]),
          Expanded(child: pages[index]),
        ])),
      ]),
      bottomNavigationBar: wide ? null : NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.report_problem_outlined), label: 'Issues'),
          NavigationDestination(icon: Icon(Icons.history_outlined), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class DriverTask {
  DriverTask({required this.id, required this.customer, required this.location,
    required this.address, required this.landmark, required this.types,
    required this.quantity, required this.contact, required this.scheduledAt,
    required this.priority, this.status = 'In Progress'});
  final String id;
  final String customer;
  final String location;
  final String address;
  final String landmark;
  final List<String> types;
  final String quantity;
  final String contact;
  final DateTime scheduledAt;
  final String priority;
  String status;
  Uint8List? completionImageBytes;
  String completionNotes = '';
  DateTime? completedAt;
}

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key, required this.tasks, required this.availability,
    required this.onAvailabilityChanged, required this.onOpenTasks});
  final List<DriverTask> tasks;
  final String availability;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onOpenTasks;
  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t.status == 'Completed').length;
    final remaining = tasks.length - completed;
    final next = tasks.where((t) => t.status != 'Completed').toList()..sort((a,b) => a.scheduledAt.compareTo(b.scheduledAt));
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Welcome back, Jordan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4), const Text('Here is your collection schedule for today.'),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Availability status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: ['Available', 'Busy', 'Off Duty'].map((v) => ChoiceChip(label: Text(v), selected: availability == v, onSelected: (_) => onAvailabilityChanged(v))).toList()),
      ]))),
      const SizedBox(height: 14),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _driverStat(context, '${tasks.length}', 'Assigned today', Icons.assignment_outlined),
        _driverStat(context, '$completed', 'Completed', Icons.task_alt),
        _driverStat(context, '$remaining', 'Remaining', Icons.pending_actions),
      ]),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Next collection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), TextButton(onPressed: onOpenTasks, child: const Text('View all'))]),
      if (next.isNotEmpty) Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.location_on_outlined)), title: Text(next.first.location), subtitle: Text('${next.first.address}\n${_driverTime(next.first.scheduledAt)} · ${next.first.priority} priority'), isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: onOpenTasks)) else const Card(child: ListTile(title: Text('All collections completed'), leading: Icon(Icons.check_circle, color: Colors.green))),
    ]);
  }
  Widget _driverStat(BuildContext context, String value, String label, IconData icon) => SizedBox(width: 175, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFF17834B)), const SizedBox(height: 10), Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), Text(label)]))));
}

String _driverTime(DateTime value) => '${value.day.toString().padLeft(2,'0')}/${value.month.toString().padLeft(2,'0')} · ${value.hour.toString().padLeft(2,'0')}:${value.minute.toString().padLeft(2,'0')}';

class DriverTaskScreen extends StatefulWidget {
  const DriverTaskScreen({super.key, required this.tasks});
  final List<DriverTask> tasks;
  @override
  State<DriverTaskScreen> createState() => _DriverTaskScreenState();
}
class _DriverTaskScreenState extends State<DriverTaskScreen> {
  String sortBy = 'Scheduled time';
  @override
  Widget build(BuildContext context) {
    final active = widget.tasks.where((t) => t.status != 'Completed').toList();
    active.sort((a,b) => sortBy == 'Priority' ? _priorityValue(a.priority).compareTo(_priorityValue(b.priority)) : a.scheduledAt.compareTo(b.scheduledAt));
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [const Expanded(child: Text('Your assigned collection tasks', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))), SizedBox(width: 175, child: DropdownButtonFormField<String>(initialValue: sortBy, decoration: const InputDecoration(labelText: 'Sort by'), items: const ['Scheduled time','Priority'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v)=>setState(()=>sortBy=v ?? sortBy)))]),
      const SizedBox(height: 12),
      if (active.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('No pending collections.'))),
      ...active.map((task) => Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.local_shipping_outlined)),
        title: Text(task.location, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${task.id} · ${task.customer}\n${_driverTime(task.scheduledAt)} · ${task.priority} priority\n${task.types.join(', ')}'),
        isThreeLine: true, trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverTaskDetailScreen(task: task, onChanged: () => setState(() {})))),
      ))),
    ]);
  }
}
int _priorityValue(String value) => value == 'High' ? 0 : value == 'Medium' ? 1 : 2;

class DriverTaskDetailScreen extends StatefulWidget {
  const DriverTaskDetailScreen({super.key, required this.task, required this.onChanged});
  final DriverTask task;
  final VoidCallback onChanged;
  @override
  State<DriverTaskDetailScreen> createState() => _DriverTaskDetailScreenState();
}
class _DriverTaskDetailScreenState extends State<DriverTaskDetailScreen> {
  final notesController = TextEditingController();
  bool navigationStarted = false;
  Future<void> completeTask() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() { widget.task.completionImageBytes = bytes; });
      final now = DateTime.now();
      widget.task.completionNotes = notesController.text.trim();
      widget.task.completedAt = now;
      widget.task.status = 'Completed';
      widget.onChanged();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completion photo saved. Collection marked completed.')));
    } on PlatformException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to access the photo gallery.'))); }
  }
  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return Scaffold(appBar: AppBar(title: Text('Collection ${t.id}')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(t.location, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), _detailLine(Icons.person_outline, 'Customer', t.customer),
      _detailLine(Icons.location_on_outlined, 'Pickup address', t.address), _detailLine(Icons.place_outlined, 'Landmark', t.landmark),
      _detailLine(Icons.delete_outline, 'Waste type', t.types.join(', ')), _detailLine(Icons.scale_outlined, 'Approximate quantity', t.quantity),
      _detailLine(Icons.phone_outlined, 'Contact', t.contact), _detailLine(Icons.schedule, 'Scheduled time', _driverTime(t.scheduledAt)),
      _detailLine(Icons.flag_outlined, 'Priority', t.priority), _detailLine(Icons.info_outline, 'Status', t.status),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pickup location map', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), Container(height: 150, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.map_outlined, size: 42), Text('Map preview · Connect maps for live directions')]))), const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => setState(() => navigationStarted = true), icon: const Icon(Icons.navigation_outlined), label: Text(navigationStarted ? 'Navigation started (demo)' : 'Start navigation')))]))),
      const SizedBox(height: 12), const Text('Update collection status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      DropdownButtonFormField<String>(initialValue: t.status, decoration: const InputDecoration(labelText: 'Collection status'), items: const ['In Progress', 'Completed'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (value) { if (value == 'Completed' && t.status != 'Completed') { completeTask(); } else if (value == 'In Progress') { setState(() { t.status = 'In Progress'; t.completionImageBytes = null; t.completedAt = null; t.completionNotes = ''; }); widget.onChanged(); } }),
      if (t.status != 'Completed') ...[
        const SizedBox(height: 8),
        TextField(controller: notesController, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Completion notes (optional)', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: completeTask, icon: const Icon(Icons.photo_camera_outlined), label: const Text('Upload clean-site photo & complete'))),
      ] else ...[
        const SizedBox(height: 12), const Text('Collection completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        if (t.completedAt != null) Text('Recorded at ${_driverTime(t.completedAt!)}'),
        if (t.completionImageBytes != null) Padding(padding: const EdgeInsets.only(top: 12), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(t.completionImageBytes!, height: 190, fit: BoxFit.cover))),
        if (t.completionNotes.isNotEmpty) Text('Notes: ${t.completionNotes}'),
      ],
    ]));
  }
  Widget _detailLine(IconData icon, String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 19, color: const Color(0xFF17834B)), const SizedBox(width: 10), SizedBox(width: 125, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), Expanded(child: Text(value))]));
}

class DriverIssue {
  DriverIssue({required this.taskId, required this.location, required this.type, required this.description, required this.reportedAt, this.photo});
  final String taskId, location, type, description;
  final DateTime reportedAt;
  final Uint8List? photo;
  String resolutionStatus = 'Submitted to manager';
}
class DriverIssueScreen extends StatefulWidget {
  const DriverIssueScreen({super.key, required this.tasks, required this.issues, required this.onIssueAdded});
  final List<DriverTask> tasks; final List<DriverIssue> issues; final ValueChanged<DriverIssue> onIssueAdded;
  @override
  State<DriverIssueScreen> createState() => _DriverIssueScreenState();
}
class _DriverIssueScreenState extends State<DriverIssueScreen> {
  String? selectedTask; String issueType = 'Customer unavailable'; Uint8List? photo; final description = TextEditingController();
  static const issueTypes = ['Customer unavailable','Location inaccessible','Garbage not available','Vehicle breakdown','Road blocked','Incorrect address','Other'];
  Future<void> choosePhoto() async { try { final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80); if (f != null) { final bytes = await f.readAsBytes(); if (mounted) setState(() => photo = bytes); } } on PlatformException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open gallery.'))); } }
  void submit() { if (selectedTask == null || description.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a collection and enter an issue description.'))); return; } final task = widget.tasks.firstWhere((t)=>t.id==selectedTask); widget.onIssueAdded(DriverIssue(taskId: task.id, location: task.location, type: issueType, description: description.text.trim(), reportedAt: DateTime.now(), photo: photo)); setState(() { description.clear(); photo = null; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue report submitted to manager.'))); }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Report a collection issue', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 14),
    DropdownButtonFormField<String>(initialValue: selectedTask, decoration: const InputDecoration(labelText: 'Affected collection', border: OutlineInputBorder()), items: widget.tasks.map((t)=>DropdownMenuItem(value:t.id,child:Text('${t.id} · ${t.location}'))).toList(), onChanged:(v)=>setState(()=>selectedTask=v)),
    const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: issueType, decoration: const InputDecoration(labelText: 'Issue type', border: OutlineInputBorder()), items: issueTypes.map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(), onChanged:(v)=>setState(()=>issueType=v ?? issueType)),
    const SizedBox(height: 12), TextField(controller: description, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe what happened...', border: OutlineInputBorder())),
    const SizedBox(height: 12), OutlinedButton.icon(onPressed: choosePhoto, icon: const Icon(Icons.add_a_photo_outlined), label: Text(photo == null ? 'Upload relevant photo (optional)' : 'Photo attached')),
    if (photo != null) Padding(padding: const EdgeInsets.only(top: 8), child: Image.memory(photo!, height: 150, fit: BoxFit.cover)),
    const SizedBox(height: 12), Text('Issue time will be recorded as ${_driverTime(DateTime.now())}.'),
    const SizedBox(height: 12), FilledButton.icon(onPressed: submit, icon: const Icon(Icons.send), label: const Text('Submit report to manager')),
    const Divider(height: 32), const Text('Submitted issue reports', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    if (widget.issues.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('No issues reported yet.')),
    ...widget.issues.map((i)=>Card(child: ListTile(leading: const Icon(Icons.report_problem_outlined), title: Text('${i.type} · ${i.location}'), subtitle: Text('${i.taskId} · ${_driverTime(i.reportedAt)}\n${i.description}\n${i.resolutionStatus}'), isThreeLine: true, trailing: const Icon(Icons.schedule)))),
  ]);
}

class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key, required this.tasks, required this.issues});
  final List<DriverTask> tasks; final List<DriverIssue> issues;
  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t)=>t.status=='Completed').toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Completed collections · ${completed.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      if (completed.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('No completed collections yet.')),
      ...completed.map((t)=>Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ListTile(contentPadding: EdgeInsets.zero, title: Text(t.location), subtitle: Text('${t.id} · ${t.customer}\nCompleted ${t.completedAt == null ? '' : _driverTime(t.completedAt!)}'), trailing: const Icon(Icons.check_circle, color: Colors.green), isThreeLine: true), if (t.completionImageBytes != null) ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(t.completionImageBytes!, height: 150, width: double.infinity, fit: BoxFit.cover)), if (t.completionNotes.isNotEmpty) Text('Notes: ${t.completionNotes}')])))),
      const Divider(height: 32), const Text('Issue report history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      if (issues.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('No issue reports submitted.')),
      ...issues.map((i)=>ListTile(leading: const Icon(Icons.report_outlined), title: Text(i.type), subtitle: Text('${i.location} · ${_driverTime(i.reportedAt)}\n${i.resolutionStatus}'))),
      const Divider(height: 32), const Text('Shift information', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const ListTile(leading: Icon(Icons.access_time), title: Text('Today’s shift'), subtitle: Text('08:00 AM – 05:00 PM · Attendance demo: Present')),
    ]);
  }
}

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key, required this.tasks, required this.availability, required this.isDark, required this.onThemeChanged, required this.onSignOut});
  final List<DriverTask> tasks; final String availability; final bool isDark; final ValueChanged<bool> onThemeChanged; final VoidCallback onSignOut;
  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}
class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final name = TextEditingController(text: 'Jordan Mathew'); final phone = TextEditingController(text: '+91 98765 43210'); final email = TextEditingController(text: 'jordan.driver@example.com');
  bool notifications = true;
  @override
  Widget build(BuildContext context) {
    final done = widget.tasks.where((t)=>t.status=='Completed').length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 42)), const SizedBox(height: 10), Center(child: Text(name.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), const Center(child: Text('Employee ID · DRV-1042')),
      const SizedBox(height: 18), const Text('Driver details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Driver name')), TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone number')), TextField(controller: email, decoration: const InputDecoration(labelText: 'Email address')),
      const SizedBox(height: 10), OutlinedButton.icon(onPressed: () { setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile details updated for this session.'))); }, icon: const Icon(Icons.save_outlined), label: const Text('Save profile changes')),
      const ListTile(leading: Icon(Icons.local_shipping_outlined), title: Text('Assigned vehicle'), subtitle: Text('KA 05 AB 2048')),
      ListTile(leading: const Icon(Icons.calendar_month_outlined), title: const Text('Work schedule'), subtitle: const Text('Monday – Saturday · 08:00 AM – 05:00 PM')),
      ListTile(leading: const Icon(Icons.circle), title: const Text('Availability'), subtitle: Text(widget.availability)),
      ListTile(leading: const Icon(Icons.task_alt), title: const Text('Today’s completed collections'), trailing: Text('$done')),
      const Divider(), const Text('Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      SwitchListTile(value: notifications, onChanged:(v)=>setState(()=>notifications=v), title: const Text('Work notifications')),
      SwitchListTile(value: Theme.of(context).brightness == Brightness.dark, onChanged: widget.onThemeChanged, title: const Text('Dark mode')),
      ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Change password'), onTap: ()=>showDialog(context: context, builder:(ctx)=>AlertDialog(title: const Text('Change password'), content: const Text('Password changes will be enabled when authentication is connected.'), actions:[TextButton(onPressed:()=>Navigator.pop(ctx), child: const Text('Close'))]))),
      const SizedBox(height: 10), FilledButton.icon(onPressed: widget.onSignOut, icon: const Icon(Icons.logout), label: const Text('Logout')),
    ]);
  }
}
