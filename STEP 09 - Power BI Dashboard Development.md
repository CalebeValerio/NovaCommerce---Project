# STEP 09 — Power BI Dashboard Development

## 1. Objective

The objective of this step was to transform the analytical data model developed in Step 08 into an interactive business intelligence dashboard using Microsoft Power BI.

The goal was to present key business metrics, identify relevant patterns, and make the results of the NovaCommerce analysis accessible through clear and interactive visualizations.

The dashboard focuses on two main business areas:

- Sales Performance
- Customer Analytics

## 2. Tools & Technologies

- Microsoft Power BI Desktop
- DAX (Data Analysis Expressions)
- Power Query
- MotherDuck
- DuckDB ODBC Connector

## 3. Dashboard Structure

The report was organized into two pages, each addressing a different analytical perspective.

### Page 01 — Sales Overview

**Objective:** Analyze sales performance, revenue distribution, product performance, and geographical contribution.

**KPI Cards:**
- Net Revenue
- Total Orders
- Average Order Value (AOV)
- Units Sold

**Visualizations:**

1. **Revenue Over Time**
   - Line chart
   - Axis: Date
   - Value: Net Revenue
   - Tooltips: Total Orders, Average Order Value, Gross Revenue, Total Discounts

2. **Revenue by Category**
   - Horizontal bar chart
   - Axis: Product Category
   - Value: Net Revenue
   - Tooltips: Units Sold and Revenue Contribution

3. **Revenue by Country**
   - Horizontal bar chart
   - Axis: Customer Country
   - Value: Net Revenue
   - Tooltips: Total Orders, Customers, and Revenue Contribution

4. **Top 10 Products**
   - Horizontal bar chart
   - Axis: Product Name
   - Value: Net Revenue
   - Filter: Top 10 products by Net Revenue

### Page 02 — Customer Insights

**Objective:** Understand customer purchasing behavior, customer segmentation, and revenue contribution.

**KPIs & Measures:**
- Customers with Orders
- Repeat Customers
- One-time Customers
- Repeat Purchase Rate
- Average Revenue per Customer

**Visualizations:**

1. **Customer Distribution**
   - Donut chart
   - Legend: Customer Segment
   - Values: Customer Count

2. **Revenue by Segment**
   - Horizontal bar chart
   - Axis: Customer Segment
   - Value: Net Revenue
   - Tooltips: Average Revenue per Customer, Customers with Orders, and Total Orders

**Customer Segmentation:**

Customers were classified into three groups based on their total number of orders:

- No Purchase
- One-time Customer
- Repeat Customer

The segmentation was implemented using a calculated DAX column.

## 4. DAX Measures & Business Metrics

The dashboard uses DAX measures to calculate business KPIs dynamically.

### Sales Metrics

- Gross Revenue
- Total Discounts
- Net Revenue
- Total Orders
- Average Order Value
- Units Sold
- Delivered Net Revenue
- Revenue Contribution %
- Customers

### Customer Metrics

- Customers with Orders
- Repeat Customers
- One-time Customers
- Repeat Purchase Rate
- Average Revenue per Customer

These measures support the dashboard's calculations and respond to the applicable report filter context.

## 5. Design & User Experience

A consistent visual identity was developed for the NovaCommerce dashboard.

**Theme and Color Palette:**
- Dark navy: `#14283F`
- Blue: `#3186C8`
- Light blue: `#DCE7F2`
- Supporting dark blue: `#1C3550`
- Border color: `#30465D`

The visual design uses a dark interface to create consistency between report pages.

**Navigation:**

A vertical Page Navigator was added to allow users to switch between dashboard pages.

The navigation labels were simplified to:

- Sales Overview
- Customer Insights

A custom NovaCommerce logo was also created to reinforce the dashboard's visual identity.

## 6. Results & Key Business Metrics

The dashboard presents the following analytical results obtained during the previous analysis stages:

| Metric | Result |
|---|---:|
| Net Revenue | 6,065,773.69 |
| Gross Revenue | 6,342,691.36 |
| Total Discounts | 276,917.67 |
| Total Orders | 20,000 |
| Units Sold | 44,414 |
| Average Order Value | 303.29 |
| Customers with Orders | 6,046 |
| Repeat Customers | 4,391 |
| One-time Customers | 1,655 |
| Repeat Purchase Rate | 72.63% |

*These figures represent the previously validated analytical results and are not a claim that every dashboard visual was independently reconciled again during this step.*

## 7. Methodology

The dashboard development followed this workflow:

1. Connected Power BI to the MotherDuck database.
2. Imported the Star Schema views created in Step 08.
3. Configured relationships between the fact and dimension tables.
4. Marked the Date dimension as the official Date Table.
5. Created DAX measures for the required business KPIs.
6. Built the Sales Overview and Customer Insights pages.
7. Configured visualizations, tooltips, and filters.
8. Applied a consistent theme and navigation system.
9. Added the NovaCommerce brand identity.

## 8. Scope & Limitations

The final scope of this step was focused on two dashboard pages:

- Sales Overview
- Customer Insights

The Operations & Customer Experience and Payment Analysis pages were not included in the final dashboard scope.

The customer segmentation represents historical purchasing behavior across the available dataset period (2023–2025), rather than a dynamically recalculated segment for each selected date range.

## 9. Conclusion

Step 09 transformed the analytical model into an interactive Power BI reporting experience.

The final dashboard provides an overview of NovaCommerce's sales performance and customer behavior, combining business KPIs, customer segmentation, revenue analysis, and interactive navigation.

This step connects the data preparation and analytical work from previous stages with a business-oriented reporting solution.





<img width="1078" height="600" alt="Capture" src="https://github.com/user-attachments/assets/70f7d0c2-69db-43a4-ba8a-d6931a5f77b7" />


<img width="1076" height="601" alt="Capture11" src="https://github.com/user-attachments/assets/8143c921-bfa6-465d-bf2e-667d805cf76d" />
