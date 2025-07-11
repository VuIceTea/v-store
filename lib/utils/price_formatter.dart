import 'package:intl/intl.dart';

class PriceFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ ',
    decimalDigits: 0,
  );

  static String format(double price) {
    return _currencyFormat.format(price);
  }

  static String formatWithDiscount(double originalPrice, double? discount) {
    if (discount != null && discount > 0) {
      final discountedPrice = originalPrice * (1 - discount / 100);
      return format(discountedPrice);
    }
    return format(originalPrice);
  }
}
