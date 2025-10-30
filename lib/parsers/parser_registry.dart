// Bank Parser Registry
// Registers all bank-specific parsers with the factory

import 'financial_text_parser.dart';
import 'bank_parsers/sbi_parser.dart';
import 'bank_parsers/hdfc_parser.dart';
import 'bank_parsers/icici_parser.dart';
import 'bank_parsers/axis_parser.dart';
import 'bank_parsers/kotak_parser.dart';
import 'bank_parsers/indusind_parser.dart';
import 'bank_parsers/yesbank_parser.dart';
import 'bank_parsers/idfcfirst_parser.dart';
import 'bank_parsers/pnb_parser.dart';
import 'bank_parsers/bob_parser.dart';
import 'bank_parsers/canara_parser.dart';
import 'bank_parsers/union_parser.dart';
import 'bank_parsers/federal_parser.dart';
import 'bank_parsers/indianbank_parser.dart';
import 'bank_parsers/boi_parser.dart';
import 'bank_parsers/centralbank_parser.dart';
import 'bank_parsers/idbi_parser.dart';
import 'bank_parsers/iob_parser.dart';
import 'bank_parsers/amex_parser.dart';
import 'bank_parsers/generic_parser.dart';

/// Initialize all bank parsers and register them with the factory
void initializeBankParsers() {
  // Clear any existing parsers (useful for testing)
  BankParserFactory.clearParsers();
  
  // Register major Indian banks (alphabetical order)
  BankParserFactory.registerParser(AMEXParser());
  BankParserFactory.registerParser(AxisBankParser());
  BankParserFactory.registerParser(BankOfBarodaParser());
  BankParserFactory.registerParser(BankOfIndiaParser());
  BankParserFactory.registerParser(CanaraBankParser());
  BankParserFactory.registerParser(CentralBankOfIndiaParser());
  BankParserFactory.registerParser(FederalBankParser());
  BankParserFactory.registerParser(HDFCBankParser());
  BankParserFactory.registerParser(ICICIBankParser());
  BankParserFactory.registerParser(IDBIBankParser());
  BankParserFactory.registerParser(IDFCFirstBankParser());
  BankParserFactory.registerParser(IndianBankParser());
  BankParserFactory.registerParser(IndianOverseasBankParser());
  BankParserFactory.registerParser(IndusIndBankParser());
  BankParserFactory.registerParser(KotakBankParser());
  BankParserFactory.registerParser(PNBBankParser());
  BankParserFactory.registerParser(SBIBankParser());
  BankParserFactory.registerParser(UnionBankParser());
  BankParserFactory.registerParser(YesBankParser());
  
  // Register generic parser as fallback (must be last!)
  BankParserFactory.registerParser(GenericBankParser());
  
  // TODO: Add more bank parsers here as they are created
  // Additional banks to add:
  // - RBL Bank
  // - Standard Chartered
  // - Citibank
  // - HSBC
  // - DBS Bank
  // - Karnataka Bank
  // - South Indian Bank
  // - Jammu & Kashmir Bank
  // - Paytm Payments Bank
  // - AU Small Finance Bank
  // - Bandhan Bank
  // - Credit cards: AMEX, OneCard, Slice, etc.
  // - Wallets: Paytm, PhonePe, Google Pay, etc.
}

/// Get list of all supported banks
List<String> getSupportedBanks() {
  return BankParserFactory.getAllParsers()
      .map((parser) => parser.getBankName())
      .toList();
}

/// Check if a sender is supported by any registered parser
bool isSenderSupported(String sender) {
  return BankParserFactory.findParser(sender) != null;
}
