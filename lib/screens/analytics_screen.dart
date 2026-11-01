import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../core/app_utils.dart';
import '../providers/finance_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/section_title.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        final now = DateTime.now();

        final breakdown = finance.expenseBreakdown(now);
        final months = List.generate(
          6,
              (index) => DateTime(now.year, now.month - 5 + index),
        );

        final days = List.generate(
          7,
              (index) => DateTime(
            now.year,
            now.month,
            now.day - 6 + index,
          ),
        );

        final incomeValues = months
            .map(finance.incomeForMonth)
            .toList();

        final expenseValues = months
            .map(finance.expenseForMonth)
            .toList();

        final dailyValues = days
            .map(finance.expenseForDay)
            .toList();

        final maxMonthly = [
          ...incomeValues,
          ...expenseValues,
        ].fold<double>(0, (a, b) => a > b ? a : b);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Financial Insights',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),

          body: finance.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.fromLTRB(
              20, 12, 20, 110,
            ),
            children: [
              const SectionTitle(
                title: 'This month',
                subtitle: 'Understand your financial habits',
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      title: 'Income',
                      value: finance.currentMonthIncome,
                      color: AppColors.income,
                      icon: Icons.south_west,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _Metric(
                      title: 'Expenses',
                      value: finance.currentMonthExpenses,
                      color: AppColors.expense,
                      icon: Icons.north_east,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // PIE CHART

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense distribution',
                      style: Theme.of(context)
                          .textTheme.titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      monthLabel(now),
                      style: const TextStyle(
                        color: AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (breakdown.isEmpty)
                      const SizedBox(
                        height: 180,
                        child: Center(
                          child: Text(
                            'No expenses recorded this month.',
                          ),
                        ),
                      )
                    else ...[
                      SizedBox(
                        height: 210,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 48,
                            sectionsSpace: 3,

                            sections: breakdown.entries
                                .map((entry) {
                              final total =
                                  finance.currentMonthExpenses;

                              final percent = total <= 0
                                  ? 0.0
                                  : entry.value / total * 100;

                              return PieChartSectionData(
                                value: entry.value,
                                color: categoryColor(entry.key),
                                radius: 55,
                                title:
                                '${percent.toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      ...breakdown.entries.map((entry) {
                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                height: 11,
                                width: 11,
                                decoration: BoxDecoration(
                                  color: categoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(entry.key),
                              ),

                              Text(
                                formatMoney(entry.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BAR CHART

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income vs expenses',
                      style: Theme.of(context)
                          .textTheme.titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Last six months',
                      style: TextStyle(
                        color: AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        _Legend(
                          color: AppColors.income,
                          label: 'Income',
                        ),
                        const SizedBox(width: 18),
                        _Legend(
                          color: AppColors.expense,
                          label: 'Expenses',
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          maxY: maxMonthly <= 0
                              ? 100
                              : maxMonthly * 1.2,

                          barGroups: List.generate(
                            6,
                                (index) {
                              return BarChartGroupData(
                                x: index,
                                barsSpace: 5,
                                barRods: [
                                  BarChartRodData(
                                    toY: incomeValues[index],
                                    color: AppColors.income,
                                    width: 9,
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  BarChartRodData(
                                    toY: expenseValues[index],
                                    color: AppColors.expense,
                                    width: 9,
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            },
                          ),

                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),

                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();

                                  if (index < 0 || index >= 6) {
                                    return const SizedBox();
                                  }

                                  return Padding(
                                    padding:
                                    const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateFormat('MMM')
                                          .format(months[index]),
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // LINE CHART

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily spending trend',
                      style: Theme.of(context)
                          .textTheme.titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Your last seven days of expenses',
                      style: TextStyle(
                        color: AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minY: 0,

                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),

                          titlesData: const FlTitlesData(
                            show: false,
                          ),

                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                dailyValues.length,
                                    (index) => FlSpot(
                                  index.toDouble(),
                                  dailyValues[index],
                                ),
                              ),

                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,

                              dotData: const FlDotData(
                                show: true,
                              ),

                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: days.map((day) {
                        return Text(
                          DateFormat('E').format(day),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 5),
          Text(
            formatMoney(value, compact: true),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}