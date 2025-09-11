import 'package:flutter/material.dart';
import 'package:hope/features/auth/citizen_login_screen.dart';
import 'package:hope/features/auth/ngo_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // A local state variable to manage the "About Us" dropdown visibility.
  bool _isServicesDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildMainContent(context),
              const SizedBox(height: 60),
              _buildAuthCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          Row(
            children: [
              _buildServiceDropdown(context),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {},
                child: const Text('Contact', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return const Text(
      'HopeBridge',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF212121),
      ),
    );
  }

  Widget _buildServiceDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'about', child: Text('About Us')),
        const PopupMenuItem<String>(
          value: 'how_it_works',
          child: Text('How it Works'),
        ),
      ],
      child: const Text(
        'Services',
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(painter: LogoPainter()),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Transforming Citizen Reporting to Actionable Rescues',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Citizen Reporting Card
          GestureDetector(
            onTap: () {
              // This is the correct way to navigate to the login screen.
              Navigator.pushNamed(context, '/citizen-login');
              print('Navigating to citizen login page.');
            },
            child: _buildCard(
              icon: Icons.person_outline,
              title: 'Citizen - Reporting',
              description:
                  'Empowering individuals to report incidents safely and efficiently.',
            ),
          ),
          const SizedBox(height: 20),
          // NGO Rescue Card
          GestureDetector(
            onTap: () {
              // This is the correct way to navigate to the NGO login screen.
              Navigator.pushNamed(context, '/ngo-login');
              print('Navigating to NGO login page.');
            },
            child: _buildCard(
              icon: Icons.group_add_outlined,
              title: 'NGO - Rescue',
              description:
                  'Organize and respond to citizen reports with efficient and coordinated efforts.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.indigo),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path shieldPath = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(0, size.height * 0.75)
      ..lineTo(0, size.height * 0.25)
      ..close();

    final Path leftHandPath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.25, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();

    final Path rightHandPath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.6)
      ..lineTo(size.width * 0.75, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..close();

    final Paint shieldPaint = Paint()..color = const Color(0xFF3F51B5);
    final Paint handsPaint = Paint()..color = const Color(0xFF4CAF50);

    canvas.drawPath(shieldPath, shieldPaint);
    canvas.drawPath(leftHandPath, handsPaint);
    canvas.drawPath(rightHandPath, handsPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
