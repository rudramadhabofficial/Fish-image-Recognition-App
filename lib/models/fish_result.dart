class FishResult {
  int? id;
  String imagePath;
  String species;
  int count;
  double confidence;
  double individualWeight;
  double totalWeight;
  String healthStatus;
  DateTime analyzedAt;
  bool uploadedToMarket;

  FishResult({
    this.id,
    required this.imagePath,
    required this.species,
    required this.count,
    required this.confidence,
    required this.individualWeight,
    required this.totalWeight,
    required this.healthStatus,
    required this.analyzedAt,
    this.uploadedToMarket = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'species': species,
      'count': count,
      'confidence': confidence,
      'individual_weight': individualWeight,
      'total_weight': totalWeight,
      'health_status': healthStatus,
      'analyzed_at': analyzedAt.toIso8601String(),
      'uploaded_to_market': uploadedToMarket ? 1 : 0,
    };
  }

  factory FishResult.fromMap(Map<String, dynamic> map) {
    return FishResult(
      id: map['id'],
      imagePath: map['image_path'],
      species: map['species'],
      count: map['count'],
      confidence: map['confidence'].toDouble(),
      individualWeight: map['individual_weight'].toDouble(),
      totalWeight: map['total_weight'].toDouble(),
      healthStatus: map['health_status'],
      analyzedAt: DateTime.parse(map['analyzed_at']),
      uploadedToMarket: map['uploaded_to_market'] == 1,
    );
  }
}