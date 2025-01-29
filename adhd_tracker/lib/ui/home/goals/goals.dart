import 'package:flutter/material.dart';
import 'package:mindle/models/database_helper.dart';
import 'package:mindle/models/goals.dart';
import 'package:mindle/ui/home/goals/add_goal.dart';

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await DatabaseHelper.instance.getAllGoals();
    setState(() {
      _goals = goals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Goals'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              return ListTile(
                title: Text(goal.name),
                subtitle: Text('${goal.frequency} - Started: ${goal.startDate}'),
                trailing: Text(goal.notes),
              );
            },
          ),
          // Positioned ElevatedButton for Add Goal
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewGoalPage()),
                ).then((_) => _loadGoals()); // Refresh goals after adding
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.deepPurple, // Replace with your color
                shape: const CircleBorder(), // Optional for circular button
                elevation: 4,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
