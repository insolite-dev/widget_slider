import 'package:flutter/material.dart';

/// The external controller for [WidgetSlider].
class SliderController {
  /// Duration value of sub-function's animations.
  ///
  /// If unset, defaults to the [milliseconds: 350].
  final Duration duration;

  /// Curve style of sub-function's animations.
  ///
  /// If unset, defaults to the [Curves.easeOut].
  final Curve curve;

  SliderController({
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOut,
  });

  /// Navigates to item at given index(i).
  ///
  /// If given index is exceeds min/max length, nothing will happen.
  Future<void> Function(int i)? moveTo;

  /// Navigates to next(current+1) item.
  ///
  /// If next(current+1) is exceeds max length, nothing will happen.
  Future<void> Function()? moveToNext;

  /// Navigates to previous(current-1) item.
  ///
  /// If back(current-1) is exceeds min length, nothing will happen.
  Future<void> Function()? moveToPrevious;
}
