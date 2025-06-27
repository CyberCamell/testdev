class Track {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String? iconUrl;
  final bool isAvailable;
  final double? rating;
  final String? views;

  Track({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.iconUrl,
    required this.isAvailable,
    this.rating,
    this.views,
  });
  factory Track.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    String? parseViews(dynamic value) {
      if (value is String) return value;
      if (value is int) return value.toString();
      return null;
    }

    return Track(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Track',
      description: json['description'] as String? ?? '',

      imageUrl:
          (json['imageUrl'] as String? ?? '').isEmpty
              ? 'Assets/Images/Flutter_Logo.png'
              : json['imageUrl'],
      iconUrl: json['iconUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: parseDouble(json['rating']),
      views: parseViews(json['views']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'isAvailable': isAvailable,
      'rating': rating,
      'views': views,
    };
  }
}
