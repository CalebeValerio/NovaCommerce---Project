# STEP 08 — Dimensional Modeling & Power BI Integration

## 1. Objective

The objective of this step was to transform the analytical data prepared in MotherDuck into a dimensional model (Star Schema) and connect it to Power BI.

The goal was to create a structured and reliable data model, separating transactional data from descriptive dimensions and preparing the foundation for future business intelligence analysis.

## 2. Data Architecture

The dimensional model was built using five views in MotherDuck:

| View | Description | Rows |
|---|---|---:|
| `fact_sales` | Sales transactions at order-item level | 35,237 |
| `dim_customer` | Customer information | 8,000 |
| `dim_product` | Product information | 500 |
| `dim_seller` | Seller information | 300 |
| `dim_date` | Calendar dimension | 1,096 |

### Fact Table — fact_sales

The fact table was designed at the order-item grain, meaning each row represents one individual item within an order.

It contains:
- Order identifiers and order date
- Order status and sales channel
- Customer, product, and seller identifiers
- Quantity
- Unit price
- Discount rate and discount amount
- Line total

### Dimension Tables

Four dimension views were created to provide descriptive context for sales analysis:

- `dim_customer`: customer name, city, and country.
- `dim_product`: product name, category, brand, price, cost, and active status.
- `dim_seller`: seller name, city, region, country, rating, and joining date.
- `dim_date`: calendar date, year, quarter, month, month name, day, and day of week.

## 3. Star Schema Design

The model follows a Star Schema architecture.

The central fact table (`fact_sales`) is connected to four dimension tables.

### Relationships

| Dimension | Primary Key | Fact Foreign Key | Cardinality |
|---|---|---|---|
| `dim_customer` | customer_id | customer_id | 1:* |
| `dim_product` | product_id | product_id | 1:* |
| `dim_seller` | seller_id | seller_id | 1:* |
| `dim_date` | date | order_date | 1:* |

All relationships were configured with:
- One-to-many cardinality (1:*)
- Single-direction filtering
- Active relationships

## 4. Data Modeling Decisions

### Fact Table Grain

The fact table uses one row per order item instead of one row per order.

This preserves the individual product and seller information associated with each transaction.

### Separate Fact Tables

Payments and shipping were not joined directly into `fact_sales`.

These datasets have different grains, and joining them directly could multiply rows and produce incorrect aggregations.

They can be modeled as separate fact tables if future analytical requirements demand it.

### Date Dimension

A dedicated date dimension was created covering January 1, 2023, through December 31, 2025.

It contains 1,096 calendar days, including the leap day in 2024.

In Power BI, `dim_date` was marked as the official date table using its `date` column.

## 5. Power BI Integration

The MotherDuck database was connected to Power BI Desktop using the DuckDB Power Query custom connector.

The connection used:
- Database: `md:novacommerce`
- MotherDuck authentication token
- Read-only mode
- SaaS mode
- Import connectivity mode

The five dimensional views were selected and imported into Power BI.

## 6. Power Query Preparation

Before loading the data into the Power BI model, the column data types were reviewed.

Important data type decisions included:

- Identifiers: Text
- Descriptive attributes: Text
- Order and calendar dates: Date
- Prices and costs: Decimal Number
- Quantities: Numeric
- Financial values: Numeric

No changes were made to the original MotherDuck source tables.

## 7. Model Validation

The dimensional model was created successfully in Power BI.

The following elements were configured:

- Five imported views
- Four active relationships
- One-to-many cardinality
- Single-direction filtering
- Official date table configuration

The expected row counts were previously validated in MotherDuck.

A separate Power BI row-count validation was not documented as completed in this step.

## 8. Final Outcome

The NovaCommerce project now has a dimensional data model connected to Power BI.

The analytical foundation is prepared for the next stage: defining business metrics, creating DAX measures, and eventually developing interactive visualizations.

**No dashboards or visualizations were created during this step.**

---
