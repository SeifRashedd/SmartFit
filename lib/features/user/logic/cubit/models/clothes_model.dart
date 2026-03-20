class ClothesModel {
  const ClothesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isMale,
    required this.isUpper,
    required this.size,
  });

  factory ClothesModel.fromJson(Map<String, dynamic> json) {
    return ClothesModel(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      description: (json['des'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      isMale: (json['is_male'] ?? false) as bool,
      isUpper: (json['is_upper'] ?? false) as bool,
      size: (json['size'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'des': description,
      'image': image,
      'is_male': isMale,
      'is_upper': isUpper,
      'size': size,
    };
  }

  final String id;
  final String title;
  final String description;
  final String image;
  final bool isMale;
  final bool isUpper;
  final String size;
}
