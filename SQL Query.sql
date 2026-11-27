
/*
===============================================================================
PROJECT: NOVACOMMERCE
FILE: SQL Query.sql
PURPOSE: End-to-End SQL Analytics Workflow
DATABASE: MotherDuck / DuckDB
SCHEMA: main
ANALYSIS PERIOD: 2023 - 2025
===============================================================================

PROJECT DESCRIPTION
-------------------
This script documents the SQL workflow developed for the NovaCommerce
e-commerce analytics project.

It covers:

01. Data Quality Assessment
02. Data Transformation & Analytical Preparation
03. Exploratory Data Analysis (EDA)
04. Dimensional Modeling (Star Schema)
05. Final Model Validation

The queries are organized according to the analytical workflow.

IMPORTANT NOTES
---------------
- Execute this script in the novacommerce database, main schema.
- Source tables are not modified by this script.
- CREATE OR REPLACE VIEW statements create or replace analytical views.
- Payment anomalies are investigated, not automatically classified as errors.
- Net Revenue represents the sum of order-item line totals across all
  order statuses. It must not be interpreted as realized accounting revenue.

===============================================================================
*/


/*
===============================================================================
01. DATA QUALITY ASSESSMENT
===============================================================================

OBJECTIVE:
Evaluate the reliability and structural integrity of the source data
before using it for analytical purposes.

The assessment focuses on:
- Operational consistency
- Primary-key uniqueness
- Referential integrity
- Business-rule validation
- Potential financial anomalies

Why this matters:
Incorrect, duplicated, or inconsistent data can produce misleading KPIs
and unreliable business conclusions.
*/


/*-----------------------------------------------------------------------------
01.1 — SHIPPING STATUS CONSISTENCY
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Do shipping and delivery dates align with the recorded order statuses?

WHY:
Shipping dates should be interpreted in the context of order status.
For example, cancelled or processing orders may not have shipping dates.

This query compares order statuses with the presence of shipping and
delivery dates.
*/

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN s.shipping_date IS NOT NULL THEN o.order_id
    END) AS shipped_orders,
    COUNT(DISTINCT CASE
        WHEN s.delivered_date IS NOT NULL THEN o.order_id
    END) AS delivered_orders
FROM orders o
LEFT JOIN shipping s
    ON o.order_id = s.order_id
GROUP BY o.order_status
ORDER BY o.order_status;


/*-----------------------------------------------------------------------------
01.2 — PRIMARY KEY DUPLICATE VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Check whether primary-key values are duplicated across the source tables.

WHY:
Primary keys should uniquely identify records.
Duplicates can create incorrect joins, inflated counts, and inconsistent
analytical results.

EXPECTED RESULT:
No rows returned by the query means no duplicated keys were found.
*/

SELECT
    'orders' AS table_name,
    CAST(order_id AS VARCHAR) AS primary_key,
    COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'customers',
    CAST(customer_id AS VARCHAR),
    COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'products',
    CAST(product_id AS VARCHAR),
    COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'sellers',
    CAST(seller_id AS VARCHAR),
    COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'order_items',
    CAST(order_item_id AS VARCHAR),
    COUNT(*)
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'payments',
    CAST(payment_id AS VARCHAR),
    COUNT(*)
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'reviews',
    CAST(review_id AS VARCHAR),
    COUNT(*)
FROM reviews
GROUP BY review_id
HAVING COUNT(*) > 1

UNION ALL

SELECT
    'shipping',
    CAST(shipping_id AS VARCHAR),
    COUNT(*)
FROM shipping
GROUP BY shipping_id
HAVING COUNT(*) > 1;


/*-----------------------------------------------------------------------------
01.3 — REFERENTIAL INTEGRITY VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Identify records referencing IDs that do not exist in their corresponding
parent tables.

WHY:
Foreign-key relationships are essential for reliable relational analysis.

A missing customer, product, seller, or order reference can cause records
to disappear from INNER JOIN results or become difficult to interpret.

EXPECTED RESULT:
All relationship checks should return zero orphan records.
*/

SELECT
    'orders -> customers' AS relationship,
    COUNT(*) AS orphan_records
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'order_items -> products',
    COUNT(*)
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'order_items -> sellers',
    COUNT(*)
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL

UNION ALL

SELECT
    'payments -> orders',
    COUNT(*)
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'reviews -> orders',
    COUNT(*)
FROM reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'shipping -> orders',
    COUNT(*)
FROM shipping s
LEFT JOIN orders o
    ON s.order_id = o.order_id
WHERE o.order_id IS NULL;


/*-----------------------------------------------------------------------------
01.4 — SHIPPING GRAIN VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Check whether an order has multiple shipping records.

WHY:
The analytical order-level view will join shipping information using
order_id. Multiple shipping rows per order could multiply the number of
rows in the resulting view.

This check helps verify whether shipping behaves as one record per order.

EXPECTED RESULT:
No rows returned means no orders have multiple shipping records.
*/

SELECT
    order_id,
    COUNT(*) AS shipping_records
FROM shipping
GROUP BY order_id
HAVING COUNT(*) > 1;


/*-----------------------------------------------------------------------------
01.5 — BUSINESS RULE VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Identify values that violate expected business rules.

WHY:
Valid primary and foreign keys do not guarantee that the data itself
contains logically valid values.

The following checks investigate:
- Product prices and costs
- Discount-rate boundaries
- Order-item quantities
- Customer review scores
- Payment amounts

NOTE:
Payment amounts less than or equal to zero are flagged for investigation.
They are not automatically assumed to be incorrect.
*/

SELECT
    'Invalid product prices or costs' AS data_check,
    COUNT(*) AS flagged_records
FROM products
WHERE unit_price <= 0
   OR product_cost <= 0

UNION ALL

SELECT
    'Invalid discount rates',
    COUNT(*)
FROM order_items
WHERE discount_rate < 0
   OR discount_rate > 1

UNION ALL

SELECT
    'Invalid quantities',
    COUNT(*)
FROM order_items
WHERE quantity <= 0

UNION ALL

SELECT
    'Invalid review scores',
    COUNT(*)
FROM reviews
WHERE review_score < 1
   OR review_score > 5
   OR review_score IS NULL

UNION ALL

SELECT
    'Payment amounts requiring investigation',
    COUNT(*)
FROM payments
WHERE payment_amount <= 0
   OR payment_amount IS NULL;


/*-----------------------------------------------------------------------------
01.6 — PAYMENT ANOMALY INVESTIGATION
-------------------------------------------------------------------------------

OBJECTIVE:
Inspect payment records containing zero, negative, or missing amounts.

WHY:
Financial records require additional investigation before being classified
as data errors.

Negative payment amounts may represent adjustments, reversals, or refunds.
The available data did not establish a definitive explanation for every
negative record.

Therefore, this project preserves the source records and reports the
anomalies rather than modifying them.
*/

SELECT
    payment_id,
    order_id,
    payment_amount,
    payment_status,
    payment_method
FROM payments
WHERE payment_amount <= 0
   OR payment_amount IS NULL
ORDER BY payment_amount;


/*
Investigate the relationship between unusual payment amounts and their
corresponding order status.
*/

SELECT
    p.payment_id,
    p.order_id,
    p.payment_amount,
    p.payment_status,
    o.order_status,
    o.order_date
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE p.payment_amount <= 0
   OR p.payment_amount IS NULL
ORDER BY p.payment_amount;


/*
Summarize negative and zero payment records by payment status.

This helps determine whether unusual amounts are concentrated in specific
transaction statuses.
*/

SELECT
    payment_status,
    COUNT(*) AS total_records,
    SUM(CASE
        WHEN payment_amount < 0 THEN 1
        ELSE 0
    END) AS negative_payments,
    SUM(CASE
        WHEN payment_amount = 0 THEN 1
        ELSE 0
    END) AS zero_payments
FROM payments
GROUP BY payment_status
ORDER BY payment_status;


/*
Review the overall statistical distribution of payment amounts.
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(payment_amount) AS non_null_amounts,
    COUNT(*) - COUNT(payment_amount) AS null_amounts,
    MIN(payment_amount) AS minimum_amount,
    MAX(payment_amount) AS maximum_amount,
    AVG(payment_amount) AS average_amount
FROM payments;


/*-----------------------------------------------------------------------------
01.7 — ORDER ITEM FINANCIAL VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Validate the mathematical consistency of item-level financial values.

WHY:
The expected net line value is calculated as:

Net Line Total = (Unit Price x Quantity) - Discount Amount

A tolerance of 0.01 is used to account for minor decimal precision
differences.
*/

SELECT
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN ABS(
                line_total - (
                    unit_price * quantity - discount_amount
                )
            ) > 0.01
            THEN 1
            ELSE 0
        END
    ) AS inconsistent_line_totals
FROM order_items;


/*-----------------------------------------------------------------------------
01.8 — ORDERS WITHOUT ORDER ITEMS
-------------------------------------------------------------------------------

OBJECTIVE:
Determine whether every order has at least one associated order item.

WHY:
The sales analysis depends on order_items to calculate quantities,
discounts, gross values, and net order values.

Orders without item records would require separate treatment.
*/

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT oi.order_id) AS orders_with_items,
    COUNT(DISTINCT o.order_id)
        - COUNT(DISTINCT oi.order_id) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id;


/*
===============================================================================
02. DATA TRANSFORMATION & ANALYTICAL PREPARATION
===============================================================================

OBJECTIVE:
Prepare the source data for reliable business analysis.

The transformation stage aggregates transactional data at the correct
analytical grain before combining information from different tables.

WHY:
Orders, order items, and payments have different levels of granularity.

Joining raw order_items and payments directly can create row multiplication
when an order contains multiple items and multiple payment records.

To prevent this, each transactional table is aggregated by order_id
before being joined into the analytical view.
*/


/*-----------------------------------------------------------------------------
02.1 — ORDER-LEVEL SALES AGGREGATION
-------------------------------------------------------------------------------

OBJECTIVE:
Calculate the main sales metrics for each order.

WHY:
The original order_items table contains one row per order item.
Aggregating it by order_id creates an order-level dataset suitable for
order-level analysis.

LIMIT:
LIMIT 10 is used to keep the preview manageable.
*/

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.sales_channel,
    o.currency,

    COUNT(oi.order_item_id) AS total_order_items,
    SUM(oi.quantity) AS total_units,
    SUM(oi.unit_price * oi.quantity) AS gross_revenue,
    SUM(oi.discount_amount) AS total_discount,
    SUM(oi.line_total) AS net_revenue

FROM orders o

LEFT JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.sales_channel,
    o.currency

ORDER BY o.order_date
LIMIT 10;


/*-----------------------------------------------------------------------------
02.2 — ORDER-LEVEL GRAIN VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Verify that the aggregated order-level dataset contains one record
per order.

WHY:
This check helps confirm that the aggregation has not introduced
duplicate order records.
*/

WITH order_level AS (
    SELECT
        o.order_id,
        SUM(oi.line_total) AS net_revenue
    FROM orders o
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id
)

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM order_level;


/*-----------------------------------------------------------------------------
02.3 — CREATE THE ANALYTICAL ORDERS VIEW
-------------------------------------------------------------------------------

OBJECTIVE:
Create a reusable order-level analytical view.

WHY:
Instead of repeating the same aggregations across multiple analytical
queries, this view centralizes the required order-level information.

IMPORTANT TRANSFORMATION DECISION:

1. The items CTE aggregates order_items by order_id.
2. The payment CTE aggregates payments by order_id.
3. These aggregated results are joined to orders.
4. Customer and shipping information are added afterward.

This structure prevents the direct combination of raw payment and
order-item records from multiplying transactional rows.

The shipping relationship should also be checked for multiple records
per order before using this one-row-per-order structure.

The source tables remain unchanged.
*/

CREATE OR REPLACE VIEW analytics_orders AS

WITH items AS (
    SELECT
        order_id,
        COUNT(*) AS total_order_items,
        SUM(quantity) AS total_units,
        SUM(unit_price * quantity) AS gross_revenue,
        SUM(discount_amount) AS total_discount,
        SUM(line_total) AS net_revenue
    FROM order_items
    GROUP BY order_id
),

payment AS (
    SELECT
        order_id,
        COUNT(*) AS total_payments,
        SUM(payment_amount) AS total_payment_amount
    FROM payments
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.sales_channel,
    o.currency,

    c.customer_name,
    c.customer_city,
    c.customer_country,

    i.total_order_items,
    i.total_units,
    i.gross_revenue,
    i.total_discount,
    i.net_revenue,

    p.total_payments,
    p.total_payment_amount,

    s.shipping_date,
    s.delivered_date

FROM orders o

LEFT JOIN customers c
    ON o.customer_id = c.customer_id

LEFT JOIN items i
    ON o.order_id = i.order_id

LEFT JOIN payment p
    ON o.order_id = p.order_id

LEFT JOIN shipping s
    ON o.order_id = s.order_id;


/*-----------------------------------------------------------------------------
02.4 — ANALYTICAL VIEW PREVIEW
-------------------------------------------------------------------------------

OBJECTIVE:
Inspect the resulting analytical view.

WHY:
A sample preview helps verify that the transformation produced the
expected columns and correctly combined the required information.
*/

SELECT *
FROM analytics_orders
LIMIT 10;


/*-----------------------------------------------------------------------------
02.5 — ANALYTICAL VIEW VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Validate the record count, order uniqueness, and availability of
financial fields in the analytical view.

WHY:
The analytical view should retain the expected order-level grain.

Missing revenue and payment values are checked separately because
a missing value may have a different explanation depending on the
underlying transactional records.
*/

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders,

    SUM(
        CASE
            WHEN net_revenue IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_revenue,

    SUM(
        CASE
            WHEN total_payment_amount IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_payment

FROM analytics_orders;


/*
===============================================================================
03. EXPLORATORY DATA ANALYSIS (EDA)
===============================================================================

OBJECTIVE:
Investigate business performance and identify relevant patterns
before designing the final reporting model.

The following queries explore:
- Overall sales performance
- Order status
- Sales channels
- Geographic contribution
- Revenue trends
- Customer purchasing behavior
- Product and category performance
- Delivery performance
- Payment methods

WHY:
Exploratory analysis helps identify the metrics, dimensions, and business
questions that should be prioritized in the final dashboard.
*/


/*-----------------------------------------------------------------------------
03.1 — OVERALL SALES PERFORMANCE
-------------------------------------------------------------------------------

BUSINESS QUESTION:
What is the overall sales performance of NovaCommerce?

KPIs:
- Total Orders
- Total Units Sold
- Gross Revenue
- Total Discounts
- Net Revenue
- Average Order Value

WHY:
This query establishes the baseline metrics used throughout the project.

IMPORTANT:
All order statuses are included in the calculations.
Net Revenue represents recorded order-item value, not confirmed
realized revenue.
*/

SELECT
    COUNT(*) AS total_orders,
    SUM(total_units) AS total_units_sold,
    ROUND(SUM(gross_revenue), 2) AS gross_revenue,
    ROUND(SUM(total_discount), 2) AS total_discounts,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(AVG(net_revenue), 2) AS average_order_value
FROM analytics_orders;


/*-----------------------------------------------------------------------------
03.2 — PERFORMANCE BY ORDER STATUS
-------------------------------------------------------------------------------

BUSINESS QUESTION:
How are orders and recorded net order value distributed across statuses?

WHY:
This analysis provides operational context to the financial metrics.

It also helps prevent cancelled, processing, and shipped orders from
being interpreted as completed sales.
*/

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_revenue), 2) AS total_net_revenue,
    ROUND(AVG(net_revenue), 2) AS average_order_value
FROM analytics_orders
GROUP BY order_status
ORDER BY total_orders DESC;


/*-----------------------------------------------------------------------------
03.3 — SALES CHANNEL PERFORMANCE
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Which sales channels contribute most to recorded net order value?

WHY:
Comparing sales channels helps identify where recorded order value
and purchasing activity are concentrated.
*/

SELECT
    sales_channel,
    COUNT(*) AS total_orders,
    SUM(total_units) AS total_units_sold,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(AVG(net_revenue), 2) AS average_order_value
FROM analytics_orders
GROUP BY sales_channel
ORDER BY net_revenue DESC;


/*-----------------------------------------------------------------------------
03.4 — GEOGRAPHIC PERFORMANCE
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Which customer countries contribute most to recorded net order value?

WHY:
Geographic analysis helps identify the largest markets and potential
opportunities for market diversification.
*/

SELECT
    customer_country,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_revenue), 2) AS net_revenue,
    ROUND(AVG(net_revenue), 2) AS average_order_value
FROM analytics_orders
GROUP BY customer_country
ORDER BY net_revenue DESC
LIMIT 10;


/*-----------------------------------------------------------------------------
03.5 — MONTHLY REVENUE TREND
-------------------------------------------------------------------------------

BUSINESS QUESTION:
How does recorded net order value change over time?

WHY:
Aggregating by month makes it possible to identify trends,
seasonality, and changes in business performance.

DATE_TRUNC groups individual order dates into calendar months.
*/

SELECT
    DATE_TRUNC('month', order_date) AS sales_month,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_revenue), 2) AS net_revenue
FROM analytics_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY sales_month;


/*-----------------------------------------------------------------------------
03.6 — CUSTOMER PURCHASING FREQUENCY
-------------------------------------------------------------------------------

BUSINESS QUESTION:
How many orders does each purchasing customer place on average?

WHY:
This metric provides an initial understanding of customer activity
and purchasing frequency.
*/

SELECT
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 1.0 /
        COUNT(DISTINCT customer_id),
        2
    ) AS orders_per_customer

FROM analytics_orders;


/*-----------------------------------------------------------------------------
03.7 — CUSTOMER SEGMENT DISTRIBUTION
-------------------------------------------------------------------------------

BUSINESS QUESTION:
How many customers are one-time or repeat purchasers?

WHY:
Segmenting customers according to historical purchasing frequency
helps evaluate the importance of repeat purchasing.

A customer with exactly one order is classified as One-Time Customer.
Customers with more than one order are classified as Returning Customers.

NOTE:
This query includes customers with at least one order because it uses
analytics_orders rather than the complete customers table.
*/

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders
    FROM analytics_orders
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-Time Customer'
        ELSE 'Returning Customer'
    END AS customer_type,

    COUNT(*) AS total_customers

FROM customer_orders
GROUP BY customer_type
ORDER BY total_customers DESC;


/*-----------------------------------------------------------------------------
03.8 — TOP 10 CUSTOMERS BY RECORDED NET ORDER VALUE
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Which customers contribute the highest recorded net order value?

WHY:
This analysis identifies customers with the highest historical
order value and helps investigate customer concentration.
*/

SELECT
    customer_id,
    customer_name,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_revenue), 2) AS total_revenue
FROM analytics_orders
GROUP BY
    customer_id,
    customer_name
ORDER BY total_revenue DESC
LIMIT 10;


/*-----------------------------------------------------------------------------
03.9 — TOP 10 CUSTOMER REVENUE CONTRIBUTION
-------------------------------------------------------------------------------

BUSINESS QUESTION:
What percentage of total recorded net order value comes from
the top 10 customers?

WHY:
This analysis helps understand how concentrated the recorded
order value is among the highest-value customers.

ROW_NUMBER assigns a rank to each customer based on total revenue.
The final query calculates the contribution of the top 10.
*/

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(net_revenue) AS total_revenue
    FROM analytics_orders
    GROUP BY customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        total_revenue,

        ROW_NUMBER() OVER (
            ORDER BY total_revenue DESC
        ) AS customer_rank

    FROM customer_revenue
)

SELECT
    ROUND(SUM(total_revenue), 2) AS top_10_revenue,

    ROUND(
        SUM(total_revenue) * 100.0 /
        (SELECT SUM(net_revenue) FROM analytics_orders),
        2
    ) AS revenue_share_percentage

FROM ranked_customers
WHERE customer_rank <= 10;


/*-----------------------------------------------------------------------------
03.10 — TOP 10 PRODUCTS BY RECORDED NET ORDER VALUE
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Which products generate the highest recorded net order value?

WHY:
Product-level analysis helps identify the products that contribute
most to the overall business.
*/

SELECT
    oi.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    oi.product_id,
    p.product_name

ORDER BY total_revenue DESC
LIMIT 10;


/*-----------------------------------------------------------------------------
03.11 — PRODUCTS BY AVERAGE SELLING PRICE
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Which products have the highest average selling price?

WHY:
This query provides a complementary perspective to total revenue.

A product may have a high average selling price without being
one of the highest-volume products.

The average selling price is calculated as total line value divided
by total units sold.
*/

SELECT
    oi.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(oi.line_total) / SUM(oi.quantity),
        2
    ) AS average_selling_price,

    ROUND(SUM(oi.line_total), 2) AS total_revenue

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    oi.product_id,
    p.product_name

ORDER BY average_selling_price DESC
LIMIT 10;


/*-----------------------------------------------------------------------------
03.12 — PRODUCT CATEGORY PERFORMANCE
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Which product categories contribute most to recorded net order value?

WHY:
Category-level performance helps identify the main contributors
to business value and supports product strategy discussions.
*/

SELECT
    p.product_category,
    COUNT(DISTINCT oi.product_id) AS total_products,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY p.product_category

ORDER BY total_revenue DESC
LIMIT 10;


/*-----------------------------------------------------------------------------
03.13 — DELIVERY TIME ANALYSIS
-------------------------------------------------------------------------------

BUSINESS QUESTION:
How long does delivery take for delivered orders?

WHY:
Delivery performance is relevant to operational efficiency
and customer experience.

Delivery duration is calculated as the difference in days between
shipping_date and delivered_date.

Only delivered orders with both dates available are included.

NOTE:
No delivery SLA target was established in this project.
Therefore, delivery duration is descriptive and is not classified
as on-time or delayed performance.
*/

SELECT
    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            DATE_DIFF('day', shipping_date, delivered_date)
        ),
        2
    ) AS avg_delivery_days,

    MIN(
        DATE_DIFF('day', shipping_date, delivered_date)
    ) AS min_delivery_days,

    MAX(
        DATE_DIFF('day', shipping_date, delivered_date)
    ) AS max_delivery_days

FROM analytics_orders

WHERE order_status = 'Delivered'
  AND shipping_date IS NOT NULL
  AND delivered_date IS NOT NULL;


/*-----------------------------------------------------------------------------
03.14 — PAYMENT METHOD ANALYSIS
-------------------------------------------------------------------------------

BUSINESS QUESTION:
Which payment methods are most frequently used?

WHY:
Understanding transaction distribution helps describe customer
payment preferences.

The transaction percentage is calculated relative to all payment
records, not relative to total order value.
*/

SELECT
    payment_method,
    COUNT(*) AS total_transactions,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS transaction_percentage,

    ROUND(SUM(payment_amount), 2) AS total_payment_amount

FROM payments

GROUP BY payment_method

ORDER BY total_transactions DESC;


/*
===============================================================================
04. DIMENSIONAL MODELING — STAR SCHEMA
===============================================================================

OBJECTIVE:
Create a dimensional model for Power BI reporting.

The model consists of:
- One fact table: fact_sales
- Four dimension tables:
    dim_customer
    dim_product
    dim_seller
    dim_date

WHY:
A Star Schema separates measurable transactional data from descriptive
attributes.

This structure supports clearer relationships, more efficient filtering,
and easier analytical calculations in Power BI.

FACT TABLE GRAIN:
One row per order item.

DIMENSION RELATIONSHIPS:
Each dimension provides descriptive attributes used to analyze
the corresponding sales records.
*/


/*-----------------------------------------------------------------------------
04.1 — CREATE FACT_SALES
-------------------------------------------------------------------------------

OBJECTIVE:
Create the central fact table at order-item grain.

WHY:
Order-item-level granularity preserves product, seller, quantity,
price, discount, and line-total information.

Order-level attributes are added through a LEFT JOIN to orders.

The LEFT JOIN preserves order-item records even if a matching order
record is unexpectedly missing, allowing data quality issues to remain
visible rather than silently removing rows.
*/

CREATE OR REPLACE VIEW fact_sales AS

SELECT
    oi.order_item_id,
    oi.order_id,

    o.order_date,
    o.order_status,
    o.sales_channel,
    o.currency,

    o.customer_id,

    oi.product_id,
    oi.seller_id,

    oi.quantity,
    oi.unit_price,
    oi.discount_rate,
    oi.discount_amount,
    oi.line_total

FROM order_items oi

LEFT JOIN orders o
    ON oi.order_id = o.order_id;


/*-----------------------------------------------------------------------------
04.2 — FACT TABLE VALIDATION
-------------------------------------------------------------------------------

OBJECTIVE:
Validate the row count, unique item count, order count, and duplicate
item count in fact_sales.

WHY:
The fact table should preserve its original order-item grain.

The number of fact rows should match the number of source order items.
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_item_id) AS unique_items,
    COUNT(DISTINCT order_id) AS unique_orders,

    COUNT(*) - COUNT(DISTINCT order_item_id)
        AS duplicate_items

FROM fact_sales;


/*-----------------------------------------------------------------------------
04.3 — CREATE DIM_CUSTOMER
-------------------------------------------------------------------------------

OBJECTIVE:
Create the customer dimension.

WHY:
Customer attributes are separated from transactional sales records.

This dimension supports customer-level filtering, geographical analysis,
and customer segmentation in Power BI.
*/

CREATE OR REPLACE VIEW dim_customer AS

SELECT
    customer_id,
    customer_name,
    customer_city,
    customer_country

FROM customers;


/*-----------------------------------------------------------------------------
04.4 — CREATE DIM_PRODUCT
-------------------------------------------------------------------------------

OBJECTIVE:
Create the product dimension.

WHY:
Product descriptions and category attributes should be stored separately
from the sales fact table.

This enables product-level and category-level analysis.
*/

CREATE OR REPLACE VIEW dim_product AS

SELECT
    product_id,
    product_name,
    product_category,
    brand,
    unit_price,
    product_cost,
    is_active

FROM products;


/*-----------------------------------------------------------------------------
04.5 — CREATE DIM_SELLER
-------------------------------------------------------------------------------

OBJECTIVE:
Create the seller dimension.

WHY:
Seller attributes provide context for seller-level and geographical
analysis without duplicating descriptive fields in the fact table.
*/

CREATE OR REPLACE VIEW dim_seller AS

SELECT
    seller_id,
    seller_name,
    seller_city,
    seller_region,
    seller_country,
    seller_rating,
    seller_join_date

FROM sellers;


/*-----------------------------------------------------------------------------
04.6 — CREATE DIM_DATE
-------------------------------------------------------------------------------

OBJECTIVE:
Generate a continuous calendar dimension covering the analysis period.

WHY:
A dedicated date dimension provides consistent date attributes
for time-based reporting.

It supports:
- Year-level analysis
- Quarter-level analysis
- Month-level analysis
- Day-level analysis

The date range covers January 1, 2023 through December 31, 2025.
*/

CREATE OR REPLACE VIEW dim_date AS

SELECT
    calendar_date AS date,
    YEAR(calendar_date) AS year,
    QUARTER(calendar_date) AS quarter,
    MONTH(calendar_date) AS month,
    MONTHNAME(calendar_date) AS month_name,
    DAY(calendar_date) AS day,
    DAYOFWEEK(calendar_date) AS day_of_week

FROM (
    SELECT
        UNNEST(
            GENERATE_SERIES(
                DATE '2023-01-01',
                DATE '2025-12-31',
                INTERVAL 1 DAY
            )
        ) AS calendar_date
);


/*
===============================================================================
05. FINAL STAR SCHEMA VALIDATION
===============================================================================

OBJECTIVE:
Validate the record counts of all final analytical views.

WHY:
A final validation confirms that the expected fact and dimension
structures were created successfully and contain the expected
number of records.

EXPECTED PROJECT COUNTS:

fact_sales:    35,237
dim_customer:   8,000
dim_product:      500
dim_seller:       300
dim_date:       1,096

These counts represent the final model structure developed for
the NovaCommerce Power BI report.
*/


SELECT
    'fact_sales' AS table_name,
    COUNT(*) AS total_rows
FROM fact_sales

UNION ALL

SELECT
    'dim_customer',
    COUNT(*)
FROM dim_customer

UNION ALL

SELECT
    'dim_product',
    COUNT(*)
FROM dim_product

UNION ALL

SELECT
    'dim_seller',
    COUNT(*)
FROM dim_seller

UNION ALL

SELECT
    'dim_date',
    COUNT(*)
FROM dim_date;


/*
===============================================================================
END OF SQL ANALYTICS WORKFLOW
===============================================================================

FINAL DELIVERABLES
------------------

1. Data quality validation queries.
2. Analytical order-level view: analytics_orders.
3. Exploratory Data Analysis queries.
4. Fact table: fact_sales.
5. Dimension tables:
   - dim_customer
   - dim_product
   - dim_seller
   - dim_date
6. Final model validation.

The resulting Star Schema was imported into Power BI, where relationships,
DAX measures, and the final NovaCommerce dashboards were developed.

PROJECT CONCLUSION
------------------

This SQL workflow demonstrates the transition from raw transactional
data to a structured analytical model.

The focus was not only on retrieving data, but also on validating
its quality, preserving the correct level of granularity, preventing
aggregation errors, and preparing reliable structures for business
intelligence reporting.

===============================================================================
*/
