# Contributing to MFTracker

First off, thank you for considering contributing to MFTracker! It's people like you that make MFTracker such a great tool for personal finance management.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps to reproduce the problem**
* **Provide specific examples** (screenshots, code snippets, etc.)
* **Describe the behavior you observed and what you expected**
* **Include your environment details** (Flutter version, Android version, device model)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

* **Use a clear and descriptive title**
* **Provide a detailed description of the suggested enhancement**
* **Explain why this enhancement would be useful**
* **List any similar features in other apps**

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding standards** outlined below
3. **Write tests** for new features (aim for 80%+ coverage)
4. **Update documentation** if needed
5. **Ensure all tests pass** (`flutter test`)
6. **Run code analysis** (`flutter analyze`)
7. **Format your code** (`flutter format .`)
8. **Write a clear commit message**

## Development Setup

### Prerequisites

* Flutter SDK 3.0+
* Android Studio / VS Code
* Android SDK (for Android development)
* Xcode (for iOS development, macOS only)

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/FinanceTracker.git
cd FinanceTracker

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Run analyzer
flutter analyze
```

## Coding Standards

### Dart Style Guide

* Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
* Use `flutter format .` before committing
* Run `flutter analyze` and fix all issues
* Keep functions small and focused (< 50 lines when possible)
* Use meaningful variable and function names

### Documentation

* Use `///` for public API documentation
* Use `//` for inline comments (sparingly, code should be self-documenting)
* Document complex algorithms or non-obvious logic
* Update README.md if adding new features

### Testing

* Write unit tests for business logic
* Write widget tests for UI components
* Aim for 80%+ code coverage
* Name tests descriptively: `test('should parse HDFC SMS correctly', ...)`

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
feat: add support for HDFC Bank SMS parsing
fix: resolve budget calculation error
docs: update installation instructions
test: add tests for transaction categorization
refactor: simplify SMS parser logic
style: format code with flutter format
chore: update dependencies
```

## Areas for Contribution

### High Priority

* 🏦 **Add new bank parsers** - Support for more banks
* 🤖 **Improve categorization** - Better merchant categorization rules
* 🧪 **Increase test coverage** - More unit and widget tests
* 🌐 **Localization** - Support for more languages

### Medium Priority

* 📊 **Analytics features** - More insights and visualizations
* 🎨 **UI/UX improvements** - Better design, animations
* 📝 **Documentation** - Improve or expand documentation
* 🐛 **Bug fixes** - Fix reported issues

### Future Features

* 💳 **Credit card integration** - Direct bank API integration
* ☁️ **Cloud backup** - Encrypted backup to cloud storage
* 📱 **iOS support** - Port to iOS platform
* 🌍 **Multi-currency** - Support for multiple currencies

## Adding a New Bank Parser

To add support for a new bank:

1. Create a new parser class extending `FinancialTextParser`:

```dart
// lib/parsers/banks/newbank_parser.dart
import '../financial_text_parser.dart';

class NewBankParser extends FinancialTextParser {
  @override
  String get bankName => 'New Bank';

  @override
  List<String> get keywords => ['NEWBANK', 'NB-'];

  @override
  ParsedTransaction? parse(String text, String sender, DateTime date) {
    // Implement parsing logic
  }
}
```

2. Register it in `parser_registry.dart`:

```dart
void initializeBankParsers() {
  // ... existing parsers ...
  ParserFactory.registerParser(NewBankParser());
}
```

3. Add tests in `test/parsers/`:

```dart
test('should parse New Bank debit SMS', () {
  final parser = NewBankParser();
  final result = parser.parse(sampleSMS, 'NEWBANK', DateTime.now());
  expect(result, isNotNull);
  expect(result!.amount, 500.0);
  expect(result.type, TransactionType.expense);
});
```

## Project Structure

```
lib/
├── database/          # SQLite repositories
├── models/            # Data models (Freezed)
├── parsers/           # SMS/notification parsers
├── providers/         # Riverpod state management
├── screens/           # UI screens
├── services/          # Business logic services
├── theme/             # App theming
├── utils/             # Utilities and constants
└── widgets/           # Reusable widgets

test/
├── database/          # Database tests
├── models/            # Model tests
├── parsers/           # Parser tests
└── services/          # Service tests

docs/
├── 01_PROJECT_OVERVIEW.md
├── 02_ARCHITECTURE.md
└── 05_ML_INTEGRATION.md
```

## Review Process

1. **Automated checks** - All CI checks must pass
2. **Code review** - At least one maintainer approval required
3. **Testing** - All new features must have tests
4. **Documentation** - Update docs if needed

## Questions?

* Open an issue for discussion
* Join our community chat (if available)
* Email the maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to MFTracker! 🎉
