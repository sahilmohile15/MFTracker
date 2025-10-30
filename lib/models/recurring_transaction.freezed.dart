// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurringTransaction _$RecurringTransactionFromJson(Map<String, dynamic> json) {
  return _RecurringTransaction.fromJson(json);
}

/// @nodoc
mixin _$RecurringTransaction {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// Merchant/payee name pattern
  String get merchantPattern => throw _privateConstructorUsedError;

  /// Expected amount (may vary slightly)
  double get amount => throw _privateConstructorUsedError;

  /// Amount tolerance for matching (e.g., ±5%)
  double get amountTolerance => throw _privateConstructorUsedError;

  /// Frequency of recurrence
  RecurringFrequency get frequency => throw _privateConstructorUsedError;

  /// Category of the recurring transaction
  String get category => throw _privateConstructorUsedError;

  /// List of transaction IDs that match this pattern
  List<String> get matchedTransactionIds => throw _privateConstructorUsedError;

  /// Confidence score (0-1) of the pattern detection
  double get confidence => throw _privateConstructorUsedError;

  /// Whether this pattern is confirmed by user
  bool get isConfirmed => throw _privateConstructorUsedError;

  /// Whether to send reminder notifications
  bool get notificationsEnabled => throw _privateConstructorUsedError;

  /// Days before expected date to send reminder
  int get reminderDaysBefore => throw _privateConstructorUsedError;

  /// Next expected transaction date
  DateTime get nextExpectedDate => throw _privateConstructorUsedError;

  /// Last detected transaction date
  DateTime get lastDetectedDate => throw _privateConstructorUsedError;

  /// Date when pattern was first detected
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Optional notes/description
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this RecurringTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurringTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurringTransactionCopyWith<RecurringTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringTransactionCopyWith<$Res> {
  factory $RecurringTransactionCopyWith(
    RecurringTransaction value,
    $Res Function(RecurringTransaction) then,
  ) = _$RecurringTransactionCopyWithImpl<$Res, RecurringTransaction>;
  @useResult
  $Res call({
    String id,
    String merchantPattern,
    double amount,
    double amountTolerance,
    RecurringFrequency frequency,
    String category,
    List<String> matchedTransactionIds,
    double confidence,
    bool isConfirmed,
    bool notificationsEnabled,
    int reminderDaysBefore,
    DateTime nextExpectedDate,
    DateTime lastDetectedDate,
    DateTime createdAt,
    DateTime updatedAt,
    String? notes,
  });
}

/// @nodoc
class _$RecurringTransactionCopyWithImpl<
  $Res,
  $Val extends RecurringTransaction
>
    implements $RecurringTransactionCopyWith<$Res> {
  _$RecurringTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurringTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? merchantPattern = null,
    Object? amount = null,
    Object? amountTolerance = null,
    Object? frequency = null,
    Object? category = null,
    Object? matchedTransactionIds = null,
    Object? confidence = null,
    Object? isConfirmed = null,
    Object? notificationsEnabled = null,
    Object? reminderDaysBefore = null,
    Object? nextExpectedDate = null,
    Object? lastDetectedDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            merchantPattern: null == merchantPattern
                ? _value.merchantPattern
                : merchantPattern // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            amountTolerance: null == amountTolerance
                ? _value.amountTolerance
                : amountTolerance // ignore: cast_nullable_to_non_nullable
                      as double,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as RecurringFrequency,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            matchedTransactionIds: null == matchedTransactionIds
                ? _value.matchedTransactionIds
                : matchedTransactionIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            isConfirmed: null == isConfirmed
                ? _value.isConfirmed
                : isConfirmed // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderDaysBefore: null == reminderDaysBefore
                ? _value.reminderDaysBefore
                : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
                      as int,
            nextExpectedDate: null == nextExpectedDate
                ? _value.nextExpectedDate
                : nextExpectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastDetectedDate: null == lastDetectedDate
                ? _value.lastDetectedDate
                : lastDetectedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurringTransactionImplCopyWith<$Res>
    implements $RecurringTransactionCopyWith<$Res> {
  factory _$$RecurringTransactionImplCopyWith(
    _$RecurringTransactionImpl value,
    $Res Function(_$RecurringTransactionImpl) then,
  ) = __$$RecurringTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String merchantPattern,
    double amount,
    double amountTolerance,
    RecurringFrequency frequency,
    String category,
    List<String> matchedTransactionIds,
    double confidence,
    bool isConfirmed,
    bool notificationsEnabled,
    int reminderDaysBefore,
    DateTime nextExpectedDate,
    DateTime lastDetectedDate,
    DateTime createdAt,
    DateTime updatedAt,
    String? notes,
  });
}

/// @nodoc
class __$$RecurringTransactionImplCopyWithImpl<$Res>
    extends _$RecurringTransactionCopyWithImpl<$Res, _$RecurringTransactionImpl>
    implements _$$RecurringTransactionImplCopyWith<$Res> {
  __$$RecurringTransactionImplCopyWithImpl(
    _$RecurringTransactionImpl _value,
    $Res Function(_$RecurringTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurringTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? merchantPattern = null,
    Object? amount = null,
    Object? amountTolerance = null,
    Object? frequency = null,
    Object? category = null,
    Object? matchedTransactionIds = null,
    Object? confidence = null,
    Object? isConfirmed = null,
    Object? notificationsEnabled = null,
    Object? reminderDaysBefore = null,
    Object? nextExpectedDate = null,
    Object? lastDetectedDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$RecurringTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        merchantPattern: null == merchantPattern
            ? _value.merchantPattern
            : merchantPattern // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        amountTolerance: null == amountTolerance
            ? _value.amountTolerance
            : amountTolerance // ignore: cast_nullable_to_non_nullable
                  as double,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as RecurringFrequency,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        matchedTransactionIds: null == matchedTransactionIds
            ? _value._matchedTransactionIds
            : matchedTransactionIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        isConfirmed: null == isConfirmed
            ? _value.isConfirmed
            : isConfirmed // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderDaysBefore: null == reminderDaysBefore
            ? _value.reminderDaysBefore
            : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
                  as int,
        nextExpectedDate: null == nextExpectedDate
            ? _value.nextExpectedDate
            : nextExpectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastDetectedDate: null == lastDetectedDate
            ? _value.lastDetectedDate
            : lastDetectedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurringTransactionImpl implements _RecurringTransaction {
  const _$RecurringTransactionImpl({
    required this.id,
    required this.merchantPattern,
    required this.amount,
    this.amountTolerance = 0.05,
    required this.frequency,
    required this.category,
    required final List<String> matchedTransactionIds,
    required this.confidence,
    this.isConfirmed = false,
    this.notificationsEnabled = true,
    this.reminderDaysBefore = 3,
    required this.nextExpectedDate,
    required this.lastDetectedDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  }) : _matchedTransactionIds = matchedTransactionIds;

  factory _$RecurringTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringTransactionImplFromJson(json);

  /// Unique identifier
  @override
  final String id;

  /// Merchant/payee name pattern
  @override
  final String merchantPattern;

  /// Expected amount (may vary slightly)
  @override
  final double amount;

  /// Amount tolerance for matching (e.g., ±5%)
  @override
  @JsonKey()
  final double amountTolerance;

  /// Frequency of recurrence
  @override
  final RecurringFrequency frequency;

  /// Category of the recurring transaction
  @override
  final String category;

  /// List of transaction IDs that match this pattern
  final List<String> _matchedTransactionIds;

  /// List of transaction IDs that match this pattern
  @override
  List<String> get matchedTransactionIds {
    if (_matchedTransactionIds is EqualUnmodifiableListView)
      return _matchedTransactionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchedTransactionIds);
  }

  /// Confidence score (0-1) of the pattern detection
  @override
  final double confidence;

  /// Whether this pattern is confirmed by user
  @override
  @JsonKey()
  final bool isConfirmed;

  /// Whether to send reminder notifications
  @override
  @JsonKey()
  final bool notificationsEnabled;

  /// Days before expected date to send reminder
  @override
  @JsonKey()
  final int reminderDaysBefore;

  /// Next expected transaction date
  @override
  final DateTime nextExpectedDate;

  /// Last detected transaction date
  @override
  final DateTime lastDetectedDate;

  /// Date when pattern was first detected
  @override
  final DateTime createdAt;

  /// Last update timestamp
  @override
  final DateTime updatedAt;

  /// Optional notes/description
  @override
  final String? notes;

  @override
  String toString() {
    return 'RecurringTransaction(id: $id, merchantPattern: $merchantPattern, amount: $amount, amountTolerance: $amountTolerance, frequency: $frequency, category: $category, matchedTransactionIds: $matchedTransactionIds, confidence: $confidence, isConfirmed: $isConfirmed, notificationsEnabled: $notificationsEnabled, reminderDaysBefore: $reminderDaysBefore, nextExpectedDate: $nextExpectedDate, lastDetectedDate: $lastDetectedDate, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.merchantPattern, merchantPattern) ||
                other.merchantPattern == merchantPattern) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.amountTolerance, amountTolerance) ||
                other.amountTolerance == amountTolerance) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(
              other._matchedTransactionIds,
              _matchedTransactionIds,
            ) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.isConfirmed, isConfirmed) ||
                other.isConfirmed == isConfirmed) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.reminderDaysBefore, reminderDaysBefore) ||
                other.reminderDaysBefore == reminderDaysBefore) &&
            (identical(other.nextExpectedDate, nextExpectedDate) ||
                other.nextExpectedDate == nextExpectedDate) &&
            (identical(other.lastDetectedDate, lastDetectedDate) ||
                other.lastDetectedDate == lastDetectedDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    merchantPattern,
    amount,
    amountTolerance,
    frequency,
    category,
    const DeepCollectionEquality().hash(_matchedTransactionIds),
    confidence,
    isConfirmed,
    notificationsEnabled,
    reminderDaysBefore,
    nextExpectedDate,
    lastDetectedDate,
    createdAt,
    updatedAt,
    notes,
  );

  /// Create a copy of RecurringTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringTransactionImplCopyWith<_$RecurringTransactionImpl>
  get copyWith =>
      __$$RecurringTransactionImplCopyWithImpl<_$RecurringTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringTransactionImplToJson(this);
  }
}

abstract class _RecurringTransaction implements RecurringTransaction {
  const factory _RecurringTransaction({
    required final String id,
    required final String merchantPattern,
    required final double amount,
    final double amountTolerance,
    required final RecurringFrequency frequency,
    required final String category,
    required final List<String> matchedTransactionIds,
    required final double confidence,
    final bool isConfirmed,
    final bool notificationsEnabled,
    final int reminderDaysBefore,
    required final DateTime nextExpectedDate,
    required final DateTime lastDetectedDate,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? notes,
  }) = _$RecurringTransactionImpl;

  factory _RecurringTransaction.fromJson(Map<String, dynamic> json) =
      _$RecurringTransactionImpl.fromJson;

  /// Unique identifier
  @override
  String get id;

  /// Merchant/payee name pattern
  @override
  String get merchantPattern;

  /// Expected amount (may vary slightly)
  @override
  double get amount;

  /// Amount tolerance for matching (e.g., ±5%)
  @override
  double get amountTolerance;

  /// Frequency of recurrence
  @override
  RecurringFrequency get frequency;

  /// Category of the recurring transaction
  @override
  String get category;

  /// List of transaction IDs that match this pattern
  @override
  List<String> get matchedTransactionIds;

  /// Confidence score (0-1) of the pattern detection
  @override
  double get confidence;

  /// Whether this pattern is confirmed by user
  @override
  bool get isConfirmed;

  /// Whether to send reminder notifications
  @override
  bool get notificationsEnabled;

  /// Days before expected date to send reminder
  @override
  int get reminderDaysBefore;

  /// Next expected transaction date
  @override
  DateTime get nextExpectedDate;

  /// Last detected transaction date
  @override
  DateTime get lastDetectedDate;

  /// Date when pattern was first detected
  @override
  DateTime get createdAt;

  /// Last update timestamp
  @override
  DateTime get updatedAt;

  /// Optional notes/description
  @override
  String? get notes;

  /// Create a copy of RecurringTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurringTransactionImplCopyWith<_$RecurringTransactionImpl>
  get copyWith => throw _privateConstructorUsedError;
}
