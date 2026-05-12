# Dash

A Flutter mobile app for tracking car maintenance. Keep a garage of vehicles and log transactions like oil changes, repairs, and costs per car.

This project is a test for implementing a single codebase that can later be used for a Firebase-backed cloud-hosted option.

![](/docs/dashboard.png)

## Features

- Add and manage multiple vehicles with brand icons, VIN, plate, and mileage
- Log maintenance transactions with type, date, cost, and mileage
- SQLite-backed persistence via `sqflite`
- Provider state management

## Project Structure

```
lib/
  main.dart                # App entry point, root scaffold, drawer
  theme.dart               # App-wide Material theme
  models/
    car.dart               # Car data model + DB mapping
    txn.dart               # Transaction data model + DB mapping
  screens/
    car_detail.dart        # View a single car and its transactions
    car_edit.dart          # Edit car details
    car_new.dart           # Add a new car
    txn_new.dart           # Log a new transaction
    txn_type.dart          # Transaction type picker
    iconpicker.dart        # Manufacturer icon picker
    about.dart             # About screen
  utils/
    dbhelper_sqflite.dart  # SQLite singleton (cars + txns tables)
    garage_model.dart      # ChangeNotifier provider (app state)
scripts/
  seed_dummy_data.py       # Creates demo cars + transactions
```

## Quick Setup

This repo was revived mainly to run the Windows desktop app and make screenshots.
Do not use Chrome/web for this version.

```powershell
flutter pub get
flutter run -d windows
```

Android is not currently the happy path because some dependencies are old.

## SQLite Setup

The app uses `sqflite` on mobile and `sqflite_common_ffi` on Windows desktop.
Desktop FFI is initialized in `lib/main.dart` before `runApp()`.

At runtime the app does **not** use `cars_sqlite.db` from the project folder.
It opens the database from the platform documents directory. On Windows this is usually your Documents folder:
```text
$env:userprofile\Documents\cars_sqlite.db
```

The app prints the exact path when it opens the DB:
```text
sqlite db path: $env:userprofile\Documents\cars_sqlite.db
```

## Dummy Data

Generate demo cars and transactions in the project folder:

```powershell
python scripts\seed_dummy_data.py --reset cars_sqlite.db
```

Copy that seeded DB to the Windows app location:

```powershell
Copy-Item .\cars_sqlite.db "$HOME\Documents\cars_sqlite.db" -Force
```

Then run the app:

```powershell
flutter run -d windows
```

The seed script creates 4 cars and 28 transactions.

Important DB version note: `sqflite` uses SQLite `PRAGMA user_version` to decide whether to run `onCreate`. A database created outside Flutter must have `user_version=1`, or the app may try to create tables that already exist. The seed script handles this.

## Testing / Checks

Useful commands:

```powershell
flutter analyze
flutter test
python -m py_compile scripts\seed_dummy_data.py
```

Note: no unit tests exist yet. The `bups/` directory contains dated backup snapshots of earlier iterations and is not part of the build.
