import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/flavor_model.dart';

/// 아이스크림 맛 데이터 로드 서비스
/// Ice cream flavor data loading service
class FlavorService {
  static const String _assetPath = 'assets/data/baskin_flavors.json';

  /// JSON 파일에서 맛 데이터 로드
  Future<List<FlavorModel>> loadFlavors() async {
    try {
      final String jsonString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      return jsonList
          .map((json) => FlavorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('맛 데이터를 불러오는 데 실패했습니다: $e');
    }
  }
}
