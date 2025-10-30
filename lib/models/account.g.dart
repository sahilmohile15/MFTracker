// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      institution: json['institution'] as String,
      accountNumber: json['accountNumber'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      includeInTotal: json['includeInTotal'] as bool? ?? true,
      defaultCategory: $enumDecodeNullable(
        _$CategoryEnumMap,
        json['defaultCategory'],
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'institution': instance.institution,
      'accountNumber': instance.accountNumber,
      'balance': instance.balance,
      'creditLimit': instance.creditLimit,
      'currency': instance.currency,
      'color': instance.color,
      'icon': instance.icon,
      'isActive': instance.isActive,
      'includeInTotal': instance.includeInTotal,
      'defaultCategory': _$CategoryEnumMap[instance.defaultCategory],
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AccountTypeEnumMap = {
  AccountType.savings: 'savings',
  AccountType.current: 'current',
  AccountType.creditCard: 'creditCard',
  AccountType.wallet: 'wallet',
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
