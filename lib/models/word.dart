class Word {
  final int? id;
  final String english;
  final String chinese;
  final DateTime createTime;
  final String? category;

  Word({
    this.id,
    required this.english,
    required this.chinese,
    this.category,
    DateTime? createTime,
  }) : this.createTime = createTime ?? DateTime.now();

  Word copyWith({
    int? id,
    String? english,
    String? chinese,
    String? category,
    DateTime? createTime,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      chinese: chinese ?? this.chinese,
      category: category ?? this.category,
      createTime: createTime ?? this.createTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'chinese': chinese,
      'category': category,
      'createTime': createTime.toIso8601String(),
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      english: map['english'],
      chinese: map['chinese'],
      category: map['category'],
      createTime: DateTime.parse(map['createTime']),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Word.fromJson(Map<String, dynamic> json) => Word.fromMap(json);
}