import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_utils.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends State<TransactionsScreen> {
  final _searchController = TextEditingController();

  String _filter = 'all';
  String _category = 'All categories';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'This transaction will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<FinanceProvider>()
          .deleteTransaction(id);
    }
  }

  List<dynamic> _filteredItems(List<dynamic> transactions) {
    final query = _searchController.text.toLowerCase();

    return transactions.where((item) {
      final matchesType =
          _filter == 'all' || item.type == _filter;

      final matchesCategory =
          _category == 'All categories' ||
              item.category == _category;

      final matchesSearch =
          item.title.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query) ||
              item.note.toLowerCase().contains(query);

      return matchesType &&
          matchesCategory &&
          matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        final items = _filteredItems(finance.transactions);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Transactions',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),

          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _filterButton('All', 'all'),
                        const SizedBox(width: 7),
                        _filterButton('Income', 'income'),
                        const SizedBox(width: 7),
                        _filterButton('Expenses', 'expense'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category filter',
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        'All categories',
                        ...incomeCategories,
                        ...expenseCategories,
                      ].toSet().map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: finance.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : items.isEmpty
                    ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No transactions found',
                  message:
                  'Try a different search or add a transaction.',
                )
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    18, 0, 18, 110,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      child: TransactionTile(
                        transaction: item,
                        showActions: true,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(
                                    transaction: item,
                                  ),
                            ),
                          );
                        },

                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(
                                    transaction: item,
                                  ),
                            ),
                          );
                        },

                        onDelete: () {
                          if (item.id != null) {
                            _delete(item.id!);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterButton(String label, String value) {
    final selected = _filter == value;

    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label)),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) {
          setState(() => _filter = value);
        },
      ),
    );
  }
}