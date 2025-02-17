// Copyright 2016 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:meta/meta.dart';

import '../../value.dart' as internal;
import 'value.dart';

/// A SassScript number.
///
/// Numbers can have units. Although there's no literal syntax for it, numbers
/// support scientific-style numerator and denominator units (for example,
/// `miles/hour`). These are expected to be resolved before being emitted to
/// CSS.
@sealed
abstract class SassNumber extends Value {
  /// The number of distinct digits that are emitted when converting a number to
  /// CSS.
  static const precision = 10;

  /// The value of this number.
  ///
  /// Note that due to details of floating-point arithmetic, this may be a
  /// [double] even if [this] represents an int from Sass's perspective. Use
  /// [isInt] to determine whether this is an integer, [asInt] to get its
  /// integer value, or [assertInt] to do both at once.
  num get value;

  /// This number's numerator units.
  List<String> get numeratorUnits;

  /// This number's denominator units.
  List<String> get denominatorUnits;

  /// Whether [this] has any units.
  ///
  /// If a function expects a number to have no units, it should use
  /// [assertNoUnits]. If it expects the number to have a particular unit, it
  /// should use [assertUnit].
  bool get hasUnits;

  /// Whether [this] is an integer, according to [fuzzyEquals].
  ///
  /// The [int] value can be accessed using [asInt] or [assertInt]. Note that
  /// this may return `false` for very large doubles even though they may be
  /// mathematically integers, because not all platforms have a valid
  /// representation for integers that large.
  bool get isInt;

  /// If [this] is an integer according to [isInt], returns [value] as an [int].
  ///
  /// Otherwise, returns `null`.
  int? get asInt;

  /// Creates a number, optionally with a single numerator unit.
  ///
  /// This matches the numbers that can be written as literals.
  /// [SassNumber.withUnits] can be used to construct more complex units.
  factory SassNumber(num value, [String? unit]) = internal.SassNumber;

  /// Creates a number with full [numeratorUnits] and [denominatorUnits].
  factory SassNumber.withUnits(num value,
      {List<String>? numeratorUnits,
      List<String>? denominatorUnits}) = internal.SassNumber.withUnits;

  /// Returns [value] as an [int], if it's an integer value according to
  /// [isInt].
  ///
  /// Throws a [SassScriptException] if [value] isn't an integer. If this came
  /// from a function argument, [name] is the argument name (without the `$`).
  /// It's used for error reporting.
  int assertInt([String? name]);

  /// If [value] is between [min] and [max], returns it.
  ///
  /// If [value] is [fuzzyEquals] to [min] or [max], it's clamped to the
  /// appropriate value. Otherwise, this throws a [SassScriptException]. If this
  /// came from a function argument, [name] is the argument name (without the
  /// `$`). It's used for error reporting.
  num valueInRange(num min, num max, [String? name]);

  /// Returns whether [this] has [unit] as its only unit (and as a numerator).
  bool hasUnit(String unit);

  /// Returns whether [this] can be coerced to the given [unit].
  ///
  /// This always returns `true` for a unitless number.
  bool compatibleWithUnit(String unit);

  /// Throws a [SassScriptException] unless [this] has [unit] as its only unit
  /// (and as a numerator).
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`). It's used for error reporting.
  void assertUnit(String unit, [String? name]);

  /// Throws a [SassScriptException] unless [this] has no units.
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`). It's used for error reporting.
  void assertNoUnits([String? name]);

  /// Returns a copy of this number, converted to the same units as [other].
  ///
  /// Unlike [convertToMatch], this does *not* throw an error if this number is
  /// unitless and [other] is not, or vice versa. Instead, it treats all
  /// unitless numbers as convertible to and from all units without changing the
  /// value.
  ///
  /// Note that [coerceValueToMatch] is generally more efficient if the value is
  /// going to be accessed directly.
  ///
  /// Throws a [SassScriptException] if this number's units aren't compatible
  /// with [other]'s units.
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`) and [otherName] is the argument name for [other]. These
  /// are used for error reporting.
  SassNumber coerceToMatch(SassNumber other, [String? name, String? otherName]);

  /// Returns [value], converted to the same units as [other].
  ///
  /// Unlike [convertValueToMatch], this does *not* throw an error if this
  /// number is unitless and [other] is not, or vice versa. Instead, it treats
  /// all unitless numbers as convertible to and from all units without changing
  /// the value.
  ///
  /// Throws a [SassScriptException] if this number's units aren't compatible
  /// with [other]'s units.
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`) and [otherName] is the argument name for [other]. These
  /// are used for error reporting.
  num coerceValueToMatch(SassNumber other, [String? name, String? otherName]);

  /// Returns a copy of this number, converted to the same units as [other].
  ///
  /// Note that [convertValueToMatch] is generally more efficient if the value
  /// is going to be accessed directly.
  ///
  /// Throws a [SassScriptException] if this number's units aren't compatible
  /// with [other]'s units, or if either number is unitless but the other is
  /// not.
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`) and [otherName] is the argument name for [other]. These
  /// are used for error reporting.
  SassNumber convertToMatch(SassNumber other,
      [String? name, String? otherName]);

  /// Returns [value], converted to the same units as [other].
  ///
  /// Throws a [SassScriptException] if this number's units aren't compatible
  /// with [other]'s units, or if either number is unitless but the other is
  /// not.
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`) and [otherName] is the argument name for [other]. These
  /// are used for error reporting.
  num convertValueToMatch(SassNumber other, [String? name, String? otherName]);

  /// Returns a copy of this number, converted to the units represented by
  /// [newNumerators] and [newDenominators].
  ///
  /// This does *not* throw an error if this number is unitless and
  /// [newNumerators]/[newDenominators] are not empty, or vice versa. Instead,
  /// it treats all unitless numbers as convertible to and from all units
  /// without changing the value.
  ///
  /// Note that [coerceValue] is generally more efficient if the value is going
  /// to be accessed directly.
  ///
  /// Throws a [SassScriptException] if this number's units aren't compatible
  /// with [newNumerators] and [newDenominators].
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`). It's used for error reporting.
  SassNumber coerce(List<String> newNumerators, List<String> newDenominators,
      [String? name]);

  /// Returns [value], converted to the units represented by [newNumerators] and
  /// [newDenominators].
  ///
  /// This does *not* throw an error if this number is unitless and
  /// [newNumerators]/[newDenominators] are not empty, or vice versa. Instead,
  /// it treats all unitless numbers as convertible to and from all units
  /// without changing the value.
  ///
  /// Throws a [SassScriptException] if this number's units aren't compatible
  /// with [newNumerators] and [newDenominators].
  ///
  /// If this came from a function argument, [name] is the argument name
  /// (without the `$`). It's used for error reporting.
  num coerceValue(List<String> newNumerators, List<String> newDenominators,
      [String? name]);

  /// This has been renamed [coerceValue] for consistency with [coerceToMatch],
  /// [coerceValueToMatch], [convertToMatch], and [convertValueToMatch].
  @deprecated
  num valueInUnits(List<String> newNumerators, List<String> newDenominators,
      [String? name]);

  /// A shorthand for [coerceValue] with only one numerator unit.
  num coerceValueToUnit(String unit, [String? name]);
}
