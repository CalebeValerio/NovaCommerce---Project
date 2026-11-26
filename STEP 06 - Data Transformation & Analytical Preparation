<img width="2169" height="725" alt="Logótipo NovaCommerce com Saco Orbitante" src="https://github.com/user-attachments/assets/cec5fbdf-826b-44e5-b07d-57cc16dbc2f9" />






# Step 06 — Data Transformation & Analytical Preparation

## Objective

The objective of this step was to transform the original normalized database tables into an analytical structure suitable for business analysis, KPI development, and dashboard creation.

The original database contained multiple tables with different levels of granularity. Before combining them, the data needed to be aggregated to prevent duplicated records and incorrect calculations.

## 1. Data Aggregation

The `order_items` table was aggregated at the order level to calculate:

- Total order items
- Total units sold
- Gross revenue
- Total discounts
- Net revenue

The `payments` table was also aggregated at the order level to calculate:

- Total payment transactions
- Total payment amount

## 2. Analytical View Creation

A SQL VIEW named `analytics_orders` was created using the following tables:

| Source table | Information integrated |
|---|---|
| orders | Order identifiers, dates, status, sales channel and currency |
| customers | Customer name and geographical information |
| order_items | Item quantities, gross revenue, discounts and net revenue |
| payments | Payment transaction count and total payment amount |
| shipping | Shipping and delivery dates |

Each supporting dataset was aggregated where necessary before being joined to the main `orders` table.

This approach prevented row multiplication caused by joining tables with different granularities.

## 3. Data Validation

The resulting analytical view was validated.

| Validation | Result |
|---|---:|
| Total orders | 20,000 |
| Unique orders | 20,000 |
| Duplicate orders | 0 |
| Missing net revenue values | 0 |
| Missing payment values | 0 |

Additional validations performed:

- All 20,000 orders had at least one associated order item.
- All 35,237 order item records had consistent `line_total` calculations within a tolerance of 0.01.
- The order-level aggregation preserved one row per order.

## 4. Final Analytical Structure

The final `analytics_orders` VIEW provides a consolidated dataset containing:

- Order information
- Customer information
- Sales metrics
- Payment metrics
- Shipping and delivery information

The resulting structure contains 20,000 rows, with one row representing one order.

## 5. Important Data Considerations

During previous data quality investigations, four negative payment amounts were identified.

Additionally, some payment totals did not match the corresponding net revenue values.

These discrepancies were not modified or removed during this step. Payment amounts should therefore be interpreted carefully in subsequent financial analyses.

## Conclusion

The data transformation and analytical preparation stage was completed successfully.

The original normalized database is now complemented by a consolidated order-level analytical view, providing a foundation for exploratory data analysis, business performance measurement, and dashboard development.

**Next Step:** Step 07 — Exploratory Data Analysis (EDA).
