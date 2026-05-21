import 'package:intl/intl.dart';

class Formatters {
  static NumberFormat _moneyFor(String languageCode) => NumberFormat.currency(
        locale: languageCode == 'en' ? 'en_US' : 'bn_BD',
        symbol: '৳',
        decimalDigits: 2,
      );

  static DateFormat _dateFor(String languageCode) =>
      DateFormat('dd MMMM yyyy', languageCode == 'en' ? 'en_US' : 'bn_BD');

  static String money(num value, {String languageCode = 'bn'}) =>
      _moneyFor(languageCode).format(value);

  static String date(DateTime value, {String languageCode = 'bn'}) =>
      _dateFor(languageCode).format(value);

  static String isoDate(DateTime value) => value.toIso8601String();
}
