# Project Summary — E-Commerce Customer & Revenue Intelligence

## 1. Project Objective

The objective of this project was to build an end-to-end e-commerce business intelligence solution that analyzes revenue, profitability, customer behavior, acquisition channels, and customer retention.

The project combines SQL analysis with Power BI and DAX to convert transactional data into an interactive management dashboard.

---

## 2. Business Questions

The analysis focuses on the following questions:

- How much revenue and profit does the business generate?
- Which product categories contribute most to revenue?
- Which categories and products are more profitable?
- Which acquisition channels bring customers and revenue?
- Who are the highest-value customers?
- Which customers are loyal, emerging, at risk, or inactive?
- How is customer value distributed across different RFM segments?
- How recently are customers purchasing?

---

## 3. Dataset

The project uses a synthetic e-commerce dataset covering:

**January 2024 – December 2025**

| Table | Records |
|---|---:|
| Customers | 8,000 |
| Products | 150 |
| Orders | 15,000 |
| Order_Items | 24,395 |
| Date | 731 |

### Data Model

The project follows a relational structure connecting:

- Customers → Orders
- Products → Order_Items
- Orders → Order_Items
- Date → Orders

---

## 4. Technology Stack

### SQL / MySQL
Used for:

- Data validation
- Referential integrity checks
- Revenue analysis
- Profitability analysis
- Product analysis
- Customer analysis
- Acquisition channel analysis
- RFM segmentation

### Power BI
Used for:

- Data modeling
- KPI development
- Interactive dashboard creation
- Customer segmentation analysis
- Revenue and profitability visualization

### DAX
Used for:

- Revenue and profit measures
- Profit margin
- Order count
- Customer count
- Average Order Value
- Customer acquisition metrics
- RFM customer analysis

### Excel

Used for dataset organization and preparation.

---

## 5. Dashboard Structure

The Power BI solution contains four analytical pages.

### Page 1 — Customer Intelligence

Focuses on overall customer and revenue behavior.

Key visuals:

- Revenue Momentum
- Customer Portfolio
- Customer Value Contribution
- Customer Value Map

---

### Page 2 — Revenue & Product Intelligence

Focuses on product and category-level performance.

Key visuals:

- Category Performance
- Revenue Mix
- Top 10 Products
- Product Profitability Map

---

### Page 3 — Customer Acquisition

Focuses on acquisition channels and customer value.

Key visuals:

- Acquisition Channel Performance
- Customer Reach
- Channel Revenue Trend
- Channel Quality Matrix

---

### Page 4 — Customer Retention & RFM Intelligence

Focuses on customer retention and customer-value segmentation.

Key visuals:

- RFM Segment Portfolio
- Segment Revenue Contribution
- RFM Revenue vs Customer Base
- Customer Recency Distribution
- RFM Customer Detail

---

## 6. Key Metrics

| Metric | Result |
|---|---:|
| Total Revenue | $91.21M |
| Total Cost | $75.68M |
| Total Profit | $15.52M |
| Profit Margin | 17.02% |
| Total Orders | 15,000 |
| Active Customers | 5,724 |

---

## 7. Key Findings

### Revenue Concentration

Electronics generated approximately **61.69% of total revenue**, making it the largest revenue-generating category.

Its profit margin was approximately **11.07%**.

### Category Profitability

Beauty recorded a profit margin of approximately **38.22%**, while Fashion recorded approximately **33.67%**.

This demonstrates that revenue contribution and profitability are not necessarily proportional across categories.

### Customer Segmentation

The RFM framework divides active customers into:

- Champions
- Loyal Customers
- Potential Loyalists
- At Risk
- High Value - Inactive
- New / Emerging
- Needs Attention

### Customer Retention

The RFM analysis provides a framework for identifying customers based on:

- Recency
- Purchase Frequency
- Monetary Value

This allows customer groups to be analyzed differently rather than treating the entire customer base uniformly.

---

## 8. RFM Methodology

RFM analysis evaluates customers using three dimensions.

### Recency

Measures the number of days since the customer's most recent purchase.

### Frequency

Measures the number of distinct orders placed by the customer.

### Monetary Value

Measures the customer's total revenue contribution.

Each dimension is converted into a five-level score.

The resulting RFM scores are used to classify customers into meaningful customer segments.

The Power BI implementation uses deterministic tie handling for the RFM ranking process.

---

## 9. Analytical Workflow

```text
Raw Dataset
     ↓
Data Validation
     ↓
MySQL Data Model
     ↓
SQL Analysis
     ↓
RFM Customer Segmentation
     ↓
Power BI Data Model
     ↓
DAX Measures
     ↓
Interactive Dashboard
     ↓
Business Insights
