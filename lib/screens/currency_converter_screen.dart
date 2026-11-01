import 'package:flutter/material.dart';

import '../services/currency_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends State<CurrencyConverterScreen> {
  final _amountController =
  TextEditingController(text: '1000');

  final _service = CurrencyService();

  static const currencies = [
    'INR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'AUD',
    'CAD',
    'JPY',
    'SGD',
  ];

  String _from = 'INR';
  String _to = 'USD';

  double? _convertedAmount;
  double? _exchangeRate;

  DateTime? _rateDate;

  bool _loading = false;
  String? _error;

  Future<void> _convert() async {
    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null ||
        !amount.isFinite ||
        amount <= 0) {
      setState(() {
        _error = 'Enter a valid amount.';
        _convertedAmount = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.getRate(
        from: _from,
        to: _to,
      );

      if (!mounted) return;

      setState(() {
        _exchangeRate = result.rate;
        _convertedAmount = amount * result.rate;
        _rateDate = result.date;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not retrieve exchange rates. '
            'Check your internet connection and try again.';
        _convertedAmount = null;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final oldFrom = _from;
      _from = _to;
      _to = oldFrom;
    });

    _convert();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3767E8),
                  Color(0xFF244FC4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.currency_exchange,
                  color: Colors.white,
                  size: 35,
                ),

                SizedBox(height: 15),

                Text(
                  'Currency Converter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'Convert currencies using reference exchange rates.',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Amount',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          TextField(
            controller: _amountController,
            keyboardType:
            const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter amount',
            ),
            onChanged: (_) {
              setState(() {
                _convertedAmount = null;
                _exchangeRate = null;
                _error = null;
              });
            },
          ),

          const SizedBox(height: 22),

          const Text(
            'From currency',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          _currencyDropdown(
            value: _from,
            onChanged: (value) {
              setState(() {
                _from = value!;
                _convertedAmount = null;
              });
            },
          ),

          const SizedBox(height: 12),

          Center(
            child: IconButton.filledTonal(
              onPressed: _swapCurrencies,
              icon: const Icon(Icons.swap_vert_rounded),
              tooltip: 'Swap currencies',
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'To currency',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          _currencyDropdown(
            value: _to,
            onChanged: (value) {
              setState(() {
                _to = value!;
                _convertedAmount = null;
              });
            },
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _loading ? null : _convert,
              icon: _loading
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.currency_exchange),
              label: Text(
                _loading ? 'Converting...' : 'Convert currency',
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 20),

            Text(
              _error!,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ],

          if (_convertedAmount != null) ...[
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: theme.dividerColor,
                ),
              ),

              child: Column(
                children: [
                  const Text(
                    'CONVERTED AMOUNT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    '${_convertedAmount!.toStringAsFixed(2)} $_to',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    '1 $_from = '
                        '${_exchangeRate!.toStringAsFixed(5)} $_to',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  if (_rateDate != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      'Rate date: '
                          '${_rateDate!.day}/'
                          '${_rateDate!.month}/'
                          '${_rateDate!.year}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          const Text(
            'Exchange rates are reference rates and may differ '
                'from rates offered by banks or payment providers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.currency_exchange),
      ),
      items: currencies.map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}