
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../core/app_utils.dart';
import '../models/finance_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  final FinanceTransaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = transaction.isIncome
        ? AppColors.income
        : categoryColor(transaction.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                transaction.isIncome
                    ? Icons.south_west_rounded
                    : categoryIcon(transaction.category),
                color: color,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.category} · '
                        '${DateFormat('dd MMM').format(transaction.date)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '${transaction.isIncome ? '+' : '−'}'
                  '${formatMoney(transaction.amount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: transaction.isIncome
                    ? AppColors.income
                    : theme.colorScheme.onSurface,
              ),
            ),

            if (showActions)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
