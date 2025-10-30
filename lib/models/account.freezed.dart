// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Account _$AccountFromJson(Map<String, dynamic> json) {
  return _Account.fromJson(json);
}

/// @nodoc
mixin _$Account {
  /// Unique identifier for the account
  String get id => throw _privateConstructorUsedError;

  /// Account name (e.g., "HDFC Savings", "ICICI Credit Card")
  String get name => throw _privateConstructorUsedError;

  /// Type of account
  AccountType get type => throw _privateConstructorUsedError;

  /// Bank/institution name
  String get institution => throw _privateConstructorUsedError;

  /// Last 4 digits of account number
  String? get accountNumber => throw _privateConstructorUsedError;

  /// Current balance (if tracked)
  double? get balance => throw _privateConstructorUsedError;

  /// Credit limit (for credit cards)
  double? get creditLimit => throw _privateConstructorUsedError;

  /// Currency code (default: INR)
  String get currency => throw _privateConstructorUsedError;

  /// Custom color for the account (hex string)
  String? get color => throw _privateConstructorUsedError;

  /// Custom icon name
  String? get icon => throw _privateConstructorUsedError;

  /// Whether this account is active
  bool get isActive => throw _privateConstructorUsedError;

  /// Whether to include in total balance calculations
  bool get includeInTotal => throw _privateConstructorUsedError;

  /// Default category for transactions from this account
  Category? get defaultCategory => throw _privateConstructorUsedError;

  /// Notes about the account
  String? get notes => throw _privateConstructorUsedError;

  /// Creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountCopyWith<Account> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) then) =
      _$AccountCopyWithImpl<$Res, Account>;
  @useResult
  $Res call({
    String id,
    String name,
    AccountType type,
    String institution,
    String? accountNumber,
    double? balance,
    double? creditLimit,
    String currency,
    String? color,
    String? icon,
    bool isActive,
    bool includeInTotal,
    Category? defaultCategory,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$AccountCopyWithImpl<$Res, $Val extends Account>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? institution = null,
    Object? accountNumber = freezed,
    Object? balance = freezed,
    Object? creditLimit = freezed,
    Object? currency = null,
    Object? color = freezed,
    Object? icon = freezed,
    Object? isActive = null,
    Object? includeInTotal = null,
    Object? defaultCategory = freezed,
    Object? notes = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AccountType,
            institution: null == institution
                ? _value.institution
                : institution // ignore: cast_nullable_to_non_nullable
                      as String,
            accountNumber: freezed == accountNumber
                ? _value.accountNumber
                : accountNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            balance: freezed == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as double?,
            creditLimit: freezed == creditLimit
                ? _value.creditLimit
                : creditLimit // ignore: cast_nullable_to_non_nullable
                      as double?,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeInTotal: null == includeInTotal
                ? _value.includeInTotal
                : includeInTotal // ignore: cast_nullable_to_non_nullable
                      as bool,
            defaultCategory: freezed == defaultCategory
                ? _value.defaultCategory
                : defaultCategory // ignore: cast_nullable_to_non_nullable
                      as Category?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AccountImplCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$$AccountImplCopyWith(
    _$AccountImpl value,
    $Res Function(_$AccountImpl) then,
  ) = __$$AccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    AccountType type,
    String institution,
    String? accountNumber,
    double? balance,
    double? creditLimit,
    String currency,
    String? color,
    String? icon,
    bool isActive,
    bool includeInTotal,
    Category? defaultCategory,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$AccountImplCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountImpl>
    implements _$$AccountImplCopyWith<$Res> {
  __$$AccountImplCopyWithImpl(
    _$AccountImpl _value,
    $Res Function(_$AccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? institution = null,
    Object? accountNumber = freezed,
    Object? balance = freezed,
    Object? creditLimit = freezed,
    Object? currency = null,
    Object? color = freezed,
    Object? icon = freezed,
    Object? isActive = null,
    Object? includeInTotal = null,
    Object? defaultCategory = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$AccountImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AccountType,
        institution: null == institution
            ? _value.institution
            : institution // ignore: cast_nullable_to_non_nullable
                  as String,
        accountNumber: freezed == accountNumber
            ? _value.accountNumber
            : accountNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        balance: freezed == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as double?,
        creditLimit: freezed == creditLimit
            ? _value.creditLimit
            : creditLimit // ignore: cast_nullable_to_non_nullable
                  as double?,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeInTotal: null == includeInTotal
            ? _value.includeInTotal
            : includeInTotal // ignore: cast_nullable_to_non_nullable
                  as bool,
        defaultCategory: freezed == defaultCategory
            ? _value.defaultCategory
            : defaultCategory // ignore: cast_nullable_to_non_nullable
                  as Category?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
class _$AccountImpl implements _Account {
  const _$AccountImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.institution,
    this.accountNumber,
    this.balance,
    this.creditLimit,
    this.currency = 'INR',
    this.color,
    this.icon,
    this.isActive = true,
    this.includeInTotal = true,
    this.defaultCategory,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$AccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountImplFromJson(json);

  /// Unique identifier for the account
  @override
  final String id;

  /// Account name (e.g., "HDFC Savings", "ICICI Credit Card")
  @override
  final String name;

  /// Type of account
  @override
  final AccountType type;

  /// Bank/institution name
  @override
  final String institution;

  /// Last 4 digits of account number
  @override
  final String? accountNumber;

  /// Current balance (if tracked)
  @override
  final double? balance;

  /// Credit limit (for credit cards)
  @override
  final double? creditLimit;

  /// Currency code (default: INR)
  @override
  @JsonKey()
  final String currency;

  /// Custom color for the account (hex string)
  @override
  final String? color;

  /// Custom icon name
  @override
  final String? icon;

  /// Whether this account is active
  @override
  @JsonKey()
  final bool isActive;

  /// Whether to include in total balance calculations
  @override
  @JsonKey()
  final bool includeInTotal;

  /// Default category for transactions from this account
  @override
  final Category? defaultCategory;

  /// Notes about the account
  @override
  final String? notes;

  /// Creation timestamp
  @override
  final DateTime createdAt;

  /// Last update timestamp
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, institution: $institution, accountNumber: $accountNumber, balance: $balance, creditLimit: $creditLimit, currency: $currency, color: $color, icon: $icon, isActive: $isActive, includeInTotal: $includeInTotal, defaultCategory: $defaultCategory, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.institution, institution) ||
                other.institution == institution) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.includeInTotal, includeInTotal) ||
                other.includeInTotal == includeInTotal) &&
            (identical(other.defaultCategory, defaultCategory) ||
                other.defaultCategory == defaultCategory) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
    type,
    institution,
    accountNumber,
    balance,
    creditLimit,
    currency,
    color,
    icon,
    isActive,
    includeInTotal,
    defaultCategory,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      __$$AccountImplCopyWithImpl<_$AccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountImplToJson(this);
  }
}

abstract class _Account implements Account {
  const factory _Account({
    required final String id,
    required final String name,
    required final AccountType type,
    required final String institution,
    final String? accountNumber,
    final double? balance,
    final double? creditLimit,
    final String currency,
    final String? color,
    final String? icon,
    final bool isActive,
    final bool includeInTotal,
    final Category? defaultCategory,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$AccountImpl;

  factory _Account.fromJson(Map<String, dynamic> json) = _$AccountImpl.fromJson;

  /// Unique identifier for the account
  @override
  String get id;

  /// Account name (e.g., "HDFC Savings", "ICICI Credit Card")
  @override
  String get name;

  /// Type of account
  @override
  AccountType get type;

  /// Bank/institution name
  @override
  String get institution;

  /// Last 4 digits of account number
  @override
  String? get accountNumber;

  /// Current balance (if tracked)
  @override
  double? get balance;

  /// Credit limit (for credit cards)
  @override
  double? get creditLimit;

  /// Currency code (default: INR)
  @override
  String get currency;

  /// Custom color for the account (hex string)
  @override
  String? get color;

  /// Custom icon name
  @override
  String? get icon;

  /// Whether this account is active
  @override
  bool get isActive;

  /// Whether to include in total balance calculations
  @override
  bool get includeInTotal;

  /// Default category for transactions from this account
  @override
  Category? get defaultCategory;

  /// Notes about the account
  @override
  String? get notes;

  /// Creation timestamp
  @override
  DateTime get createdAt;

  /// Last update timestamp
  @override
  DateTime get updatedAt;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
