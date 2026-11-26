<img width="2169" height="725" alt="Logótipo NovaCommerce com Saco Orbitante" src="https://github.com/user-attachments/assets/cec5fbdf-826b-44e5-b07d-57cc16dbc2f9" />







# Step 07 — Exploratory Data Analysis (EDA)

## 1. Objective

The objective of this stage was to explore the NovaCommerce dataset and answer the business questions defined during Step 01 — Business Understanding.

The analysis focused on identifying sales trends, understanding customer behavior, evaluating product performance, examining geographic distribution, and assessing operational performance.

All analyses were conducted using SQL in MotherDuck, primarily through the `analytics_orders` analytical view and the original normalized tables.

---

## 2. Business Questions & Analysis

### 2.1 How has revenue evolved over time?

**Analysis:** Monthly and yearly revenue trends from 2023 to 2025.

| Year | Total Orders | Net Revenue |
|---|---:|---:|
| 2023 | 6,724 | $2,003,129.42 |
| 2024 | 6,662 | $2,048,500.59 |
| 2025 | 6,614 | $2,014,143.68 |

**Key Findings:**
- Revenue increased by approximately 2.27% in 2024 compared to 2023.
- Revenue decreased by approximately 1.68% in 2025 compared to 2024.
- Order volume declined slightly throughout the three-year period.
- Revenue remained relatively stable, without a consistent upward growth trend.

**Business Insight:**

NovaCommerce maintained relatively stable revenue over the analyzed period. However, the slight decline in order volume suggests that the company should investigate customer acquisition and purchasing activity.

### 2.2 Which products and categories perform best?

**Analysis:** Product and category performance based on units sold, average selling price, and total revenue.

**Top Performing Products by Revenue:**

| Product | Units Sold | Total Revenue |
|---|---:|---:|
| Everpeak Electronics Item 033 | 98 | $78,810.83 |
| Vertex Electronics Item 168 | 98 | $78,450.55 |
| Everpeak Electronics Item 371 | 95 | $75,312.32 |
| BlueOak Electronics Item 472 | 95 | $74,626.25 |
| Vertex Electronics Item 086 | 88 | $71,153.95 |

**Category Performance:**

| Category | Products | Units Sold | Total Revenue |
|---|---:|---:|---:|
| Electronics | 76 | 6,720 | $2,660,202.04 |
| Sports & Outdoors | 62 | 5,548 | $1,057,956.06 |
| Home & Kitchen | 55 | 4,883 | $713,361.48 |
| Fashion | 55 | 4,948 | $481,985.65 |
| Office Supplies | 60 | 5,481 | $398,893.16 |
| Toys | 58 | 4,996 | $328,149.17 |
| Beauty | 63 | 5,579 | $284,518.19 |
| Books | 71 | 6,259 | $140,707.94 |

**Key Findings:**
- Electronics is the strongest category, generating approximately 43.85% of total net revenue.
- Sports & Outdoors ranks second, with approximately 17.43%.
- Electronics generates more than twice the revenue of the second-place category.
- Product sales volume and revenue are not always directly proportional.

**Business Insight:**

Electronics is the main revenue-generating category for NovaCommerce. The company should continue evaluating its performance while monitoring its dependence on this category.

### 2.3 Which customer segments are most valuable?

**Analysis:** Customer purchasing frequency and revenue contribution.

The dataset contained 6,046 unique customers and 20,000 orders.

**Customer Overview:**

| Metric | Result |
|---|---:|
| Unique Customers | 6,046 |
| Total Orders | 20,000 |
| Average Orders per Customer | 3.31 |

**Returning vs. One-Time Customers:**

| Customer Type | Customers | Percentage |
|---|---:|---:|
| Returning Customers | 4,391 | 72.63% |
| One-Time Customers | 1,655 | 27.37% |

**Customer Revenue Concentration:**

| Metric | Result |
|---|---:|
| Top 10 Customers Revenue | $65,715.58 |
| Share of Total Revenue | 1.08% |

**Key Findings:**
- Approximately 72.63% of customers placed more than one order.
- The average customer placed 3.31 orders.
- The ten highest-revenue customers accounted for only 1.08% of total revenue.
- Revenue is relatively distributed across the customer base rather than concentrated among a small group of customers.

**Business Insight:**

NovaCommerce demonstrates a high proportion of repeat customers and relatively low revenue concentration among its ten largest customers. This suggests that the business is not heavily dependent on a small number of individual customers.

### 2.4 How many customers make repeat purchases?

**Analysis:** Customers were classified according to their total number of recorded orders.

**Key Findings:**
- 4,391 customers placed more than one order.
- 1,655 customers placed exactly one order.
- Returning customers represented 72.63% of the customer base.

**Business Insight:**

The high proportion of returning customers indicates recurring purchasing activity. Maintaining customer satisfaction and encouraging additional purchases should remain important business priorities.

### 2.5 Which regions generate the most sales?

**Analysis:** Revenue and order distribution by customer country.

| Country | Orders | Net Revenue |
|---|---:|---:|
| United States | 11,500 | $3,487,275.70 |
| Canada | 3,200 | $984,319.66 |
| United Kingdom | 3,248 | $953,798.74 |
| Australia | 2,052 | $640,379.59 |

**Key Findings:**
- The United States generated approximately 57.5% of total revenue.
- Canada and the United Kingdom were the second and third largest markets.
- Australia had the highest average order value among the four countries, at $312.08.
- The United Kingdom had the lowest average order value, at $293.66.

**Business Insight:**

The United States is NovaCommerce's primary market. Its strong contribution to revenue represents an opportunity for further growth, while the company could also investigate opportunities to expand its presence in other countries.

### 2.6 How efficient are deliveries?

**Analysis:** Average delivery time calculated using the difference between shipping date and delivery date for delivered orders.

| Metric | Result |
|---|---:|
| Delivered Orders | 16,814 |
| Average Delivery Time | 5.71 days |
| Minimum Delivery Time | 0 days |
| Maximum Delivery Time | 19 days |

**Key Findings:**
- The average delivery time was approximately 5.71 days.
- The shortest recorded delivery interval was zero days.
- The longest recorded delivery interval was 19 days.

**Business Insight:**

Delivery performance provides an important operational indicator. The average delivery time offers a baseline for monitoring logistics performance and identifying potential improvements.

However, a delivery target or service-level agreement would be necessary to determine whether this performance meets business expectations.

### 2.7 Which payment methods are most used?

**Analysis:** Payment transaction volume and payment amount by method.

| Payment Method | Transactions | Percentage |
|---|---:|---:|
| Credit Card | 10,534 | 47.75% |
| PayPal | 4,424 | 20.05% |
| Debit Card | 3,555 | 16.11% |
| Bank Transfer | 2,472 | 11.20% |
| Gift Card | 1,078 | 4.89% |

**Key Findings:**
- Credit Card was the most frequently used payment method, representing 47.75% of transactions.
- PayPal ranked second, accounting for 20.05%.
- Credit Card and PayPal together represented 67.80% of all transactions.
- Gift Card was the least frequently used method.

**Business Insight:**

Credit Card and PayPal are the dominant payment methods. NovaCommerce should prioritize maintaining a reliable payment experience for these methods while monitoring the adoption of alternative payment options.

---

## 3. Overall Business Findings

The exploratory analysis revealed several important characteristics of NovaCommerce:

1. **Revenue Stability:** Revenue remained relatively stable between 2023 and 2025, with no consistent upward growth trend.

2. **Category Concentration:** Electronics generated approximately 43.85% of total revenue, making it the company's strongest product category.

3. **Customer Recurrence:** Returning customers represented 72.63% of the customer base.

4. **Customer Revenue Distribution:** The ten highest-revenue customers contributed only 1.08% of total revenue, indicating relatively low concentration among individual customers.

5. **Geographic Concentration:** The United States accounted for approximately 57.5% of total revenue.

6. **Delivery Performance:** The average delivery time was 5.71 days, providing a baseline for future operational monitoring.

7. **Payment Preferences:** Credit Card was the dominant payment method, followed by PayPal.

---

## 4. Data Limitations & Analytical Considerations

Several limitations must be considered when interpreting the results:

- Revenue calculations include orders with different statuses, including Cancelled, Processing, Shipped, and Delivered. Therefore, net revenue associated with orders should not automatically be interpreted as realized revenue.
- Customer repeat-purchase analysis includes all recorded orders, regardless of order status. It measures repeated order activity rather than confirmed completed purchases.
- Payment transaction totals include Paid, Pending, and Refunded transactions. They should not be interpreted as confirmed cash received.
- Four negative payment amounts were identified during the Data Quality Assessment. Their causes could not be conclusively determined.
- Delivery efficiency was measured using elapsed calendar days between shipping and delivery dates. No company delivery target was available for comparison.
- Customer revenue concentration was evaluated using the ten highest-revenue customers. A broader concentration analysis could provide additional insights.
- The analysis identified revenue and sales patterns but did not evaluate product profitability because a complete profitability analysis was outside the scope of this EDA.

These limitations were documented to ensure that business conclusions remain supported by the available data.

---

## 5. Conclusion

The Exploratory Data Analysis successfully addressed the seven business questions defined during the Business Understanding stage.

The analysis provided an overview of NovaCommerce's revenue trends, customer purchasing behavior, product performance, geographic distribution, delivery operations, and payment preferences.

The findings identified Electronics as the primary revenue-generating category, the United States as the largest market, and returning customers as a significant part of the customer base.

The results also highlighted opportunities for further investigation, particularly regarding revenue concentration by category, geographic dependence, and delivery performance.

**Step 07 — Exploratory Data Analysis (EDA) completed.**

The next stage will focus on transforming the analytical findings into meaningful visualizations and business dashboards using PowerBI.
