#!/usr/bin/env python3
"""Seed the Dash SQLite database with demo garage data.

Usage:
  python scripts/seed_dummy_data.py "C:\\path\\to\\cars_sqlite.db"
  python scripts/seed_dummy_data.py --reset "C:\\path\\to\\cars_sqlite.db"

If no database path is provided, the script writes to ./cars_sqlite.db.
Use the "sqlite db path:" line printed by the app for the active Windows DB.
"""

from __future__ import annotations

import argparse
import sqlite3
from datetime import datetime, timedelta
from pathlib import Path


CARS = [
    {
        "vin": "1HGBH41JXMN109186",
        "nickname": "Civic Commuter",
        "plate": "DASH-101",
        "mileage": 84250,
        "icon": "images/car_icons/honda.png",
    },
    {
        "vin": "5YJ3E1EA7KF317000",
        "nickname": "Model 3",
        "plate": "EV-2026",
        "mileage": 36640,
        "icon": "images/car_icons/tesla.png",
    },
    {
        "vin": "1FTFW1E50NFA00042",
        "nickname": "Weekend Truck",
        "plate": "HAUL-42",
        "mileage": 58910,
        "icon": "images/car_icons/ford.png",
    },
    {
        "vin": "WBA8E9G52JNU12345",
        "nickname": "Blue Sedan",
        "plate": "BLUE-5",
        "mileage": 72115,
        "icon": "images/car_icons/bmw.png",
    },
]

TXN_TEMPLATES = [
    ("Fuel", 46.82, 120, "Filled tank"),
    ("Oil Change", 78.40, 420, "Synthetic oil and filter"),
    ("Tire Rotation", 34.99, 960, "Rotated tires"),
    ("Repair", 312.65, 1410, "Replaced worn brake pads"),
    ("Registration", 128.00, 1850, "Annual registration renewal"),
    ("Wash", 18.00, 2020, "Exterior wash"),
    ("Insurance", 146.25, 2350, "Monthly premium"),
]


def create_schema(conn: sqlite3.Connection) -> None:
    conn.executescript(
        """
        PRAGMA foreign_keys=ON;

        CREATE TABLE IF NOT EXISTS cars (
          id INTEGER PRIMARY KEY,
          vin TEXT UNIQUE,
          nickname TEXT,
          mileage INTEGER,
          plate TEXT,
          icon TEXT
        );

        CREATE TABLE IF NOT EXISTS txns (
          id INTEGER PRIMARY KEY,
          txntype TEXT,
          datetime INTEGER,
          cost REAL,
          mileage INTEGER,
          note TEXT,
          carid INTEGER,
          FOREIGN KEY(carid) REFERENCES cars(id)
        );

        PRAGMA user_version=1;
        """
    )


def table_columns(conn: sqlite3.Connection, table_name: str) -> set[str]:
    return {row[1] for row in conn.execute(f"PRAGMA table_info({table_name})")}


def reset_data(conn: sqlite3.Connection) -> None:
    conn.execute("DELETE FROM txns")
    conn.execute("DELETE FROM cars")


def seed(conn: sqlite3.Connection) -> tuple[int, int]:
    car_count = 0
    txn_count = 0
    today = datetime.now().replace(hour=9, minute=0, second=0, microsecond=0)
    car_columns = table_columns(conn, "cars")
    has_icon_column = "icon" in car_columns

    for car_index, car in enumerate(CARS):
        if has_icon_column:
            cursor = conn.execute(
                """
                INSERT OR IGNORE INTO cars (vin, nickname, mileage, plate, icon)
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    car["vin"],
                    car["nickname"],
                    car["mileage"],
                    car["plate"],
                    car["icon"],
                ),
            )
        else:
            cursor = conn.execute(
                """
                INSERT OR IGNORE INTO cars (vin, nickname, mileage, plate)
                VALUES (?, ?, ?, ?)
                """,
                (
                    car["vin"],
                    car["nickname"],
                    car["mileage"],
                    car["plate"],
                ),
            )
        if cursor.rowcount:
            car_count += 1

        car_id = conn.execute(
            "SELECT id FROM cars WHERE vin = ?",
            (car["vin"],),
        ).fetchone()[0]

        existing_txns = conn.execute(
            "SELECT COUNT(*) FROM txns WHERE carid = ?",
            (car_id,),
        ).fetchone()[0]
        if existing_txns:
            continue

        base_mileage = int(car["mileage"]) - 3000
        for txn_index, (txntype, cost, miles_after, note) in enumerate(TXN_TEMPLATES):
            when = today - timedelta(days=(txn_index * 24) + (car_index * 5))
            conn.execute(
                """
                INSERT INTO txns (txntype, datetime, cost, mileage, note, carid)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    txntype,
                    int(when.timestamp()),
                    cost + (car_index * 7.5),
                    base_mileage + miles_after,
                    note,
                    car_id,
                ),
            )
            txn_count += 1

    return car_count, txn_count


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Seed cars_sqlite.db with demo data for Dash screenshots."
    )
    parser.add_argument(
        "db_path",
        nargs="?",
        default="cars_sqlite.db",
        help="Path to cars_sqlite.db. Defaults to ./cars_sqlite.db.",
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Delete existing cars and transactions before inserting demo data.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    db_path = Path(args.db_path).expanduser().resolve()
    db_path.parent.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(db_path) as conn:
        create_schema(conn)
        if args.reset:
            reset_data(conn)
        car_count, txn_count = seed(conn)
        conn.commit()

    print(f"Seeded {db_path}")
    print(f"Inserted {car_count} cars and {txn_count} transactions")


if __name__ == "__main__":
    main()
