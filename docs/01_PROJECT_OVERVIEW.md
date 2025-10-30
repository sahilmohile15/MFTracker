# 📱 MFTracker - Notification-Based Expense Tracking App

**Version:** 1.0.0  
**Last Updated:** October 30, 2025  
**Platform:** Android (iOS future consideration)  
**Framework:** Flutter 3.x with Dart 3.8+

---

## 🎯 Project Vision

A privacy-first, lightweight mobile application that automatically tracks monthly expenses by capturing transaction notifications from banks and financial institutions. The app operates entirely offline, ensuring user data never leaves the device.

---

## ✨ Core Features

### Current (v1.0.0)

1. **Notification Listening & Parsing**
   - Listen to notifications with NotificationListenerService
   - Parse financial transactions (debit/credit) from notifications
   - Extract: Amount, Date, Merchant, Account, Balance
   - Support for 20+ Indian banks and payment apps

2. **Smart Categorization**
   - Automatic category assignment (Food, Shopping, Bills, Transport, etc.)
   - Rule-based categorization (90%+ accuracy)
   - User correction and manual categorization

3. **Transaction Management**
   - View all transactions (list & detail view)
   - Filter by date, category, type, account
   - Search transactions
   - Manual transaction entry (cash transactions)
   - Edit/delete transactions
   - Bulk operations

4. **Analytics Dashboard**
   - Monthly expense summary
   - Income vs Expense comparison
   - Category-wise breakdown (pie/bar charts)
   - Spending trends over time
   - Daily/weekly/monthly views
   - Insights and predictions

5. **Budget Management**
   - Set budgets per category
   - Real-time budget tracking
   - Alert thresholds (50%, 75%, 90%, 100%)
   - Budget period selection (daily/weekly/monthly/yearly)

6. **Multi-Account Support**
   - Track multiple bank accounts
   - Credit cards, wallets, cash
   - Separate views per account
   - Consolidated dashboard

### Upcoming Features

- ML-based categorization (v1.1)
- Recurring transaction detection
- Export reports (CSV/Excel)
- Cloud backup (optional, encrypted)
- Bill reminders
- Investment tracking

---

## 🎨 Design Principles

1. **Privacy-First**: All data stored locally, no analytics tracking
2. **Lightweight**: Minimal RAM usage (<50MB active, <20MB background)
3. **Fast**: Instant app launch, smooth animations (60fps)
4. **Offline-First**: Works without internet connection
5. **Battery Efficient**: Background processing optimized
6. **Material Design 3**: Modern, accessible UI

---

## 🔒 Privacy & Security

- **No Cloud Dependencies**: App works 100% offline
- **No Data Collection**: Zero analytics or tracking
- **Local Storage Only**: SQLite database on device
- **SMS Permissions**: Only read, never send or delete
- **Encrypted Backup**: Optional, user-controlled
- **Open Source Ready**: Transparent codebase

---

## 🌍 Target Audience

- **Primary**: Indian users with multiple bank accounts
- **Secondary**: Privacy-conscious users globally
- **Age Group**: 18-45 years
- **Tech Savvy**: Moderate to high

---

## 📊 Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| SMS Parsing Accuracy | >92% | Automated tests |
| Categorization Accuracy | >85% | User feedback |
| App Launch Time | <1.5s | Performance tests |
| Memory Usage (Active) | <50MB | Profiling |
| Memory Usage (Background) | <20MB | Profiling |
| Battery Impact | <2%/day | Android vitals |
| User Retention (30 day) | >60% | Analytics (opt-in) |

---

## 🛠️ Technology Stack

### Core

- **Framework**: Flutter 3.x
- **Language**: Dart 3.8+
- **State Management**: Riverpod 2.6.1
- **Database**: SQLite (sqflite 2.4.1)

### Notification & Permissions

- **telephony**: ^0.2.0 (notification access)
- **permission_handler**: ^11.3.1

### UI/UX

- **fl_chart**: ^0.70.2 (charts and visualizations)
- **intl**: ^0.19.0 (formatting)
- **Material Design 3**: Built-in

### Code Generation

- **freezed**: ^2.6.1 (immutable models)
- **json_serializable**: ^6.9.2

### ML (Future)

- **tflite_flutter**: ^0.11.0 (optional, for ML categorization)

### Utilities

- **uuid**: ^4.5.1
- **shared_preferences**: ^2.3.3

---

## 📦 Project Structure

```
finance_tracker/
├── lib/
│   ├── main.dart
│   ├── config/              # App configuration
│   ├── models/              # Data models
│   ├── services/            # Business logic
│   ├── providers/           # State management
│   ├── screens/             # UI screens
│   ├── widgets/             # Reusable widgets
│   ├── utils/               # Helpers & constants
│   ├── parsers/             # SMS parsing logic
│   ├── database/            # Database layer
│   └── ml/                  # ML integration (Phase 2)
├── assets/
│   ├── models/              # ML models
│   ├── data/                # Mock data, mappings
│   └── images/              # Icons, logos
├── test/
│   ├── unit/
│   ├── integration/
│   └── widget/
├── docs/                    # Documentation
└── scripts/                 # Build & utility scripts
```

---

## 🚦 Development Phases

### Phase 1: Foundation (Completed ✅)

- Project setup & architecture
- Core data models (Transaction, Budget, Account, Category)
- Database implementation with repositories
- Basic UI scaffold

### Phase 2: Notification Parsing (Completed ✅)

- Notification reading service
- Parser implementation (20+ banks)
- Rule-based categorization (90%+ accuracy)
- Unit tests

### Phase 3: Core Features (Completed ✅)

- Dashboard UI with charts
- Transaction list & filters
- Category management
- Analytics and insights

### Phase 4: Budget Management (Completed ✅)

- Budget creation and tracking
- Alert system
- Performance optimization
- Memory profiling

### Phase 5: Polish & Release (Completed ✅)

- Performance optimization
- Error handling
- Documentation
- Testing

### Phase 6: ML Integration (Planned - v1.1)

- ML model training
- TFLite integration
- User feedback loop
- Model optimization

---

## 🔮 Future Roadmap

**Q1 2026**
- Multi-language support (Hindi, regional languages)
- Widget for home screen
- Wear OS companion app

**Q2 2026**
- Bill payment reminders
- Savings goals
- Expense limits & alerts

**Q3 2026**
- iOS version (manual entry, no SMS)
- Cloud sync (encrypted)
- Family account sharing

**Q4 2026**
- AI-powered insights
- Predictive spending analysis
- Investment tracking

---

## 🤝 Contributing Guidelines

See CONTRIBUTING.md (to be created)

---

## 📄 License

MIT License

---

## 📞 Contact & Support

- **Project Start**: October 2025
- **Status**: v1.0.0 Released

---

**Last Updated**: October 30, 2025
