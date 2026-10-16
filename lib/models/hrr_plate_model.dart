import 'package:colorlens/models/ishihara_plate_model.dart';

/// Model for an HRR Plate.
class HRRPlate {
  final int id;
  final String type;
  final String targetShape;
  final String correctAnswer;
  final List<String> options;
  final String cvdType;
  final List<DotData>? dots;

  /// Creates an [HRRPlate].
  const HRRPlate({
    required this.id,
    required this.type,
    required this.targetShape,
    required this.correctAnswer,
    required this.options,
    required this.cvdType,
    this.dots,
  });

  /// Returns a copy of this [HRRPlate] with updated fields.
  HRRPlate copyWith({
    int? id,
    String? type,
    String? targetShape,
    String? correctAnswer,
    List<String>? options,
    String? cvdType,
    List<DotData>? dots,
  }) {
    return HRRPlate(
      id: id ?? this.id,
      type: type ?? this.type,
      targetShape: targetShape ?? this.targetShape,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      cvdType: cvdType ?? this.cvdType,
      dots: dots ?? this.dots,
    );
  }
}
