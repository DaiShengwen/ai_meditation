import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meditation_service.dart';
import 'meditation_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<MeditationService>(
          builder: (context, meditationService, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      '今天感觉如何？',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '选择你当前的心情，让我们为你创建个性化的冥想引导。',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: meditationService.predefinedMoods.map((mood) {
                        return FilterChip(
                          label: Text(mood.name),
                          selected: mood.isSelected,
                          onSelected: (selected) {
                            meditationService.toggleMood(mood.id);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.indigo.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: '或者详细描述一下你的感受...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 40),
                    if (meditationService.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            await meditationService.generateMeditation(
                              _descriptionController.text,
                            );
                            if (meditationService.error == null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MeditationPlayerScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '开始冥想',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    if (meditationService.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          meditationService.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
} 