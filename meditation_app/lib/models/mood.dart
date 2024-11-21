class Mood {
  final String id;
  final String name;
  final String? description;
  bool isSelected;

  Mood({
    required this.id,
    required this.name,
    this.description,
    this.isSelected = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isSelected': isSelected,
    };
  }
}