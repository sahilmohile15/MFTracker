// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetImpl _$$BudgetImplFromJson(Map<String, dynamic> json) => _$BudgetImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num).toDouble(),
  period: $enumDecode(_$BudgetPeriodEnumMap, json['period']),
  category: $enumDecodeNullable(_$CategoryEnumMap, json['category']),
  accountId: json['accountId'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  isActive: json['isActive'] as bool? ?? true,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 80.0,
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$BudgetImplToJson(_$BudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'period': _$BudgetPeriodEnumMap[instance.period]!,
      'category': _$CategoryEnumMap[instance.category],
      'accountId': instance.accountId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isActive': instance.isActive,
      'notificationsEnabled': instance.notificationsEnabled,
      'alertThreshold': instance.alertThreshold,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$BudgetPeriodEnumMap = {
  BudgetPeriod.daily: 'daily',
  BudgetPeriod.weekly: 'weekly',
  BudgetPeriod.monthly: 'monthly',
  BudgetPeriod.yearly: 'yearly',
  BudgetPeriod.custom: 'custom',
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
