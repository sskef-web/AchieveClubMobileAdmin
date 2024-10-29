class AchievementToEdit {
  final int id;
  final int xp;
  final String titleEn;
  final String titleRu;
  final String titlePl;
  final String descriptionEn;
  final String descriptionRu;
  final String descriptionPl;
  final String logoURL;
  final bool isMultiple;

  AchievementToEdit({
    required this.id,
    required this.xp,
    required this.titleEn,
    required this.titleRu,
    required this.titlePl,
    required this.descriptionEn,
    required this.descriptionRu,
    required this.descriptionPl,
    required this.logoURL,
    required this.isMultiple,
  });

  factory AchievementToEdit.fromJson(Map<String, dynamic> json) {
    return AchievementToEdit(
      id: json['id'],
      xp: json['xp'],
      titleEn: json['title_en'],
      titleRu: json['title_ru'],
      titlePl: json['title_pl'],
      descriptionEn: json['description_en'],
      descriptionRu: json['description_ru'],
      descriptionPl: json['description_pl'],
      logoURL: json['logoURL'],
      isMultiple: json['isMultiple'],
    );
  }
}