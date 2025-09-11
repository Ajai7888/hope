import 'package:flutter/material.dart';

class NGOProfileScreen extends StatefulWidget {
  const NGOProfileScreen({super.key});

  @override
  State<NGOProfileScreen> createState() => _NGOProfileScreenState();
}

class _NGOProfileScreenState extends State<NGOProfileScreen> {
  bool isEditing = false;

  // Placeholder data
  String ngoName = "Nalam NGO";
  String mobileNumber = "+91 9361206802";
  String licenseNumber = "NGO1234567";
  String email = "ngo.hopebridge@example.com";

  // Controllers for text fields
  late TextEditingController nameController;
  late TextEditingController mobileController;
  late TextEditingController licenseController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ngoName);
    mobileController = TextEditingController(text: mobileNumber);
    licenseController = TextEditingController(text: licenseNumber);
    emailController = TextEditingController(text: email);
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    licenseController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFC7514A),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // NGO Name
            isEditing
                ? TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1B2A41),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  )
                : Text(
                    ngoName,
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF1B2A41),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            const SizedBox(height: 4),

            // Email
            isEditing
                ? TextField(
                    controller: emailController,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  )
                : Text(
                    email,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  isEditing
                      ? EditableProfileRow(
                          controller: mobileController,
                          label: "Mobile Number",
                          icon: Icons.phone_rounded,
                        )
                      : ProfileInfoRow(
                          label: 'Mobile Number',
                          value: mobileNumber,
                          icon: Icons.phone_rounded,
                        ),
                  const Divider(height: 32, thickness: 1),
                  isEditing
                      ? EditableProfileRow(
                          controller: licenseController,
                          label: "License Number",
                          icon: Icons.assignment_rounded,
                        )
                      : ProfileInfoRow(
                          label: 'License Number',
                          value: licenseNumber,
                          icon: Icons.assignment_rounded,
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isEditing) {
                    // Just switch back to view mode (don’t actually save)
                    ngoName = nameController.text;
                    mobileNumber = mobileController.text;
                    licenseNumber = licenseController.text;
                    email = emailController.text;
                  }
                  isEditing = !isEditing;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E639A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text(
                isEditing ? 'Save' : 'Edit Profile',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1B2A41)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2A41),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EditableProfileRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const EditableProfileRow({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1B2A41)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
