# Metrics Dictionary

This document defines the key business metrics used in the Athleisure Brand Analytics Platform. These metrics are designed to help ecommerce, sales planning, merchandising, and inventory teams evaluate product performance, inventory health, and business opportunities.

---

## 1. Revenue

**Definition:**  
Total sales generated from products before returns are removed.

**Formula:**  
    Revenue = SUM(unit_price * quantity)

**Primary Table:**  
`order_items`

**Why It Matters:**  
Revenue shows which products, categories, channels, and regions are generating the most sales.

---

## 2. Units Sold

**Definition:**  
The total number of product units sold.

**Formula:**  
    Units Sold = SUM(quantity)

**Primary Table:**  
`order_items`

**Why It Matters:**  
Units sold helps identify product demand independent of price.

---

## 3. Gross Profit

**Definition:**  
The profit remaining after subtracting product cost from sales revenue.

**Formula:**  
    Gross Profit = SUM((unit_price - unit_cost) * quantity)

**Primary Table:**  
`order_items`

**Why It Matters:**  
Gross profit shows which products generate the most actual business value, not just sales volume.

---

## 4. Gross Margin %

**Definition:**  
The percentage of revenue that remains after subtracting product cost.

**Formula:**  
    Gross Margin % = Gross Profit / Revenue

**Primary Table:**  
`order_items`

**Why It Matters:**  
Gross margin helps compare profitability across products and categories.

---

## 5. Average Order Value

**Definition:**  
The average amount of revenue generated per order.

**Formula:**  
    Average Order Value = Total Revenue / Number of Orders

**Primary Tables:**  
`orders`, `order_items`

**Why It Matters:**  
Average order value helps evaluate customer purchasing behavior and channel performance.

---

## 6. Discount Amount

**Definition:**  
The total dollar amount discounted from product sales.

**Formula:**  
    Discount Amount = SUM(discount_amount)

**Primary Table:**  
`order_items`

**Why It Matters:**  
Discount tracking helps determine whether revenue is being driven by full-price demand or markdown activity.

---

## 7. Discount Rate

**Definition:**  
The percentage of original sales value reduced through discounts.

**Formula:**  
    Discount Rate = Total Discount Amount / Gross Sales Before Discount

**Primary Table:**  
`order_items`

**Why It Matters:**  
A high discount rate may indicate weak demand, poor pricing, or end-of-season markdowns.

---

## 8. Return Rate

**Definition:**  
The percentage of sold units that were returned.

**Formula:**  
    Return Rate = Returned Units / Units Sold

**Primary Tables:**  
`returns`, `order_items`

**Why It Matters:**  
High return rates may indicate sizing issues, product quality issues, unclear product descriptions, or poor customer fit.

---

## 9. Sell-Through Rate

**Definition:**  
The percentage of available inventory that was sold during a time period.

**Formula:**  
    Sell-Through Rate = Units Sold / (Units Sold + Ending Inventory)

**Primary Tables:**  
`order_items`, `inventory_snapshots`

**Why It Matters:**  
Sell-through rate helps identify products that are moving quickly versus products that are underperforming.

---

## 10. Inventory Aging

**Definition:**  
The number of days a product has been active in inventory since its launch date.

**Formula:**  
    Inventory Aging = Current Date - Launch Date

**Primary Tables:**  
`products`, `inventory_snapshots`

**Why It Matters:**  
Inventory aging helps identify stale products that may require markdowns or promotional support.

---

## 11. Days of Supply

**Definition:**  
The estimated number of days current inventory will last based on recent sales velocity.

**Formula:**  
    Days of Supply = Current Inventory / Average Daily Units Sold

**Primary Tables:**  
`inventory_snapshots`, `order_items`

**Why It Matters:**  
Days of supply helps inventory teams understand whether a product has too much inventory, too little inventory, or a healthy stock position.

---

## 12. Stockout Risk

**Definition:**  
A flag that identifies products at risk of running out of inventory soon.

**Example Logic:**  
    Stockout Risk = TRUE
    if Ending Inventory <= 20
    and Units Sold in Last 30 Days >= 50

**Primary Tables:**  
`inventory_snapshots`, `order_items`

**Why It Matters:**  
Stockout risk helps the business prioritize restocks for products with strong demand and low inventory.

---

## 13. Markdown Candidate Flag

**Definition:**  
A flag that identifies products that may need to be discounted.

**Example Logic:**  
    Markdown Candidate = TRUE
    if Inventory Age >= 90 days
    and Sell-Through Rate < 30%
    and Ending Inventory >= 50

**Primary Tables:**  
`products`, `inventory_snapshots`, `order_items`

**Why It Matters:**  
Markdown candidate logic helps merchandising teams identify slow-moving products before they become excess inventory.

---

## 14. Restock Candidate Flag

**Definition:**  
A flag that identifies products that may need to be reordered or replenished.

**Example Logic:**  
    Restock Candidate = TRUE
    if Sell-Through Rate >= 70%
    and Ending Inventory <= 25
    and Return Rate < 10%

**Primary Tables:**  
`inventory_snapshots`, `order_items`, `returns`

**Why It Matters:**  
Restock candidate logic helps the business prioritize products with strong demand and healthy customer response.

---

## 15. Revenue by Channel

**Definition:**  
Revenue grouped by sales channel.

**Formula:**  
    Revenue by Channel = SUM(unit_price * quantity) GROUP BY channel

**Primary Tables:**  
`orders`, `order_items`

**Channels:**  
- Ecommerce
- Retail
- Wholesale

**Why It Matters:**  
Channel performance helps the company understand where sales are strongest.

---

## 16. Revenue by Region

**Definition:**  
Revenue grouped by geographic region.

**Formula:**  
    Revenue by Region = SUM(unit_price * quantity) GROUP BY region

**Primary Tables:**  
`orders`, `order_items`

**Example Regions:**  
- Northeast
- Southeast
- Midwest
- Southwest
- West

**Why It Matters:**  
Regional performance helps identify strong and weak markets.

---

## 17. Revenue by Category

**Definition:**  
Revenue grouped by product category.

**Formula:**  
    Revenue by Category = SUM(unit_price * quantity) GROUP BY category

**Primary Tables:**  
`products`, `order_items`

**Why It Matters:**  
Category performance helps merchandising and sales teams understand which product groups drive the business.

---

## 18. Top Products

**Definition:**  
Products ranked by revenue, units sold, or gross profit.

**Formula:**  
    Top Products = Products ordered by Revenue, Units Sold, or Gross Profit descending

**Primary Tables:**  
`products`, `order_items`

**Why It Matters:**  
Top product analysis identifies the strongest performing items in the assortment.

---

## 19. Slow-Moving Products

**Definition:**  
Products with low sales volume and high inventory levels.

**Example Logic:**  
    Slow-Moving Product = TRUE
    if Units Sold in Last 60 Days <= 10
    and Ending Inventory >= 50

**Primary Tables:**  
`products`, `order_items`, `inventory_snapshots`

**Why It Matters:**  
Slow-moving product analysis helps identify inventory that may require markdowns, promotions, or discontinuation.

---

## 20. Return Reason Breakdown

**Definition:**  
The count and percentage of returns by reason.

**Formula:**  
    Return Reason % = Returns for Reason / Total Returns

**Primary Table:**  
`returns`

**Example Return Reasons:**  
- Too small
- Too large
- Color not as expected
- Quality issue
- Changed mind
- Late delivery

**Why It Matters:**  
Return reason analysis helps identify product, sizing, quality, or customer experience issues.

---

# Metric Priority for MVP

The first version of the project should prioritize these metrics:

1. Revenue
2. Units Sold
3. Gross Profit
4. Gross Margin %
5. Average Order Value
6. Return Rate
7. Sell-Through Rate
8. Inventory Aging
9. Stockout Risk
10. Markdown Candidate Flag
11. Restock Candidate Flag

These metrics are enough to build a strong first dashboard and demonstrate business value.