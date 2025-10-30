// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParsedTransactionImpl _$$ParsedTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$ParsedTransactionImpl(
  amount: (json['amount'] as num).toDouble(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  description: json['description'] as String,
  smsSender: json['smsSender'] as String,
  smsBody: json['smsBody'] as String,
  smsTimestamp: DateTime.parse(json['smsTimestamp'] as String),
  accountNumber: json['accountNumber'] as String?,
  merchantName: json['merchantName'] as String?,
  upiTransactionId: json['upiTransactionId'] as String?,
  upiId: json['upiId'] as String?,
  paymentMethod: json['paymentMethod'] as String?,
  balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
  isValid: json['isValid'] as bool? ?? true,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$ParsedTransactionImplToJson(
  _$ParsedTransactionImpl instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'description': instance.description,
  'smsSender': instance.smsSender,
  'smsBody': instance.smsBody,
  'smsTimestamp': instance.smsTimestamp.toIso8601String(),
  'accountNumber': instance.accountNumber,
  'merchantName': instance.merchantName,
  'upiTransactionId': instance.upiTransactionId,
  'upiId': instance.upiId,
  'paymentMethod': instance.paymentMethod,
  'balanceAfter': instance.balanceAfter,
  'confidence': instance.confidence,
  'isValid': instance.isValid,
  'errorMessage': instance.errorMessage,
};

const _$TransactionTypeEnumMap = {
  TransactionType.debit: 'debit',
  TransactionType.credit: 'credit',
};
