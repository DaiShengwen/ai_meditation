import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import 'api_service.dart';
import 'package:just_audio/just_audio.dart';

class MeditationService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Mood> _predefinedMoods = [
    Mood(id: '1', name: '焦虑'),
    Mood(id: '2', name: '压力'),
    Mood(id: '3', name: '疲惫'),
    Mood(id: '4', name: '困惑'),
    Mood(id: '5', name: '平静'),
    Mood(id: '6', name: '开心'),
  ];

  String? _meditationText;
  String? _audioUrl;
  bool _isLoading = false;
  String? _error;
  
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 5);
  
  // Getters
  List<Mood> get predefinedMoods => _predefinedMoods;
  String? get meditationText => _meditationText;
  String? get audioUrl => _audioUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  Future<void> initAudio(String url) async {
    try {
      print('\n=== 初始化音频 ===');
      print('音频 URL: $url');
      
      await _audioPlayer.stop();
      print('已停止之前的音频播放');
      
      await _audioPlayer.setUrl(url);
      print('已设置新的音频源');
      
      _duration = await _audioPlayer.duration ?? const Duration(minutes: 5);
      print('音频时长: $_duration');
      
      _audioPlayer.playerStateStream.listen((state) {
        print('音频状态变化: $state');
        _isPlaying = state.playing;
        notifyListeners();
      });

      _audioPlayer.positionStream.listen((position) {
        print('播放位置更新: $position');
        _position = position;
        notifyListeners();
      });

      print('音频初始化完成');
      notifyListeners();
    } catch (e) {
      print('音频初始化错误: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  void togglePlayPause() async {
    try {
      print('切换播放状态，当前状态: $_isPlaying');
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
      notifyListeners();
    } catch (e) {
      print('播放控制错误: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  void seek(Duration position) async {
    try {
      print('跳转到位置: $position');
      await _audioPlayer.seek(position);
      _position = position;
      notifyListeners();
    } catch (e) {
      print('跳转错误: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleMood(String moodId) {
    final index = _predefinedMoods.indexWhere((m) => m.id == moodId);
    if (index != -1) {
      _predefinedMoods[index].isSelected = !_predefinedMoods[index].isSelected;
      notifyListeners();
    }
  }

  Future<void> generateMeditation(String? description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final selectedMoods = _predefinedMoods.where((m) => m.isSelected).toList();
      if (selectedMoods.isEmpty) {
        throw Exception('请至少选择一种情绪');
      }

      final result = await _apiService.generateMeditation(
        selectedMoods: selectedMoods,
        description: description,
      );

      _meditationText = result['text'];
      _audioUrl = result['audioUrl'];
      
      // 初始化音频
      if (_audioUrl != null) {
        await initAudio(_audioUrl!);
      }
      
      // 重置状态
      _position = Duration.zero;
      _isPlaying = false;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 