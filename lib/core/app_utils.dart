import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_colors.dart';

const incomeCategories = <String>[
  'Salary',
  'Freelance',
  'Business',
  'Investment',
  'Gift',
  'Other',
];

const expenseCategories = <String>[
  'Food',
  'Shopping',
  'Transport',
  'Travel',
  'Bills',
  'Education',
  'Health',
  'Entertainment',
  'Rent',
  'Groceries',
  'Other',
];

const paymentMethods = <String>[
  'Cash',
  'UPI',
  'Debit card',
  'Credit card',
  'Bank transfer',
  'Other',
];

String formatMoney(
    num value, {
      bool compact = false,
    }) {
  if (compact && value.abs() >= 10000000) {
    return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
  }

  if (compact && value.abs() >= 100000) {
    return '₹${(value / 100000).toStringAsFixed(1)}L';
  }

  if (compact && value.abs() >= 1000) {
    return '₹${(value / 1000).toStringAsFixed(1)}k';
  }

  final decimals = value % 1 == 0 ? 0 : 2;

  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: decimals,
  ).format(value);
}

String monthKey(DateTime date) {
  return DateFormat('yyyy-MM').format(date);
}

String monthLabel(DateTime date) {
  return DateFormat('MMM yyyy').format(date);
}

IconData categoryIcon(String category) {
  return switch (category) {
    'Food' => Icons.restaurant_rounded,
    'Shopping' => Icons.shopping_bag_rounded,
    'Transport' => Icons.directions_car_rounded,
    'Travel' => Icons.flight_takeoff_rounded,
    'Bills' => Icons.receipt_long_rounded,
    'Education' => Icons.school_rounded,
    'Health' => Icons.medical_services_rounded,
    'Entertainment' => Icons.movie_rounded,
    'Rent' => Icons.home_rounded,
    'Groceries' => Icons.local_grocery_store_rounded,
    'Salary' => Icons.account_balance_wallet_rounded,
    'Freelance' => Icons.laptop_mac_rounded,
    'Business' => Icons.storefront_rounded,
    'Investment' => Icons.trending_up_rounded,
    'Gift' => Icons.card_giftcard_rounded,
    _ => Icons.category_rounded,
  };
}

Color categoryColor(String category) {
  final index = (category.hashCode & 0x7fffffff) %
      AppColors.chartPalette.length;

  return AppColors.chartPalette[index];
}

String greetingForNow() {
  final hour = DateTime.now().hour;

  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';

  return 'Good evening';
}