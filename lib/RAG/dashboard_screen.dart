import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(onPressed: (){

            }, child: const Text("Chat")),
            const SizedBox(height: 16),
            FilledButton(onPressed: (){

            }, child: const Text("Image To Text"))
          ]
        ),
      ),
    );
  }
}
