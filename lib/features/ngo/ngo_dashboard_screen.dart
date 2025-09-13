import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camera.dart';
import 'ngo_profile_screen.dart';

class NGODashboardScreen extends StatefulWidget {
  const NGODashboardScreen({super.key});

  @override
  State<NGODashboardScreen> createState() => _NGODashboardScreenState();
}

class _NGODashboardScreenState extends State<NGODashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardContent(),
    NGOVolunteersScreen(),
    NGOProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NGO Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B2A41),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_rounded),
            label: 'Volunteers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade300,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// ---------- Dashboard with Live Firestore Data ----------
class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRef = FirebaseFirestore.instance.collection('reports');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          /// Top Cards
          StreamBuilder<QuerySnapshot>(
            stream: reportsRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;

              final newReports = docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return (data['status'] ?? 'new') == 'new';
              }).length;

              final activeRescues = docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return (data['status'] ?? '') == 'active';
              }).length;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoCard(
                    title: 'New Reports',
                    value: newReports.toString(),
                    icon: Icons.assignment_rounded,
                    color: Colors.blue.shade100,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E639A), Color(0xFF1F486C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  InfoCard(
                    title: 'Active Rescues',
                    value: activeRescues.toString(),
                    icon: Icons.health_and_safety_rounded,
                    color: Colors.red.shade100,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC7514A), Color(0xFFB13A33)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          /// Recent Incidents Section
          const Text(
            'Recent Incidents',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2A41),
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: reportsRef
                .orderBy('createdAt', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Text("No reports available.");
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return IncidentCard(
                    reportId: doc.id,
                    description: data['description'] ?? 'No description',
                    status: data['status'] ?? 'new',
                    imageUrl: data['imageUrl'],
                    location:
                        data['location'] ??
                        'Administration Office, Chennai, India',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------- InfoCard ----------
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Gradient? gradient;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 36;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- IncidentCard ----------
class IncidentCard extends StatelessWidget {
  final String reportId;
  final String description;
  final String status;
  final String? imageUrl;
  final String location;

  const IncidentCard({
    super.key,
    required this.reportId,
    required this.description,
    required this.status,
    this.imageUrl,
    required this.location,
  });

  Future<void> _updateStatus(String newStatus) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update(
      {'status': newStatus},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1B2A41),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              "Status: $status",
              style: TextStyle(
                color: status == "active"
                    ? Colors.green
                    : status == "rejected"
                    ? Colors.red
                    : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: status == "new"
                      ? () => _updateStatus("active")
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C9A2A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: status == "new"
                      ? () => _updateStatus("rejected")
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC44D58),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NGOVolunteersScreen extends StatelessWidget {
  const NGOVolunteersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Volunteers',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2A41),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                VolunteerCard(name: 'Ajai', area: 'Navalur'),
                VolunteerCard(name: 'Eric', area: 'Kilambakkam'),
                VolunteerCard(name: 'Nitya', area: 'Sholinganallur'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VolunteerCard extends StatelessWidget {
  final String name;
  final String area;

  const VolunteerCard({super.key, required this.name, required this.area});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2E639A),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Text(area),
      ),
    );
  }
}
