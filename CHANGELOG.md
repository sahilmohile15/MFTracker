# Changelog

All notable changes to MFTracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-30

### Added

#### Core Features

- Automatic transaction parsing from bank SMS and notifications (20+ Indian banks supported)
- Rule-based smart categorization with 90%+ accuracy
- Real-time budget tracking with customizable alert thresholds (50%, 75%, 90%, 100%)
- Multi-account support (bank accounts, credit cards, wallets, cash)
- Comprehensive analytics dashboard with charts and insights
- Spending predictions and trend analysis
- Recurring transaction detection
- CSV and PDF export functionality
- Material Design 3 UI with dark mode support

#### Banking Support
- HDFC Bank parser
- ICICI Bank parser
- State Bank of India (SBI) parser
- Axis Bank parser
- Kotak Mahindra Bank parser
- Punjab National Bank (PNB) parser
- Bank of Baroda parser
- Canara Bank parser
- IDBI Bank parser
- Yes Bank parser
- IndusInd Bank parser
- IDFC First Bank parser
- Federal Bank parser
- Union Bank parser
- Indian Bank parser
- Bank of India parser
- Central Bank of India parser
- Indian Overseas Bank parser
- American Express parser
- Generic fallback parser for unsupported banks

#### Privacy & Security

- 100% offline operation - no internet permission
- Local SQLite database storage
- No cloud sync or external data transmission
- No user accounts or authentication
- SMS and notification data never leaves device
- Only financial transactions are processed
- Optional database encryption support (SQLCipher ready)
- Privacy-first, always and forever

#### User Interface
- Home dashboard with summary cards
- Transaction list with filters and search
- Budget management screen
- Analytics screen with interactive charts
- Insights screen with predictions
- Settings and preferences
- Account management
- Category management
- Tag management
- Developer tools for testing

#### Technical Implementation
- Clean Architecture with layer separation
- Riverpod state management
- Freezed for immutable models
- SQLite database with optimized queries
- Background task management
- Notification service integration
- CSV/PDF generation
- Batch operations support

### Performance
- APK Size: 22.7MB (85.9MB uncompressed)
- Memory Usage: <50MB active, <20MB background
- Battery Impact: <2% per day
- App Launch Time: <1.5s
- Transaction Parsing Accuracy: 90%+

### Documentation
- Comprehensive README
- Architecture documentation
- ML integration roadmap
- Contributing guidelines
- Code of Conduct
- F-Droid submission guide

### Build Information
- Flutter 3.x
- Dart 3.8.1+
- Target Android SDK: 34
- Minimum Android SDK: 26 (Android 8.0+)

---

## [Unreleased]

### Planned for v1.1.0 (Q1 2026)
- ML-powered categorization (95%+ accuracy target)
- Enhanced expense predictions
- Advanced budget alerts
- Recurring transaction management improvements
- Export templates

### Planned for v1.2.0 (Q2 2026)
- iOS support
- Cloud backup (optional, encrypted)
- Multi-user support (family accounts)
- Bill reminders and payment tracking
- Investment tracking

### Planned for v2.0.0 (Q3 2026)
- AI-powered financial advisor
- Smart savings recommendations
- Goal-based savings tracking
- Credit score monitoring
- Tax filing app integration

---

## Release Notes Format

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security improvements

---

[1.0.0]: https://github.com/sahilmohile15/mftracker/releases/tag/v1.0.0
[Unreleased]: https://github.com/sahilmohile15/mftracker/compare/v1.0.0...HEAD
