// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringTransactionImpl _$$RecurringTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$RecurringTransactionImpl(
  id: json['id'] as String,
  merchantPattern: json['merchantPattern'] as String,
  amount: (json['amount'] as num).toDouble(),
  amountTolerance: (json['amountTolerance'] as num?)?.toDouble() ?? 0.05,
  frequency: $enumDecode(_$RecurringFrequencyEnumMap, json['frequency']),
  category: json['category'] as String,
  matchedTransactionIds: (json['matchedTransactionIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
  isConfirmed: json['isConfirmed'] as bool? ?? false,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 3,
  nextExpectedDate: DateTime.parse(json['nextExpectedDate'] as String),
  lastDetectedDate: DateTime.parse(json['lastDetectedDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$RecurringTransactionImplToJson(
  _$RecurringTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'merchantPattern': instance.merchantPattern,
  'amount': instance.amount,
  'amountTolerance': instance.amountTolerance,
  'frequency': _$RecurringFrequencyEnumMap[instance.frequency]!,
  'category': instance.category,
  'matchedTransactionIds': instance.matchedTransactionIds,
  'confidence': instance.confidence,
  'isConfirmed': instance.isConfirmed,
  'notificationsEnabled': instance.notificationsEnabled,
  'reminderDaysBefore': instance.reminderDaysBefore,
  'nextExpectedDate': instance.nextExpectedDate.toIso8601String(),
  'lastDetectedDate': instance.lastDetectedDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'notes': instance.notes,
};

const _$RecurringFrequencyEnumMap = {
  RecurringFrequency.weekly: 'weekly',
  RecurringFrequency.biweekly: 'biweekly',
  RecurringFrequency.monthly: 'monthly',
  RecurringFrequency.quarterly: 'quarterly',
  RecurringFrequency.yearly: 'yearly',
};
