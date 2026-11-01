import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/app_utils.dart';
import '../models/budget.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  Future<void> _addBudget(BuildContext context) async {
    final categories = expenseCategories;
    final controller = TextEditingController();
    String category = categories.first;

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create monthly budget'),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: categories.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          category = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: controller,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Budget amount',
                      prefixText: '₹ ',
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: () {
                    final value =
                    double.tryParse(controller.text);

                    if (value == null ||
                        !value.isFinite ||
                        value <= 0) {
                      return;
                    }

                    Navigator.pop(dialogContext, value);
                  },
                  child: const Text('Save budget'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (amount == null || !context.mounted) return;

    await context.read<FinanceProvider>().saveBudget(
      Budget(
        category: category,
        amount: amount,
        month: monthKey(DateTime.now()),
      ),
    );
  }

  Future<void> _deleteBudget(
      BuildContext context,
      Budget budget,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove budget?'),
        content: Text(
          'Remove the ${budget.category} budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true &&
        budget.id != null &&
        context.mounted) {
      await context.read<FinanceProvider>()
          .deleteBudget(budget.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        final budgets = finance.currentMonthBudgets;

        final totalSpent = budgets.fold<double>(
          0,
              (sum, budget) =>
          sum +
              finance.expenseForCategory(
                budget.category,
                DateTime.now(),
              ),
        );

        final totalBudget =
            finance.currentMonthBudgetTotal;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Budgets',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),

          floatingActionButton:
          FloatingActionButton.extended(
            onPressed: () => _addBudget(context),
            icon: const Icon(Icons.add),
            label: const Text('Add budget'),
          ),

          body: finance.isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : ListView(
            padding: const EdgeInsets.fromLTRB(
              20, 12, 20, 110,
            ),
            children: [
              AppCard(
                backgroundColor:
                AppColors.primary,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MONTHLY BUDGET',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      formatMoney(totalBudget),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${formatMoney(totalSpent)} spent this month',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 14),

                    LinearProgressIndicator(
                      value: totalBudget <= 0
                          ? 0
                          : (totalSpent / totalBudget)
                          .clamp(0.0, 1.0),
                      minHeight: 9,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      formatMoney(totalBudget - totalSpent) +
                          ' remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Category budgets',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              if (budgets.isEmpty)
                const EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No budgets created',
                  message:
                  'Create category-wise budgets to control your spending.',
                  actionLabel: null,
                )
              else
                ...budgets.map((budget) {
                  final spent = finance.expenseForCategory(
                    budget.category,
                    DateTime.now(),
                  );

                  return _BudgetCard(
                    budget: budget,
                    spent: spent,
                    onDelete: () =>
                        _deleteBudget(context, budget),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.onDelete,
  });

  final Budget budget;
  final double spent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(budget.category);
    final ratio = (spent / budget.amount).clamp(0.0, 1.0);
    final remaining = budget.amount - spent;

    final exceeded = spent > budget.amount;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 13),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(
                  categoryIcon(budget.category),
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  budget.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatMoney(spent)),
              Text(
                'of ${formatMoney(budget.amount)}',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: ratio,
            minHeight: 9,
            borderRadius: BorderRadius.circular(15),
            color: exceeded ? AppColors.expense : color,
            backgroundColor: color.withValues(alpha: 0.12),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              exceeded
                  ? '${formatMoney(remaining.abs())} over budget'
                  : '${formatMoney(remaining)} remaining',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: exceeded
                    ? AppColors.expense
                    : AppColors.income,
              ),
            ),
          ),
        ],
      ),
    );
  }
}