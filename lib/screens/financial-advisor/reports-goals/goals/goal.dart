import 'package:flutter/material.dart';
import 'package:wise/models/Goals.dart';

class GoalPage extends StatelessWidget {
  final List<Goal> goals; // List of Goal objects
  final String userId;

  const GoalPage({super.key, required this.goals, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1e1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1e1e),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Goal Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: goals.map((goal) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.0,
                          backgroundColor: Colors.amber.shade200,
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            'Goal: ${goal.name}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: _buildGoalInfoCard('Target Amount', 'RM ${goal.targetAmount}'),
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                      child: _buildGoalInfoCard('Current Amount', 'RM ${goal.currentAmount}'),
                    ),
                    const SizedBox(height: 20.0),
                    _buildGoalStatus(goal.isCompleted),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStatus(bool isCompleted) {
    return Center(
      child: Text(
        isCompleted ? 'Status: Completed' : 'Status: In Progress',
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: isCompleted ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
    );
  }
}
