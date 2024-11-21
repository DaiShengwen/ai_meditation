import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meditation_service.dart';

class MeditationPlayerScreen extends StatelessWidget {
  const MeditationPlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 在返回前停止播放
        final meditationService = context.read<MeditationService>();
        if (meditationService.isPlaying) {
          meditationService.togglePlayPause();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () {
              final meditationService = context.read<MeditationService>();
              if (meditationService.isPlaying) {
                meditationService.togglePlayPause();
              }
              Navigator.pop(context);
            },
          ),
        ),
        body: Consumer<MeditationService>(
          builder: (context, meditationService, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      size: 100,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    meditationService.meditationText?.replaceAll('\\n', '\n') ?? '准备开始冥想...',
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // 进度条
                  Slider(
                    value: meditationService.position.inSeconds.toDouble(),
                    max: meditationService.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      meditationService.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  // 时间显示
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(meditationService.position)),
                        Text(_formatDuration(meditationService.duration)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        onPressed: () {
                          final newPosition = meditationService.position - 
                              const Duration(seconds: 10);
                          meditationService.seek(newPosition);
                        },
                        iconSize: 32,
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            meditationService.isPlaying ? 
                                Icons.pause : Icons.play_arrow
                          ),
                          onPressed: () {
                            meditationService.togglePlayPause();
                          },
                          color: Colors.white,
                          iconSize: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        onPressed: () {
                          final newPosition = meditationService.position + 
                              const Duration(seconds: 10);
                          meditationService.seek(newPosition);
                        },
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 