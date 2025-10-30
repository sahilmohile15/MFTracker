// Merchant Category Mapper
// Maps merchant names to predefined categories for transaction classification

class MerchantCategoryMapper {
  // Merchant to category mapping (case-insensitive)
  static final Map<String, List<String>> _categoryMerchants = {
    'food_delivery': [
      'SWIGGY', 'ZOMATO', 'FOODAHOLIC', 'DOMINOS PIZZA', 'MCDONALDS', 'KFC',
      'BURGER KING', 'BIRYANI BLUES', 'FAASOS', 'BEHROUZ', 'OVENSTORY'
    ],
    'grocery': [
      'BLINKIT COMMERCE PRIVATE LIMITED', 'INGBIGBASKET', 'BIGBASKET', 'DMART READY', 'ZEPTO',
      'AMAZON PANTRY', 'JIOMART', 'MORE MEGASTORE', 'SPENCERS RETAIL'
    ],
    'ecommerce': [
      'AMAZON PAY INDIA PRIVATET', 'AMAZON PAY INDIA PVT L', 'AMAZON PAY', 'AMAZON',
      'IND*AMAZON', 'FLIPKART', 'MYNTRA', 'AJIO', 'NYKAA', 'MEESHO', 'SNAPDEAL'
    ],
    'payment_gateway': [
      'PAYU RETAIL', 'RAZORPAY', 'PHONEPE', 'PAYTM', 'GOOGLEPAY',
      'CASHFREE', 'BILLDESK', 'INSTAMOJO'
    ],
    'entertainment': [
      'BOOKMYSHOW', 'PVR CINEMAS', 'INOX', 'NETFLIX', 'AMAZON PRIME',
      'HOTSTAR', 'SPOTIFY', 'SONY LIV', 'ZEE5'
    ],
    'transport': [
      'OLA CABS', 'UBER INDIA', 'RAPIDO', 'MAKEMYTRIP', 'GOIBIBO',
      'REDBUS', 'IRCTC'
    ],
    'retail': [
      'RELIANCE DIGITAL', 'CROMA', 'DECATHLON', 'PANTALOONS', 'WESTSIDE',
      'SHOPPERS STOP', 'MAX FASHION', 'LIFESTYLE'
    ],
    'pharmacy': [
      'APOLLO PHARMACY', 'MEDPLUS', 'PHARMEASY', '1MG', 'NETMEDS'
    ],
    'subscription': [
      'LINKEDIN', 'MICROSOFT', 'ADOBE', 'CANVA', 'AWS', 'DROPBOX'
    ],
    'utilities': [
      'TATA POWER', 'ADANI ELECTRICITY', 'MAHANAGAR GAS', 'AIRTEL',
      'JIO', 'VODAFONE IDEA', 'BSNL'
    ],
    'misc': [
      'PETROL PUMP', 'HP PETROL PUMP', 'INDIAN OIL', 'SHELL', 'ESSAR'
    ]
  };

  // Reverse lookup map for faster category detection
  static final Map<String, String> _merchantToCategory = _buildReverseLookup();

  static Map<String, String> _buildReverseLookup() {
    final Map<String, String> lookup = {};
    _categoryMerchants.forEach((category, merchants) {
      for (final merchant in merchants) {
        lookup[merchant.toUpperCase()] = category;
      }
    });
    return lookup;
  }

  /// Get category for a merchant name (case-insensitive)
  /// Returns the category string or 'uncategorized' if not found
  static String getCategory(String? merchantName) {
    if (merchantName == null || merchantName.isEmpty) {
      return 'uncategorized';
    }

    final upperMerchant = merchantName.toUpperCase();

    // Direct lookup first (exact match)
    if (_merchantToCategory.containsKey(upperMerchant)) {
      return _merchantToCategory[upperMerchant]!;
    }

    // Partial match - check if merchant name contains any known merchant
    // Sort by length to prefer longer (more specific) matches
    String? bestMatch;
    int bestMatchLength = 0;
    
    for (final entry in _merchantToCategory.entries) {
      final knownMerchant = entry.key;
      final category = entry.value;

      // Check if the known merchant is contained in the extracted merchant name
      if (upperMerchant.contains(knownMerchant) && knownMerchant.length > bestMatchLength) {
        bestMatch = category;
        bestMatchLength = knownMerchant.length;
      }

      // Check if the extracted merchant name is contained in the known merchant
      if (knownMerchant.contains(upperMerchant) && upperMerchant.length > bestMatchLength) {
        bestMatch = category;
        bestMatchLength = upperMerchant.length;
      }
    }

    if (bestMatch != null) {
      return bestMatch;
    }

    // No match found
    return 'uncategorized';
  }

  /// Get a human-readable category name
  static String getCategoryDisplayName(String category) {
    final Map<String, String> displayNames = {
      'food_delivery': 'Food Delivery',
      'grocery': 'Grocery',
      'ecommerce': 'E-Commerce',
      'payment_gateway': 'Payment Gateway',
      'entertainment': 'Entertainment',
      'transport': 'Transport',
      'retail': 'Retail',
      'pharmacy': 'Pharmacy',
      'subscription': 'Subscription',
      'utilities': 'Utilities',
      'misc': 'Miscellaneous',
      'uncategorized': 'Uncategorized'
    };

    return displayNames[category] ?? 'Uncategorized';
  }

  /// Get all available categories
  static List<String> getAllCategories() {
    return _categoryMerchants.keys.toList()..add('uncategorized');
  }

  /// Get all merchants for a specific category
  static List<String> getMerchantsForCategory(String category) {
    return _categoryMerchants[category] ?? [];
  }

  /// Get category statistics for a list of merchants
  static Map<String, int> getCategoryStats(List<String?> merchantNames) {
    final Map<String, int> stats = {};

    for (final merchant in merchantNames) {
      final category = getCategory(merchant);
      stats[category] = (stats[category] ?? 0) + 1;
    }

    return stats;
  }

  /// Check if a merchant belongs to a specific category
  static bool isInCategory(String? merchantName, String category) {
    return getCategory(merchantName) == category;
  }

  /// Normalize merchant name for better matching
  /// Removes common suffixes and standardizes format
  static String normalizeMerchantName(String merchantName) {
    String normalized = merchantName.toUpperCase().trim();

    // Remove common suffixes
    final suffixes = [
      'PRIVATE LIMITED',
      'PVT LTD',
      'PRIVATE LTD',
      'PVT. LTD.',
      'PVT LTD.',
      'LIMITED',
      'LTD',
      'INDIA',
      'COMMERCE',
    ];

    for (final suffix in suffixes) {
      if (normalized.endsWith(suffix)) {
        normalized = normalized.substring(0, normalized.length - suffix.length).trim();
      }
    }

    // Remove common prefixes
    if (normalized.startsWith('IND*')) {
      normalized = normalized.substring(4);
    }

    return normalized;
  }

  /// Enhanced category detection with normalization
  static String getCategoryWithNormalization(String? merchantName) {
    if (merchantName == null || merchantName.isEmpty) {
      return 'uncategorized';
    }

    // Try direct match first
    final directCategory = getCategory(merchantName);
    if (directCategory != 'uncategorized') {
      return directCategory;
    }

    // Try with normalized name
    final normalizedName = normalizeMerchantName(merchantName);
    return getCategory(normalizedName);
  }
}
