import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_utils.dart';
import '../core/app_colors.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.transaction,
  });

  final FinanceTransaction? transaction;

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _type;
  late String _category;
  late String _paymentMethod;
  late DateTime _date;

  bool _isSaving = false;

  bool get _isEditing => widget.transaction != null;

  List<String> get _categories =>
      _type == 'income'
          ? incomeCategories
          : expenseCategories;

  @override
  void initState() {
    super.initState();

    final existing = widget.transaction;

    _titleController = TextEditingController(
      text: existing?.title ?? '',
    );

    _amountController = TextEditingController(
      text: existing?.amount.toString() ?? '',
    );

    _noteController = TextEditingController(
      text: existing?.note ?? '',
    );

    _type = existing?.type ?? 'expense';
    _category = existing?.category ?? 'Food';
    _paymentMethod = existing?.paymentMethod ?? 'UPI';
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 5),
      ),
    );

    if (selected != null) {
      setState(() => _date = selected);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final amount = double.parse(
      _amountController.text.trim(),
    );

    final transaction = FinanceTransaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      category: _category,
      date: DateTime(
        _date.year,
        _date.month,
        _date.day,
        12,
      ),
      paymentMethod: _paymentMethod,
      note: _noteController.text.trim(),
    );

    final messenger = ScaffoldMessenger.of(context);

    try {
      final provider = context.read<FinanceProvider>();

      if (_isEditing) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }

      if (!mounted) return;

      Navigator.pop(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Transaction updated successfully'
                : 'Transaction added successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Error saving transaction: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit transaction'
              : 'New transaction',
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            // INCOME / EXPENSE SELECTOR

            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    title: 'Expense',
                    icon: Icons.arrow_upward_rounded,
                    selected: _type == 'expense',
                    color: AppColors.expense,
                    onTap: () {
                      setState(() {
                        _type = 'expense';
                        _category = expenseCategories.first;
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _TypeButton(
                    title: 'Income',
                    icon: Icons.arrow_downward_rounded,
                    selected: _type == 'income',
                    color: AppColors.income,
                    onTap: () {
                      setState(() {
                        _type = 'income';
                        _category = incomeCategories.first;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              'Amount',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: _amountController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Enter amount',
              ),
              validator: (value) {
                final amount =
                double.tryParse(value ?? '');

                if (amount == null ||
                    !amount.isFinite ||
                    amount <= 0) {
                  return 'Enter a valid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 22),

            Text(
              'Transaction details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _titleController,
              textCapitalization:
              TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Monthly groceries',
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please enter a title';
                }

                return null;
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),

            const SizedBox(height: 15),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Transaction date',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(
                  DateFormat('dd MMMM yyyy').format(_date),
                ),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment method',
                prefixIcon: Icon(Icons.payment),
              ),
              items: paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMethod = value);
                }
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Additional details',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 55,
              child: FilledButton.icon(
                onPressed:
                _isSaving ? null : _saveTransaction,
                icon: _isSaving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : _isEditing
                      ? 'Update transaction'
                      : 'Save transaction',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? color : Colors.transparent,
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? color : null,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}