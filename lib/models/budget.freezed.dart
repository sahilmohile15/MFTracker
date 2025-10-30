// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Budget _$BudgetFromJson(Map<String, dynamic> json) {
  return _Budget.fromJson(json);
}

/// @nodoc
mixin _$Budget {
  /// Unique identifier for the budget
  String get id => throw _privateConstructorUsedError;

  /// Budget name
  String get name => throw _privateConstructorUsedError;

  /// Budget amount limit
  double get amount => throw _privateConstructorUsedError;

  /// Budget period
  BudgetPeriod get period => throw _privateConstructorUsedError;

  /// Category this budget applies to (null for overall budget)
  Category? get category => throw _privateConstructorUsedError;

  /// Account this budget applies to (null for all accounts)
  String? get accountId => throw _privateConstructorUsedError;

  /// Budget start date
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Budget end date (for custom period)
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Whether budget is active
  bool get isActive => throw _privateConstructorUsedError;

  /// Whether to send notifications
  bool get notificationsEnabled => throw _privateConstructorUsedError;

  /// Alert threshold percentage (e.g., 80 for 80%)
  double get alertThreshold => throw _privateConstructorUsedError;

  /// Budget description/notes
  String? get description => throw _privateConstructorUsedError;

  /// Creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Budget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetCopyWith<Budget> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetCopyWith<$Res> {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) then) =
      _$BudgetCopyWithImpl<$Res, Budget>;
  @useResult
  $Res call({
    String id,
    String name,
    double amount,
    BudgetPeriod period,
    Category? category,
    String? accountId,
    DateTime startDate,
    DateTime? endDate,
    bool isActive,
    bool notificationsEnabled,
    double alertThreshold,
    String? description,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$BudgetCopyWithImpl<$Res, $Val extends Budget>
    implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? period = null,
    Object? category = freezed,
    Object? accountId = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isActive = null,
    Object? notificationsEnabled = null,
    Object? alertThreshold = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as BudgetPeriod,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as Category?,
            accountId: freezed == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            alertThreshold: null == alertThreshold
                ? _value.alertThreshold
                : alertThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BudgetImplCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$$BudgetImplCopyWith(
    _$BudgetImpl value,
    $Res Function(_$BudgetImpl) then,
  ) = __$$BudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    double amount,
    BudgetPeriod period,
    Category? category,
    String? accountId,
    DateTime startDate,
    DateTime? endDate,
    bool isActive,
    bool notificationsEnabled,
    double alertThreshold,
    String? description,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$BudgetImplCopyWithImpl<$Res>
    extends _$BudgetCopyWithImpl<$Res, _$BudgetImpl>
    implements _$$BudgetImplCopyWith<$Res> {
  __$$BudgetImplCopyWithImpl(
    _$BudgetImpl _value,
    $Res Function(_$BudgetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? period = null,
    Object? category = freezed,
    Object? accountId = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isActive = null,
    Object? notificationsEnabled = null,
    Object? alertThreshold = null,
    Object? description = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$BudgetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as BudgetPeriod,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as Category?,
        accountId: freezed == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        alertThreshold: null == alertThreshold
            ? _value.alertThreshold
            : alertThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BudgetImpl implements _Budget {
  const _$BudgetImpl({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    this.category,
    this.accountId,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notificationsEnabled = true,
    this.alertThreshold = 80.0,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$BudgetImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetImplFromJson(json);

  /// Unique identifier for the budget
  @override
  final String id;

  /// Budget name
  @override
  final String name;

  /// Budget amount limit
  @override
  final double amount;

  /// Budget period
  @override
  final BudgetPeriod period;

  /// Category this budget applies to (null for overall budget)
  @override
  final Category? category;

  /// Account this budget applies to (null for all accounts)
  @override
  final String? accountId;

  /// Budget start date
  @override
  final DateTime startDate;

  /// Budget end date (for custom period)
  @override
  final DateTime? endDate;

  /// Whether budget is active
  @override
  @JsonKey()
  final bool isActive;

  /// Whether to send notifications
  @override
  @JsonKey()
  final bool notificationsEnabled;

  /// Alert threshold percentage (e.g., 80 for 80%)
  @override
  @JsonKey()
  final double alertThreshold;

  /// Budget description/notes
  @override
  final String? description;

  /// Creation timestamp
  @override
  final DateTime createdAt;

  /// Last update timestamp
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Budget(id: $id, name: $name, amount: $amount, period: $period, category: $category, accountId: $accountId, startDate: $startDate, endDate: $endDate, isActive: $isActive, notificationsEnabled: $notificationsEnabled, alertThreshold: $alertThreshold, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.alertThreshold, alertThreshold) ||
                other.alertThreshold == alertThreshold) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    amount,
    period,
    category,
    accountId,
    startDate,
    endDate,
    isActive,
    notificationsEnabled,
    alertThreshold,
    description,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      __$$BudgetImplCopyWithImpl<_$BudgetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetImplToJson(this);
  }
}

abstract class _Budget implements Budget {
  const factory _Budget({
    required final String id,
    required final String name,
    required final double amount,
    required final BudgetPeriod period,
    final Category? category,
    final String? accountId,
    required final DateTime startDate,
    final DateTime? endDate,
    final bool isActive,
    final bool notificationsEnabled,
    final double alertThreshold,
    final String? description,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$BudgetImpl;

  factory _Budget.fromJson(Map<String, dynamic> json) = _$BudgetImpl.fromJson;

  /// Unique identifier for the budget
  @override
  String get id;

  /// Budget name
  @override
  String get name;

  /// Budget amount limit
  @override
  double get amount;

  /// Budget period
  @override
  BudgetPeriod get period;

  /// Category this budget applies to (null for overall budget)
  @override
  Category? get category;

  /// Account this budget applies to (null for all accounts)
  @override
  String? get accountId;

  /// Budget start date
  @override
  DateTime get startDate;

  /// Budget end date (for custom period)
  @override
  DateTime? get endDate;

  /// Whether budget is active
  @override
  bool get isActive;

  /// Whether to send notifications
  @override
  bool get notificationsEnabled;

  /// Alert threshold percentage (e.g., 80 for 80%)
  @override
  double get alertThreshold;

  /// Budget description/notes
  @override
  String? get description;

  /// Creation timestamp
  @override
  DateTime get createdAt;

  /// Last update timestamp
  @override
  DateTime get updatedAt;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
