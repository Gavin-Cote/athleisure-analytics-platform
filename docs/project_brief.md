# Athleisure Brand Analytics Platform

## Project Summary

The Athleisure Brand Analytics Platform is an internal analytics project for a mock premium athleisure company. The platform is designed to help ecommerce, sales planning, merchandising, and inventory teams understand product performance, inventory health, and business opportunities across multiple sales channels.

This project focuses on business intelligence, data analysis, and analytics product thinking rather than building a customer-facing storefront.

## Mock Brand

**Brand Name:** Summit Active

**Brand Description:**  
Summit Active is a mock premium athleisure brand that sells performance-focused lifestyle apparel across ecommerce, retail stores, and wholesale channels. The brand offers products such as joggers, hoodies, training shorts, performance tees, polos, leggings, and outerwear.

## Business Problem

Athleisure brands need clear visibility into which products are performing well, which items are at risk of stocking out, and which products are sitting in inventory too long. Without a centralized analytics tool, sales planning and inventory teams may struggle to make timely decisions about restocking, markdowns, promotions, and product strategy.

This project solves that problem by creating a data-driven analytics platform that turns sales, inventory, returns, and marketing data into actionable business insights.

## Target Users

- Ecommerce Analyst
- Sales Planning Analyst
- Inventory Planner
- Merchandising Manager
- Retail Operations Manager
- Product Manager for Analytics

## Core Business Questions

1. Which products are generating the most revenue?
2. Which product categories have the highest gross margin?
3. Which products are selling quickly and may need to be restocked?
4. Which products are slow-moving and may need markdowns?
5. Which products or categories have high return rates?
6. Which sales channels are performing best?
7. Which regions generate the most revenue?
8. Which products should be promoted, discounted, or discontinued?

## Project Goals

The goal of this project is to build an internal analytics system that can:

- Track revenue, units sold, gross profit, and margin.
- Analyze product and category performance.
- Monitor inventory health and stockout risk.
- Identify slow-moving products.
- Flag potential markdown candidates.
- Analyze return behavior.
- Compare ecommerce, retail, and wholesale performance.
- Recommend business actions based on data.

## MVP Scope

The first version of the project will include:

1. A PostgreSQL database with realistic mock athleisure sales and inventory data.
2. SQL queries for key business metrics.
3. A Power BI dashboard for executive and operational reporting.
4. A metrics dictionary explaining each KPI.
5. A written case study explaining the business problem, approach, and insights.

## Future Scope

Future versions may include:

- dbt models for cleaner analytics workflows.
- A Python-based demand forecasting model.
- A markdown recommendation model.
- A Streamlit internal analytics app.
- Customer segmentation analysis.
- Marketing campaign performance analysis.
- More advanced inventory optimization.

## Out of Scope

This project will not include:

- A customer-facing ecommerce storefront.
- Payment processing.
- User authentication.
- Real customer data.
- Real company data.
- Order checkout functionality.

The focus is on analytics, business intelligence, and internal decision support.

## Planned Tech Stack

- PostgreSQL for the database.
- SQL for data analysis and KPI calculations.
- Python for mock data generation and advanced analytics.
- Power BI for dashboarding and reporting.
- dbt for future data modeling.
- Streamlit for a future internal analytics tool.
- GitHub for version control and portfolio presentation.

## Main Datasets

The project will use mock data for the following business areas:

### Products

Product-level information such as product name, category, color, size, season, cost, retail price, and launch date.

### Orders

Order-level information such as order date, customer, sales channel, region, and total order amount.

### Order Items

Line-item sales data connecting orders to individual products, including quantity sold, unit price, discount amount, and unit cost.

### Inventory

Inventory snapshots showing beginning inventory, ending inventory, units received, and units sold over time.

### Returns

Return data showing returned products, return reasons, return dates, and refund amounts.

### Marketing Campaigns

Campaign data showing marketing spend, target category, channel, campaign dates, and performance.

## Key Metrics

The platform will track the following KPIs:

- Revenue
- Units Sold
- Gross Profit
- Gross Margin %
- Average Order Value
- Return Rate
- Sell-Through Rate
- Inventory Aging
- Stockout Risk
- Markdown Candidate Flag
- Revenue by Channel
- Revenue by Region
- Revenue by Category
- Top Products
- Slow-Moving Products

## Example Business Insights

The platform should be able to generate insights such as:

- Performance tees are the highest revenue category but have lower gross margin due to frequent discounting.
- Joggers have strong sell-through and low return rates, making them strong restock candidates.
- Certain hoodie colors are sitting in inventory longer than 90 days and may require markdowns.
- Ecommerce generates the most revenue, while retail stores have higher average order value.
- Products with high return rates may indicate sizing, quality, or description issues.

## Success Criteria

This project is successful if it clearly demonstrates the ability to:

- Design a realistic retail analytics data model.
- Use SQL to answer business questions.
- Build dashboards that communicate insights clearly.
- Translate raw data into business recommendations.
- Explain analytics work in a way that both technical and non-technical audiences can understand.
- Connect retail operations, ecommerce performance, and product analytics into one cohesive project.

## Portfolio Positioning

This project is intended to demonstrate skills relevant to roles such as:

- Ecommerce Analyst
- Product Analyst
- Business Intelligence Analyst
- Retail Analytics Intern
- Sales Planning Analyst
- Data Analyst
- Analytics Product Manager

The project combines technical skills, business thinking, retail domain knowledge, and analytics communication.