// Generic Bank Parser
// Fallback parser for banks without specific parsers
// Uses only base class patterns

import '../financial_text_parser.dart';

class GenericBankParser extends FinancialTextParser {
  @override
  String getBankName() => 'Generic Bank';

  @override
  bool canHandle(String sender) {
    // This is the fallback parser - it accepts any sender
    // Will be checked last in the registry
    return true;
  }

  // No overrides - uses all base class extraction methods
  // This provides basic parsing for any bank message
}
