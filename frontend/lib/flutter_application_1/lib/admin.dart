part of 'main.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({
    super.key,
    required this.accounts,
    required this.reports,
    required this.onUpdateAccount,
    required this.onCreateAccount,
    required this.onSignOut,
    required this.adminName,
    required this.adminEmail,
    required this.adminPhone,
    required this.onAdminProfileChanged,
    required this.onAdminPasswordChanged,
  });

  final List<ManagerAccount> accounts;
  final List<WasteReport> reports;
  final ValueChanged<ManagerAccount> onUpdateAccount;
  final ValueChanged<ManagerAccount> onCreateAccount;
  final VoidCallback onSignOut;
  final String adminName;
  final String adminEmail;
  final String adminPhone;
  final ValueChanged<(String, String, String)> onAdminProfileChanged;
  final ValueChanged<String> onAdminPasswordChanged;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int selectedPage = 0;

  Future<void> _showCreateAccountDialog(BuildContext context) async {
    final account = await showDialog<ManagerAccount>(
      context: context,
      builder: (_) => _CreateManagerAccountDialog(
        existingAccounts: widget.accounts,
      ),
    );

    if (account != null && context.mounted) {
      widget.onCreateAccount(account);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${account.email} can now log in as Manager.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboard(
        accounts: widget.accounts,
        reports: widget.reports,
        onCreateManagerAccount: () => _showCreateAccountDialog(context),
        onOpenUserManagement: () => setState(() => selectedPage = 1),
      ),
      UserManagementScreen(
        customers: _demoCustomers,
        drivers: _demoDrivers,
        accounts: widget.accounts,
        onCreateManagerAccount: () => _showCreateAccountDialog(context),
        onUpdateManagerAccount: widget.onUpdateAccount,
      ),
      CollectionMonitoringScreen(
        requests: _demoRequests,
        drivers: _demoDrivers,
      ),
      AdminBinManagementScreen(bins: _demoBins),
      ComplaintManagementScreen(
        requests: _demoRequests,
        reports: widget.reports,
        managers: widget.accounts,
      ),
      AdminReportsAnalyticsScreen(
        requests: _demoRequests,
        reports: widget.reports,
        drivers: _demoDrivers,
        managers: widget.accounts,
      ),
      AdminProfileSettingsScreen(
        name: widget.adminName,
        email: widget.adminEmail,
        phone: widget.adminPhone,
        onProfileChanged: widget.onAdminProfileChanged,
        onPasswordChanged: widget.onAdminPasswordChanged,
        onSignOut: widget.onSignOut,
      ),
    ];
    const titles = [
      'Admin Dashboard',
      'User Management',
      'Garbage Collection Monitoring',
      'Garbage Bin Management',
      'Complaint Management',
      'Reports & Analytics',
      'Admin Profile & Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
            tooltip: 'Open menu',
          ),
        ),
        title: Text(titles[selectedPage]),
        actions: [
          IconButton(
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF17834B)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Admin module',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            _adminMenuItem(0, Icons.dashboard_outlined, 'Dashboard'),
            _adminMenuItem(1, Icons.people_alt_outlined, 'User Management'),
            _adminMenuItem(
              2,
              Icons.local_shipping_outlined,
              'Collection Monitoring',
            ),
            _adminMenuItem(3, Icons.delete_outline, 'Garbage Bin Management'),
            _adminMenuItem(4, Icons.report_problem_outlined, 'Complaint Management'),
            _adminMenuItem(5, Icons.analytics_outlined, 'Reports & Analytics'),
            _adminMenuItem(6, Icons.admin_panel_settings_outlined, 'Profile & Settings'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: widget.onSignOut,
            ),
          ],
        ),
      ),
      body: pages[selectedPage],
    );
  }

  Widget _adminMenuItem(int index, IconData icon, String title) {
    return ListTile(
      selected: selectedPage == index,
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        setState(() => selectedPage = index);
        Navigator.pop(context);
      },
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.accounts,
    required this.reports,
    required this.onCreateManagerAccount,
    required this.onOpenUserManagement,
  });

  final List<ManagerAccount> accounts;
  final List<WasteReport> reports;
  final VoidCallback onCreateManagerAccount;
  final VoidCallback onOpenUserManagement;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String period = 'Daily';

  @override
  Widget build(BuildContext context) {
    final totalCustomers = _demoCustomers.length + 127;
    final totalDrivers = _demoDrivers.length + 83;
    final totalManagers = widget.accounts.length;
    final totalRequests =
        _demoRequests.where((request) => request.type == 'Collection').length +
        24;
    final completedCollections =
        _demoRequests.where((request) => request.status == 'Resolved').length +
        64;
    final pendingCollections =
        _demoRequests.where((request) => request.status != 'Resolved').length +
        12;
    final activeComplaints =
        _demoRequests.where(
          (request) =>
              request.type == 'Complaint' && request.status != 'Resolved',
        ).length +
        widget.reports.where((report) => report.status != 'Resolved').length +
        6;
    final totalCollections = completedCollections + pendingCollections;
    final performance = totalCollections == 0
        ? 0
        : (completedCollections / totalCollections * 100).round();
    final statistics = switch (period) {
      'Weekly' => const ['1,284', '342', '96%', '18'],
      'Monthly' => const ['5,486', '1,478', '94%', '61'],
      _ => const ['186', '48', '97%', '7'],
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monitor users, collections, infrastructure, and system health.',
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: widget.onCreateManagerAccount,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Create manager'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 560
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 3.2 : 1.65,
              children: [
                _metricCard(
                  context,
                  'Registered customers',
                  '$totalCustomers',
                  Icons.people_alt_outlined,
                  Colors.blue,
                ),
                _metricCard(
                  context,
                  'Registered drivers',
                  '$totalDrivers',
                  Icons.local_shipping_outlined,
                  Colors.orange,
                ),
                _metricCard(
                  context,
                  'Registered managers',
                  '$totalManagers',
                  Icons.manage_accounts_outlined,
                  Colors.purple,
                ),
                _metricCard(
                  context,
                  'Collection requests',
                  '$totalRequests',
                  Icons.assignment_outlined,
                  Colors.teal,
                ),
                _metricCard(
                  context,
                  'Completed collections',
                  '$completedCollections',
                  Icons.task_alt_outlined,
                  Colors.green,
                ),
                _metricCard(
                  context,
                  'Pending collections',
                  '$pendingCollections',
                  Icons.pending_actions_outlined,
                  Colors.amber.shade800,
                ),
                _metricCard(
                  context,
                  'Registered garbage bins',
                  '${_demoBins.length}',
                  Icons.delete_outline,
                  Colors.indigo,
                ),
                _metricCard(
                  context,
                  'Active complaints',
                  '$activeComplaints',
                  Icons.report_problem_outlined,
                  Colors.red,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Overall system performance',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '$performance%',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: performance / 100,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 10),
                Text(
                  '$completedCollections completed of $totalCollections tracked collections',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'System statistics',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: DropdownButtonFormField<String>(
                        initialValue: period,
                        decoration: const InputDecoration(
                          labelText: 'Period',
                          isDense: true,
                        ),
                        items: const ['Daily', 'Weekly', 'Monthly']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => period = value ?? period),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 28,
                  runSpacing: 16,
                  children: [
                    _statValue('Requests received', statistics[0]),
                    _statValue('Collections completed', statistics[1]),
                    _statValue('Success rate', statistics[2]),
                    _statValue('New complaints', statistics[3]),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: widget.onOpenUserManagement,
          icon: const Icon(Icons.manage_accounts_outlined),
          label: const Text('Open user management'),
        ),
        const SizedBox(height: 20),
        Text(
          'Recent system activities',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _activity(
                Icons.person_add_alt_1,
                'Manager access reviewed',
                '${widget.accounts.length} manager account(s) currently active',
                'Just now',
              ),
              _activity(
                Icons.local_shipping_outlined,
                'Collection operations updated',
                '$completedCollections collections completed',
                'Today',
              ),
              _activity(
                Icons.report_problem_outlined,
                'Complaints require attention',
                '$activeComplaints active complaint(s) are awaiting resolution',
                'Today',
              ),
              _activity(
                Icons.delete_outline,
                'Bin inventory synchronized',
                '${_demoBins.length} registered bins are being monitored',
                'Yesterday',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Manager accounts',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...widget.accounts.map(
          (account) => Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.manage_accounts_outlined),
              ),
              title: Text(account.name),
              subtitle: Text(account.email),
              trailing: const Chip(
                label: Text('Active'),
                avatar: Icon(Icons.check_circle_outline, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.14),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(title),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statValue(String label, String value) {
    return SizedBox(
      width: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _activity(IconData icon, String title, String subtitle, String time) {
    return ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(time),
    );
  }
}

class CollectionMonitoringScreen extends StatefulWidget {
  const CollectionMonitoringScreen({
    super.key,
    required this.requests,
    required this.drivers,
  });

  final List<RequestRecord> requests;
  final List<DriverRecord> drivers;

  @override
  State<CollectionMonitoringScreen> createState() =>
      _CollectionMonitoringScreenState();
}

class _CollectionMonitoringScreenState
    extends State<CollectionMonitoringScreen> {
  String status = 'All';
  String dateRange = 'All dates';
  String driver = 'All drivers';
  final location = TextEditingController();

  @override
  void dispose() {
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections = widget.requests.where((request) {
      final requestStatus = _monitoringStatus(request);
      final matchesStatus = status == 'All' || requestStatus == status;
      final matchesDriver = driver == 'All drivers' ||
          _driverFor(request)?.name == driver;
      final matchesLocation = location.text.trim().isEmpty ||
          request.location.toLowerCase().contains(
            location.text.trim().toLowerCase(),
          );
      final matchesDate = _matchesDate(request.createdAt);
      return request.type == 'Collection' &&
          matchesStatus &&
          matchesDriver &&
          matchesLocation &&
          matchesDate;
    }).toList();
    final allCollections = widget.requests
        .where((request) => request.type == 'Collection')
        .toList();
    final counts = <String, int>{
      for (final value in const [
        'Pending',
        'Approved',
        'Assigned',
        'Ongoing',
        'Completed',
        'Failed',
        'Delayed',
      ])
        value: allCollections
            .where((request) => _monitoringStatus(request) == value)
            .length,
    };
    final collectionPoints = collections.asMap().entries.map((entry) {
      final index = entry.key;
      final request = entry.value;
      return MapLocationPoint(
        label: request.location,
        subtitle: '${request.id} · ${_monitoringStatus(request)}',
        latitude: 12.9716 + (index % 5) * 0.006,
        longitude: 77.5946 + (index % 5) * 0.006,
        icon: Icons.local_shipping,
        color: Colors.blue,
      );
    }).toList()
      ..addAll(widget.drivers.asMap().entries.map((entry) => MapLocationPoint(
        label: entry.value.name,
        subtitle: '${entry.value.availability} · ${entry.value.vehicleRegistration}',
        latitude: 12.9716 + (entry.key % 5) * 0.006,
        longitude: 77.5946 + (entry.key % 5) * 0.006,
        icon: Icons.local_shipping,
        color: Colors.blue,
      )));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Garbage collection monitoring',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Track collection requests, drivers, locations, delays, and history.',
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _monitorMetric('All requests', '${allCollections.length}', Icons.list_alt),
            _monitorMetric('Pending', '${counts['Pending']}', Icons.pending_actions),
            _monitorMetric('Assigned', '${counts['Assigned']}', Icons.assignment_ind_outlined),
            _monitorMetric('Ongoing', '${counts['Ongoing']}', Icons.local_shipping_outlined),
            _monitorMetric('Completed', '${counts['Completed']}', Icons.task_alt),
            _monitorMetric('Delayed', '${counts['Delayed']}', Icons.warning_amber_outlined),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: location,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Filter by location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
                _filter(
                  'Status',
                  status,
                  ['All', 'Pending', 'Approved', 'Assigned', 'Ongoing', 'Completed', 'Failed', 'Delayed'],
                  (value) => setState(() => status = value),
                ),
                _filter(
                  'Date',
                  dateRange,
                  ['All dates', 'Today', 'This week', 'This month'],
                  (value) => setState(() => dateRange = value),
                ),
                _filter(
                  'Driver',
                  driver,
                  ['All drivers', ...widget.drivers.map((item) => item.name)],
                  (value) => setState(() => driver = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.map_outlined)),
            title: const Text('Collection locations map'),
            subtitle: Text(
              '${collections.length} filtered collection location(s) ready to display on a map.',
            ),
            trailing: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => OperationsMapScreen(
                  title: 'Collection locations',
                  points: collectionPoints,
                ),
              )),
              child: const Text('Open map'),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '${collections.length} collection(s)',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (collections.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.search_off_outlined),
              title: Text('No collections match the selected filters'),
            ),
          )
        else
          ...collections.map((request) => _collectionCard(context, request)),
        const SizedBox(height: 18),
        Text(
          'Area-wise collection activity',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._areaSummary(allCollections),
      ],
    );
  }

  Widget _monitorMetric(String title, String value, IconData icon) {
    return SizedBox(
      width: 150,
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(icon, size: 22),
          title: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(title),
        ),
      ),
    );
  }

  Widget _filter(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: values
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (item) => onChanged(item ?? value),
      ),
    );
  }

  Widget _collectionCard(BuildContext context, RequestRecord request) {
    final assignedDriver = _driverFor(request);
    final currentStatus = _monitoringStatus(request);
    final delayed = currentStatus == 'Delayed';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          foregroundColor: delayed ? Colors.red : null,
          child: Icon(delayed ? Icons.warning_amber : Icons.recycling),
        ),
        title: Text('${request.id} · ${request.title}'),
        subtitle: Text(
          '${request.location} · ${_formatDate(request.createdAt)}\n'
          'Driver: ${assignedDriver?.name ?? 'Unassigned'} · '
          '${assignedDriver?.vehicleRegistration ?? 'No vehicle'}\n'
          'Status: $currentStatus · Priority: ${request.priority}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'history') _showHistory(context, request);
            if (action == 'details') _showCollectionDetails(context, request);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'details', child: Text('View details')),
            PopupMenuItem(value: 'history', child: Text('View collection history')),
          ],
        ),
      ),
    );
  }

  List<Widget> _areaSummary(List<RequestRecord> requests) {
    final areas = <String, int>{};
    for (final request in requests) {
      areas[request.location] = (areas[request.location] ?? 0) + 1;
    }
    return areas.entries
        .map(
          (entry) => Card(
            child: ListTile(
              leading: const Icon(Icons.location_city_outlined),
              title: Text(entry.key),
              trailing: Text('${entry.value} collection(s)'),
            ),
          ),
        )
        .toList();
  }

  DriverRecord? _driverFor(RequestRecord request) {
    if (request.assignedDriver != null) {
      for (final driver in widget.drivers) {
        if (driver.id == request.assignedDriver) return driver;
      }
    }
    return null;
  }

  String _monitoringStatus(RequestRecord request) {
    if (request.status == 'Resolved') return 'Completed';
    if (request.status == 'Approved' && request.assignedDriver != null) {
      return 'Assigned';
    }
    if (request.status == 'Approved') return 'Approved';
    if (request.status == 'In Progress') return 'Ongoing';
    if (DateTime.now().difference(request.createdAt).inDays >= 3) {
      return 'Delayed';
    }
    return 'Pending';
  }

  bool _matchesDate(DateTime date) {
    final now = DateTime.now();
    if (dateRange == 'Today') {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    }
    if (dateRange == 'This week') {
      return now.difference(date).inDays < 7 && !date.isAfter(now);
    }
    if (dateRange == 'This month') {
      return date.year == now.year && date.month == now.month;
    }
    return true;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _showCollectionDetails(BuildContext context, RequestRecord request) {
    final driver = _driverFor(request);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${request.id} · Collection details'),
        content: Text(
          'Customer: ${request.customer}\n'
          'Location: ${request.location}\n'
          'Created: ${_formatDate(request.createdAt)}\n'
          'Status: ${_monitoringStatus(request)}\n'
          'Driver: ${driver?.name ?? 'Unassigned'}\n'
          'Vehicle: ${driver?.vehicleRegistration ?? 'Not assigned'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context, RequestRecord request) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${request.id} · Collection history'),
        content: const Text(
          'Request submitted → reviewed → scheduled → driver status updates '
          '→ collection completion. Detailed event history will be connected '
          'to the backend.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class AdminBinManagementScreen extends StatefulWidget {
  const AdminBinManagementScreen({super.key, required this.bins});

  final List<GarbageBinRecord> bins;

  @override
  State<AdminBinManagementScreen> createState() =>
      _AdminBinManagementScreenState();
}

class _AdminBinManagementScreenState extends State<AdminBinManagementScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final visible = widget.bins.where((bin) {
      if (filter == 'Nearly full') return bin.fillLevel >= 75 && bin.fillLevel < 90;
      if (filter == 'Overflowing') return bin.fillLevel >= 90;
      if (filter == 'Damaged') return bin.isDamaged;
      return true;
    }).toList();
    final nearlyFull = widget.bins.where((bin) => bin.fillLevel >= 75).length;
    final overflowing = widget.bins.where((bin) => bin.fillLevel >= 90).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Garbage bin management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _editBin(),
              icon: const Icon(Icons.add),
              label: const Text('Add bin'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage bin inventory, GPS locations, fill levels, collections, and maintenance.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _summary('Registered bins', '${widget.bins.length}', Icons.delete_outline),
            _summary('Nearly full', '$nearlyFull', Icons.warning_amber_outlined),
            _summary('Overflowing', '$overflowing', Icons.error_outline),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.map_outlined)),
            title: const Text('Garbage bin locations map'),
            subtitle: Text(
              '${widget.bins.length} GPS-enabled location(s) available for mapping.',
            ),
            trailing: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => OperationsMapScreen(
                  title: 'Garbage bin locations',
                  points: widget.bins.asMap().entries.map((entry) => MapLocationPoint(
                    label: entry.value.id,
                    subtitle: '${entry.value.type} · ${entry.value.fillLevel}% full',
                    latitude: 12.9716 + (entry.key % 5) * 0.006,
                    longitude: 77.5946 + (entry.key % 5) * 0.006,
                    icon: Icons.delete_outline,
                    color: Colors.green,
                  )).toList(),
                  showCurrentLocation: false,
                ),
              )),
              child: const Text('Open map'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: filter,
          decoration: const InputDecoration(labelText: 'Filter bins'),
          items: const ['All', 'Nearly full', 'Overflowing', 'Damaged']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) => setState(() => filter = value ?? filter),
        ),
        const SizedBox(height: 12),
        ...visible.map(
          (bin) => Card(
            child: ListTile(
              leading: CircleAvatar(
                foregroundColor: _fillColor(bin.fillLevel),
                child: Icon(bin.isDamaged ? Icons.warning_amber : Icons.delete_outline),
              ),
              title: Text('${bin.id} · ${bin.type}'),
              subtitle: Text(
                '${bin.location}\n'
                'Fill level: ${bin.fillLevel}% · Capacity: ${bin.capacity}\n'
                'Last collection: ${_formatDate(bin.lastCollection)} · '
                '${bin.condition}\n'
                'GPS: ${bin.gpsCoordinates.isEmpty ? 'Not assigned' : bin.gpsCoordinates}',
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') _editBin(bin);
                  if (action == 'history') _showHistory(bin);
                  if (action == 'delete') _deleteBin(bin);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit bin')),
                  PopupMenuItem(value: 'history', child: Text('Maintenance history')),
                  PopupMenuItem(value: 'delete', child: Text('Delete bin')),
                ],
              ),
              onTap: () => _editBin(bin),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summary(String title, String value, IconData icon) => SizedBox(
    width: 170,
    child: Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(title),
      ),
    ),
  );

  Color _fillColor(int value) =>
      value >= 90 ? Colors.red : value >= 75 ? Colors.orange : Colors.green;

  String _formatDate(DateTime value) => '${value.day}/${value.month}/${value.year}';

  Future<void> _editBin([GarbageBinRecord? bin]) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _AdminBinEditorDialog(
        bin: bin,
        nextId: 'BIN-${1001 + widget.bins.length}',
        onSave: (updated) => setState(() {
          if (bin == null) {
            widget.bins.add(updated);
          } else {
            bin.location = updated.location;
            bin.type = updated.type;
            bin.capacity = updated.capacity;
            bin.condition = updated.condition;
            bin.fillLevel = updated.fillLevel;
            bin.gpsCoordinates = updated.gpsCoordinates;
            bin.requiresCollection = updated.requiresCollection;
            bin.isDamaged = updated.isDamaged;
            bin.maintenanceHistory = updated.maintenanceHistory;
          }
        }),
      ),
    );
  }

  void _deleteBin(GarbageBinRecord bin) {
    setState(() => widget.bins.remove(bin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${bin.id} was removed from the inventory.')),
    );
  }

  void _showHistory(GarbageBinRecord bin) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${bin.id} maintenance history'),
        content: Text(
          bin.maintenanceHistory.isEmpty
              ? 'No maintenance history recorded.'
              : bin.maintenanceHistory.map((item) => '• $item').join('\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AdminBinEditorDialog extends StatefulWidget {
  const _AdminBinEditorDialog({
    required this.bin,
    required this.nextId,
    required this.onSave,
  });

  final GarbageBinRecord? bin;
  final String nextId;
  final ValueChanged<GarbageBinRecord> onSave;

  @override
  State<_AdminBinEditorDialog> createState() => _AdminBinEditorDialogState();
}

class _AdminBinEditorDialogState extends State<_AdminBinEditorDialog> {
  late final TextEditingController location;
  late final TextEditingController capacity;
  late final TextEditingController gps;
  late String type;
  late String condition;
  late int fillLevel;
  late bool damaged;

  @override
  void initState() {
    super.initState();
    final bin = widget.bin;
    location = TextEditingController(text: bin?.location);
    capacity = TextEditingController(text: bin?.capacity);
    gps = TextEditingController(text: bin?.gpsCoordinates);
    type = bin?.type ?? 'Dry waste';
    condition = bin?.condition ?? 'Good';
    fillLevel = bin?.fillLevel ?? 50;
    damaged = bin?.isDamaged ?? false;
  }

  @override
  void dispose() {
    location.dispose();
    capacity.dispose();
    gps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bin == null ? 'Add garbage bin' : 'Edit garbage bin'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Unique bin ID: ${widget.bin?.id ?? widget.nextId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: location,
              decoration: const InputDecoration(labelText: 'Bin location'),
            ),
            TextField(
              controller: gps,
              decoration: const InputDecoration(
                labelText: 'GPS coordinates',
                hintText: '12.9716, 77.5946',
              ),
            ),
            TextField(
              controller: capacity,
              decoration: const InputDecoration(labelText: 'Capacity'),
            ),
            DropdownButtonFormField<String>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Bin type'),
              items: const ['Wet Waste', 'Dry Waste', 'Mixed waste']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => type = value ?? type),
            ),
            DropdownButtonFormField<String>(
              initialValue: condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: const ['Good', 'Needs Maintenance', 'Damaged']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => condition = value ?? condition),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Fill level'),
                Expanded(
                  child: Slider(
                    value: fillLevel.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '$fillLevel%',
                    onChanged: (value) => setState(() => fillLevel = value.round()),
                  ),
                ),
                Text('$fillLevel%'),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: damaged,
              title: const Text('Mark as damaged'),
              onChanged: (value) => setState(() => damaged = value ?? damaged),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final updated = GarbageBinRecord(
              id: widget.bin?.id ?? widget.nextId,
              location: location.text.trim(),
              type: type,
              capacity: capacity.text.trim(),
              condition: condition,
              lastCollection: widget.bin?.lastCollection ?? DateTime.now(),
              collectionHistory: widget.bin?.collectionHistory ?? [],
              requiresCollection: fillLevel >= 75,
              isDamaged: damaged,
              fillLevel: fillLevel,
              gpsCoordinates: gps.text.trim(),
              maintenanceHistory: [
                ...?widget.bin?.maintenanceHistory,
                if (damaged || condition != 'Good') 'Condition reviewed by Admin · Today',
              ],
            );
            widget.onSave(updated);
            Navigator.pop(context);
          },
          child: const Text('Save bin'),
        ),
      ],
    );
  }
}

class ComplaintManagementScreen extends StatefulWidget {
  const ComplaintManagementScreen({
    super.key,
    required this.requests,
    required this.reports,
    required this.managers,
  });

  final List<RequestRecord> requests;
  final List<WasteReport> reports;
  final List<ManagerAccount> managers;

  @override
  State<ComplaintManagementScreen> createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState
    extends State<ComplaintManagementScreen> {
  String status = 'All';
  String priority = 'All';

  @override
  Widget build(BuildContext context) {
    final complaints = widget.requests
        .where((request) => request.type == 'Complaint')
        .where(
          (request) =>
              (status == 'All' || _status(request) == status) &&
              (priority == 'All' || request.priority == priority),
        )
        .toList();
    final allComplaints = widget.requests
        .where((request) => request.type == 'Complaint')
        .toList();
    final unresolved = allComplaints
        .where((request) => _status(request) != 'Resolved')
        .length;
    final areas = <String, int>{};
    for (final complaint in allComplaints) {
      areas[complaint.location] = (areas[complaint.location] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Complaint management',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Review customer complaints, locations, evidence, escalation, and resolution progress.',
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _summary('Total complaints', '${allComplaints.length}', Icons.report_problem_outlined),
            _summary('Unresolved', '$unresolved', Icons.pending_actions_outlined),
            _summary('High priority', '${allComplaints.where((item) => item.priority == 'High').length}', Icons.priority_high),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _filter(
              'Status',
              status,
              ['All', 'Under Review', 'Resolved', 'Escalated'],
              (value) => setState(() => status = value),
            ),
            _filter(
              'Priority',
              priority,
              ['All', 'High', 'Medium', 'Low'],
              (value) => setState(() => priority = value),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '${complaints.length} complaint(s)',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (complaints.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.search_off_outlined),
              title: Text('No complaints match the selected filters'),
            ),
          )
        else
          ...complaints.map((complaint) => _complaintCard(complaint)),
        const SizedBox(height: 18),
        Text(
          'Frequently reported areas',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...areas.entries.map(
          (entry) => Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(entry.key),
              trailing: Text('${entry.value} report(s)'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summary(String title, String value, IconData icon) => SizedBox(
    width: 170,
    child: Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(title),
      ),
    ),
  );

  Widget _filter(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (item) => onChanged(item ?? value),
    ),
  );

  Widget _complaintCard(RequestRecord complaint) {
    final complaintStatus = _status(complaint);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          foregroundColor: complaintStatus == 'Resolved' ? Colors.green : Colors.orange,
          child: Icon(
            complaint.photoName == null
                ? Icons.report_problem_outlined
                : Icons.photo_camera_outlined,
          ),
        ),
        title: Text('${complaint.id} · ${complaint.title}'),
        subtitle: Text(
          'Customer: ${complaint.customer}\n'
          'Location: ${complaint.location}\n'
          'Reported: ${_formatDateTime(complaint.createdAt)} · '
          'Priority: ${complaint.priority} · Status: $complaintStatus\n'
          'Manager: ${complaint.assignedManager ?? 'Unassigned'}'
          '${complaint.photoName == null ? '' : '\nPhoto: ${complaint.photoName}'}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'assign') _assignManager(complaint);
            if (action == 'resolve') _resolve(complaint);
            if (action == 'history') _showHistory(complaint);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'assign', child: Text('Assign / escalate')),
            PopupMenuItem(value: 'resolve', child: Text('Mark resolved')),
            PopupMenuItem(value: 'history', child: Text('View history')),
          ],
        ),
      ),
    );
  }

  String _status(RequestRecord complaint) =>
      complaint.forwardedForReview ? 'Escalated' : complaint.status;

  String _formatDateTime(DateTime value) =>
      '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _assignManager(RequestRecord complaint) async {
    final manager = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Assign or escalate complaint'),
        children: [
          ...widget.managers.map(
            (item) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item.name),
              child: Text(item.name),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Escalated for review'),
            child: const Text('Escalate for review'),
          ),
        ],
      ),
    );
    if (manager == null) return;
    setState(() {
      complaint.assignedManager = manager;
      complaint.forwardedForReview = manager == 'Escalated for review';
      complaint.resolutionHistory = [
        ...complaint.resolutionHistory,
        'Assigned to $manager · Today',
      ];
    });
  }

  void _resolve(RequestRecord complaint) {
    setState(() {
      complaint.status = 'Resolved';
      complaint.forwardedForReview = false;
      complaint.resolutionHistory = [
        ...complaint.resolutionHistory,
        'Complaint marked resolved by Admin · Today',
      ];
    });
  }

  void _showHistory(RequestRecord complaint) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${complaint.id} complaint history'),
        content: Text(
          complaint.resolutionHistory.isEmpty
              ? 'No resolution history recorded.'
              : complaint.resolutionHistory.map((item) => '• $item').join('\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class AdminReportsAnalyticsScreen extends StatefulWidget {
  const AdminReportsAnalyticsScreen({
    super.key,
    required this.requests,
    required this.reports,
    required this.drivers,
    required this.managers,
  });

  final List<RequestRecord> requests;
  final List<WasteReport> reports;
  final List<DriverRecord> drivers;
  final List<ManagerAccount> managers;

  @override
  State<AdminReportsAnalyticsScreen> createState() =>
      _AdminReportsAnalyticsScreenState();
}

class _AdminReportsAnalyticsScreenState
    extends State<AdminReportsAnalyticsScreen> {
  String period = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final collections = widget.requests
        .where((request) => request.type == 'Collection')
        .toList();
    final completed = collections
        .where((request) => request.status == 'Resolved')
        .length;
    final pending = collections.length - completed;
    final categoryTotals = <String, double>{
      'Wet waste': 420,
      'Dry waste': 310,
      'Recyclables': 185,
      'Mixed waste': 125,
    };
    final areaTotals = <String, int>{};
    for (final request in collections) {
      areaTotals[request.location] = (areaTotals[request.location] ?? 0) + 1;
    }
    final complaintCount = widget.requests
        .where((request) => request.type == 'Complaint')
        .length;
    final reportCount = widget.reports.length;
    final totalCollected = period == 'Daily'
        ? 186
        : period == 'Weekly'
        ? 1284
        : 5040;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reports & analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value export is ready to connect.')),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'PDF', child: Text('Export PDF')),
                PopupMenuItem(value: 'Excel', child: Text('Export Excel')),
              ],
              child: FilledButton.icon(
                onPressed: null,
                icon: Icon(Icons.file_download_outlined),
                label: Text('Export'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Analyse collection volume, service performance, complaints, and operations.',
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: period,
          decoration: const InputDecoration(
            labelText: 'Report period',
            prefixIcon: Icon(Icons.date_range_outlined),
          ),
          items: const ['Daily', 'Weekly', 'Monthly']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) => setState(() => period = value ?? period),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _metric('Total garbage collected', '$totalCollected kg', Icons.scale_outlined),
            _metric('Completed collections', '$completed', Icons.task_alt),
            _metric('Pending collections', '$pending', Icons.pending_actions),
            _metric('Customer complaints', '${complaintCount + reportCount}', Icons.report_problem_outlined),
          ],
        ),
        const SizedBox(height: 18),
        _sectionCard(
          context,
          'Waste collected by category',
          _barChart(categoryTotals),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          'Collection trend',
          _lineChart(period == 'Daily' ? [18, 24, 21, 32, 29, 38, 42] : [42, 56, 48, 71, 65, 82, 94]),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          'Pending vs completed collections',
          _pieChart(completed, pending),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          'Area-wise collection statistics',
          Column(
            children: areaTotals.entries
                .map(
                  (entry) => ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(entry.key),
                    trailing: Text('${entry.value} collections'),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          'Driver performance',
          Column(
            children: widget.drivers
                .map(
                  (driver) => ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(driver.name),
                    subtitle: Text(
                      '${driver.assignedJobs} pending · ${driver.completedCollections} completed',
                    ),
                    trailing: Text(
                      '${driver.completedCollections + driver.assignedJobs == 0 ? 0 : (driver.completedCollections / (driver.completedCollections + driver.assignedJobs) * 100).round()}%',
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          context,
          'Manager performance',
          Column(
            children: widget.managers
                .map(
                  (manager) => ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: Text(manager.name),
                    subtitle: Text('${manager.zone} · Activity records: ${manager.activityHistory.length}'),
                    trailing: const Icon(Icons.trending_up),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _metric(String title, String value, IconData icon) => SizedBox(
    width: 190,
    child: Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(title),
      ),
    ),
  );

  Widget _sectionCard(BuildContext context, String title, Widget content) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              content,
            ],
          ),
        ),
      );

  Widget _barChart(Map<String, double> values) {
    final maximum = values.values.reduce((a, b) => a > b ? a : b);
    return Column(
      children: values.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(width: 105, child: Text(entry.key)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / maximum,
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value.round()} kg'),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _lineChart(List<int> values) => SizedBox(
    height: 150,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values
          .map(
            (value) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$value'),
                const SizedBox(height: 4),
                Container(
                  width: 22,
                  height: value.toDouble() * 2.2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF17834B),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    ),
  );

  Widget _pieChart(int completed, int pending) {
    final total = completed + pending;
    final completedRatio = total == 0 ? 0.0 : completed / total;
    return Column(
      children: [
        SizedBox(
          height: 130,
          width: 130,
          child: CircularProgressIndicator(
            value: completedRatio,
            strokeWidth: 24,
            backgroundColor: Colors.orange.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 10),
        Text('Completed $completed · Pending $pending'),
      ],
    );
  }
}

class AdminProfileSettingsScreen extends StatefulWidget {
  const AdminProfileSettingsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.onProfileChanged,
    required this.onPasswordChanged,
    required this.onSignOut,
  });

  final String name;
  final String email;
  final String phone;
  final ValueChanged<(String, String, String)> onProfileChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSignOut;

  @override
  State<AdminProfileSettingsScreen> createState() =>
      _AdminProfileSettingsScreenState();
}

class _AdminProfileSettingsScreenState
    extends State<AdminProfileSettingsScreen> {
  late String name;
  late String email;
  late String phone;
  Uint8List? profileImage;
  bool emailAlerts = true;
  bool complaintAlerts = true;
  bool collectionAlerts = true;
  bool requireDriverApproval = true;
  String priority = 'High';
  final categories = ['Wet Waste', 'Dry Waste', 'Recyclables', 'Mixed Waste'];

  @override
  void initState() {
    super.initState();
    name = widget.name;
    email = widget.email;
    phone = widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Admin profile & settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: profileImage == null
                        ? null
                        : MemoryImage(profileImage!),
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 36)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleLarge),
                      Text('Admin ID: ADM-1001'),
                      Text(email),
                      Text(phone),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _editProfile,
                  child: const Text('Edit profile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _settingsCard(
          context,
          'Access and permissions',
          [
            const ListTile(
              leading: Icon(Icons.security_outlined),
              title: Text('User roles and permissions'),
              subtitle: Text('Admin can manage customers, drivers, managers, complaints, and operations.'),
            ),
            SwitchListTile(
              title: const Text('Require driver approval'),
              subtitle: const Text('New driver accounts require admin review.'),
              value: requireDriverApproval,
              onChanged: (value) => setState(() => requireDriverApproval = value),
            ),
          ],
        ),
        _settingsCard(
          context,
          'Waste categories',
          [
            Wrap(
              spacing: 8,
              children: categories
                  .map((item) => Chip(label: Text(item)))
                  .toList(),
            ),
            TextButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add),
              label: const Text('Add category'),
            ),
          ],
        ),
        _settingsCard(
          context,
          'Collection priorities and rules',
          [
            DropdownButtonFormField<String>(
              initialValue: priority,
              decoration: const InputDecoration(labelText: 'Default collection priority'),
              items: const ['High', 'Medium', 'Low']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => priority = value ?? priority),
            ),
            const ListTile(
              leading: Icon(Icons.rule_outlined),
              title: Text('System-wide collection rules'),
              subtitle: Text('Prevent duplicate assignments and flag delayed collections after 3 days.'),
            ),
          ],
        ),
        _settingsCard(
          context,
          'Notification settings',
          [
            SwitchListTile(
              title: const Text('Email notifications'),
              value: emailAlerts,
              onChanged: (value) => setState(() => emailAlerts = value),
            ),
            SwitchListTile(
              title: const Text('Complaint alerts'),
              value: complaintAlerts,
              onChanged: (value) => setState(() => complaintAlerts = value),
            ),
            SwitchListTile(
              title: const Text('Collection alerts'),
              value: collectionAlerts,
              onChanged: (value) => setState(() => collectionAlerts = value),
            ),
          ],
        ),
        _settingsCard(
          context,
          'Security and activity',
          [
            ListTile(
              leading: const Icon(Icons.password_outlined),
              title: const Text('Change password'),
              onTap: _changePassword,
            ),
            const ListTile(
              leading: Icon(Icons.login_outlined),
              title: Text('Admin login history'),
              subtitle: Text('Today · Successful login · Admin portal\nYesterday · Successful login · Admin portal'),
            ),
            const ListTile(
              leading: Icon(Icons.history_outlined),
              title: Text('System activity logs'),
              subtitle: Text('Manager account created · Complaint reviewed · Bin inventory updated'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: widget.onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _settingsCard(BuildContext context, String title, List<Widget> children) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );

  Future<void> _pickProfileImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null && mounted) {
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => profileImage = bytes);
    }
  }

  Future<void> _editProfile() async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => _AdminProfileEditor(
        name: name,
        email: email,
        phone: phone,
      ),
    );
    if (values == null) return;
    setState(() {
      name = values[0];
      email = values[1];
      phone = values[2];
    });
    widget.onProfileChanged((name, email, phone));
  }

  Future<void> _changePassword() async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _AdminPasswordDialog(),
    );
    if (password == null) return;
    widget.onPasswordChanged(password);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin password updated successfully.')),
      );
    }
  }

  void _addCategory() {
    setState(() => categories.add('New category'));
  }
}

class _AdminProfileEditor extends StatefulWidget {
  const _AdminProfileEditor({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

  @override
  State<_AdminProfileEditor> createState() => _AdminProfileEditorState();
}

class _AdminProfileEditorState extends State<_AdminProfileEditor> {
  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController phone;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.name);
    email = TextEditingController(text: widget.email);
    phone = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit admin profile'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Admin name')),
        TextField(controller: email, decoration: const InputDecoration(labelText: 'Email address')),
        TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone number')),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(
        onPressed: () => Navigator.pop(context, [
          name.text.trim(),
          email.text.trim(),
          phone.text.trim(),
        ]),
        child: const Text('Save'),
      ),
    ],
  );
}

class _AdminPasswordDialog extends StatefulWidget {
  const _AdminPasswordDialog();

  @override
  State<_AdminPasswordDialog> createState() => _AdminPasswordDialogState();
}

class _AdminPasswordDialogState extends State<_AdminPasswordDialog> {
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Change admin password'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
        TextField(controller: confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(
        onPressed: () {
          if (password.text.length < 8 || password.text != confirm.text) return;
          Navigator.pop(context, password.text);
        },
        child: const Text('Update password'),
      ),
    ],
  );
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({
    super.key,
    required this.customers,
    required this.drivers,
    required this.accounts,
    required this.onCreateManagerAccount,
    required this.onUpdateManagerAccount,
  });

  final List<CustomerRecord> customers;
  final List<DriverRecord> drivers;
  final List<ManagerAccount> accounts;
  final VoidCallback onCreateManagerAccount;
  final ValueChanged<ManagerAccount> onUpdateManagerAccount;

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final search = TextEditingController();
  String role = 'All';
  String status = 'All';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = <_AdminUser>[
      ...widget.customers.map(
        (user) => _AdminUser(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: 'Customer',
          isActive: user.isActive,
          registeredAt: user.registeredAt,
          activity: user.activityHistory.isEmpty
              ? ['Collection requests: ${user.collections.length}']
              : user.activityHistory,
          onToggle: () => setState(() => user.isActive = !user.isActive),
          onEdit: () => _editCustomer(user),
        ),
      ),
      ...widget.drivers.map(
        (user) => _AdminUser(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: 'Driver',
          isActive: user.isActive,
          registeredAt: user.registeredAt,
          metadata:
              'Vehicle: ${user.vehicleRegistration} · ${user.availability} · '
              'Assigned: ${user.assignedJobs} · Completed: ${user.completedCollections}',
          activity: user.activityHistory.isEmpty
              ? [
                  'Vehicle: ${user.vehicleRegistration}',
                  'Availability: ${user.availability}',
                  'Assigned tasks: ${user.assignedJobs}',
                  'Completed collections: ${user.completedCollections}',
                ]
              : user.activityHistory,
          onToggle: () => setState(() => user.isActive = !user.isActive),
          onEdit: () => _editDriver(user),
        ),
      ),
      ...widget.accounts.map(
        (user) {
          final managerIndex = widget.accounts.indexOf(user);
          final managedDrivers = widget.drivers
              .asMap()
              .entries
              .where(
                (entry) =>
                    entry.key % widget.accounts.length == managerIndex,
              )
              .map((entry) => entry.value)
              .toList();
          final completed = managedDrivers.fold<int>(
            0,
            (total, driver) => total + driver.completedCollections,
          );
          final assigned = managedDrivers.fold<int>(
            0,
            (total, driver) => total + driver.assignedJobs,
          );
          final performance = completed + assigned == 0
              ? 0
              : (completed / (completed + assigned) * 100).round();
          return _AdminUser(
          id: user.managerId,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: 'Manager',
          isActive: user.isActive,
          registeredAt: user.registeredAt,
          metadata:
              'Zone: ${user.zone} · Drivers managed: ${managedDrivers.length} · '
              'Collection performance: $performance%',
          activity: [
            ...user.activityHistory,
            'Area: ${user.zone}',
            'Drivers managed: ${managedDrivers.length}',
            'Collection performance: $performance%',
          ],
          onToggle: () => setState(() => user.isActive = !user.isActive),
          onEdit: () => _editManager(user),
          );
        },
      ),
    ];
    final filtered = users.where((user) {
      final query = search.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          [user.id, user.name, user.email, user.phone]
              .any((value) => value.toLowerCase().contains(query));
      final matchesRole = role == 'All' || user.role == role;
      final matchesStatus = status == 'All' ||
          (status == 'Active' ? user.isActive : !user.isActive);
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Manage registered users',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'manager') {
                  widget.onCreateManagerAccount();
                } else {
                  _addBasicUser(value);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'customer', child: Text('Add customer')),
                PopupMenuItem(value: 'driver', child: Text('Add driver')),
                PopupMenuItem(value: 'manager', child: Text('Add manager')),
              ],
              child: FilledButton.icon(
                onPressed: null,
                icon: Icon(Icons.person_add_alt_1),
                label: Text('Add user'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Search, filter, activate, edit, and review activity for every account.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Search by name, email, phone, or user ID',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const ['All', 'Customer', 'Driver', 'Manager']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => role = value ?? role),
              ),
            ),
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['All', 'Active', 'Inactive']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => status = value ?? status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('${filtered.length} user(s) found'),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.person_search_outlined),
              title: Text('No users match these filters'),
            ),
          )
        else
          ...filtered.map(
            (user) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(_roleIcon(user.role))),
                title: Text(user.name),
                subtitle: Text(
                  '${user.role} · ${user.email}\n'
                  '${user.phone.isEmpty ? 'No phone number' : user.phone} · '
                  'Registered ${_formatRegistrationDate(user.registeredAt)}'
                  '${user.metadata.isEmpty ? '' : '\n${user.metadata}'}',
                ),
                isThreeLine: user.metadata.isNotEmpty,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'details') _showDetails(user);
                    if (action == 'edit') user.onEdit();
                    if (action == 'toggle') {
                      user.onToggle();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Text('View details'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('Edit user')),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _roleIcon(String value) => switch (value) {
    'Driver' => Icons.local_shipping_outlined,
    'Manager' => Icons.manage_accounts_outlined,
    _ => Icons.person_outline,
  };

  String _formatRegistrationDate(DateTime? date) =>
      date == null ? 'Demo record' : '${date.day}/${date.month}/${date.year}';

  Future<void> _addBasicUser(String userRole) async {
    if (userRole == 'customer') {
      final values = await showDialog<List<String>>(
        context: context,
        builder: (_) => const _BasicUserDialog(role: 'customer'),
      );
      if (values == null) return;
      widget.customers.add(
        CustomerRecord(
          id: 'CUS-${1001 + widget.customers.length}',
          name: values[0],
          phone: values[2],
          email: values[1],
          addresses: const [],
          complaints: const [],
          collections: const [],
          registeredAt: DateTime.now(),
          activityHistory: ['Account created by Admin · Today'],
        ),
      );
    } else if (userRole == 'driver') {
      await showDialog<void>(
        context: context,
        builder: (_) => _DriverEditorDialog(
          driver: null,
          nextId: 'DRV-${1001 + widget.drivers.length}',
          onSave: (driver) {
            driver.activityHistory = ['Account created by Admin · Today'];
            widget.drivers.add(driver);
          },
        ),
      );
    }
    setState(() {});
  }

  Future<void> _editCustomer(CustomerRecord user) async {
    final values = await _editUser(user.name, user.email, user.phone);
    if (values == null) return;
    setState(() {
      user.name = values[0];
      user.email = values[1];
      user.phone = values[2];
    });
  }

  Future<void> _editDriver(DriverRecord user) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DriverEditorDialog(
        driver: user,
        nextId: user.id,
        onSave: (updated) {
          setState(() {
            user.name = updated.name;
            user.email = updated.email;
            user.phone = updated.phone;
            user.employeeId = updated.employeeId;
            user.vehicleRegistration = updated.vehicleRegistration;
            user.availability = updated.availability;
            user.activityHistory = [
              ...user.activityHistory,
              'Driver profile edited by Admin · Today',
            ];
          });
        },
      ),
    );
  }

  Future<void> _editManager(ManagerAccount user) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => _ManagerEditorDialog(
        manager: user,
      ),
    );
    if (values == null) return;
    widget.onUpdateManagerAccount(
      ManagerAccount(
        managerId: user.managerId,
        name: values[0],
        email: values[1],
        password: user.password,
        phone: values[2],
        zone: values[3],
        isActive: user.isActive,
        registeredAt: user.registeredAt,
        activityHistory: [
          ...user.activityHistory,
          'Profile edited by Admin · Today',
        ],
      ),
    );
    setState(() {});
  }

  Future<List<String>?> _editUser(
    String name,
    String email,
    String phone,
  ) => showDialog<List<String>>(
    context: context,
    builder: (_) => _BasicUserDialog(
      role: 'Edit',
      initialValues: [name, email, phone],
    ),
  );

  void _showDetails(_AdminUser user) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${user.id}'),
            Text('Role: ${user.role}'),
            Text('Email: ${user.email}'),
            Text('Phone: ${user.phone.isEmpty ? 'Not provided' : user.phone}'),
            Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
            Text('Registered: ${_formatRegistrationDate(user.registeredAt)}'),
            const SizedBox(height: 12),
            const Text(
              'Activity history',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...user.activity.map((item) => Text('• $item')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AdminUser {
  const _AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.registeredAt,
    this.metadata = '',
    required this.activity,
    required this.onToggle,
    required this.onEdit,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime? registeredAt;
  final String metadata;
  final List<String> activity;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
}

class _ManagerEditorDialog extends StatefulWidget {
  const _ManagerEditorDialog({required this.manager});

  final ManagerAccount manager;

  @override
  State<_ManagerEditorDialog> createState() => _ManagerEditorDialogState();
}

class _ManagerEditorDialogState extends State<_ManagerEditorDialog> {
  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController phone;
  late String zone;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.manager.name);
    email = TextEditingController(text: widget.manager.email);
    phone = TextEditingController(text: widget.manager.phone);
    zone = widget.manager.zone;
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit manager · ${widget.manager.managerId}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Manager name'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
            DropdownButtonFormField<String>(
              initialValue: zone,
              decoration: const InputDecoration(labelText: 'Assigned area / zone'),
              items: const [
                'Central Market',
                'Lake Road',
                'Green Park',
                'North Zone',
                'Unassigned',
              ]
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => zone = value ?? zone),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (name.text.trim().isEmpty || email.text.trim().isEmpty) return;
            Navigator.pop(context, [
              name.text.trim(),
              email.text.trim(),
              phone.text.trim(),
              zone,
            ]);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _BasicUserDialog extends StatefulWidget {
  const _BasicUserDialog({
    required this.role,
    this.initialValues = const ['', '', ''],
  });

  final String role;
  final List<String> initialValues;

  @override
  State<_BasicUserDialog> createState() => _BasicUserDialogState();
}

class _BasicUserDialogState extends State<_BasicUserDialog> {
  late final TextEditingController name;
  late final TextEditingController email;
  late final TextEditingController phone;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initialValues[0]);
    email = TextEditingController(text: widget.initialValues[1]);
    phone = TextEditingController(text: widget.initialValues[2]);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.role == 'Edit' ? 'Edit' : 'Add'} ${widget.role == 'Edit' ? 'user' : widget.role}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email address'),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (name.text.trim().isEmpty || email.text.trim().isEmpty) return;
            Navigator.pop(context, [
              name.text.trim(),
              email.text.trim(),
              phone.text.trim(),
            ]);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CreateManagerAccountDialog extends StatefulWidget {
  const _CreateManagerAccountDialog({required this.existingAccounts});

  final List<ManagerAccount> existingAccounts;

  @override
  State<_CreateManagerAccountDialog> createState() =>
      _CreateManagerAccountDialogState();
}

class _CreateManagerAccountDialogState
    extends State<_CreateManagerAccountDialog> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create manager account'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Manager name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the manager name'
                  : null,
            ),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter an email address';
                }
                if (widget.existingAccounts.any(
                  (account) =>
                      account.email.toLowerCase() ==
                      value.trim().toLowerCase(),
                )) {
                  return 'An account with this email already exists';
                }
                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            TextFormField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) => value == null || value.length < 8
                  ? 'Use at least 8 characters'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              ManagerAccount(
                name: name.text.trim(),
                email: email.text.trim(),
                password: password.text,
              ),
            );
          },
          child: const Text('Create account'),
        ),
      ],
    );
  }
}

final _demoCustomers = [
  CustomerRecord(
    id: 'CUS-1001',
    name: 'Aarav Sharma',
    phone: '+91 98765 43210',
    email: 'aarav@example.com',
    addresses: ['12 Central Market Road, Bengaluru'],
    complaints: ['Overflowing bin near market entrance · In Progress'],
    collections: ['REQ-2048 · Completed', 'REQ-2032 · In Progress'],
  ),
  CustomerRecord(
    id: 'CUS-1002',
    name: 'Meera Rao',
    phone: '+91 98765 12340',
    email: 'meera@example.com',
    addresses: ['45 Lake Road, Bengaluru', '8 Green View Layout, Bengaluru'],
    complaints: ['Plastic bags beside walkway · Resolved'],
    collections: ['REQ-2038 · Completed'],
  ),
  CustomerRecord(
    id: 'CUS-1003',
    name: 'Rohan Kumar',
    phone: '+91 99887 76655',
    email: 'rohan@example.com',
    addresses: ['8 Green Park Layout, Bengaluru'],
    complaints: [],
    collections: ['REQ-2029 · Completed'],
    isActive: false,
  ),
];

final _demoDrivers = [
  DriverRecord(
    id: 'DRV-1001',
    name: 'Rahul Kumar',
    phone: '+91 98765 43210',
    email: 'rahul.driver@example.com',
    password: '12345678',
    employeeId: 'EMP-2041',
    vehicleRegistration: 'KA 05 AB 2048',
    availability: 'Available',
    assignedJobs: 8,
    completedCollections: 42,
  ),
  DriverRecord(
    id: 'DRV-1002',
    name: 'Priya Nair',
    phone: '+91 98765 88776',
    email: 'priya.driver@example.com',
    password: '12345678',
    employeeId: 'EMP-2042',
    vehicleRegistration: 'KA 03 CD 7712',
    availability: 'Busy',
    assignedJobs: 5,
    completedCollections: 36,
  ),
  DriverRecord(
    id: 'DRV-1003',
    name: 'Vikram Singh',
    phone: '+91 99887 66554',
    email: 'vikram.driver@example.com',
    password: '12345678',
    employeeId: 'EMP-2043',
    vehicleRegistration: 'KA 01 EF 4410',
    availability: 'Off Duty',
    assignedJobs: 0,
    completedCollections: 29,
    isActive: false,
  ),
];

final _demoRequests = [
  RequestRecord(
    id: 'REQ-2048',
    type: 'Complaint',
    title: 'Overflowing bin',
    customer: 'Aarav Sharma',
    location: 'Central Market, Gate 2',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    priority: 'High',
    status: 'Under Review',
    photoName: 'overflowing_bin.jpg',
  ),
  RequestRecord(
    id: 'REQ-2038',
    type: 'Collection',
    title: 'Plastic and recyclable waste pickup',
    customer: 'Meera Rao',
    location: 'Lake Road',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    priority: 'Medium',
    status: 'Approved',
  ),
  RequestRecord(
    id: 'REQ-2029',
    type: 'Complaint',
    title: 'Damaged collection point',
    customer: 'Rohan Kumar',
    location: 'Green Park',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    priority: 'Low',
    status: 'Resolved',
    notes: 'Replacement scheduled with the maintenance team.',
  ),
];

final _demoBins = [
  GarbageBinRecord(
    id: 'BIN-1001',
    location: 'Central Market, Gate 2',
    type: 'Mixed waste',
    capacity: '1100 L',
    condition: 'Good',
    lastCollection: DateTime.now().subtract(const Duration(hours: 4)),
    collectionHistory: ['Today · 8:00 AM', 'Yesterday · 8:15 AM'],
    requiresCollection: true,
  ),
  GarbageBinRecord(
    id: 'BIN-1002',
    location: 'Lake Road Bus Stop',
    type: 'Recyclables',
    capacity: '660 L',
    condition: 'Good',
    lastCollection: DateTime.now().subtract(const Duration(days: 1)),
    collectionHistory: ['Yesterday · 7:30 AM', '05 Nov · 7:40 AM'],
  ),
  GarbageBinRecord(
    id: 'BIN-1003',
    location: 'Green Park Entrance',
    type: 'Organic waste',
    capacity: '240 L',
    condition: 'Damaged',
    lastCollection: DateTime.now().subtract(const Duration(days: 3)),
    collectionHistory: ['03 Nov · 9:00 AM'],
    isDamaged: true,
  ),
];

final _demoSchedules = [
  CollectionSchedule(
    id: 'SCH-1001',
    wasteType: 'Dry waste',
    area: 'Central Market',
    driverId: 'DRV-1001',
    vehicle: 'KA 05 AB 2048',
    startsAt: DateTime.now().add(const Duration(days: 1)),
    timeSlot: '08:00 AM - 11:00 AM',
  ),
  CollectionSchedule(
    id: 'SCH-1002',
    wasteType: 'Wet waste',
    area: 'Lake Road',
    driverId: 'DRV-1002',
    vehicle: 'KA 03 CD 7712',
    startsAt: DateTime.now().add(const Duration(days: 2)),
    timeSlot: '07:00 AM - 10:00 AM',
  ),
];
