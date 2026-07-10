from pathlib import Path

import psycopg2


# ============================================================
# Database Connection
# ============================================================

DB_CONFIG = {
    "host": "localhost",
    "port": 5433,
    "dbname": "athleisure_db",
    "user": "athleisure_user",
    "password": "athleisure_password",
}

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "generated"


# ============================================================
# CSV Load Order
# ============================================================

TABLE_LOAD_ORDER = [
    {
        "table": "products",
        "file": "products.csv",
        "columns": [
            "product_id",
            "product_name",
            "category",
            "gender",
            "color",
            "size",
            "season",
            "unit_cost",
            "retail_price",
            "launch_date",
            "product_status",
        ],
    },
    {
        "table": "customers",
        "file": "customers.csv",
        "columns": [
            "customer_id",
            "first_name",
            "last_name",
            "email",
            "region",
            "customer_segment",
            "created_at",
        ],
    },
    {
        "table": "orders",
        "file": "orders.csv",
        "columns": [
            "order_id",
            "customer_id",
            "order_date",
            "channel",
            "region",
            "order_status",
            "total_amount",
        ],
    },
    {
        "table": "order_items",
        "file": "order_items.csv",
        "columns": [
            "order_item_id",
            "order_id",
            "product_id",
            "quantity",
            "unit_price",
            "discount_amount",
            "unit_cost",
        ],
    },
    {
        "table": "inventory_snapshots",
        "file": "inventory_snapshots.csv",
        "columns": [
            "snapshot_id",
            "product_id",
            "snapshot_date",
            "starting_inventory",
            "ending_inventory",
            "units_received",
            "units_sold",
        ],
    },
    {
        "table": "returns",
        "file": "returns.csv",
        "columns": [
            "return_id",
            "order_id",
            "order_item_id",
            "product_id",
            "return_date",
            "quantity_returned",
            "return_reason",
            "refund_amount",
        ],
    },
    {
        "table": "marketing_campaigns",
        "file": "marketing_campaigns.csv",
        "columns": [
            "campaign_id",
            "campaign_name",
            "marketing_channel",
            "start_date",
            "end_date",
            "spend",
            "target_category",
            "campaign_goal",
        ],
    },
]


# ============================================================
# Helper Functions
# ============================================================

def copy_csv_to_table(cursor, table_name, csv_path, columns):
    column_list = ", ".join(columns)

    copy_sql = f"""
        COPY {table_name} ({column_list})
        FROM STDIN
        WITH CSV HEADER
    """

    with open(csv_path, "r", encoding="utf-8") as file:
        cursor.copy_expert(copy_sql, file)


def reset_sequence(cursor, table_name, id_column):
    sql = f"""
        SELECT setval(
            pg_get_serial_sequence('{table_name}', '{id_column}'),
            COALESCE((SELECT MAX({id_column}) FROM {table_name}), 1),
            true
        );
    """
    cursor.execute(sql)


def print_table_count(cursor, table_name):
    cursor.execute(f"SELECT COUNT(*) FROM {table_name};")
    count = cursor.fetchone()[0]
    print(f"{table_name}: {count:,} rows")


# ============================================================
# Main Load Process
# ============================================================

def main():
    print("Connecting to PostgreSQL...")

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        print("Clearing existing data...")

        cursor.execute("""
            TRUNCATE TABLE
                returns,
                inventory_snapshots,
                order_items,
                orders,
                marketing_campaigns,
                customers,
                products
            RESTART IDENTITY CASCADE;
        """)

        print("Loading CSV files...")

        for table_info in TABLE_LOAD_ORDER:
            table_name = table_info["table"]
            csv_file = table_info["file"]
            columns = table_info["columns"]
            csv_path = DATA_DIR / csv_file

            if not csv_path.exists():
                raise FileNotFoundError(f"Missing file: {csv_path}")

            copy_csv_to_table(cursor, table_name, csv_path, columns)
            print(f"Loaded {csv_file} into {table_name}")

        print("Resetting ID sequences...")

        reset_sequence(cursor, "products", "product_id")
        reset_sequence(cursor, "customers", "customer_id")
        reset_sequence(cursor, "orders", "order_id")
        reset_sequence(cursor, "order_items", "order_item_id")
        reset_sequence(cursor, "inventory_snapshots", "snapshot_id")
        reset_sequence(cursor, "returns", "return_id")
        reset_sequence(cursor, "marketing_campaigns", "campaign_id")

        conn.commit()

        print()
        print("Data loaded successfully.")
        print()
        print("Table counts:")

        for table_info in TABLE_LOAD_ORDER:
            print_table_count(cursor, table_info["table"])

    except Exception as error:
        conn.rollback()
        print("Data load failed.")
        print(error)
        raise

    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()