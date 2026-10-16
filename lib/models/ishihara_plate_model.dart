import 'package:flutter/material.dart';

/// Represents a single dot in an Ishihara plate.
class DotData {
  final double x;
  final double y;
  final double radius;
  final Color color;

  /// Creates a [DotData] with normalized coordinates and size.
  const DotData({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
  });
}

/// Model for an Ishihara Plate.
class IshiharaPlate {
  final int id;
  final int correctAnswer;
  final int? cvdAnswer;
  final String description;
  final List<int> options;
  final String cvdType;
  final List<DotData> dots;
  final String? imagePath;

  /// Creates an [IshiharaPlate].
  const IshiharaPlate({
    required this.id,
    required this.correctAnswer,
    this.cvdAnswer,
    required this.description,
    required this.options,
    required this.cvdType,
    required this.dots,
    this.imagePath,
  });

  /// Returns a copy of this [IshiharaPlate] with updated fields.
  IshiharaPlate copyWith({
    int? id,
    int? correctAnswer,
    int? cvdAnswer,
    String? description,
    List<int>? options,
    String? cvdType,
    List<DotData>? dots,
    String? imagePath,
  }) {
    return IshiharaPlate(
      id: id ?? this.id,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      cvdAnswer: cvdAnswer ?? this.cvdAnswer,
      description: description ?? this.description,
      options: options ?? this.options,
      cvdType: cvdType ?? this.cvdType,
      dots: dots ?? this.dots,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
