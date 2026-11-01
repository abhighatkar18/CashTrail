# CashTrail – Personal Expense Tracker

CashTrail is a Flutter-based personal expense tracking application designed to help users manage their finances, monitor spending habits, organize budgets, and gain insights into their financial activities.

The application provides a clean and intuitive interface for tracking income and expenses, managing budgets, viewing transaction history, and analyzing financial data.

## Features

- **Dashboard:** View an overview of your financial activities, including income, expenses, and available balance.
- **Transaction Management:** Add and manage income and expense transactions.
- **Budget Management:** Create and monitor budgets to keep spending under control.
- **Analytics & Insights:** Visualize financial activities through charts and graphical representations.
- **Currency Converter:** Convert amounts between different currencies.
- **Settings:** Customize application preferences and settings.
- **Local Data Storage:** Store financial information locally using SQLite.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| SQLite (sqflite) | Local database management |
| Provider | State management |
| fl_chart | Data visualization |
| HTTP | API communication |
| SharedPreferences | Local preferences storage |
| Android Studio | Development environment |

## Application Structure

```text
CashTrail/
│
├── android/                 # Android platform configuration
├── ios/                     # iOS platform configuration
├── linux/                   # Linux platform configuration
├── macos/                   # macOS platform configuration
├── web/                     # Web platform configuration
├── windows/                 # Windows platform configuration
│
├── lib/
│   ├── core/                # App theme, colors and utilities
│   ├── data/                # Database configuration
│   ├── models/              # Data models
│   ├── providers/           # State management
│   ├── screens/             # Application screens
│   ├── services/            # Application services
│   ├── widgets/             # Reusable UI components
│   ├── app.dart             # Application configuration
│   └── main.dart            # Application entry point
│
├── test/                    # Application tests
├── pubspec.yaml             # Dependencies and project configuration
└── README.md
```

## Getting Started

Follow these instructions to run CashTrail locally.

### Prerequisites

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or Visual Studio Code
- Android Emulator or a physical Android device

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/abhighatkar18/CashTrail.git
```

**2. Navigate to the project directory**

```bash
cd CashTrail
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Check connected devices**

```bash
flutter devices
```

**5. Run the application**

```bash
flutter run
```

## Screenshots

Screenshots of the application will be added here.

<!-- Add screenshots using the following format:

![Dashboard](screenshots/dashboard.png)
![Transactions](screenshots/transactions.png)
![Budgets](screenshots/budgets.png)
![Analytics](screenshots/analytics.png)

-->

## Project Goals

CashTrail aims to provide a simple and accessible way to:

- Maintain records of daily financial transactions.
- Monitor income and expenditure.
- Set and manage personal budgets.
- Understand spending patterns through visual analytics.
- Improve personal financial awareness.

## Future Enhancements

- Cloud synchronization and backup.
- User authentication.
- Export financial reports in PDF and CSV formats.
- Advanced financial analytics.
- Recurring transactions and reminders.
- Enhanced budget notifications.

## Contributing

Contributions, suggestions, and feedback are welcome.

1. Fork this repository.
2. Create a new feature branch.
3. Commit your changes.
4. Push the branch to your fork.
5. Open a Pull Request.

## License

This project is currently available for educational and personal development purposes. A formal open-source license can be added in the future.

---

**Developed with Flutter and Dart.**

GitHub Repository: https://github.com/abhighatkar18/CashTrail