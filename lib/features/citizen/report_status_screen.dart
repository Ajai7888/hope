import 'package:flutter/material.dart';

class ReportStatusScreen extends StatelessWidget {
  const ReportStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Reports")),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (_, index) => Card(
          child: ListTile(
            title: Text("Report #$index"),
            subtitle: const Text("Status: Pending"),
          ),
        ),
      ),
    );
  }
}
