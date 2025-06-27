class Language {
  final int id;
  final String name;
  final String code;
  final String? flagUrl;
  final String? description;
  final String? icon;

  Language({
    required this.id,
    required this.name,
    required this.code,
    this.flagUrl,
    this.description,
    this.icon,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Language',
      code: json['code'] as String? ?? '',
      flagUrl: json['flag_url'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'flag_url': flagUrl,
      'description': description,
      'icon': icon,
    };
  }
} 