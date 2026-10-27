"""Generate deterministic sample data for the lakehouse.

Writes data/raw_orders.csv, data/raw_customers.csv, data/raw_products.csv.
Run anytime to regenerate: python scripts/generate_sample_data.py
"""

import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
DATA.mkdir(exist_ok=True)

COUNTRIES = ["USA", "Canada", "UK", "Germany", "India"]
CATEGORIES = ["apparel", "footwear", "accessories", "home"]
FIRST = ["Asha", "Liam", "Maya", "Noah", "Priya", "Omar", "Sara", "Ken", "Lena", "Raj"]
LAST = ["Kumar", "Smith", "Patel", "Garcia", "Kim", "Ali", "Brown", "Singh", "Lee", "Davis"]

products = []
for i in range(1, 51):
    products.append(
        {
            "product_id": f"SKU-{i:04d}",
            "product_name": f"Product {i}",
            "category": random.choice(CATEGORIES),
            "unit_cost": round(random.uniform(9.99, 299.99), 2),
        }
    )

customers = []
for i in range(1, 201):
    first, last = random.choice(FIRST), random.choice(LAST)
    signup = date(2024, 1, 1) + timedelta(days=random.randint(0, 600))
    customers.append(
        {
            "customer_id": f"CUST-{i:05d}",
            "first_name": first,
            "last_name": last,
            "email": f"{first.lower()}.{last.lower()}{i}@example.com",
            "country": random.choice(COUNTRIES),
            "signup_date": signup.isoformat(),
            "updated_at": (signup + timedelta(days=random.randint(0, 90))).isoformat(),
        }
    )

orders = []
start = date(2025, 1, 1)
for i in range(1, 1001):
    product = random.choice(products)
    orders.append(
        {
            "order_id": f"ORD-{i:06d}",
            "customer_id": random.choice(customers)["customer_id"],
            "product_id": product["product_id"],
            "order_date": (start + timedelta(days=random.randint(0, 300))).isoformat(),
            "quantity": random.randint(1, 5),
            "unit_price": product["unit_cost"],
            "status": random.choices(
                ["completed", "cancelled", "refunded"], weights=[85, 10, 5]
            )[0],
        }
    )


def write(name, rows):
    with open(DATA / name, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows)} rows to data/{name}")


write("raw_products.csv", products)
write("raw_customers.csv", customers)
write("raw_orders.csv", orders)
