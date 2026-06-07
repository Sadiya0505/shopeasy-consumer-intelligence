import pyodbc
import random
from faker import Faker
from datetime import date, timedelta

fake = Faker()

# ── Auto-pick best available driver ────────────────────────────────────
drivers = pyodbc.drivers()
if "ODBC Driver 18 for SQL Server" in drivers:
    driver = "ODBC Driver 18 for SQL Server"
elif "ODBC Driver 17 for SQL Server" in drivers:
    driver = "ODBC Driver 17 for SQL Server"
else:
    driver = "SQL Server"

print(f"Using driver: {driver}")

# ── Connect to SQL Server ──────────────────────────────────────────────
conn = pyodbc.connect(
    f"DRIVER={{{driver}}};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=ShopEasy;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)
cursor = conn.cursor()
print("Connected to ShopEasy database!")

# ── Reference data ─────────────────────────────────────────────────────
products = list(range(1, 19))
stages   = ["View", "Click", "Add to Cart", "Checkout", "Purchase"]
start_date = date(2023, 1, 1)

# ── Table 1: customer_journey ──────────────────────────────────────────
print("Generating customer_journey...")
rows = []
for journey_id in range(1, 4012):
    customer_id = random.randint(1, 1000)
    product_id  = random.choice(products)
    visit_date  = start_date + timedelta(days=random.randint(0, 729))

    drop_probs  = [0.0, 0.49, 0.55, 0.96, 0.0]
    final_stage = "View"
    action      = "Proceeded"
    duration    = round(random.uniform(10, 300), 2)

    for i, stage in enumerate(stages):
        final_stage = stage
        if i == len(stages) - 1:
            action   = "Proceeded"
            duration = round(random.uniform(10, 300), 2)
            break
        if random.random() < drop_probs[i]:
            action   = "Drop-off"
            duration = None
            break
        action   = "Proceeded"
        duration = round(random.uniform(10, 300), 2)

    rows.append((journey_id, customer_id, product_id,
                 visit_date, final_stage, action, duration))

# Insert with fast executemany
cursor.fast_executemany = True
cursor.executemany(
    "INSERT INTO customer_journey VALUES (?,?,?,?,?,?,?)", rows
)
conn.commit()
print(f"  customer_journey: {len(rows)} rows inserted")

# ── Table 2: customer_reviews ──────────────────────────────────────────
print("Generating customer_reviews...")

positive_texts = [
    "Absolutely love this product, exceeded my expectations!",
    "Great quality and fast delivery, highly recommend.",
    "Perfect for my needs, very happy with this purchase.",
    "Excellent product, works exactly as described.",
    "Amazing value for money, will buy again.",
    "Top quality item, very satisfied with my order.",
    "Fantastic product, my whole family loves it.",
]
negative_texts = [
    "Did not meet my expectations at all, very disappointed.",
    "Product quality is average at best, not worth the price.",
    "Delivery was slow and product did not match the description.",
    "Poor performance, would not recommend this to anyone.",
    "The product broke after just one week of use.",
    "Not satisfied, expected much better quality.",
    "Overpriced for what you get, very average performance.",
    "The quality does not meet expectations I had.",
    "Average product, nothing special about it.",
    "Disappointed with the performance of this item.",
]
mixed_texts = [
    "Good product overall but the price is a bit high.",
    "Decent quality but delivery took longer than expected.",
    "Works fine but instructions were confusing.",
    "Product is okay, nothing special but does the job.",
    "Quality is acceptable but expected better for this price.",
]

rows = []
for review_id in range(1, 1364):
    customer_id = random.randint(1, 1000)
    product_id  = random.choice(products)
    review_date = start_date + timedelta(days=random.randint(0, 729))
    rating      = random.choices([1,2,3,4,5], weights=[8,10,12,35,35])[0]

    if rating >= 4:
        text = random.choice(positive_texts)
    elif rating <= 2:
        text = random.choice(negative_texts)
    else:
        text = random.choice(mixed_texts)

    rows.append((review_id, customer_id, product_id, review_date, rating, text))

cursor.executemany(
    "INSERT INTO customer_reviews VALUES (?,?,?,?,?,?)", rows
)
conn.commit()
print(f"  customer_reviews: {len(rows)} rows inserted")

# ── Table 3: engagement_data ───────────────────────────────────────────
print("Generating engagement_data...")

content_types = ["Video", "Blog", "Social Media", "Newsletter"]
rows = []
for eng_id in range(1, 4624):
    content_id   = random.randint(1, 100)
    content_type = random.choice(content_types)
    eng_date     = start_date + timedelta(days=random.randint(0, 729))
    views        = random.randint(500, 5000)
    clicks       = random.randint(50, int(views * 0.25))
    combined     = f"{views}-{clicks}"
    likes        = random.randint(10, int(clicks * 0.8))

    rows.append((eng_id, content_id, content_type, combined, likes, eng_date))

cursor.executemany(
    "INSERT INTO engagement_data VALUES (?,?,?,?,?,?)", rows
)
conn.commit()
print(f"  engagement_data: {len(rows)} rows inserted")

# ── Done ───────────────────────────────────────────────────────────────
cursor.close()
conn.close()
print("\nAll data generated successfully! ShopEasy database is ready.")