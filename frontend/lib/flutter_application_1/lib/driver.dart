part of 'main.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({
    super.key,
    required this.driver,
    required this.onSignOut,
    required this.isDark,
    required this.onThemeChanged,
    required this.onIssueReported,
  });
  final VoidCallback onSignOut;
  final DriverRecord driver;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<DriverIssue> onIssueReported;
  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int index = 0;
  late String availability = widget.driver.availability;
  final tasks = <DriverTask>[
    DriverTask(
      id: 'T-2041', customer: 'Aarav Sharma', location: 'Central Market',
      address: '12, Central Market Road, Bengaluru', landmark: 'Near City Library',
      types: ['Mixed waste'], quantity: 'Approx. 8 kg', contact: '+91 98765 43210',
      scheduledAt: DateTime.now().add(const Duration(hours: 1)), priority: 'High', status: 'In Progress',
      latitude: 12.9719, longitude: 77.5948),
    DriverTask(
      id: 'T-2038', customer: 'Meera Rao', location: 'Lake Road',
      address: '45, Lake Road, Bengaluru', landmark: 'Opposite Lake Gate',
      types: ['Plastic', 'Recyclables'], quantity: 'Approx. 5 kg', contact: '+91 98765 12340',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)), priority: 'Medium', status: 'In Progress',
      latitude: 12.9752, longitude: 77.6033),
    DriverTask(
      id: 'T-2029', customer: 'Rohan Kumar', location: 'Green Park',
      address: '8, Green Park Layout, Bengaluru', landmark: 'Beside Park Entrance',
      types: ['Garden waste'], quantity: 'Approx. 12 kg', contact: '+91 99887 76655',
      scheduledAt: DateTime.now().subtract(const Duration(minutes: 40)), priority: 'Low', status: 'Completed',
      latitude: 12.9564, longitude: 77.5857),
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
      DriverIssueScreen(
        tasks: tasks,
        issues: issues,
        onIssueAdded: (issue) {
          setState(() => issues.insert(0, issue));
          widget.onIssueReported(issue);
        },
      ),
      DriverHistoryScreen(tasks: tasks, issues: issues),
      DriverProfileScreen(tasks: tasks, driver: widget.driver, availability: availability, isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged, onSignOut: widget.onSignOut),
    ];
    const titles = ['Driver Dashboard', 'Assigned Collections', 'Report Collection Issue', 'Work History', 'Driver Profile'];
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                accountName: Text('Driver'),
                accountEmail: Text('Waste Management System'),
                currentAccountPicture: CircleAvatar(
                  child: Icon(Icons.local_shipping_outlined),
                ),
              ),
              _driverMenuItem(0, Icons.dashboard_outlined, 'Dashboard'),
              _driverMenuItem(
                1,
                Icons.assignment_outlined,
                'Assigned Collections',
              ),
              _driverMenuItem(
                2,
                Icons.report_problem_outlined,
                'Report Issue',
              ),
              _driverMenuItem(3, Icons.history_outlined, 'Work History'),
              _driverMenuItem(4, Icons.person_outline, 'Profile'),
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
          AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
                tooltip: 'Open menu',
              ),
            ),
            title: Text(titles[index]),
            actions: [
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

  Widget _driverMenuItem(int page, IconData icon, String label) {
    return ListTile(
      selected: index == page,
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        setState(() => index = page);
        Navigator.pop(context);
      },
    );
  }
}

class DriverTask {
  DriverTask({required this.id, required this.customer, required this.location,
    required this.address, required this.landmark, required this.types,
    required this.quantity, required this.contact, required this.scheduledAt,
    required this.priority, this.latitude = 12.9716, this.longitude = 77.5946, this.status = 'In Progress'});
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
  final double latitude;
  final double longitude;
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
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pickup location map', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(height: 210, child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(t.latitude, t.longitude),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: LatLng(t.latitude, t.longitude),
                  width: 48,
                  height: 48,
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 42),
                ),
              ]),
            ],
          ),
        )),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => MapNavigationScreen(task: t),
          )),
          icon: const Icon(Icons.navigation_outlined),
          label: Text(navigationStarted ? 'Open navigation again' : 'Start navigation'),
        )),
      ]))),
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

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key, required this.task});
  final DriverTask task;

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  LatLng? currentPosition;
  String locationStatus = 'Getting your current location...';

  @override
  void initState() {
    super.initState();
    _loadCurrentPosition();
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
          locationStatus = 'Your location is shown on the map.';
        });
      }
    } on Exception {
      if (mounted) setState(() => locationStatus = 'Could not read your current location.');
    }
  }

  Future<void> _openExternalNavigation() async {
    final destination = '${widget.task.latitude},${widget.task.longitude}';
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open a navigation app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = LatLng(widget.task.latitude, widget.task.longitude);
    final center = currentPosition ?? destination;
    return Scaffold(
      appBar: AppBar(title: Text('Navigate to ${widget.task.location}')),
      body: Column(children: [
        Expanded(child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_application_1',
            ),
            MarkerLayer(markers: [
              Marker(
                point: destination,
                width: 52,
                height: 52,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 46),
              ),
              if (currentPosition != null)
                Marker(
                  point: currentPosition!,
                  width: 42,
                  height: 42,
                  child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                ),
            ]),
          ],
        )),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.task.address, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(locationStatus),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: _openExternalNavigation,
              icon: const Icon(Icons.directions),
              label: const Text('Open turn-by-turn navigation'),
            )),
          ]),
        ),
      ]),
    );
  }
}

class DriverIssue {
  DriverIssue({
    required this.taskId,
    required this.location,
    required this.type,
    required this.description,
    required this.reportedAt,
    required this.customer,
    required this.driverName,
    this.photo,
  });
  final String taskId, location, type, description;
  final String customer, driverName;
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
  static const issueTypes = ['Customer unavailable','Location inaccessible','Garbage not available','Vehicle breakdown','Road blocked','Incorrect address','Fake report','Other'];
  Future<void> choosePhoto() async { try { final f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80); if (f != null) { final bytes = await f.readAsBytes(); if (mounted) setState(() => photo = bytes); } } on PlatformException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open gallery.'))); } }
  void submit() { if (selectedTask == null || description.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a collection and enter an issue description.'))); return; } final task = widget.tasks.firstWhere((t)=>t.id==selectedTask); widget.onIssueAdded(DriverIssue(taskId: task.id, location: task.location, type: issueType, description: description.text.trim(), reportedAt: DateTime.now(), customer: task.customer, driverName: 'Jordan Mathew', photo: photo)); setState(() { description.clear(); photo = null; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(issueType == 'Fake report' ? 'Fake report complaint submitted to manager.' : 'Issue report submitted to manager.'))); }
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
  const DriverProfileScreen({super.key, required this.tasks, required this.driver, required this.availability, required this.isDark, required this.onThemeChanged, required this.onSignOut});
  final List<DriverTask> tasks; final String availability; final bool isDark; final ValueChanged<bool> onThemeChanged; final VoidCallback onSignOut;
  final DriverRecord driver;
  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}
class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController email;
  bool notifications = true;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.driver.name);
    phone = TextEditingController(text: widget.driver.phone);
    email = TextEditingController(text: widget.driver.email);
  }
  @override
  void dispose() {
    name.dispose(); phone.dispose(); email.dispose(); super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final done = widget.tasks.where((t)=>t.status=='Completed').length;
    return ListView(padding: const EdgeInsets.all(20), children: [
      const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 42)), const SizedBox(height: 10), Center(child: Text(name.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), Center(child: Text('Employee ID · ${widget.driver.employeeId}')),
      const SizedBox(height: 18), const Text('Driver details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Driver name')), TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone number')), TextField(controller: email, decoration: const InputDecoration(labelText: 'Email address')),
      const SizedBox(height: 10), OutlinedButton.icon(onPressed: () { setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile details updated for this session.'))); }, icon: const Icon(Icons.save_outlined), label: const Text('Save profile changes')),
      ListTile(leading: const Icon(Icons.local_shipping_outlined), title: const Text('Assigned vehicle'), subtitle: Text(widget.driver.vehicleRegistration)),
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
