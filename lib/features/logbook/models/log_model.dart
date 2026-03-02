import 'package:bson/src/classes/object_id.dart';

class LogModel {
  final ObjectId? id;
  final String title;
  final String date;
  final String description;
  final String category;

  LogModel({
    this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.category,
  });

  // Untuk Tugas HOTS: Konversi Map (JSON) ke Object
  factory LogModel.fromMap(Map<String, dynamic> map) {
    final dynamic rawId = map['_id'] ?? map['id'];
    final String rawCategory = (map['category'] ?? '').toString().trim();
    final String normalizedCategory = rawCategory.isEmpty
        ? 'Pribadi'
        : rawCategory;

    return LogModel(
      id: rawId is ObjectId ? rawId : null,
      title: map['title'],
      date: map['date'],
      description: map['description'],
      category: normalizedCategory,
    );
  }

  // Konversi Object ke Map (JSON) untuk disimpan
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };

    if (id != null) {
      map['_id'] = id;
    }

    return map;
  }
}
