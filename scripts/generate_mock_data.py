from pathlib import Path
from datetime import timedelta

import numpy as np
import pandas as pd
from faker import Faker


# ============================================================
# Setup
# ============================================================

fake = Faker()
rng = np.random.default_rng(42)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "generated"
DATA_DIR.mkdir(parents=True, exist_ok=True)

START_DATE = pd.Timestamp("2025-01-01")
END_DATE = pd.Timestamp("2025-12-31")


# ============================================================
# Helper Functions
# ============================================================

def random_date(start: pd.Timestamp, end: pd.Timestamp) -> pd.Timestamp:
    days_between = (end - start).days
    random_days = int(rng.integers(0, days_between + 1))
    return start + pd.Timedelta(days=random_days)


def money(value: float) -> float:
    return round(float(value), 2)


def choose(items):
    return rng.choice(items).item() if hasattr(rng.choice(items), "item") else rng.choice(items)


# ============================================================
# Products
# ============================================================

category_info = {
    "Joggers": {
        "base_names": ["Transit Performance Jogger", "Sunday Lounge Jogger", "Strata Training Jogger"],
        "price_range": (98, 128),
        "gender_options": ["Men", "Women", "Unisex"],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "demand_weight": 1.30,
    },
    "Shorts": {
        "base_names": ["Interval Training Short", "Core Run Short", "Sunday Performance Short"],
        "price_range": (58, 78),
        "gender_options": ["Men", "Women"],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "demand_weight": 1.15,
    },
    "Hoodies": {
        "base_names": ["Cloud Fleece Hoodie", "Daily Restore Hoodie", "Studio Soft Hoodie"],
        "price_range": (98, 138),
        "gender_options": ["Men", "Women", "Unisex"],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "demand_weight": 1.20,
    },
    "Half-Zips": {
        "base_names": ["Elevation Half-Zip", "Canyon Performance Half-Zip", "Summit Knit Half-Zip"],
        "price_range": (108, 148),
        "gender_options": ["Men", "Women"],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "demand_weight": 0.95,
    },
    "Performance Tees": {
        "base_names": ["Strive Performance Tee", "Core Training Tee", "Daily Tech Tee"],
        "price_range": (48, 68),
        "gender_options": ["Men", "Women", "Unisex"],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "demand_weight": 1.40,
    },
    "Tanks": {
        "base_names": ["Studio Rib Tank", "Flow Training Tank", "Daily Essential Tank"],
        "price_range": (42, 58),
        "gender_options": ["Women"],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "demand_weight": 0.90,
    },
    "Leggings": {
        "base_names": ["Studio Sculpt Legging", "Daily Movement Legging", "Elevation Pocket Legging"],
        "price_range": (88, 118),
        "gender_options": ["Women"],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "demand_weight": 1.25,
    },
    "Polos": {
        "base_names": ["Ace Performance Polo", "Clubhouse Tech Polo", "Daily Stretch Polo"],
        "price_range": (68, 88),
        "gender_options": ["Men"],
        "sizes": ["S", "M", "L", "XL"],
        "demand_weight": 0.80,
    },
    "Outerwear": {
        "base_names": ["Summit Shell Jacket", "Canyon Insulated Vest", "Trail Lightweight Jacket"],
        "price_range": (148, 228),
        "gender_options": ["Men", "Women", "Unisex"],
        "sizes": ["S", "M", "L", "XL"],
        "demand_weight": 0.75,
    },
    "Accessories": {
        "base_names": ["Performance Crew Sock", "Training Cap", "Everyday Sling Bag"],
        "price_range": (18, 58),
        "gender_options": ["Unisex"],
        "sizes": ["One Size"],
        "demand_weight": 0.65,
    },
}

colors = [
    "Black",
    "Charcoal",
    "Heather Grey",
    "Navy",
    "Forest",
    "Stone",
    "Oat",
    "Sky",
    "Plum",
    "White",
]

seasons = ["Spring", "Summer", "Fall", "Winter", "Core"]

products = []
product_id = 1

for category, info in category_info.items():
    for base_name in info["base_names"]:
        selected_colors = rng.choice(colors, size=4, replace=False)
        for gender in info["gender_options"]:
            for color in selected_colors:
                selected_sizes = info["sizes"]

                for size in selected_sizes:
                    retail_price = money(rng.integers(info["price_range"][0], info["price_range"][1] + 1))
                    unit_cost = money(retail_price * rng.uniform(0.34, 0.52))
                    launch_date = random_date(pd.Timestamp("2024-01-01"), pd.Timestamp("2025-10-01"))

                    products.append({
                        "product_id": product_id,
                        "product_name": base_name,
                        "category": category,
                        "gender": gender,
                        "color": color,
                        "size": size,
                        "season": choose(seasons),
                        "unit_cost": unit_cost,
                        "retail_price": retail_price,
                        "launch_date": launch_date.date(),
                        "product_status": "active",
                        "demand_weight": info["demand_weight"],
                    })

                    product_id += 1

products_df = pd.DataFrame(products)


# ============================================================
# Customers
# ============================================================

regions = ["Northeast", "Southeast", "Midwest", "Southwest", "West"]
customer_segments = ["New", "Returning", "Loyal", "High Value"]

customers = []

for customer_id in range(1, 1201):
    first_name = fake.first_name()
    last_name = fake.last_name()

    customers.append({
        "customer_id": customer_id,
        "first_name": first_name,
        "last_name": last_name,
        "email": f"{first_name.lower()}.{last_name.lower()}{customer_id}@example.com",
        "region": choose(regions),
        "customer_segment": rng.choice(
            customer_segments,
            p=[0.35, 0.35, 0.20, 0.10]
        ),
        "created_at": random_date(pd.Timestamp("2023-01-01"), END_DATE).date(),
    })

customers_df = pd.DataFrame(customers)


# ============================================================
# Orders and Order Items
# ============================================================

channels = ["Ecommerce", "Retail", "Wholesale"]
channel_probs = [0.62, 0.28, 0.10]

orders = []
order_items = []

order_item_id = 1

product_weights = products_df["demand_weight"].to_numpy()
product_weights = product_weights / product_weights.sum()

for order_id in range(1, 3501):
    customer = customers_df.sample(1, random_state=int(rng.integers(0, 1_000_000))).iloc[0]
    order_date = random_date(START_DATE, END_DATE)
    channel = rng.choice(channels, p=channel_probs)
    region = customer["region"]

    num_items = int(rng.choice([1, 1, 1, 2, 2, 3, 4]))
    order_total = 0

    for _ in range(num_items):
        product = products_df.sample(
            1,
            weights=product_weights,
            random_state=int(rng.integers(0, 1_000_000))
        ).iloc[0]

        quantity = int(rng.choice([1, 1, 1, 1, 2, 2, 3]))

        unit_price = float(product["retail_price"])
        unit_cost = float(product["unit_cost"])

        discount_rate = float(rng.choice(
            [0.00, 0.00, 0.00, 0.05, 0.10, 0.15, 0.20],
            p=[0.50, 0.10, 0.10, 0.10, 0.08, 0.07, 0.05]
        ))

        discount_amount = money(unit_price * quantity * discount_rate)
        line_total = money((unit_price * quantity) - discount_amount)
        order_total += line_total

        order_items.append({
            "order_item_id": order_item_id,
            "order_id": order_id,
            "product_id": int(product["product_id"]),
            "quantity": quantity,
            "unit_price": money(unit_price),
            "discount_amount": discount_amount,
            "unit_cost": money(unit_cost),
        })

        order_item_id += 1

    orders.append({
        "order_id": order_id,
        "customer_id": int(customer["customer_id"]),
        "order_date": order_date.date(),
        "channel": channel,
        "region": region,
        "order_status": "completed",
        "total_amount": money(order_total),
    })

orders_df = pd.DataFrame(orders)
order_items_df = pd.DataFrame(order_items)


# ============================================================
# Inventory Snapshots
# ============================================================

order_items_with_dates = (
    order_items_df
    .merge(orders_df[["order_id", "order_date"]], on="order_id", how="left")
)

order_items_with_dates["order_month"] = pd.to_datetime(order_items_with_dates["order_date"]).dt.to_period("M")

monthly_units_sold = (
    order_items_with_dates
    .groupby(["product_id", "order_month"])["quantity"]
    .sum()
    .reset_index()
)

monthly_units_sold_lookup = {
    (int(row["product_id"]), str(row["order_month"])): int(row["quantity"])
    for _, row in monthly_units_sold.iterrows()
}

months = pd.period_range("2025-01", "2025-12", freq="M")

inventory_snapshots = []
snapshot_id = 1

for _, product in products_df.iterrows():
    product_id_value = int(product["product_id"])
    starting_inventory = int(rng.integers(60, 220))

    for month in months:
        month_key = str(month)
        snapshot_date = month.to_timestamp(how="end").date()

        units_sold = monthly_units_sold_lookup.get((product_id_value, month_key), 0)

        if starting_inventory < 35 or rng.random() < 0.18:
            units_received = int(rng.integers(40, 160))
        else:
            units_received = 0

        ending_inventory = max(starting_inventory + units_received - units_sold, 0)

        inventory_snapshots.append({
            "snapshot_id": snapshot_id,
            "product_id": product_id_value,
            "snapshot_date": snapshot_date,
            "starting_inventory": starting_inventory,
            "ending_inventory": ending_inventory,
            "units_received": units_received,
            "units_sold": units_sold,
        })

        starting_inventory = ending_inventory
        snapshot_id += 1

inventory_df = pd.DataFrame(inventory_snapshots)


# ============================================================
# Returns
# ============================================================

return_reasons = [
    "Too small",
    "Too large",
    "Color not as expected",
    "Quality issue",
    "Changed mind",
    "Late delivery",
]

return_rows = []

return_candidate_items = order_items_df.sample(
    frac=0.08,
    random_state=42
).copy()

return_id = 1

for _, item in return_candidate_items.iterrows():
    order = orders_df.loc[orders_df["order_id"] == item["order_id"]].iloc[0]
    order_date = pd.Timestamp(order["order_date"])

    return_date = order_date + pd.Timedelta(days=int(rng.integers(3, 45)))

    if return_date > END_DATE:
        continue

    quantity_returned = 1
    refund_amount = money((float(item["unit_price"]) * quantity_returned) - min(float(item["discount_amount"]), float(item["unit_price"])))

    return_rows.append({
        "return_id": return_id,
        "order_id": int(item["order_id"]),
        "order_item_id": int(item["order_item_id"]),
        "product_id": int(item["product_id"]),
        "return_date": return_date.date(),
        "quantity_returned": quantity_returned,
        "return_reason": choose(return_reasons),
        "refund_amount": refund_amount,
    })

    return_id += 1

returns_df = pd.DataFrame(return_rows)


# ============================================================
# Marketing Campaigns
# ============================================================

marketing_channels = [
    "Email",
    "Paid Search",
    "Paid Social",
    "Organic Social",
    "Influencer",
    "Affiliate",
]

campaign_goals = [
    "Awareness",
    "Conversion",
    "Retention",
    "Product Launch",
    "Markdown Support",
]

campaigns = []

for campaign_id in range(1, 31):
    target_category = choose(list(category_info.keys()))
    marketing_channel = choose(marketing_channels)
    start_date = random_date(START_DATE, END_DATE - pd.Timedelta(days=30))
    duration = int(rng.integers(10, 45))
    end_date = start_date + pd.Timedelta(days=duration)

    campaigns.append({
        "campaign_id": campaign_id,
        "campaign_name": f"{target_category} {choose(['Launch', 'Refresh', 'Promo', 'Seasonal Push', 'Performance Campaign'])}",
        "marketing_channel": marketing_channel,
        "start_date": start_date.date(),
        "end_date": end_date.date(),
        "spend": money(rng.integers(2500, 45000)),
        "target_category": target_category,
        "campaign_goal": choose(campaign_goals),
    })

campaigns_df = pd.DataFrame(campaigns)


# ============================================================
# Save CSVs
# ============================================================

products_output_df = products_df.drop(columns=["demand_weight"])

products_output_df.to_csv(DATA_DIR / "products.csv", index=False)
customers_df.to_csv(DATA_DIR / "customers.csv", index=False)
orders_df.to_csv(DATA_DIR / "orders.csv", index=False)
order_items_df.to_csv(DATA_DIR / "order_items.csv", index=False)
inventory_df.to_csv(DATA_DIR / "inventory_snapshots.csv", index=False)
returns_df.to_csv(DATA_DIR / "returns.csv", index=False)
campaigns_df.to_csv(DATA_DIR / "marketing_campaigns.csv", index=False)

print("Mock data generated successfully.")
print(f"Output folder: {DATA_DIR}")
print()
print(f"Products: {len(products_output_df):,}")
print(f"Customers: {len(customers_df):,}")
print(f"Orders: {len(orders_df):,}")
print(f"Order Items: {len(order_items_df):,}")
print(f"Inventory Snapshots: {len(inventory_df):,}")
print(f"Returns: {len(returns_df):,}")
print(f"Marketing Campaigns: {len(campaigns_df):,}")