part of 'main.dart';

class MapLocationPoint {
  const MapLocationPoint({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.subtitle,
    this.icon = Icons.location_pin,
    this.color = Colors.red,
  });

  final String label;
  final double latitude;
  final double longitude;
  final String? subtitle;
  final IconData icon;
  final Color color;
}

class OperationsMapScreen extends StatefulWidget {
  const OperationsMapScreen({
    super.key,
    required this.title,
    required this.points,
    this.showCurrentLocation = true,
  });

  final String title;
  final List<MapLocationPoint> points;
  final bool showCurrentLocation;

  @override
  State<OperationsMapScreen> createState() => _OperationsMapScreenState();
}

class _OperationsMapScreenState extends State<OperationsMapScreen> {
  LatLng? currentPosition;
  String locationStatus = 'Current location is not loaded.';

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentLocation) _loadCurrentPosition();
  }

  Future<void> _loadCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => locationStatus = 'Location services are disabled.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => locationStatus = 'Location permission was not granted.');
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
          locationStatus = 'Your current location is shown on the map.';
        });
      }
    } on Exception {
      if (mounted) setState(() => locationStatus = 'Could not read your current location.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.points.isEmpty
        ? const LatLng(12.9716, 77.5946)
        : LatLng(widget.points.first.latitude, widget.points.first.longitude);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(initialCenter: first, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              MarkerLayer(markers: [
                ...widget.points.map((point) => Marker(
                  point: LatLng(point.latitude, point.longitude),
                  width: 52,
                  height: 62,
                  child: Tooltip(
                    message: '${point.label}${point.subtitle == null ? '' : '\n${point.subtitle}'}',
                    child: Icon(point.icon, color: point.color, size: 42),
                  ),
                )),
                if (currentPosition != null)
                  Marker(
                    point: currentPosition!,
                    width: 42,
                    height: 42,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                  ),
              ]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('${widget.points.length} location(s) · $locationStatus')),
            IconButton(onPressed: _loadCurrentPosition, icon: const Icon(Icons.my_location)),
          ]),
        ),
      ]),
    );
  }
}

class GarbageApp extends StatefulWidget {
  const GarbageApp({super.key});

  @override
  State<GarbageApp> createState() => _GarbageAppState();
}

class _GarbageAppState extends State<GarbageApp> {
  ThemeMode themeMode = ThemeMode.dark;
  final List<WasteReport> reports = [];
  final List<ManagerAccount> managerAccounts = [
    ManagerAccount(
      managerId: 'MGR-1001',
      name: 'Ankith',
      email: 'ankith@gmail.com',
      password: '12345678',
      phone: '+91 90000 10001',
      zone: 'Central Market',
      registeredAt: DateTime(2026, 1, 15),
      activityHistory: ['Signed in as Manager · Today'],
    ),
  ];
  String adminName = 'System Administrator';
  String adminEmail = 'admin@gmail.com';
  String adminPhone = '+91 90000 00000';
  String adminPassword = '12345678';
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
      onRoleSelected: (role) {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => AuthScreen(
              role: role,
              managerAccounts: managerAccounts,
              drivers: _demoDrivers,
              adminEmail: adminEmail,
              adminPassword: adminPassword,
              onContinue: (email) => openDashboard(
                role,
                driver: role == UserRole.driver
                    ? _demoDrivers.firstWhere(
                        (driver) => driver.email.toLowerCase() == email.toLowerCase(),
                      )
                    : null,
              ),
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

  void openDashboard(UserRole role, {DriverRecord? driver}) {
    final isDark = themeMode == ThemeMode.dark;
    final onThemeChanged = (bool dark) => setState(
      () => themeMode = dark ? ThemeMode.dark : ThemeMode.light,
    );

    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => role == UserRole.admin
            ? AdminShell(
                accounts: managerAccounts,
                reports: reports,
                onUpdateAccount: updateManagerAccount,
                onCreateAccount: addManagerAccount,
                onSignOut: openRoleSelection,
                adminName: adminName,
                adminEmail: adminEmail,
                adminPhone: adminPhone,
                onAdminProfileChanged: (profile) => setState(() {
                  adminName = profile.$1;
                  adminEmail = profile.$2;
                  adminPhone = profile.$3;
                }),
                onAdminPasswordChanged: (password) =>
                    setState(() => adminPassword = password),
              )
            : role == UserRole.manager
            ? ManagerShell(
                reports: reports,
                onSignOut: openRoleSelection,
              )
            : role == UserRole.driver
            ? DriverShell(
                driver: driver!,
                onSignOut: openRoleSelection,
                isDark: isDark,
                onThemeChanged: onThemeChanged,
                onIssueReported: (issue) => addReport(
                  WasteReport(
                    id: 'DRV-CMP-${DateTime.now().millisecondsSinceEpoch % 100000}',
                    title: issue.type,
                    category: issue.type == 'Fake report'
                        ? 'Fake customer report'
                        : 'Driver issue',
                    description: issue.description,
                    location: issue.location,
                    severity: issue.type == 'Fake report' ? 'High' : 'Medium',
                    createdAt: issue.reportedAt,
                    status: 'Submitted',
                    customer: issue.customer,
                    driverName: issue.driverName,
                    photoName: issue.photo == null ? null : 'driver-evidence.jpg',
                  ),
                ),
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

  void addManagerAccount(ManagerAccount account) {
    account.managerId = 'MGR-${1001 + managerAccounts.length}';
    setState(() => managerAccounts.add(account));
  }

  void updateManagerAccount(ManagerAccount updated) {
    setState(() {
      final index = managerAccounts.indexWhere(
        (account) => account.managerId == updated.managerId,
      );
      if (index >= 0) managerAccounts[index] = updated;
    });
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
    required this.role,
    required this.managerAccounts,
    required this.drivers,
    required this.adminEmail,
    required this.adminPassword,
    required this.onContinue,
    required this.onChangeRole,
  });
  final UserRole role;
  final List<ManagerAccount> managerAccounts;
  final List<DriverRecord> drivers;
  final String adminEmail;
  final String adminPassword;
  final ValueChanged<String> onContinue;
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
                              ? 'Create your citizen account'
                              : '${widget.role == UserRole.driver
                                    ? 'Driver'
                                    : widget.role == UserRole.manager
                                    ? 'Manager'
                                    : 'Citizen'} sign in',
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
                            if (widget.role == UserRole.admin &&
                                v.trim().toLowerCase() !=
                                    widget.adminEmail.toLowerCase())
                              return 'Enter the admin email address';
                            if (widget.role == UserRole.manager &&
                                !widget.managerAccounts.any(
                                  (account) =>
                                      account.email.toLowerCase() ==
                                      v.trim().toLowerCase(),
                                ))
                              return 'This manager account does not exist';
                            if (widget.role == UserRole.driver &&
                                !widget.drivers.any(
                                  (driver) =>
                                      driver.isActive &&
                                      driver.email.toLowerCase() ==
                                      v.trim().toLowerCase(),
                                ))
                              return 'This driver account does not exist';
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
                            if (widget.role == UserRole.admin &&
                                v != widget.adminPassword)
                              return 'Incorrect admin password';
                            if (widget.role == UserRole.manager &&
                                findManagerAccount(
                                  widget.managerAccounts,
                                  email.text,
                                  v,
                                ) ==
                                null)
                              return 'Incorrect manager password';
                            if (widget.role == UserRole.driver &&
                                !widget.drivers.any(
                                  (driver) =>
                                      driver.isActive &&
                                      driver.email.toLowerCase() ==
                                          email.text.trim().toLowerCase() &&
                                      driver.password == v,
                                ))
                              return 'Incorrect driver password';
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
                              widget.onContinue(email.text.trim());
                            },
                            child: Text(
                              widget.role == UserRole.admin
                                  ? 'ADMIN SIGN IN'
                                  : signup
                                  ? 'CREATE ACCOUNT'
                                  : 'SIGN IN',
                            ),
                          ),
                        ),
                        if (widget.role == UserRole.citizen)
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

  final ValueChanged<UserRole> onRoleSelected;

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
                        UserRole.citizen,
                      ),
                      _roleCard(
                        context,
                        'Driver',
                        'View collection tasks and manage routes',
                        Icons.local_shipping_outlined,
                        UserRole.driver,
                      ),
                      _roleCard(
                        context,
                        'Manager',
                        'Manage collections, drivers and reports',
                        Icons.manage_accounts_outlined,
                        UserRole.manager,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextButton.icon(
                    onPressed: () => onRoleSelected(UserRole.admin),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Admin login'),
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
    UserRole role,
  ) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 48)
        .clamp(0, 320)
        .toDouble();

    return SizedBox(
      width: cardWidth,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onRoleSelected(role),
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
