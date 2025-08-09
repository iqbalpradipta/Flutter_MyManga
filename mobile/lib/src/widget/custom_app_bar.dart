import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('MangaBal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 28, color: Colors.white)),
        ],
      ),
    );
  }
}