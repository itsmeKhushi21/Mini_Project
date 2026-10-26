import 'package:flutter/material.dart';

void main() {
  runApp(const GarbageApp());
}

const green = Color(0xFF218838);

class GarbageApp extends StatelessWidget {
  const GarbageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart City Garbage Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF4F8F3),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const Icon(Icons.recycling, size: 85, color: green),
                const SizedBox(height: 16),
                const Text(
                  'Smart City',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const Text('Garbage Management System'),
                const SizedBox(height: 10),
                const Text('Cleaner streets, greener future.'),
                const SizedBox(height: 36),
                const Text(
                  'Choose your role',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _roleCard(
                  context,
                  'Citizen',
                  'Report garbage issues and track complaints.',
                  Icons.people_alt,
                  green,
                ),
                const SizedBox(height: 16),
                _roleCard(
                  context,
                  'Driver',
                  'View collection tasks and update garbage loads.',
                  Icons.local_shipping,
                  Colors.blue,
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
    String role,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: color, size: 45),
            const SizedBox(height: 8),
            Text(
              role,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardScreen(role: role),
                    ),
                  );
                },
                child: Text('Continue as $role'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> bins = [
    {'name': 'Main Gate Bin', 'area': 'Campus Main Gate', 'fill': 92},
    {'name': 'Library Bin', 'area': 'Library Block', 'fill': 58},
    {'name': 'Cafeteria Bin', 'area': 'Food Court', 'fill': 76},
  ];

  final List<Map<String, String>> complaints = [];

  Future<void> reportComplaint() async {
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    String issue = 'Overflowing garbage bin';

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Report a garbage issue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: issue,
                  decoration: const InputDecoration(labelText: 'Issue type'),
                  items:
                      [
                        'Overflowing garbage bin',
                        'Garbage not collected',
                        'Illegal dumping',
                        'Damaged bin',
                      ].map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => issue = value);
                    }
                  },
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location or landmark',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (locationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter the location first.')),
                  );
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );

    if (submitted == true && mounted) {
      
final now = DateTime.now();

setState(() {
  complaints.insert(0, {
    'id': 'GMS-${now.millisecondsSinceEpoch.toString().substring(7)}',
    'issue': issue,
    'location': locationController.text.trim(),
    'description': descriptionController.text.trim(),
    'status': 'Submitted',
    'date': now.toLocal().toString().substring(0, 16),
  });
});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Complaint submitted!')));
    }

    locationController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'Driver') {
      return Scaffold(
        appBar: AppBar(title: const Text('Driver Dashboard')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Driver Dashboard\n\nCollection tasks and route management '
              'will be added here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Dashboard'),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: reportComplaint,
        backgroundColor: green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Report Issue'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Hello, Citizen!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('Help keep your city clean and healthy.'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Nearby Bins',
                  '${bins.length}',
                  Icons.delete,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'My Reports',
                  '${complaints.length}',
                  Icons.assignment,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Nearby Garbage Bins',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...bins.map((bin) {
            final fill = bin['fill'] as int;
            final color = fill >= 80 ? Colors.red : green;

            return Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bin['name'] as String,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(bin['area'] as String),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: fill / 100,
                      color: color,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$fill% full · ${fill >= 80 ? 'Needs collection' : 'Normal'}',
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'My Complaints',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (complaints.isEmpty)
            const Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No complaints submitted yet.'),
              ),
            )
          else
            ...complaints.map(
              (complaint) => Card(
                color: Colors.white,
                child: ListTile(
                 

  leading: const CircleAvatar(
    backgroundColor: Color(0xFFDDF3DF),
    child: Icon(Icons.assignment_outlined, color: green),
  ),
  title: Text(
    complaint['issue']!,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      'ID: ${complaint['id']}\n'
      'Location: ${complaint['location']}\n'
      'Submitted: ${complaint['date']}\n'
      '${complaint['description'] ?? ''}',
    ),
  ),
  isThreeLine: true,
  trailing: Chip(
    backgroundColor: const Color(0xFFDDF3DF),
    label: Text(
      complaint['status']!,
      style: const TextStyle(
        color: Color(0xFF176B32),
        fontSize: 11,
      ),
    ),
  ),
)

                ),
              ),
            
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: green, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}
