/// 아이스크림 맛 데이터 모델
/// Ice cream flavor data model
class FlavorModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const FlavorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory FlavorModel.fromJson(Map<String, dynamic> json) {
    return FlavorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() => 'FlavorModel(id: $id, name: $name)';
}
