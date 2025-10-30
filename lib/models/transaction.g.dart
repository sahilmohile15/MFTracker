// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      categorizationMethod: $enumDecode(
        _$CategorizationMethodEnumMap,
        json['categorizationMethod'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      accountId: json['accountId'] as String,
      accountNumber: json['accountNumber'] as String?,
      merchantName: json['merchantName'] as String?,
      upiTransactionId: json['upiTransactionId'] as String?,
      upiId: json['upiId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      smsBody: json['smsBody'] as String?,
      smsSender: json['smsSender'] as String?,
      smsTimestamp: json['smsTimestamp'] == null
          ? null
          : DateTime.parse(json['smsTimestamp'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringParentId: json['recurringParentId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      notes: json['notes'] as String?,
      categorizationConfidence:
          (json['categorizationConfidence'] as num?)?.toDouble() ?? 0.0,
      isManuallyEdited: json['isManuallyEdited'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'category': _$CategoryEnumMap[instance.category]!,
      'categorizationMethod':
          _$CategorizationMethodEnumMap[instance.categorizationMethod]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'description': instance.description,
      'accountId': instance.accountId,
      'accountNumber': instance.accountNumber,
      'merchantName': instance.merchantName,
      'upiTransactionId': instance.upiTransactionId,
      'upiId': instance.upiId,
      'paymentMethod': instance.paymentMethod,
      'balanceAfter': instance.balanceAfter,
      'smsBody': instance.smsBody,
      'smsSender': instance.smsSender,
      'smsTimestamp': instance.smsTimestamp?.toIso8601String(),
      'isRecurring': instance.isRecurring,
      'recurringParentId': instance.recurringParentId,
      'tags': instance.tags,
      'notes': instance.notes,
      'categorizationConfidence': instance.categorizationConfidence,
      'isManuallyEdited': instance.isManuallyEdited,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.debit: 'debit',
  TransactionType.credit: 'credit',
};

const _$CategoryEnumMap = {
  Category.upiPayments: 'upiPayments',
  Category.foodDelivery: 'foodDelivery',
  Category.shopping: 'shopping',
  Category.groceries: 'groceries',
  Category.transportation: 'transportation',
  Category.entertainment: 'entertainment',
  Category.billPayments: 'billPayments',
  Category.recharge: 'recharge',
  Category.cardPayments: 'cardPayments',
  Category.bankTransfers: 'bankTransfers',
  Category.atmWithdrawals: 'atmWithdrawals',
  Category.emi: 'emi',
  Category.subscriptions: 'subscriptions',
  Category.healthcare: 'healthcare',
  Category.income: 'income',
  Category.investment: 'investment',
  Category.others: 'others',
};

const _$CategorizationMethodEnumMap = {
  CategorizationMethod.ruleBased: 'ruleBased',
  CategorizationMethod.machineLearning: 'machineLearning',
  CategorizationMethod.merchantDatabase: 'merchantDatabase',
  CategorizationMethod.userCorrected: 'userCorrected',
  CategorizationMethod.defaultFallback: 'defaultFallback',
};
