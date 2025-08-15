class CurrencyInfo {
  final String code;
  final String name;
  final String flag;
  const CurrencyInfo(this.code, this.name, this.flag);
}

const List<CurrencyInfo> kCurrencies = [
  CurrencyInfo('USD', 'US Dollar', '🇺🇸'),
  CurrencyInfo('EUR', 'Euro', '🇪🇺'),
  CurrencyInfo('INR', 'Indian Rupee', '🇮🇳'),
  CurrencyInfo('GBP', 'British Pound', '🇬🇧'),
  CurrencyInfo('AUD', 'Australian Dollar', '🇦🇺'),
  CurrencyInfo('CAD', 'Canadian Dollar', '🇨🇦'),
  CurrencyInfo('JPY', 'Japanese Yen', '🇯🇵'),
  CurrencyInfo('CNY', 'Chinese Yuan', '🇨🇳'),
  CurrencyInfo('AED', 'UAE Dirham', '🇦🇪'),
  CurrencyInfo('SGD', 'Singapore Dollar', '🇸🇬'),
];

CurrencyInfo? currencyByCode(String code) {
  try {
    return kCurrencies.firstWhere((c) => c.code == code);
  } catch (_) {
    return null;
  }
}
