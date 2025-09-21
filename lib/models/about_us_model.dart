class AboutUsContent {
  final String id;
  final String title;
  final String subtitle;
  final String mainDescription;
  final String mission;
  final String vision;
  final String values;
  final String heroImageUrl;
  final String teamImageUrl;
  final List<String> features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AboutUsContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.mainDescription,
    required this.mission,
    required this.vision,
    required this.values,
    required this.heroImageUrl,
    required this.teamImageUrl,
    required this.features,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AboutUsContent.fromJson(Map<String, dynamic> json) {
    return AboutUsContent(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      mainDescription: json['main_description'] as String,
      mission: json['mission'] as String,
      vision: json['vision'] as String,
      values: json['values'] as String,
      heroImageUrl: json['hero_image_url'] as String,
      teamImageUrl: json['team_image_url'] as String,
      features: List<String>.from(json['features'] ?? []),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'main_description': mainDescription,
      'mission': mission,
      'vision': vision,
      'values': values,
      'hero_image_url': heroImageUrl,
      'team_image_url': teamImageUrl,
      'features': features,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AboutUsContent copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? mainDescription,
    String? mission,
    String? vision,
    String? values,
    String? heroImageUrl,
    String? teamImageUrl,
    List<String>? features,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AboutUsContent(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      mainDescription: mainDescription ?? this.mainDescription,
      mission: mission ?? this.mission,
      vision: vision ?? this.vision,
      values: values ?? this.values,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      teamImageUrl: teamImageUrl ?? this.teamImageUrl,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
