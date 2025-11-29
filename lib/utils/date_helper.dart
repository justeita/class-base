import 'package:intl/intl.dart';

class DateHelper {
  static String formatToIndonesian(DateTime date, {String format = 'EEEE, d MMMM y'}) {
    String formatted = DateFormat(format).format(date);
    return _translateToIndonesian(formatted);
  }

  static String getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'SENIN';
      case 2: return 'SELASA';
      case 3: return 'RABU';
      case 4: return 'KAMIS';
      case 5: return 'JUMAT';
      case 6: return 'SABTU';
      default: return 'MINGGU';
    }
  }

  static String _translateToIndonesian(String text) {
    return text
        .replaceAll('Monday', 'Senin')
        .replaceAll('Tuesday', 'Selasa')
        .replaceAll('Wednesday', 'Rabu')
        .replaceAll('Thursday', 'Kamis')
        .replaceAll('Friday', 'Jumat')
        .replaceAll('Saturday', 'Sabtu')
        .replaceAll('Sunday', 'Minggu')
        .replaceAll('MONDAY', 'SENIN')
        .replaceAll('TUESDAY', 'SELASA')
        .replaceAll('WEDNESDAY', 'RABU')
        .replaceAll('THURSDAY', 'KAMIS')
        .replaceAll('FRIDAY', 'JUMAT')
        .replaceAll('SATURDAY', 'SABTU')
        .replaceAll('SUNDAY', 'MINGGU')
        .replaceAll('January', 'Januari')
        .replaceAll('February', 'Februari')
        .replaceAll('March', 'Maret')
        .replaceAll('April', 'April')
        .replaceAll('May', 'Mei')
        .replaceAll('June', 'Juni')
        .replaceAll('July', 'Juli')
        .replaceAll('August', 'Agustus')
        .replaceAll('September', 'September')
        .replaceAll('October', 'Oktober')
        .replaceAll('November', 'November')
        .replaceAll('December', 'Desember');
  }
}
