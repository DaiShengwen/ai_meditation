import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mood.dart';

class ApiService {
  // 使用具体IP地址而不是localhost
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  Future<Map<String, dynamic>> generateMeditation({
    required List<Mood> selectedMoods,
    String? description,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/generate-meditation');
      print('\n=== 发送 API 请求 ===');
      print('请求 URL: $uri');
      
      final requestBody = {
        'moods': selectedMoods.map((m) => m.toJson()).toList(),
        'description': description ?? '',
      };
      print('请求体: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode(requestBody),
      );

      print('响应状态码: ${response.statusCode}');
      print('响应头: ${response.headers}');
      
      if (response.statusCode == 200) {
        // 使用 utf8.decode 处理响应数据
        final decodedBody = utf8.decode(response.bodyBytes);
        print('解码后的响应体: $decodedBody');
        
        final result = jsonDecode(decodedBody);
        print('解析后的数据: $result');
        return result;
      } else {
        throw Exception('请求失败: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('API 错误: $e');
      rethrow;
    }
  }
} 