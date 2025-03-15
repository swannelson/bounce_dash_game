import 'package:flutter/material.dart';
import 'game_screen.dart';

class StageData {
  final String name;
  final String description;
  final Color primaryColor;
  final IconData icon;
  final String backgroundType;

  StageData({
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.icon,
    required this.backgroundType,
  });
}

class StageSelection extends StatelessWidget {
  StageSelection({super.key});

  final List<StageData> stages = [
    StageData(
      name: 'Space Odyssey',
      description: 'Navigate through a starlit void with nebulas and asteroids',
      primaryColor: Colors.indigo,
      icon: Icons.stars,
      backgroundType: 'space',
    ),
    StageData(
      name: 'Cyber City',
      description: 'Dash through a neon-lit cyberpunk cityscape',
      primaryColor: Colors.purple,
      icon: Icons.memory,
      backgroundType: 'cyber',
    ),
    StageData(
      name: 'Forest Haven',
      description: 'Bounce through a mystical forest with floating islands',
      primaryColor: Colors.green,
      icon: Icons.forest,
      backgroundType: 'forest',
    ),
    StageData(
      name: 'Volcanic Core',
      description: 'Dodge molten rocks and navigate through rivers of lava',
      primaryColor: Colors.red,
      icon: Icons.local_fire_department,
      backgroundType: 'volcano',
    ),
    StageData(
      name: 'Ice Kingdom',
      description: 'Glide through crystalline caves and frozen peaks',
      primaryColor: Colors.lightBlue,
      icon: Icons.ac_unit,
      backgroundType: 'ice',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!,
              Colors.purple[900]!,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Text(
              'Select Stage',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: stages.length,
                itemBuilder: (context, index) {
                  final stage = stages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildStageCard(context, stage),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageCard(BuildContext context, StageData stage) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameScreen(stageType: stage.backgroundType),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                stage.primaryColor,
                stage.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  stage.icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stage.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 