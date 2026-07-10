# Power BI Dashboard Plan

## Dashboard Name

Summit Active Analytics Dashboard

## Dashboard Purpose

This Power BI dashboard is designed for ecommerce, sales planning, merchandising, and inventory teams at a mock premium athleisure brand. The dashboard helps users understand revenue performance, product trends, inventory health, and recommended business actions.

---

# Page 1: Executive Overview

## Purpose

Give leadership a high-level view of overall business performance.

## Data Views Used

- v_executive_kpi_summary
- v_monthly_revenue
- v_category_performance
- v_channel_performance
- v_region_performance

## KPI Cards

- Total Revenue
- Total Units Sold
- Total Gross Profit
- Gross Margin %
- Total Orders
- Total Customers
- Average Order Value

## Visuals

### 1. Monthly Revenue Trend

**Visual Type:** Line chart  
**X-Axis:** sales_month  
**Y-Axis:** revenue  
**Data View:** v_monthly_revenue

### 2. Revenue by Category

**Visual Type:** Bar chart  
**Axis:** category  
**Values:** revenue  
**Data View:** v_category_performance

### 3. Revenue by Channel

**Visual Type:** Donut chart or bar chart  
**Legend/Axis:** channel  
**Values:** revenue  
**Data View:** v_channel_performance

### 4. Revenue by Region

**Visual Type:** Bar chart  
**Axis:** region  
**Values:** revenue  
**Data View:** v_region_performance

## Business Questions Answered

- How much revenue did the business generate?
- Which categories drive the most sales?
- Which channels are strongest?
- Which regions are performing best?
- Is revenue trending upward or downward?

---

# Page 2: Product Performance

## Purpose

Help merchandising and sales teams understand which products are strongest and weakest.

## Data Views Used

- v_product_performance
- v_category_performance
- v_return_reason_breakdown

## KPI Cards

- Total Products
- Total Revenue
- Gross Margin %
- Average Return Rate
- Total Units Sold

## Visuals

### 1. Top Products by Revenue

**Visual Type:** Table  
**Columns:** product_name, category, gender, color, size, revenue, units_sold, gross_margin_percent  
**Data View:** v_product_performance

### 2. Gross Margin by Category

**Visual Type:** Bar chart  
**Axis:** category  
**Values:** gross_margin_percent  
**Data View:** v_category_performance

### 3. Units Sold by Category

**Visual Type:** Bar chart  
**Axis:** category  
**Values:** units_sold  
**Data View:** v_category_performance

### 4. Return Rate by Product

**Visual Type:** Table  
**Columns:** product_name, category, revenue, units_sold, units_returned, return_rate_percent  
**Data View:** v_product_performance

### 5. Return Reason Breakdown

**Visual Type:** Bar chart  
**Axis:** return_reason  
**Values:** return_count  
**Data View:** v_return_reason_breakdown

## Business Questions Answered

- Which products are best sellers?
- Which products produce the most gross profit?
- Which categories have the highest margins?
- Which products have high return rates?
- What are the most common return reasons?

---

# Page 3: Inventory Health and Recommendations

## Purpose

Help inventory and merchandising teams identify restock, markdown, promotion, and product review opportunities.

## Data Views Used

- v_inventory_health
- v_product_recommendations

## KPI Cards

- Products at High Stockout Risk
- Markdown Candidates
- Restock Candidates
- Slow-Moving Products
- Fast-Moving Products

## Visuals

### 1. Inventory Status Breakdown

**Visual Type:** Donut chart  
**Legend:** inventory_status  
**Values:** count of product_id  
**Data View:** v_inventory_health

### 2. Stockout Risk Table

**Visual Type:** Table  
**Columns:** product_name, category, gender, color, size, ending_inventory, units_sold_last_30_days, stockout_risk_level  
**Data View:** v_inventory_health

### 3. Product Recommendations Table

**Visual Type:** Table  
**Columns:** product_name, category, gender, color, size, ending_inventory, sell_through_rate_percent, return_rate_percent, recommended_action, recommendation_reason  
**Data View:** v_product_recommendations

### 4. Sell-Through Rate by Category

**Visual Type:** Bar chart  
**Axis:** category  
**Values:** average sell_through_rate_percent  
**Data View:** v_inventory_health

### 5. Inventory Aging vs Sell-Through

**Visual Type:** Scatter plot  
**X-Axis:** inventory_age_days  
**Y-Axis:** sell_through_rate_percent  
**Legend:** category  
**Size:** ending_inventory  
**Data View:** v_inventory_health

## Business Questions Answered

- Which products are at risk of stocking out?
- Which products should be restocked?
- Which products should be marked down?
- Which products should be promoted?
- Which products may have quality, sizing, or customer expectation issues?

---

# Recommended Dashboard Style

## Visual Design

Use a clean retail analytics style:

- White or light background
- Dark text
- Muted earth-tone accent colors
- Minimal clutter
- Consistent card layout
- Clear visual titles

## Suggested Color Direction

- Charcoal
- Sand
- Sage
- Off-white
- Slate blue

## Layout Principle

Each page should answer one main question:

- Page 1: How is the business performing overall?
- Page 2: Which products and categories are performing best?
- Page 3: What actions should the business take next?

---

# Portfolio Screenshots to Capture

Once the dashboard is complete, save screenshots of:

1. Executive Overview
2. Product Performance
3. Inventory Health and Recommendations
4. Product Recommendations Table
5. Monthly Revenue Trend
6. Category Performance Chart

Save screenshots in:

powerbi/screenshots/

---

# Portfolio Explanation

This dashboard demonstrates the ability to:

- Model ecommerce and retail data.
- Build SQL-based analytics views.
- Create executive and operational dashboards.
- Translate raw data into business recommendations.
- Communicate insights to both technical and non-technical users.