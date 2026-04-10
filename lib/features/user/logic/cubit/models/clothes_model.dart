class ClothesModel {
  const ClothesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isMale,
    required this.isUpper,
    required this.size,
    required this.price,
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
      price: _parsePrice(json['price']),
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Matches budget UI (`set_budget_view`) — dollar amounts.
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'des': description,
      'image': image,
      'is_male': isMale,
      'is_upper': isUpper,
      'size': size,
      'price': price,
    };
  }

  final String id;
  final String title;
  final String description;
  final String image;
  final bool isMale;
  final bool isUpper;
  final String size;
  final double price;
}
