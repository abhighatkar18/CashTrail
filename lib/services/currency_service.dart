import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyService {
  CurrencyService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<CurrencyRate> getRate({
    required String from,
    required String to,
  }) async {
    if (from == to) {
      return CurrencyRate(
        base: from,
        quote: to,
        rate: 1,
        date: DateTime.now(),
      );
    }

    final uri = Uri.https(
      'api.frankfurter.dev',
      '/v2/rate/$from/$to',
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Exchange-rate service error: '
            '${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> ||
        decoded['rate'] == null) {
      throw const FormatException(
        'Invalid exchange-rate response.',
      );
    }

    final rate =
    (decoded['rate'] as num).toDouble();

    final dateString = decoded['date'] as String?;

    return CurrencyRate(
      base: from,
      quote: to,
      rate: rate,
      date: dateString == null
          ? DateTime.now()
          : DateTime.parse(dateString),
    );
  }

  void dispose() {
    _client.close();
  }
}

class CurrencyRate {
  const CurrencyRate({
    required this.base,
    required this.quote,
    required this.rate,
    required this.date,
  });

  final String base;
  final String quote;
  final double rate;
  final DateTime date;
}