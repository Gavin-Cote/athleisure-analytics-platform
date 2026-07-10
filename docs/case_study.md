# Summit Active Analytics Platform Case Study

## 1. Project Summary

The Summit Active Analytics Platform is an internal retail and ecommerce analytics project for a mock premium athleisure brand. The goal of the project is to help ecommerce, merchandising, sales planning, and inventory teams understand product performance, inventory health, and recommended product actions.

Rather than building a customer-facing storefront, this project focuses on the internal analytics capabilities that a retail or apparel business would use to make better decisions. The dashboard connects sales, product, inventory, return, and recommendation data into a three-page Power BI report.

The final dashboard includes:

* Executive Overview
* Product Performance
* Inventory Health & Recommendations

## 2. Business Context

Summit Active is a mock premium athleisure company selling products across ecommerce, retail, and wholesale channels. The brand sells products such as joggers, hoodies, performance tees, shorts, leggings, half-zips, outerwear, polos, tanks, and accessories.

For a brand like this, product and inventory decisions are critical. Teams need to understand which products are driving revenue, which products are profitable, which items are moving slowly, which products may stock out, and which products may need markdowns or promotional support.

The central business problem is:

Retail and ecommerce teams need a clearer way to connect product performance, inventory position, and customer return behavior into actionable recommendations.

## 3. Target Users

This project was designed for several internal business users:

* Ecommerce Analyst
* Sales Planning Analyst
* Merchandising Manager
* Inventory Planner
* Retail Operations Manager
* Product Manager for Analytics

Each user group would interact with the dashboard slightly differently. Executives may focus on revenue, gross profit, and channel performance. Merchandising teams may focus on category performance, return reasons, and product-level trends. Inventory teams may focus on slow-moving products, stockout risk, restock candidates, and markdown opportunities.

## 4. Tools and Technologies

The project uses the following tools:

* PostgreSQL for relational data storage
* SQL for schema design, analytics views, and recommendation logic
* Python for mock data generation and data loading
* Pandas, NumPy, and Faker for synthetic retail data
* Docker for local PostgreSQL setup
* Power BI for dashboarding and business intelligence
* Git and GitHub for version control and portfolio presentation

This stack was chosen because it reflects a realistic analytics workflow. PostgreSQL and SQL handle structured business data, Python generates and loads mock datasets, and Power BI presents the final insights in a business-facing format.

## 5. Data Model

The project models a simplified retail analytics environment using seven main datasets.

### Products

The products table contains product-level attributes such as product name, category, gender, color, size, season, unit cost, retail price, launch date, and product status.

### Customers

The customers table contains mock customer records with region, customer segment, email, and account creation date.

### Orders

The orders table contains order-level information such as order date, customer, sales channel, region, order status, and total amount.

### Order Items

The order items table connects orders to individual products. It includes quantity, unit price, discount amount, unit cost, net sales, and gross profit.

### Inventory Snapshots

The inventory snapshots table tracks monthly inventory levels by product, including starting inventory, ending inventory, units received, and units sold.

### Returns

The returns table tracks returned products, return dates, return reasons, quantity returned, and refund amount.

### Marketing Campaigns

The marketing campaigns table includes mock campaign data such as campaign name, marketing channel, target category, campaign spend, start date, end date, and campaign goal.

## 6. Dashboard Design

The Power BI report is divided into three pages.

## Page 1: Executive Overview

The Executive Overview page gives leadership a high-level view of business performance.

### Key metrics

* Total revenue
* Gross profit
* Gross margin %
* Units sold
* Total orders
* Average order value
* Total customers

### Key visuals

* Monthly Revenue Trend
* Gross Profit by Category
* Revenue by Region
* Revenue by Channel

### Purpose

This page answers the question:

How is the business performing overall?

It is designed for quick executive review. The page shows overall sales performance, profitability, channel mix, category contribution, and regional revenue distribution.

![Executive Overview](../powerbi/screenshots/executive_overview.png)

## Page 2: Product Performance

The Product Performance page gives a more detailed view of product and category performance.

### Key metrics

* Revenue
* Gross profit
* Units sold
* Product count
* Return rate
* Gross margin %

### Key visuals

* Top Products by Revenue
* Return Reason Breakdown
* Revenue by Category
* Gross Margin % by Category

### Purpose

This page answers the question:

Which products and categories are performing best, and where are potential return or margin issues showing up?

The table allows users to compare product-level revenue, units sold, gross margin, and return rate. The category charts help show whether revenue and profitability are aligned. The return reason breakdown helps identify potential product experience issues, such as sizing, quality, or customer expectation mismatches.

![Product Performance](../powerbi/screenshots/product_performance.png)

## Page 3: Inventory Health & Recommendations

The Inventory Health page provides the strongest decision-support functionality in the project. It turns product, sales, return, and inventory data into recommended business actions.

### Key metrics

* Restock candidates
* Markdown candidates
* Promotion candidates
* Product review candidates
* High stockout risk products
* Slow-moving products
* Average sell-through rate

### Key visuals

* Inventory Status Breakdown
* Stockout Risk Breakdown
* Recommended Action Breakdown
* Product Recommendations table
* Recommendation slicer
* Category slicer

### Purpose

This page answers the question:

What action should the business take next for each product?

The dashboard assigns products to recommendation categories such as Restock, Markdown, Promote, Review Product Experience, and Monitor. These recommendations help merchandising and inventory teams prioritize actions.

![Inventory Health](../powerbi/screenshots/inventory_health.png)

## 7. Recommendation Logic

The recommendation logic is implemented in SQL views. Products are evaluated based on sales velocity, inventory position, return rate, and stockout risk.

### Recommended actions

#### Restock

A product is flagged for restock when it has strong sales velocity, relatively low inventory, and an acceptable return rate.

Business meaning:

The product is selling well and may need replenishment before it stocks out.

#### Markdown

A product is flagged for markdown when it has low sales velocity and high inventory.

Business meaning:

The product may need discounting, promotion, or inventory reduction before it becomes stale.

#### Promote

A product is flagged for promotion when it has strong sales velocity and enough available inventory to support additional demand.

Business meaning:

The product is performing well and the business has enough inventory to push it further.

#### Review Product Experience

A product is flagged for review when it has an elevated return rate and enough sales volume to make that return behavior meaningful.

Business meaning:

The product may have a sizing, quality, description, or expectation issue.

#### Monitor

A product is assigned Monitor when no immediate action is needed.

Business meaning:

The product does not currently require restock, markdown, promotion, or review.

## 8. Key Metrics Defined

### Revenue

Revenue measures net product sales after discounts.

### Gross Profit

Gross profit measures revenue minus product cost.

### Gross Margin %

Gross margin % measures the percentage of revenue remaining after product cost.

### Average Order Value

Average order value measures revenue divided by number of orders.

### Return Rate

Return rate measures returned units divided by units sold.

### Sell-Through Rate

Sell-through rate measures how much available inventory has sold.

### Stockout Risk

Stockout risk identifies products with high demand and low inventory.

### Markdown Candidate

A markdown candidate is a product with low sales movement and high inventory.

### Restock Candidate

A restock candidate is a product with strong sales movement and relatively low inventory.

## 9. Example Insights

The dashboard is designed to surface insights such as:

* Ecommerce leads revenue contribution across sales channels.
* Joggers and hoodies are among the strongest revenue and gross profit contributors.
* Some categories generate strong revenue but have slightly lower gross margin.
* Return reason analysis can help identify product fit, quality, or expectation issues.
* Some products have enough sales velocity and inventory to support promotion.
* Some products have high inventory and low movement, making them markdown candidates.
* Products with strong sales and low inventory are flagged as restock candidates.
* Products with high return rates are flagged for product experience review.

## 10. Project Impact

This project demonstrates how raw retail data can be transformed into a business-facing analytics product. The final dashboard allows users to move beyond static reporting and toward decision support.

Instead of only answering what happened, the dashboard helps answer:

* What products are performing well?
* What inventory needs attention?
* What should be restocked?
* What should be marked down?
* What should be promoted?
* What products may need review?
* What business action should happen next?

This type of work is relevant to ecommerce analytics, retail analytics, business intelligence, sales planning, merchandising analytics, and product analytics roles.

## 11. Skills Demonstrated

This project demonstrates the following skills:

* SQL schema design
* PostgreSQL database modeling
* SQL analytics views
* Python data generation
* Power BI dashboard development
* KPI design
* Retail and ecommerce analytics
* Inventory analysis
* Product performance analysis
* Recommendation logic
* Data storytelling
* Business problem framing
* Technical documentation
* Translating analytics into business actions

## 12. Challenges and Decisions

### Choosing an internal analytics product instead of a storefront

The original project direction could have been a customer-facing ecommerce store. However, an internal analytics product better aligns with retail analytics, ecommerce analytics, and product analyst roles. This decision made the project more directly relevant to business intelligence and sales planning work.

### Creating realistic mock data

Since the project does not use real company data, the dataset needed to feel realistic enough to support meaningful analysis. Python was used to generate products, customers, orders, inventory snapshots, returns, and marketing campaigns.

### Balancing recommendation logic

The initial recommendation logic flagged too many products as markdown candidates. The logic was revised to create a more realistic distribution across Monitor, Promote, Restock, Markdown, and Review Product Experience. This made the final dashboard more useful and more believable.

### Designing for business users

The dashboard was designed to be readable for non-technical users. It uses KPI cards, bar charts, tables, slicers, and clear recommendation labels rather than overly complex visuals.

## 13. Future Improvements

Future versions of the project could include:

* dbt models for a more production-like analytics workflow
* Data quality tests for key fields and relationships
* Customer segmentation analysis
* Marketing campaign ROI analysis
* Demand forecasting using Python
* Markdown optimization logic
* Streamlit app for internal scenario analysis
* More realistic product seasonality
* More detailed regional and store-level reporting
* Automated refresh workflow
* Portfolio website case study page

## 14. Portfolio Positioning

This project was built to show the intersection of technical analytics, business thinking, and retail domain knowledge.

It is relevant to roles such as:

* Ecommerce Analyst
* Product Analyst
* Business Intelligence Analyst
* Retail Analytics Intern
* Sales Planning Analyst
* Data Analyst
* Merchandising Analytics Intern
* Analytics Product Manager

The project demonstrates the ability to model business data, write SQL analytics logic, build dashboards, and communicate recommendations in a way that business teams can understand.
