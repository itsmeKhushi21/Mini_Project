part of 'main.dart';

class ManagerShell extends StatefulWidget {
  const ManagerShell({
    super.key,
    required this.reports,
    required this.onSignOut,
  });

  final List<WasteReport> reports;
  final VoidCallback onSignOut;

  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ManagerDashboard(
        reports: widget.reports,
        onAssignDriver: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver assignment is ready to configure.')),
        ),
        onReviewComplaints: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint review is ready to configure.')),
        ),
      ),
      CustomerManagementScreen(
        customers: _demoCustomers,
      ),
      RequestManagementScreen(
        reports: widget.reports,
      ),
      DriverAssignmentScreen(
        requests: _demoRequests,
        drivers: _demoDrivers,
      ),
      GarbageBinManagementScreen(
        bins: _demoBins,
      ),
      DriverManagementScreen(
        drivers: _demoDrivers,
      ),
      ScheduleManagementScreen(
        schedules: _demoSchedules,
        drivers: _demoDrivers,
      ),
      ReportsAnalyticsScreen(
        reports: widget.reports,
        drivers: _demoDrivers,
      ),
      ManagerProfileScreen(
        onSignOut: widget.onSignOut,
      ),
    ];
    const titles = [
      'Manager Dashboard',
      'Customer Management',
      'Requests & Complaints',
      'Driver Assignment',
      'Garbage Bin Management',
      'Drivers',
      'Collection Schedules',
      'Reports & Analytics',
      'Manager Profile & Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
            tooltip: 'Open manager menu',
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
        child: SafeArea(
          child: Column(
            children: [
              const UserAccountsDrawerHeader(
                accountName: Text('Manager'),
                accountEmail: Text('Waste Management System'),
                currentAccountPicture: CircleAvatar(
                  child: Icon(Icons.manage_accounts_outlined),
                ),
              ),
              _menuItem(0, Icons.dashboard_outlined, 'Dashboard'),
              _menuItem(1, Icons.people_outline, 'Customer Management'),
              _menuItem(
                2,
                Icons.assignment_outlined,
                'Requests & Complaints',
              ),
              _menuItem(3, Icons.assignment_ind_outlined, 'Driver Assignment'),
              _menuItem(4, Icons.delete_outline, 'Garbage Bin Management'),
              _menuItem(5, Icons.local_shipping_outlined, 'Drivers'),
              _menuItem(6, Icons.calendar_month_outlined, 'Collection Schedules'),
              _menuItem(7, Icons.analytics_outlined, 'Reports & Analytics'),
              _menuItem(8, Icons.manage_accounts_outlined, 'Profile & Settings'),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: widget.onSignOut,
              ),
            ],
          ),
        ),
      ),
      body: pages[selectedPage],
    );
  }

  Widget _menuItem(int page, IconData icon, String label) {
    return ListTile(
      selected: selectedPage == page,
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        setState(() => selectedPage = page);
        Navigator.pop(context);
      },
    );
  }
}

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key, required this.customers});

  final List<CustomerRecord> customers;

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends State<CustomerManagementScreen> {
  final search = TextEditingController();
  String status = 'All';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final customers = widget.customers.where((customer) {
      final matchesSearch =
          query.isEmpty ||
          '${customer.id} ${customer.name} ${customer.phone}'
              .toLowerCase()
              .contains(query);
      final matchesStatus =
          status == 'All' ||
          (status == 'Active' && customer.isActive) ||
          (status == 'Inactive' && !customer.isActive);
      return matchesSearch && matchesStatus;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Registered customers',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Search profiles, review history, and manage account access.'),
        const SizedBox(height: 18),
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search by name, phone, or customer ID',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Account status'),
          items: const ['All', 'Active', 'Inactive']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) => setState(() => status = value ?? 'All'),
        ),
        const SizedBox(height: 18),
        Text(
          '${customers.length} customer${customers.length == 1 ? '' : 's'} found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (customers.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.search_off),
              title: Text('No customers found'),
              subtitle: Text('Try a different search or status filter.'),
            ),
          )
        else
          ...customers.map(
            (customer) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(customer.name.substring(0, 1)),
                ),
                title: Text(customer.name),
                subtitle: Text('${customer.id} · ${customer.phone}'),
                trailing: Chip(
                  label: Text(customer.isActive ? 'Active' : 'Inactive'),
                  avatar: Icon(
                    customer.isActive ? Icons.check : Icons.pause,
                    size: 16,
                  ),
                ),
                onTap: () => _showCustomerProfile(context, customer),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showCustomerProfile(
    BuildContext context,
    CustomerRecord customer,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${customer.id} · ${customer.phone}'),
                Text(customer.email),
                const SizedBox(height: 16),
                _historySection('Addresses', customer.addresses),
                _historySection('Complaint history', customer.complaints),
                _historySection('Collection request history', customer.collections),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => customer.isActive = !customer.isActive);
              Navigator.pop(context);
            },
            child: Text(customer.isActive ? 'Deactivate account' : 'Activate account'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _historySection(String title, List<String> entries) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (entries.isEmpty)
            const Text('No records')
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• $entry'),
              ),
            ),
        ],
      ),
    );
  }
}

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({
    super.key,
    required this.schedules,
    required this.drivers,
  });

  final List<CollectionSchedule> schedules;
  final List<DriverRecord> drivers;

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  String period = 'All';

  @override
  Widget build(BuildContext context) {
    final visible = widget.schedules.where((schedule) {
      if (period == 'Daily') {
        return _sameDay(schedule.startsAt, DateTime.now());
      }
      if (period == 'Weekly') {
        final difference = schedule.startsAt.difference(DateTime.now()).inDays;
        return difference >= 0 && difference < 7;
      }
      if (period == 'Monthly') {
        return schedule.startsAt.year == DateTime.now().year &&
            schedule.startsAt.month == DateTime.now().month;
      }
      return true;
    }).toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Collection schedule management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _editSchedule(context),
              icon: const Icon(Icons.add),
              label: const Text('Create schedule'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Organise waste collection days, areas, drivers, and time slots.'),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: period,
          decoration: const InputDecoration(
            labelText: 'Schedule view',
            prefixIcon: Icon(Icons.view_week_outlined),
          ),
          items: const ['All', 'Daily', 'Weekly', 'Monthly']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) => setState(() => period = value ?? 'All'),
        ),
        const SizedBox(height: 14),
        if (visible.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.event_busy_outlined),
              title: Text('No schedules found'),
              subtitle: Text('Create a schedule for a collection area.'),
            ),
          )
        else
          ...visible.map(
            (schedule) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.calendar_month_outlined),
                ),
                title: Text('${schedule.wasteType} · ${schedule.area}'),
                subtitle: Text(
                  '${_formatDate(schedule.startsAt)} · ${schedule.timeSlot}\n'
                  '${_driverName(schedule.driverId)} · ${schedule.vehicle} · '
                  '${schedule.status}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') {
                      _editSchedule(context, schedule: schedule);
                    } else if (action == 'cancel') {
                      setState(() => schedule.status = 'Cancelled');
                    } else if (action == 'reschedule') {
                      _editSchedule(context, schedule: schedule);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit schedule')),
                    PopupMenuItem(
                      value: 'reschedule',
                      child: Text('Reschedule'),
                    ),
                    PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancel schedule'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _editSchedule(
    BuildContext context, {
    CollectionSchedule? schedule,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ScheduleEditorDialog(
        schedule: schedule,
        drivers: widget.drivers,
        nextId: 'SCH-${1001 + widget.schedules.length}',
        hasConflict: (date, timeSlot, driverId, current) => widget.schedules.any(
          (item) =>
              item != current &&
              item.status != 'Cancelled' &&
              item.driverId == driverId &&
              _sameDay(item.startsAt, date) &&
              item.timeSlot == timeSlot,
        ),
        onSave: (updated) => setState(() {
          if (schedule == null) {
            widget.schedules.add(updated);
          } else {
            schedule.wasteType = updated.wasteType;
            schedule.area = updated.area;
            schedule.driverId = updated.driverId;
            schedule.vehicle = updated.vehicle;
            schedule.startsAt = updated.startsAt;
            schedule.timeSlot = updated.timeSlot;
            schedule.status = 'Scheduled';
          }
        }),
      ),
    );
  }

  String _driverName(String id) =>
      widget.drivers.firstWhere((driver) => driver.id == id).name;

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  String _formatDate(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';
}

class _ScheduleEditorDialog extends StatefulWidget {
  const _ScheduleEditorDialog({
    required this.schedule,
    required this.drivers,
    required this.nextId,
    required this.hasConflict,
    required this.onSave,
  });

  final CollectionSchedule? schedule;
  final List<DriverRecord> drivers;
  final String nextId;
  final bool Function(DateTime, String, String, CollectionSchedule?) hasConflict;
  final ValueChanged<CollectionSchedule> onSave;

  @override
  State<_ScheduleEditorDialog> createState() => _ScheduleEditorDialogState();
}

class _ScheduleEditorDialogState extends State<_ScheduleEditorDialog> {
  late final TextEditingController area;
  late String wasteType;
  late String driverId;
  late String timeSlot;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    area = TextEditingController(text: schedule?.area);
    wasteType = schedule?.wasteType ?? 'Dry waste';
    driverId = schedule?.driverId ?? widget.drivers.first.id;
    timeSlot = schedule?.timeSlot ?? '08:00 AM - 11:00 AM';
    date = schedule?.startsAt ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    area.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.schedule == null ? 'Create collection schedule' : 'Edit schedule',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: area,
              decoration: const InputDecoration(labelText: 'Collection area'),
            ),
            DropdownButtonFormField<String>(
              initialValue: wasteType,
              decoration: const InputDecoration(labelText: 'Waste type'),
              items: const ['Dry waste', 'Wet waste', 'Recyclables', 'Mixed waste']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => wasteType = value ?? wasteType),
            ),
            DropdownButtonFormField<String>(
              initialValue: driverId,
              decoration: const InputDecoration(labelText: 'Driver and vehicle'),
              items: widget.drivers
                  .where((driver) => driver.isActive)
                  .map(
                    (driver) => DropdownMenuItem(
                      value: driver.id,
                      child: Text('${driver.name} · ${driver.vehicleRegistration}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => driverId = value ?? driverId),
            ),
            DropdownButtonFormField<String>(
              initialValue: timeSlot,
              decoration: const InputDecoration(labelText: 'Time slot'),
              items: const [
                '07:00 AM - 10:00 AM',
                '08:00 AM - 11:00 AM',
                '02:00 PM - 05:00 PM',
                '05:00 PM - 08:00 PM',
              ]
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => timeSlot = value ?? timeSlot),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Collection date'),
              subtitle: Text('${date.day}/${date.month}/${date.year}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
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
          onPressed: _save,
          child: Text(widget.schedule == null ? 'Create schedule' : 'Save changes'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: date,
    );
    if (picked != null) setState(() => date = picked);
  }

  void _save() {
    if (area.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a collection area.')),
      );
      return;
    }
    if (widget.hasConflict(date, timeSlot, driverId, widget.schedule)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scheduling conflict: this driver already has a slot then.'),
        ),
      );
      return;
    }
    final driver = widget.drivers.firstWhere((item) => item.id == driverId);
    widget.onSave(
      CollectionSchedule(
        id: widget.schedule?.id ?? widget.nextId,
        wasteType: wasteType,
        area: area.text.trim(),
        driverId: driverId,
        vehicle: driver.vehicleRegistration,
        startsAt: date,
        timeSlot: timeSlot,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customers will be notified of schedule changes.')),
    );
    Navigator.pop(context);
  }
}

class GarbageBinManagementScreen extends StatefulWidget {
  const GarbageBinManagementScreen({super.key, required this.bins});

  final List<GarbageBinRecord> bins;

  @override
  State<GarbageBinManagementScreen> createState() =>
      _GarbageBinManagementScreenState();
}

class _GarbageBinManagementScreenState
    extends State<GarbageBinManagementScreen> {
  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _editBin(context),
              icon: const Icon(Icons.add),
              label: const Text('Add bin'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Manage public bins, locations, condition, and collection history.'),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Bin locations map'),
            subtitle: const Text('View all registered bins on a map'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Map view is ready to connect.')),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...widget.bins.map(
          (bin) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: bin.isDamaged
                    ? Colors.red.withValues(alpha: 0.14)
                    : const Color(0xFFE2F3E9),
                child: Icon(
                  bin.isDamaged ? Icons.warning_amber_outlined : Icons.delete_outline,
                  color: bin.isDamaged ? Colors.red : const Color(0xFF17834B),
                ),
              ),
              title: Text('${bin.id} · ${bin.type}'),
              subtitle: Text(
                '${bin.location}\n${bin.capacity} · ${bin.condition} · '
                'Last collection: ${_formatDate(bin.lastCollection)}',
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'edit') {
                    _editBin(context, bin: bin);
                  } else if (action == 'history') {
                    _showHistory(context, bin);
                  } else {
                    setState(() => widget.bins.remove(bin));
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit bin')),
                  const PopupMenuItem(
                    value: 'history',
                    child: Text('Collection history'),
                  ),
                  const PopupMenuItem(value: 'remove', child: Text('Remove bin')),
                ],
              ),
              onTap: () => _editBin(context, bin: bin),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editBin(
    BuildContext context, {
    GarbageBinRecord? bin,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _BinEditorDialog(
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
            bin.lastCollection = updated.lastCollection;
            bin.requiresCollection = updated.requiresCollection;
            bin.isDamaged = updated.isDamaged;
          }
        }),
      ),
    );
  }

  void _showHistory(BuildContext context, GarbageBinRecord bin) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${bin.id} collection history'),
        content: SizedBox(
          width: 360,
          child: bin.collectionHistory.isEmpty
              ? const Text('No collection history recorded.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: bin.collectionHistory
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $entry'),
                          ))
                      .toList(),
                ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';
}

class _BinEditorDialog extends StatefulWidget {
  const _BinEditorDialog({
    required this.bin,
    required this.nextId,
    required this.onSave,
  });

  final GarbageBinRecord? bin;
  final String nextId;
  final ValueChanged<GarbageBinRecord> onSave;

  @override
  State<_BinEditorDialog> createState() => _BinEditorDialogState();
}

class _BinEditorDialogState extends State<_BinEditorDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController location;
  late final TextEditingController capacity;
  late String type;
  late String condition;
  late bool requiresCollection;
  late bool isDamaged;

  @override
  void initState() {
    super.initState();
    final bin = widget.bin;
    location = TextEditingController(text: bin?.location);
    capacity = TextEditingController(text: bin?.capacity);
    type = bin?.type ?? 'Mixed waste';
    condition = bin?.condition ?? 'Good';
    requiresCollection = bin?.requiresCollection ?? false;
    isDamaged = bin?.isDamaged ?? false;
  }

  @override
  void dispose() {
    location.dispose();
    capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bin = widget.bin;
    return AlertDialog(
      title: Text(bin == null ? 'Add garbage bin' : 'Edit garbage bin'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bin == null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Unique bin ID: ${widget.nextId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              TextFormField(
                controller: location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: _required,
              ),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Bin type'),
                items: const ['Mixed waste', 'Recyclables', 'Organic waste', 'Hazardous waste']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => type = value ?? type),
              ),
              TextFormField(
                controller: capacity,
                decoration: const InputDecoration(labelText: 'Capacity'),
                validator: _required,
              ),
              DropdownButtonFormField<String>(
                initialValue: condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: const ['Good', 'Needs maintenance', 'Damaged']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() {
                  condition = value ?? condition;
                  isDamaged = condition == 'Damaged';
                }),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Requires collection'),
                value: requiresCollection,
                onChanged: (value) => setState(() => requiresCollection = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Report as damaged'),
                value: isDamaged,
                onChanged: (value) => setState(() => isDamaged = value),
              ),
            ],
          ),
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
            widget.onSave(
              GarbageBinRecord(
                id: bin?.id ?? widget.nextId,
                location: location.text.trim(),
                type: type,
                capacity: capacity.text.trim(),
                condition: condition,
                lastCollection: bin?.lastCollection ?? DateTime.now(),
                collectionHistory: bin?.collectionHistory ?? [],
                requiresCollection: requiresCollection,
                isDamaged: isDamaged,
              ),
            );
            Navigator.pop(context);
          },
          child: Text(bin == null ? 'Add bin' : 'Save changes'),
        ),
      ],
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class DriverAssignmentScreen extends StatefulWidget {
  const DriverAssignmentScreen({
    super.key,
    required this.requests,
    required this.drivers,
  });

  final List<RequestRecord> requests;
  final List<DriverRecord> drivers;

  @override
  State<DriverAssignmentScreen> createState() => _DriverAssignmentScreenState();
}

class _DriverAssignmentScreenState extends State<DriverAssignmentScreen> {
  RequestRecord? selectedRequest;
  DriverRecord? selectedDriver;
  DateTime? scheduledAt;
  String priority = 'Medium';
  bool showAssigned = false;

  List<RequestRecord> get assignableRequests => widget.requests
      .where(
        (request) =>
            request.type == 'Collection' &&
            request.status != 'Rejected' &&
            request.status != 'Resolved' &&
            (showAssigned || request.assignedDriver == null),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final requests = assignableRequests;
    final drivers = widget.drivers.where((driver) => driver.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Driver assignment',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Match collection requests with suitable available drivers.'),
        const SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.map_outlined)),
            title: const Text('Driver locations'),
            subtitle: const Text('Track active drivers and collection areas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => OperationsMapScreen(
                title: 'Manager driver tracking',
                points: widget.drivers.asMap().entries.map((entry) => MapLocationPoint(
                  label: entry.value.name,
                  subtitle: '${entry.value.availability} · ${entry.value.vehicleRegistration}',
                  latitude: 12.9716 + (entry.key % 5) * 0.006,
                  longitude: 77.5946 + (entry.key % 5) * 0.006,
                  icon: Icons.local_shipping,
                  color: entry.value.availability == 'Available' ? Colors.blue : Colors.orange,
                )).toList(),
              ),
            )),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show assigned requests'),
          subtitle: const Text('Enable this to reassign an existing task.'),
          value: showAssigned,
          onChanged: (value) => setState(() {
            showAssigned = value;
            selectedRequest = null;
            selectedDriver = null;
          }),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RequestRecord>(
          initialValue: requests.contains(selectedRequest)
              ? selectedRequest
              : null,
          decoration: const InputDecoration(
            labelText: 'Collection request',
            prefixIcon: Icon(Icons.assignment_outlined),
          ),
          items: requests
              .map(
                (request) => DropdownMenuItem(
                  value: request,
                  child: Text(
                    '${request.id} · ${request.title}'
                    '${request.assignedDriver == null ? '' : ' · Assigned'}',
                  ),
                ),
              )
              .toList(),
          onChanged: (request) => setState(() {
            selectedRequest = request;
            if (request != null) {
              priority = request.priority;
              selectedDriver = null;
            }
          }),
        ),
        if (selectedRequest != null) ...[
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(selectedRequest!.title),
              subtitle: Text(
                '${selectedRequest!.customer} · ${selectedRequest!.location}',
              ),
              trailing: Text(selectedRequest!.priority),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text(
          'Available drivers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...drivers.map(
          (driver) => Card(
            child: RadioListTile<DriverRecord>(
              value: driver,
              groupValue: selectedDriver,
              onChanged: driver.availability == 'Off Duty'
                  ? null
                  : (value) => setState(() => selectedDriver = value),
              title: Text(driver.name),
              subtitle: Text(
                '${driver.availability} · ${driver.assignedJobs} current jobs · '
                '${driver.vehicleRegistration}',
              ),
              secondary: CircleAvatar(
                child: Text('${driver.assignedJobs}'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: priority,
          decoration: const InputDecoration(
            labelText: 'Collection priority',
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items: const ['High', 'Medium', 'Low']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) => setState(() => priority = value ?? priority),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickSchedule,
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(
            scheduledAt == null
                ? 'Select scheduled date and time'
                : 'Scheduled: ${_formatDateTime(scheduledAt!)}',
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: selectedRequest == null || selectedDriver == null
                ? null
                : _assignDriver,
            icon: const Icon(Icons.assignment_ind_outlined),
            label: Text(
              selectedRequest?.assignedDriver == null
                  ? 'Assign driver'
                  : 'Reassign driver',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDate: scheduledAt ?? DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(scheduledAt ?? DateTime.now()),
    );
    if (time == null) return;
    setState(() {
      scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _assignDriver() {
    final request = selectedRequest;
    final driver = selectedDriver;
    if (request == null || driver == null) return;
    if (driver.availability == 'Off Duty') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This driver is off duty.')),
      );
      return;
    }

    final wasAssigned = request.assignedDriver != null;
    final previousDriver = widget.drivers.cast<DriverRecord?>().firstWhere(
      (candidate) => candidate?.id == request.assignedDriver,
      orElse: () => null,
    );
    setState(() {
      request.assignedDriver = driver.id;
      request.priority = priority;
      request.scheduledAt = scheduledAt ?? DateTime.now();
      request.status = 'Assigned';
      if (previousDriver != null && previousDriver.id != driver.id) {
        previousDriver.assignedJobs = previousDriver.assignedJobs > 0
            ? previousDriver.assignedJobs - 1
            : 0;
        driver.assignedJobs++;
      } else if (!wasAssigned) {
        driver.assignedJobs++;
      }
      selectedRequest = null;
      selectedDriver = null;
      scheduledAt = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${wasAssigned ? 'Reassigned' : 'Assigned'} to ${driver.name}. '
          'Driver and customer notifications sent.',
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final hour = value.hour == 0 || value.hour == 12 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.day}/${value.month}/${value.year} $hour:$minute $period';
  }
}

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key, required this.drivers});

  final List<DriverRecord> drivers;

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final search = TextEditingController();
  String status = 'All';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final drivers = widget.drivers.where((driver) {
      final matchesSearch =
          query.isEmpty ||
          '${driver.id} ${driver.name} ${driver.phone} ${driver.employeeId} '
                  '${driver.vehicleRegistration}'
              .toLowerCase()
              .contains(query);
      final matchesStatus =
          status == 'All' ||
          (status == 'Active' && driver.isActive) ||
          (status == 'Inactive' && !driver.isActive);
      return matchesSearch && matchesStatus;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Registered drivers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showDriverEditor(context),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add driver'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Manage driver profiles, vehicles, availability, and collection work.'),
        const SizedBox(height: 18),
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search by name, phone, ID, employee ID, or vehicle',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Account status'),
          items: const ['All', 'Active', 'Inactive']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) => setState(() => status = value ?? 'All'),
        ),
        const SizedBox(height: 18),
        if (drivers.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.search_off),
              title: Text('No drivers found'),
              subtitle: Text('Try a different search or status filter.'),
            ),
          )
        else
          ...drivers.map(
            (driver) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(driver.name.substring(0, 1)),
                ),
                title: Text(driver.name),
                subtitle: Text(
                  '${driver.employeeId} · ${driver.vehicleRegistration}\n'
                  '${driver.availability} · ${driver.assignedJobs} assigned · '
                  '${driver.completedCollections} completed',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') {
                      _showDriverEditor(context, driver: driver);
                    } else {
                      setState(() => driver.isActive = !driver.isActive);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit details'),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        driver.isActive ? 'Deactivate account' : 'Activate account',
                      ),
                    ),
                  ],
                ),
                onTap: () => _showDriverDetails(context, driver),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showDriverDetails(
    BuildContext context,
    DriverRecord driver,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(driver.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${driver.id} · ${driver.employeeId}'),
            Text(driver.phone),
            Text(driver.email),
            Text('Vehicle: ${driver.vehicleRegistration}'),
            Text('Availability: ${driver.availability}'),
            const SizedBox(height: 12),
            Text('Assigned jobs: ${driver.assignedJobs}'),
            Text('Completed collections: ${driver.completedCollections}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => driver.isActive = !driver.isActive);
              Navigator.pop(context);
            },
            child: Text(driver.isActive ? 'Deactivate' : 'Activate'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDriverEditor(
    BuildContext context, {
    DriverRecord? driver,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DriverEditorDialog(
        driver: driver,
        nextId: 'DRV-${1001 + widget.drivers.length}',
        onSave: (updated) => setState(() {
          if (driver == null) {
            widget.drivers.add(updated);
          } else {
            driver.name = updated.name;
            driver.phone = updated.phone;
            driver.email = updated.email;
            driver.password = updated.password;
            driver.employeeId = updated.employeeId;
            driver.vehicleRegistration = updated.vehicleRegistration;
            driver.availability = updated.availability;
          }
        }),
      ),
    );
  }

}

class _DriverEditorDialog extends StatefulWidget {
  const _DriverEditorDialog({
    required this.driver,
    required this.nextId,
    required this.onSave,
  });

  final DriverRecord? driver;
  final String nextId;
  final ValueChanged<DriverRecord> onSave;

  @override
  State<_DriverEditorDialog> createState() => _DriverEditorDialogState();
}

class _DriverEditorDialogState extends State<_DriverEditorDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController email;
  late final TextEditingController password;
  late final TextEditingController employeeId;
  late final TextEditingController vehicle;
  late String availability;

  @override
  void initState() {
    super.initState();
    final driver = widget.driver;
    name = TextEditingController(text: driver?.name);
    phone = TextEditingController(text: driver?.phone);
    email = TextEditingController(text: driver?.email);
    password = TextEditingController(text: driver?.password ?? '');
    employeeId = TextEditingController(text: driver?.employeeId);
    vehicle = TextEditingController(text: driver?.vehicleRegistration);
    availability = driver?.availability ?? 'Available';
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    employeeId.dispose();
    vehicle.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.driver == null ? 'Add driver account' : 'Edit driver details',
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(name, 'Full name'),
              _field(phone, 'Phone number'),
              _field(email, 'Email address'),
              _field(password, 'Login password (minimum 8 characters)', obscureText: true, minLength: 8),
              _field(employeeId, 'Employee ID'),
              _field(vehicle, 'Vehicle registration'),
              DropdownButtonFormField<String>(
                initialValue: availability,
                decoration: const InputDecoration(labelText: 'Availability'),
                items: const ['Available', 'Busy', 'Off Duty']
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => availability = value ?? availability),
              ),
            ],
          ),
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
            widget.onSave(
              DriverRecord(
                id: widget.driver?.id ?? widget.nextId,
                name: name.text.trim(),
                phone: phone.text.trim(),
                email: email.text.trim(),
                password: password.text,
                employeeId: employeeId.text.trim(),
                vehicleRegistration: vehicle.text.trim(),
                availability: availability,
                assignedJobs: widget.driver?.assignedJobs ?? 0,
                completedCollections: widget.driver?.completedCollections ?? 0,
                isActive: widget.driver?.isActive ?? true,
              ),
            );
            Navigator.pop(context);
          },
          child: Text(widget.driver == null ? 'Add driver' : 'Save changes'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, {bool obscureText = false, int minLength = 1}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          value == null || value.trim().length < minLength ? 'Use at least $minLength characters' : null,
    );
  }
}

class RequestManagementScreen extends StatefulWidget {
  const RequestManagementScreen({super.key, required this.reports});

  final List<WasteReport> reports;

  @override
  State<RequestManagementScreen> createState() =>
      _RequestManagementScreenState();
}

class _RequestManagementScreenState extends State<RequestManagementScreen> {
  late final List<RequestRecord> requests;
  final search = TextEditingController();
  String type = 'All';
  String priority = 'All';
  String status = 'All';

  @override
  void initState() {
    super.initState();
    requests = [
      ..._demoRequests.map(
        (request) => RequestRecord(
          id: request.id,
          type: request.type,
          title: request.title,
          customer: request.customer,
          location: request.location,
          createdAt: request.createdAt,
          priority: request.priority,
          status: request.status,
          photoName: request.photoName,
          notes: request.notes,
        ),
      ),
      ...widget.reports.map(
        (report) => RequestRecord(
          id: report.id,
          type: 'Complaint',
          title: report.title,
          customer: 'Registered customer',
          location: report.location,
          createdAt: report.createdAt,
          priority: report.severity,
          status: report.status,
          notes: report.description,
          photoName: report.photoName,
        ),
      ),
    ];
  }

  @override
  void didUpdateWidget(covariant RequestManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final existingIds = requests.map((request) => request.id).toSet();
    for (final report in widget.reports) {
      if (existingIds.contains(report.id)) continue;
      requests.add(
        RequestRecord(
          id: report.id,
          type: 'Complaint',
          title: report.title,
          customer: report.customer,
          location: report.location,
          createdAt: report.createdAt,
          priority: report.severity,
          status: report.status,
          notes: report.description,
          photoName: report.photoName,
        ),
      );
    }
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final filtered = requests.where((request) {
      final matchesSearch =
          query.isEmpty ||
          '${request.id} ${request.title} ${request.customer} ${request.location}'
              .toLowerCase()
              .contains(query);
      return matchesSearch &&
          (type == 'All' || request.type == type) &&
          (priority == 'All' || request.priority == priority) &&
          (status == 'All' || request.status == status);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Garbage requests and complaints',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Review reports, collection requests, evidence, and locations.'),
        const SizedBox(height: 18),
        TextField(
          controller: search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search ID, customer, title, or location',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _filter('Type', type, ['All', 'Complaint', 'Collection'], (value) {
              setState(() => type = value);
            }),
            _filter('Priority', priority, ['All', 'High', 'Medium', 'Low'], (
              value,
            ) {
              setState(() => priority = value);
            }),
            _filter(
              'Status',
              status,
              ['All', 'Submitted', 'Under Review', 'Approved', 'Rejected', 'Resolved'],
              (value) => setState(() => status = value),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '${filtered.length} records',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...filtered.map(
          (request) => Card(
            child: ListTile(
              leading: Icon(
                request.type == 'Complaint'
                    ? Icons.report_problem_outlined
                    : Icons.assignment_outlined,
                color: request.priority == 'High'
                    ? Colors.red
                    : const Color(0xFF17834B),
              ),
              title: Text(request.title),
              subtitle: Text(
                '${request.id} · ${request.customer}\n'
                '${request.location} · ${request.status}',
              ),
              isThreeLine: true,
              trailing: request.photoName == null
                  ? null
                  : const Icon(Icons.photo_outlined),
              onTap: () => _showDetails(context, request),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filter(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((option) => DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: (next) => onChanged(next ?? options.first),
      ),
    );
  }

  Future<void> _showDetails(
    BuildContext context,
    RequestRecord request,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RequestDetailsDialog(
        request: request,
        onChanged: () => setState(() {}),
      ),
    );
  }
}

class _RequestDetailsDialog extends StatefulWidget {
  const _RequestDetailsDialog({
    required this.request,
    required this.onChanged,
  });

  final RequestRecord request;
  final VoidCallback onChanged;

  @override
  State<_RequestDetailsDialog> createState() => _RequestDetailsDialogState();
}

class _RequestDetailsDialogState extends State<_RequestDetailsDialog> {
  late final TextEditingController notes;

  @override
  void initState() {
    super.initState();
    notes = TextEditingController(text: widget.request.notes);
  }

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return AlertDialog(
      title: Text(request.title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${request.id} · ${request.type}'),
              Text('Customer: ${request.customer}'),
              Text('Location: ${request.location}'),
              Text('Priority: ${request.priority}'),
              const SizedBox(height: 12),
              if (request.photoName != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.photo_outlined),
                    title: Text(request.photoName!),
                    subtitle: const Text('Uploaded photograph available'),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo preview is ready to connect.')),
                    ),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Reported location'),
                  subtitle: Text(request.location),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => OperationsMapScreen(
                      title: 'Reported collection location',
                      points: const [
                        MapLocationPoint(
                          label: 'Reported collection location',
                          latitude: 12.9719,
                          longitude: 77.5948,
                        ),
                      ],
                    ),
                  )),
                ),
              ),
              TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Internal notes',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            request.forwardedForReview = true;
            request.notes = notes.text.trim();
            widget.onChanged();
            Navigator.pop(context);
          },
          child: const Text('Forward for review'),
        ),
        TextButton(
          onPressed: () {
            request.status = 'Rejected';
            request.notes = notes.text.trim();
            widget.onChanged();
            Navigator.pop(context);
          },
          child: const Text('Reject'),
        ),
        OutlinedButton(
          onPressed: () {
            request.status = 'Resolved';
            request.notes = notes.text.trim();
            widget.onChanged();
            Navigator.pop(context);
          },
          child: const Text('Mark resolved'),
        ),
        FilledButton(
          onPressed: () {
            request.status = request.type == 'Collection' ? 'Approved' : 'Under Review';
            request.notes = notes.text.trim();
            widget.onChanged();
            Navigator.pop(context);
          },
          child: Text(request.type == 'Collection' ? 'Approve' : 'Save note'),
        ),
      ],
    );
  }
}

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({
    super.key,
    required this.reports,
    required this.drivers,
  });

  final List<WasteReport> reports;
  final List<DriverRecord> drivers;

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  String period = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final complaints = widget.reports.length + 18;
    final completed = widget.reports.where((r) => r.status == 'Resolved').length + 64;
    final pending = widget.reports.where((r) => r.status != 'Resolved').length + 12;
    final resolved = widget.reports.where((r) => r.status == 'Resolved').length + 14;
    final overdue = 5 + widget.reports.where((r) => r.status == 'Submitted').length;
    final values = period == 'Daily'
        ? [18.0, 24.0, 21.0, 29.0, 26.0, 34.0, 31.0]
        : period == 'Weekly'
        ? [112.0, 138.0, 126.0, 161.0]
        : [524.0, 681.0, 742.0, 815.0, 778.0, 902.0];
    final labels = period == 'Daily'
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : period == 'Weekly'
        ? ['W1', 'W2', 'W3', 'W4']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reports and analytics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Export report',
              onSelected: (value) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value export is ready to connect.')),
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'CSV', child: Text('Export CSV')),
                PopupMenuItem(value: 'PDF', child: Text('Export PDF')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Track service performance and identify operational trends.'),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          initialValue: period,
          decoration: const InputDecoration(
            labelText: 'Reporting period',
            prefixIcon: Icon(Icons.date_range_outlined),
          ),
          items: const ['Daily', 'Weekly', 'Monthly']
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) => setState(() => period = value ?? period),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 3 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _kpi(context, 'Complaints received', '$complaints', Icons.report_problem_outlined, width),
                _kpi(context, 'Collections completed', '$completed', Icons.check_circle_outline, width),
                _kpi(context, 'Pending collections', '$pending', Icons.pending_actions, width),
                _kpi(context, 'Overdue collections', '$overdue', Icons.warning_amber_outlined, width),
                _kpi(context, 'Complaints resolved', '$resolved', Icons.task_alt, width),
                _kpi(context, 'Avg. resolution time', '18 hrs', Icons.timer_outlined, width),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collections by $period period',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 190,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      values.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(values[index].toInt().toString()),
                              const SizedBox(height: 4),
                              Container(
                                height: values[index] / values.reduce((a, b) => a > b ? a : b) * 125,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF17834B),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(labels[index]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final driver = _driverPerformance(context);
            final category = _categoryBreakdown(context);
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: driver),
                      const SizedBox(width: 16),
                      Expanded(child: category),
                    ],
                  )
                : Column(
                    children: [driver, const SizedBox(height: 16), category],
                  );
          },
        ),
      ],
    );
  }

  Widget _kpi(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          subtitle: Text(title),
        ),
      ),
    );
  }

  Widget _driverPerformance(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver performance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...widget.drivers.map(
              (driver) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(driver.name),
                subtitle: Text('${driver.assignedJobs} assigned · ${driver.completedCollections} completed'),
                trailing: Text('${driver.completedCollections + driver.assignedJobs}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryBreakdown(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waste collected by category', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _categoryRow('Mixed waste', 0.82, '328 kg'),
            _categoryRow('Recyclables', 0.64, '256 kg'),
            _categoryRow('Organic waste', 0.48, '192 kg'),
            _categoryRow('Hazardous waste', 0.16, '64 kg'),
          ],
        ),
      ),
    );
  }

  Widget _categoryRow(String label, double value, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: value, minHeight: 7),
        ],
      ),
    );
  }
}

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final name = TextEditingController(text: 'Ankith');
  final managerId = TextEditingController(text: 'MGR-1001');
  final email = TextEditingController(text: 'ankith@gmail.com');
  final phone = TextEditingController(text: '+91 98765 00000');
  bool notifications = true;
  bool urgentOnly = false;
  String priority = 'Medium';
  final categories = <String>{'Dry waste', 'Wet waste', 'Recyclables'};

  @override
  void dispose() {
    name.dispose();
    managerId.dispose();
    email.dispose();
    phone.dispose();
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
                  radius: 32,
                  child: Icon(Icons.manage_accounts_outlined, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.text,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Manager ID: ${managerId.text}'),
                      Text(email.text),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editProfile(context),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit profile',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Manager notifications'),
                subtitle: const Text('Receive assignment and complaint updates'),
                value: notifications,
                onChanged: (value) => setState(() => notifications = value),
              ),
              SwitchListTile(
                title: const Text('Urgent alerts only'),
                subtitle: const Text('Limit notifications to high-priority events'),
                value: urgentOnly,
                onChanged: (value) => setState(() => urgentOnly = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supported waste categories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Dry waste',
                    'Wet waste',
                    'Recyclables',
                    'Organic waste',
                    'Hazardous waste',
                  ]
                      .map(
                        (category) => FilterChip(
                          label: Text(category),
                          selected: categories.contains(category),
                          onSelected: (selected) => setState(
                            () => selected
                                ? categories.add(category)
                                : categories.remove(category),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(
                    labelText: 'Default collection priority',
                  ),
                  items: const ['High', 'Medium', 'Low']
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => priority = value ?? priority),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _changePassword(context),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.history_outlined),
                title: Text('System activity logs'),
                subtitle: Text(
                  'Today: Reviewed 3 complaints · Assigned 2 collections',
                ),
              ),
              const ListTile(
                leading: Icon(Icons.event_note_outlined),
                title: Text('Recent activity'),
                subtitle: Text(
                  'Yesterday: Updated bin BIN-1003 · Created SCH-1002',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: widget.onSignOut,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ManagerProfileEditor(
        name: name.text,
        email: email.text,
        phone: phone.text,
        onSave: (values) {
          setState(() {
            name.text = values.$1;
            email.text = values.$2;
            phone.text = values.$3;
          });
        },
      ),
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Use at least 8 characters.')),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Password updated for this session.')),
              );
            },
            child: const Text('Save password'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _ManagerProfileEditor extends StatefulWidget {
  const _ManagerProfileEditor({
    required this.name,
    required this.email,
    required this.phone,
    required this.onSave,
  });

  final String name;
  final String email;
  final String phone;
  final ValueChanged<(String, String, String)> onSave;

  @override
  State<_ManagerProfileEditor> createState() => _ManagerProfileEditorState();
}

class _ManagerProfileEditorState extends State<_ManagerProfileEditor> {
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit manager profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave((name.text.trim(), email.text.trim(), phone.text.trim()));
            Navigator.pop(context);
          },
          child: const Text('Save changes'),
        ),
      ],
    );
  }
}

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({
    super.key,
    required this.reports,
    required this.onAssignDriver,
    required this.onReviewComplaints,
  });

  final List<WasteReport> reports;
  final VoidCallback onAssignDriver;
  final VoidCallback onReviewComplaints;

  @override
  Widget build(BuildContext context) {
    final unresolved = reports.where((r) => r.status != 'Resolved').length + 2;
    final pending = reports.where((r) => r.status == 'Submitted').length + 12;
    final inProgress =
        reports.where((r) => r.status == 'In Progress').length + 8;
    final completed =
        reports.where((r) => r.status == 'Resolved').length + 64;
    final recentReports = [
      ...reports,
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
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'System overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Monitor collections, drivers, complaints, and service levels.'),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 620
                ? 2
                : 1;
            final width =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _metricCard(
                  context,
                  'Registered customers',
                  '${128 + reports.length}',
                  Icons.people_outline,
                  const Color(0xFF2878B8),
                  width,
                ),
                _metricCard(
                  context,
                  'Registered drivers',
                  '24',
                  Icons.local_shipping_outlined,
                  const Color(0xFF7B61A8),
                  width,
                ),
                _metricCard(
                  context,
                  'Collection requests',
                  '${86 + reports.length}',
                  Icons.assignment_outlined,
                  const Color(0xFFB7791F),
                  width,
                ),
                _metricCard(
                  context,
                  'Pending requests',
                  '$pending',
                  Icons.pending_actions,
                  const Color(0xFFD05A3A),
                  width,
                ),
                _metricCard(
                  context,
                  'Collections in progress',
                  '$inProgress',
                  Icons.sync,
                  const Color(0xFF2878B8),
                  width,
                ),
                _metricCard(
                  context,
                  'Completed collections',
                  '$completed',
                  Icons.check_circle_outline,
                  const Color(0xFF17834B),
                  width,
                ),
                _metricCard(
                  context,
                  'Unresolved complaints',
                  '$unresolved',
                  Icons.report_problem_outlined,
                  const Color(0xFFC44B4B),
                  width,
                ),
                _metricCard(
                  context,
                  'Active drivers',
                  '18 / 24',
                  Icons.directions_car_outlined,
                  const Color(0xFF17834B),
                  width,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            final cards = [
              _binStatusCard(context),
              _driverActivityCard(context),
            ];
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: cards[1]),
                    ],
                  )
                : Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 16),
                      cards[1],
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
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: onAssignDriver,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Assign a driver'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onReviewComplaints,
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Review complaints'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            final recent = _recentComplaintsCard(context, recentReports);
            final stats = _statisticsCard(context);
            return wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: recent),
                      const SizedBox(width: 16),
                      Expanded(child: stats),
                    ],
                  )
                : Column(
                    children: [
                      recent,
                      const SizedBox(height: 16),
                      stats,
                    ],
                  );
          },
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
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
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
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      title,
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

  Widget _binStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bin capacity status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _statusLine('Normal', '42 bins', Colors.green, 0.62),
            _statusLine('Nearly full', '11 bins', Colors.orange, 0.78),
            _statusLine('Full / needs collection', '5 bins', Colors.red, 0.96),
          ],
        ),
      ),
    );
  }

  Widget _statusLine(
    String label,
    String count,
    Color color,
    double progress,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
              Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _driverActivityCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver activity summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.local_shipping_outlined)),
              title: Text('18 drivers active'),
              subtitle: Text('6 drivers available for new assignments'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.warning_amber_outlined)),
              title: Text('2 delayed routes'),
              subtitle: Text('Review route progress before the next shift'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentComplaintsCard(
    BuildContext context,
    List<WasteReport> recentReports,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent complaints',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...recentReports.take(3).map(
              (report) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  report.status == 'Resolved'
                      ? Icons.check_circle_outline
                      : Icons.report_problem_outlined,
                  color: report.status == 'Resolved'
                      ? Colors.green
                      : Colors.orange,
                ),
                title: Text(report.title),
                subtitle: Text('${report.location} · ${report.status}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statisticsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collection statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _statRow('Today', '34 requests', '28 completed'),
            _statRow('This week', '186 requests', '161 completed'),
            _statRow('This month', '742 requests', '681 completed'),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String period, String requests, String completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              period,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(requests),
          const SizedBox(width: 12),
          Text(
            completed,
            style: const TextStyle(
              color: Color(0xFF17834B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
