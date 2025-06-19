class Review {
  int? id;
  DateTime? createdAt;
  double rating;
  String comment;

  Review({
    this.id,
    this.createdAt,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      //  'created_at': createdAt?.toIso8601String(),
      'rating': rating,
      'comment': comment,
    };
  }
}
