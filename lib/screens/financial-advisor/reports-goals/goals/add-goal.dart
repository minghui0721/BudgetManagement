import 'package:flutter/material.dart';

class AddGoalsPage extends StatelessWidget {
  const AddGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9E5C0), // Background color matching the image
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e), // Keep the background consistent with your header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White arrow back icon
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        centerTitle: true,
        title: const Text(
          'Goals', // Title for the Goals page
          style: TextStyle(
            color: Colors.white, // White text for title
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Goals',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8.0),
            _buildTextField('Set Goals...'),

            const SizedBox(height: 16.0),
            const Text(
              'Additional Comments',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8.0),
            _buildTextField('Additional Comments...'),

            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(child: _buildTextField('Start Date...')),
                const SizedBox(width: 16.0),
                Expanded(child: _buildTextField('End Date...')),
              ],
            ),

            const SizedBox(height: 16.0),
            _buildTextField('Target User...'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement submission logic
        },
        backgroundColor: Colors.pinkAccent, // Color of the floating button
        child: const Icon(Icons.arrow_forward, color: Colors.white), // Icon matching the design
      ),
    );
  }

  // Helper function to create text input fields
  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38), // Light black hint text color
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, // Remove border line for cleaner look
        ),
      ),
    );
  }
}
