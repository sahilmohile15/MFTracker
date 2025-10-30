// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  /// Unique identifier for the transaction
  String get id => throw _privateConstructorUsedError;

  /// Transaction amount (always positive, type determines debit/credit)
  double get amount => throw _privateConstructorUsedError;

  /// Transaction type (debit or credit)
  TransactionType get type => throw _privateConstructorUsedError;

  /// Category of the transaction
  Category get category => throw _privateConstructorUsedError;

  /// How the category was determined
  CategorizationMethod get categorizationMethod =>
      throw _privateConstructorUsedError;

  /// Transaction date and time
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Description/narration of the transaction
  String get description => throw _privateConstructorUsedError;

  /// Account ID this transaction belongs to
  String get accountId => throw _privateConstructorUsedError;

  /// Last 4 digits of account number (from SMS)
  String? get accountNumber => throw _privateConstructorUsedError;

  /// Merchant/payee name
  String? get merchantName => throw _privateConstructorUsedError;

  /// UPI transaction ID if applicable
  String? get upiTransactionId => throw _privateConstructorUsedError;

  /// UPI ID used for payment
  String? get upiId => throw _privateConstructorUsedError;

  /// Payment method (UPI, Card, ATM, etc.)
  String? get paymentMethod => throw _privateConstructorUsedError;

  /// Balance after transaction (if available in notification)
  double? get balanceAfter => throw _privateConstructorUsedError;

  /// Original notification body/text
  String? get smsBody => throw _privateConstructorUsedError;

  /// Notification sender (package name or title)
  String? get smsSender => throw _privateConstructorUsedError;

  /// Notification timestamp
  DateTime? get smsTimestamp => throw _privateConstructorUsedError;

  /// Whether this is a recurring transaction
  bool get isRecurring => throw _privateConstructorUsedError;

  /// Recurring transaction parent ID
  String? get recurringParentId => throw _privateConstructorUsedError;

  /// Tags associated with the transaction
  List<String> get tags => throw _privateConstructorUsedError;

  /// Notes added by user
  String? get notes => throw _privateConstructorUsedError;

  /// Confidence score of categorization (0-1)
  double get categorizationConfidence => throw _privateConstructorUsedError;

  /// Whether transaction was manually edited by user
  bool get isManuallyEdited => throw _privateConstructorUsedError;

  /// Creation timestamp
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Last update timestamp
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
    Transaction value,
    $Res Function(Transaction) then,
  ) = _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call({
    String id,
    double amount,
    TransactionType type,
    Category category,
    CategorizationMethod categorizationMethod,
    DateTime timestamp,
    String description,
    String accountId,
    String? accountNumber,
    String? merchantName,
    String? upiTransactionId,
    String? upiId,
    String? paymentMethod,
    double? balanceAfter,
    String? smsBody,
    String? smsSender,
    DateTime? smsTimestamp,
    bool isRecurring,
    String? recurringParentId,
    List<String> tags,
    String? notes,
    double categorizationConfidence,
    bool isManuallyEdited,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? type = null,
    Object? category = null,
    Object? categorizationMethod = null,
    Object? timestamp = null,
    Object? description = null,
    Object? accountId = null,
    Object? accountNumber = freezed,
    Object? merchantName = freezed,
    Object? upiTransactionId = freezed,
    Object? upiId = freezed,
    Object? paymentMethod = freezed,
    Object? balanceAfter = freezed,
    Object? smsBody = freezed,
    Object? smsSender = freezed,
    Object? smsTimestamp = freezed,
    Object? isRecurring = null,
    Object? recurringParentId = freezed,
    Object? tags = null,
    Object? notes = freezed,
    Object? categorizationConfidence = null,
    Object? isManuallyEdited = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as Category,
            categorizationMethod: null == categorizationMethod
                ? _value.categorizationMethod
                : categorizationMethod // ignore: cast_nullable_to_non_nullable
                      as CategorizationMethod,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String,
            accountNumber: freezed == accountNumber
                ? _value.accountNumber
                : accountNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            merchantName: freezed == merchantName
                ? _value.merchantName
                : merchantName // ignore: cast_nullable_to_non_nullable
                      as String?,
            upiTransactionId: freezed == upiTransactionId
                ? _value.upiTransactionId
                : upiTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            upiId: freezed == upiId
                ? _value.upiId
                : upiId // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            balanceAfter: freezed == balanceAfter
                ? _value.balanceAfter
                : balanceAfter // ignore: cast_nullable_to_non_nullable
                      as double?,
            smsBody: freezed == smsBody
                ? _value.smsBody
                : smsBody // ignore: cast_nullable_to_non_nullable
                      as String?,
            smsSender: freezed == smsSender
                ? _value.smsSender
                : smsSender // ignore: cast_nullable_to_non_nullable
                      as String?,
            smsTimestamp: freezed == smsTimestamp
                ? _value.smsTimestamp
                : smsTimestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            recurringParentId: freezed == recurringParentId
                ? _value.recurringParentId
                : recurringParentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            categorizationConfidence: null == categorizationConfidence
                ? _value.categorizationConfidence
                : categorizationConfidence // ignore: cast_nullable_to_non_nullable
                      as double,
            isManuallyEdited: null == isManuallyEdited
                ? _value.isManuallyEdited
                : isManuallyEdited // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
    _$TransactionImpl value,
    $Res Function(_$TransactionImpl) then,
  ) = __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double amount,
    TransactionType type,
    Category category,
    CategorizationMethod categorizationMethod,
    DateTime timestamp,
    String description,
    String accountId,
    String? accountNumber,
    String? merchantName,
    String? upiTransactionId,
    String? upiId,
    String? paymentMethod,
    double? balanceAfter,
    String? smsBody,
    String? smsSender,
    DateTime? smsTimestamp,
    bool isRecurring,
    String? recurringParentId,
    List<String> tags,
    String? notes,
    double categorizationConfidence,
    bool isManuallyEdited,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
    _$TransactionImpl _value,
    $Res Function(_$TransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? type = null,
    Object? category = null,
    Object? categorizationMethod = null,
    Object? timestamp = null,
    Object? description = null,
    Object? accountId = null,
    Object? accountNumber = freezed,
    Object? merchantName = freezed,
    Object? upiTransactionId = freezed,
    Object? upiId = freezed,
    Object? paymentMethod = freezed,
    Object? balanceAfter = freezed,
    Object? smsBody = freezed,
    Object? smsSender = freezed,
    Object? smsTimestamp = freezed,
    Object? isRecurring = null,
    Object? recurringParentId = freezed,
    Object? tags = null,
    Object? notes = freezed,
    Object? categorizationConfidence = null,
    Object? isManuallyEdited = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as Category,
        categorizationMethod: null == categorizationMethod
            ? _value.categorizationMethod
            : categorizationMethod // ignore: cast_nullable_to_non_nullable
                  as CategorizationMethod,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String,
        accountNumber: freezed == accountNumber
            ? _value.accountNumber
            : accountNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        merchantName: freezed == merchantName
            ? _value.merchantName
            : merchantName // ignore: cast_nullable_to_non_nullable
                  as String?,
        upiTransactionId: freezed == upiTransactionId
            ? _value.upiTransactionId
            : upiTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        upiId: freezed == upiId
            ? _value.upiId
            : upiId // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        balanceAfter: freezed == balanceAfter
            ? _value.balanceAfter
            : balanceAfter // ignore: cast_nullable_to_non_nullable
                  as double?,
        smsBody: freezed == smsBody
            ? _value.smsBody
            : smsBody // ignore: cast_nullable_to_non_nullable
                  as String?,
        smsSender: freezed == smsSender
            ? _value.smsSender
            : smsSender // ignore: cast_nullable_to_non_nullable
                  as String?,
        smsTimestamp: freezed == smsTimestamp
            ? _value.smsTimestamp
            : smsTimestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        recurringParentId: freezed == recurringParentId
            ? _value.recurringParentId
            : recurringParentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        categorizationConfidence: null == categorizationConfidence
            ? _value.categorizationConfidence
            : categorizationConfidence // ignore: cast_nullable_to_non_nullable
                  as double,
        isManuallyEdited: null == isManuallyEdited
            ? _value.isManuallyEdited
            : isManuallyEdited // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.categorizationMethod,
    required this.timestamp,
    required this.description,
    required this.accountId,
    this.accountNumber,
    this.merchantName,
    this.upiTransactionId,
    this.upiId,
    this.paymentMethod,
    this.balanceAfter,
    this.smsBody,
    this.smsSender,
    this.smsTimestamp,
    this.isRecurring = false,
    this.recurringParentId,
    final List<String> tags = const [],
    this.notes,
    this.categorizationConfidence = 0.0,
    this.isManuallyEdited = false,
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags;

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  /// Unique identifier for the transaction
  @override
  final String id;

  /// Transaction amount (always positive, type determines debit/credit)
  @override
  final double amount;

  /// Transaction type (debit or credit)
  @override
  final TransactionType type;

  /// Category of the transaction
  @override
  final Category category;

  /// How the category was determined
  @override
  final CategorizationMethod categorizationMethod;

  /// Transaction date and time
  @override
  final DateTime timestamp;

  /// Description/narration of the transaction
  @override
  final String description;

  /// Account ID this transaction belongs to
  @override
  final String accountId;

  /// Last 4 digits of account number (from SMS)
  @override
  final String? accountNumber;

  /// Merchant/payee name
  @override
  final String? merchantName;

  /// UPI transaction ID if applicable
  @override
  final String? upiTransactionId;

  /// UPI ID used for payment
  @override
  final String? upiId;

  /// Payment method (UPI, Card, ATM, etc.)
  @override
  final String? paymentMethod;

  /// Balance after transaction (if available in notification)
  @override
  final double? balanceAfter;

  /// Original notification body/text
  @override
  final String? smsBody;

  /// Notification sender (package name or title)
  @override
  final String? smsSender;

  /// Notification timestamp
  @override
  final DateTime? smsTimestamp;

  /// Whether this is a recurring transaction
  @override
  @JsonKey()
  final bool isRecurring;

  /// Recurring transaction parent ID
  @override
  final String? recurringParentId;

  /// Tags associated with the transaction
  final List<String> _tags;

  /// Tags associated with the transaction
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Notes added by user
  @override
  final String? notes;

  /// Confidence score of categorization (0-1)
  @override
  @JsonKey()
  final double categorizationConfidence;

  /// Whether transaction was manually edited by user
  @override
  @JsonKey()
  final bool isManuallyEdited;

  /// Creation timestamp
  @override
  final DateTime createdAt;

  /// Last update timestamp
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: $type, category: $category, categorizationMethod: $categorizationMethod, timestamp: $timestamp, description: $description, accountId: $accountId, accountNumber: $accountNumber, merchantName: $merchantName, upiTransactionId: $upiTransactionId, upiId: $upiId, paymentMethod: $paymentMethod, balanceAfter: $balanceAfter, smsBody: $smsBody, smsSender: $smsSender, smsTimestamp: $smsTimestamp, isRecurring: $isRecurring, recurringParentId: $recurringParentId, tags: $tags, notes: $notes, categorizationConfidence: $categorizationConfidence, isManuallyEdited: $isManuallyEdited, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.categorizationMethod, categorizationMethod) ||
                other.categorizationMethod == categorizationMethod) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.merchantName, merchantName) ||
                other.merchantName == merchantName) &&
            (identical(other.upiTransactionId, upiTransactionId) ||
                other.upiTransactionId == upiTransactionId) &&
            (identical(other.upiId, upiId) || other.upiId == upiId) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.smsBody, smsBody) || other.smsBody == smsBody) &&
            (identical(other.smsSender, smsSender) ||
                other.smsSender == smsSender) &&
            (identical(other.smsTimestamp, smsTimestamp) ||
                other.smsTimestamp == smsTimestamp) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.recurringParentId, recurringParentId) ||
                other.recurringParentId == recurringParentId) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(
                  other.categorizationConfidence,
                  categorizationConfidence,
                ) ||
                other.categorizationConfidence == categorizationConfidence) &&
            (identical(other.isManuallyEdited, isManuallyEdited) ||
                other.isManuallyEdited == isManuallyEdited) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    amount,
    type,
    category,
    categorizationMethod,
    timestamp,
    description,
    accountId,
    accountNumber,
    merchantName,
    upiTransactionId,
    upiId,
    paymentMethod,
    balanceAfter,
    smsBody,
    smsSender,
    smsTimestamp,
    isRecurring,
    recurringParentId,
    const DeepCollectionEquality().hash(_tags),
    notes,
    categorizationConfidence,
    isManuallyEdited,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(this);
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction({
    required final String id,
    required final double amount,
    required final TransactionType type,
    required final Category category,
    required final CategorizationMethod categorizationMethod,
    required final DateTime timestamp,
    required final String description,
    required final String accountId,
    final String? accountNumber,
    final String? merchantName,
    final String? upiTransactionId,
    final String? upiId,
    final String? paymentMethod,
    final double? balanceAfter,
    final String? smsBody,
    final String? smsSender,
    final DateTime? smsTimestamp,
    final bool isRecurring,
    final String? recurringParentId,
    final List<String> tags,
    final String? notes,
    final double categorizationConfidence,
    final bool isManuallyEdited,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  /// Unique identifier for the transaction
  @override
  String get id;

  /// Transaction amount (always positive, type determines debit/credit)
  @override
  double get amount;

  /// Transaction type (debit or credit)
  @override
  TransactionType get type;

  /// Category of the transaction
  @override
  Category get category;

  /// How the category was determined
  @override
  CategorizationMethod get categorizationMethod;

  /// Transaction date and time
  @override
  DateTime get timestamp;

  /// Description/narration of the transaction
  @override
  String get description;

  /// Account ID this transaction belongs to
  @override
  String get accountId;

  /// Last 4 digits of account number (from SMS)
  @override
  String? get accountNumber;

  /// Merchant/payee name
  @override
  String? get merchantName;

  /// UPI transaction ID if applicable
  @override
  String? get upiTransactionId;

  /// UPI ID used for payment
  @override
  String? get upiId;

  /// Payment method (UPI, Card, ATM, etc.)
  @override
  String? get paymentMethod;

  /// Balance after transaction (if available in notification)
  @override
  double? get balanceAfter;

  /// Original notification body/text
  @override
  String? get smsBody;

  /// Notification sender (package name or title)
  @override
  String? get smsSender;

  /// Notification timestamp
  @override
  DateTime? get smsTimestamp;

  /// Whether this is a recurring transaction
  @override
  bool get isRecurring;

  /// Recurring transaction parent ID
  @override
  String? get recurringParentId;

  /// Tags associated with the transaction
  @override
  List<String> get tags;

  /// Notes added by user
  @override
  String? get notes;

  /// Confidence score of categorization (0-1)
  @override
  double get categorizationConfidence;

  /// Whether transaction was manually edited by user
  @override
  bool get isManuallyEdited;

  /// Creation timestamp
  @override
  DateTime get createdAt;

  /// Last update timestamp
  @override
  DateTime get updatedAt;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
