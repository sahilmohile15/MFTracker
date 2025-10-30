// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParsedTransaction _$ParsedTransactionFromJson(Map<String, dynamic> json) {
  return _ParsedTransaction.fromJson(json);
}

/// @nodoc
mixin _$ParsedTransaction {
  /// Transaction amount
  double get amount => throw _privateConstructorUsedError;

  /// Transaction type (debit or credit)
  TransactionType get type => throw _privateConstructorUsedError;

  /// Transaction description from SMS
  String get description => throw _privateConstructorUsedError;

  /// SMS sender address
  String get smsSender => throw _privateConstructorUsedError;

  /// SMS body
  String get smsBody => throw _privateConstructorUsedError;

  /// SMS timestamp
  DateTime get smsTimestamp => throw _privateConstructorUsedError;

  /// Last 4 digits of account number (if found)
  String? get accountNumber => throw _privateConstructorUsedError;

  /// Merchant/payee name (if found)
  String? get merchantName => throw _privateConstructorUsedError;

  /// UPI transaction ID (if found)
  String? get upiTransactionId => throw _privateConstructorUsedError;

  /// UPI ID (if found)
  String? get upiId => throw _privateConstructorUsedError;

  /// Payment method (UPI, Card, ATM, etc.)
  String? get paymentMethod => throw _privateConstructorUsedError;

  /// Balance after transaction (if available)
  double? get balanceAfter => throw _privateConstructorUsedError;

  /// Confidence score of parsing (0-1)
  double get confidence => throw _privateConstructorUsedError;

  /// Whether parsing was successful
  bool get isValid => throw _privateConstructorUsedError;

  /// Error message if parsing failed
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this ParsedTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParsedTransactionCopyWith<ParsedTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParsedTransactionCopyWith<$Res> {
  factory $ParsedTransactionCopyWith(
    ParsedTransaction value,
    $Res Function(ParsedTransaction) then,
  ) = _$ParsedTransactionCopyWithImpl<$Res, ParsedTransaction>;
  @useResult
  $Res call({
    double amount,
    TransactionType type,
    String description,
    String smsSender,
    String smsBody,
    DateTime smsTimestamp,
    String? accountNumber,
    String? merchantName,
    String? upiTransactionId,
    String? upiId,
    String? paymentMethod,
    double? balanceAfter,
    double confidence,
    bool isValid,
    String? errorMessage,
  });
}

/// @nodoc
class _$ParsedTransactionCopyWithImpl<$Res, $Val extends ParsedTransaction>
    implements $ParsedTransactionCopyWith<$Res> {
  _$ParsedTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? type = null,
    Object? description = null,
    Object? smsSender = null,
    Object? smsBody = null,
    Object? smsTimestamp = null,
    Object? accountNumber = freezed,
    Object? merchantName = freezed,
    Object? upiTransactionId = freezed,
    Object? upiId = freezed,
    Object? paymentMethod = freezed,
    Object? balanceAfter = freezed,
    Object? confidence = null,
    Object? isValid = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TransactionType,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            smsSender: null == smsSender
                ? _value.smsSender
                : smsSender // ignore: cast_nullable_to_non_nullable
                      as String,
            smsBody: null == smsBody
                ? _value.smsBody
                : smsBody // ignore: cast_nullable_to_non_nullable
                      as String,
            smsTimestamp: null == smsTimestamp
                ? _value.smsTimestamp
                : smsTimestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            isValid: null == isValid
                ? _value.isValid
                : isValid // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParsedTransactionImplCopyWith<$Res>
    implements $ParsedTransactionCopyWith<$Res> {
  factory _$$ParsedTransactionImplCopyWith(
    _$ParsedTransactionImpl value,
    $Res Function(_$ParsedTransactionImpl) then,
  ) = __$$ParsedTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double amount,
    TransactionType type,
    String description,
    String smsSender,
    String smsBody,
    DateTime smsTimestamp,
    String? accountNumber,
    String? merchantName,
    String? upiTransactionId,
    String? upiId,
    String? paymentMethod,
    double? balanceAfter,
    double confidence,
    bool isValid,
    String? errorMessage,
  });
}

/// @nodoc
class __$$ParsedTransactionImplCopyWithImpl<$Res>
    extends _$ParsedTransactionCopyWithImpl<$Res, _$ParsedTransactionImpl>
    implements _$$ParsedTransactionImplCopyWith<$Res> {
  __$$ParsedTransactionImplCopyWithImpl(
    _$ParsedTransactionImpl _value,
    $Res Function(_$ParsedTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? type = null,
    Object? description = null,
    Object? smsSender = null,
    Object? smsBody = null,
    Object? smsTimestamp = null,
    Object? accountNumber = freezed,
    Object? merchantName = freezed,
    Object? upiTransactionId = freezed,
    Object? upiId = freezed,
    Object? paymentMethod = freezed,
    Object? balanceAfter = freezed,
    Object? confidence = null,
    Object? isValid = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ParsedTransactionImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TransactionType,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        smsSender: null == smsSender
            ? _value.smsSender
            : smsSender // ignore: cast_nullable_to_non_nullable
                  as String,
        smsBody: null == smsBody
            ? _value.smsBody
            : smsBody // ignore: cast_nullable_to_non_nullable
                  as String,
        smsTimestamp: null == smsTimestamp
            ? _value.smsTimestamp
            : smsTimestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        isValid: null == isValid
            ? _value.isValid
            : isValid // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParsedTransactionImpl implements _ParsedTransaction {
  const _$ParsedTransactionImpl({
    required this.amount,
    required this.type,
    required this.description,
    required this.smsSender,
    required this.smsBody,
    required this.smsTimestamp,
    this.accountNumber,
    this.merchantName,
    this.upiTransactionId,
    this.upiId,
    this.paymentMethod,
    this.balanceAfter,
    this.confidence = 0.0,
    this.isValid = true,
    this.errorMessage,
  });

  factory _$ParsedTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParsedTransactionImplFromJson(json);

  /// Transaction amount
  @override
  final double amount;

  /// Transaction type (debit or credit)
  @override
  final TransactionType type;

  /// Transaction description from SMS
  @override
  final String description;

  /// SMS sender address
  @override
  final String smsSender;

  /// SMS body
  @override
  final String smsBody;

  /// SMS timestamp
  @override
  final DateTime smsTimestamp;

  /// Last 4 digits of account number (if found)
  @override
  final String? accountNumber;

  /// Merchant/payee name (if found)
  @override
  final String? merchantName;

  /// UPI transaction ID (if found)
  @override
  final String? upiTransactionId;

  /// UPI ID (if found)
  @override
  final String? upiId;

  /// Payment method (UPI, Card, ATM, etc.)
  @override
  final String? paymentMethod;

  /// Balance after transaction (if available)
  @override
  final double? balanceAfter;

  /// Confidence score of parsing (0-1)
  @override
  @JsonKey()
  final double confidence;

  /// Whether parsing was successful
  @override
  @JsonKey()
  final bool isValid;

  /// Error message if parsing failed
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ParsedTransaction(amount: $amount, type: $type, description: $description, smsSender: $smsSender, smsBody: $smsBody, smsTimestamp: $smsTimestamp, accountNumber: $accountNumber, merchantName: $merchantName, upiTransactionId: $upiTransactionId, upiId: $upiId, paymentMethod: $paymentMethod, balanceAfter: $balanceAfter, confidence: $confidence, isValid: $isValid, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParsedTransactionImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.smsSender, smsSender) ||
                other.smsSender == smsSender) &&
            (identical(other.smsBody, smsBody) || other.smsBody == smsBody) &&
            (identical(other.smsTimestamp, smsTimestamp) ||
                other.smsTimestamp == smsTimestamp) &&
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
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    amount,
    type,
    description,
    smsSender,
    smsBody,
    smsTimestamp,
    accountNumber,
    merchantName,
    upiTransactionId,
    upiId,
    paymentMethod,
    balanceAfter,
    confidence,
    isValid,
    errorMessage,
  );

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParsedTransactionImplCopyWith<_$ParsedTransactionImpl> get copyWith =>
      __$$ParsedTransactionImplCopyWithImpl<_$ParsedTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParsedTransactionImplToJson(this);
  }
}

abstract class _ParsedTransaction implements ParsedTransaction {
  const factory _ParsedTransaction({
    required final double amount,
    required final TransactionType type,
    required final String description,
    required final String smsSender,
    required final String smsBody,
    required final DateTime smsTimestamp,
    final String? accountNumber,
    final String? merchantName,
    final String? upiTransactionId,
    final String? upiId,
    final String? paymentMethod,
    final double? balanceAfter,
    final double confidence,
    final bool isValid,
    final String? errorMessage,
  }) = _$ParsedTransactionImpl;

  factory _ParsedTransaction.fromJson(Map<String, dynamic> json) =
      _$ParsedTransactionImpl.fromJson;

  /// Transaction amount
  @override
  double get amount;

  /// Transaction type (debit or credit)
  @override
  TransactionType get type;

  /// Transaction description from SMS
  @override
  String get description;

  /// SMS sender address
  @override
  String get smsSender;

  /// SMS body
  @override
  String get smsBody;

  /// SMS timestamp
  @override
  DateTime get smsTimestamp;

  /// Last 4 digits of account number (if found)
  @override
  String? get accountNumber;

  /// Merchant/payee name (if found)
  @override
  String? get merchantName;

  /// UPI transaction ID (if found)
  @override
  String? get upiTransactionId;

  /// UPI ID (if found)
  @override
  String? get upiId;

  /// Payment method (UPI, Card, ATM, etc.)
  @override
  String? get paymentMethod;

  /// Balance after transaction (if available)
  @override
  double? get balanceAfter;

  /// Confidence score of parsing (0-1)
  @override
  double get confidence;

  /// Whether parsing was successful
  @override
  bool get isValid;

  /// Error message if parsing failed
  @override
  String? get errorMessage;

  /// Create a copy of ParsedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParsedTransactionImplCopyWith<_$ParsedTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
