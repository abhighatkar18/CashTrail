import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/app_utils.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/section_title.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CashTrail',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Your money, in focus',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),

          body: finance.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: finance.loadData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20, 12, 20, 110,
              ),
              children: [
                Text(
                  '${greetingForNow()},',
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: 5),

                Text(
                  'Here is your financial snapshot.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 20),

                // TOTAL BALANCE CARD

                Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3767E8),
                        Color(0xFF244FC4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'TOTAL BALANCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        formatMoney(finance.totalBalance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          _BalanceDetail(
                            title: 'Income',
                            amount: finance.totalIncome,
                            icon: Icons.south_west,
                          ),

                          const SizedBox(width: 25),

                          _BalanceDetail(
                            title: 'Expenses',
                            amount: finance.totalExpenses,
                            icon: Icons.north_east,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const SectionTitle(
                  title: 'This month',
                  subtitle: 'Your financial summary',
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Income',
                        amount: finance.currentMonthIncome,
                        icon: Icons.south_west_rounded,
                        color: AppColors.income,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _SummaryCard(
                        title: 'Expenses',
                        amount: finance.currentMonthExpenses,
                        icon: Icons.north_east_rounded,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly savings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        formatMoney(
                          finance.currentMonthSavings,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color:
                          finance.currentMonthSavings >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),

                      const SizedBox(height: 12),

                      LinearProgressIndicator(
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                        value: finance.currentMonthIncome <= 0
                            ? 0
                            : (finance.currentMonthSavings /
                            finance.currentMonthIncome)
                            .clamp(0.0, 1.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SectionTitle(
                  title: 'Recent transactions',
                  subtitle: 'Your latest financial activity',
                  actionLabel: 'View all',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const TransactionsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                if (finance.transactions.isEmpty)
                  AppCard(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 45,
                          color: AppColors.muted,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Add your first transaction to get started.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const AddTransactionScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add transaction'),
                        ),
                      ],
                    ),
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    child: Column(
                      children: finance.transactions
                          .take(5)
                          .map(
                            (transaction) =>
                            TransactionTile(
                              transaction: transaction,
                            ),
                      )
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BalanceDetail extends StatelessWidget {
  const _BalanceDetail({
    required this.title,
    required this.amount,
    required this.icon,
  });

  final String title;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 17),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            formatMoney(amount, compact: true),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 5),
          Text(
            formatMoney(amount, compact: true),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}