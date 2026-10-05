# Brazilian E-Commerce Data Analysis (2016–2018)
End-to-end analysis of +100k orders from the Olist Brazilian E-Commerce dataset: data cleaning and modeling, SQL analysis, exploratory statistics, and 8 interactive Power BI dashboards (plus Excel versions) covering sales, customers, payments, products, sellers, logistics, reviews and seasonality.

# 🛒 Business Questions

Which product categories and states drive revenue?
How do customers pay (method, installments) and how much do they spend?
How well do sellers and logistics perform (dispatch time, on-time rate, freight cost)?
How much does delivery performance affect customer satisfaction?
Are there seasonal patterns, and where do cancellations and delays concentrate?

---

## 📂 Key findings

| Area | Finding |
|---|---|
| **Revenue concentration** | São Paulo sellers generate **$10.24M of $13.59M** in total sales (~75%). Health & Beauty ($1.26M), Watches & Gifts ($1.21M) and Bed, Bath & Table ($1.04M) lead categories. |
| **Customers** | São Paulo has 40.3k customers, followed by Rio de Janeiro (12.4k) and Minas Gerais (11.3k). Only **3.12% of customers are returning** → retention is the biggest untapped opportunity. |
| **Payments** | Credit card dominates (74.98k payments, $12.54M), followed by boleto (19.78k, $2.87M). 48,268 payments use a single installment; credit card averages 3.55 installments. |
| **Logistics** | Average delivery takes **12.56 days**, average freight is **$22.82/order**, and on-time rate is **94.16%**. São Paulo is fastest (8.8 days); northern states such as Roraima, Paraíba and Rondônia pay the highest freight ($46–49 per order). |
| **Satisfaction** | Average review score is **4.1** with 77% positive reviews. On-time orders score **4.3** vs **2.3** for late orders (gap of 2.02). Scores fall from 4.4 (0–7 days) to 2.4 (29+ days). |
| **Seasonality** | November is the peak month (seasonality index **1.49**, Black Friday effect). Late-delivery rate also peaks in Nov 2017 (12.4%) and Mar 2018 (19.0%). Mondays and Tuesdays are the busiest days. |
| **Product risks** | Sports & Leisure has the most cancellations (47). Home Comfort and Flowers have freight above 44% of product price. |

---
**Insights → actions:** invest in logistics outside the Southeast, run retention/loyalty programs, bundle slow-moving categories with top sellers, prepare capacity ahead of November, and expand seller coverage in high-freight states.


### 2. 📊  Data model

Relational model built in Power BI / Power Pivot (orders as the central table, with a date table, geolocation and category-translation lookups).

![Data model](https://github.com/jeisteve999/Brazilian-E-Commerce-Public-Dataset/blob/main/Dashboards/Relation%20between%20tables%20png.png)

## ⚙️ Methodology

**1. Data preparation (ETL)**
- Power Query: fixed errors, handled nulls/blanks, removed unused columns, standardized dates, numbers and currency.
- SQL Server: imported the CSVs, defined data types, primary/foreign keys and constraints.

**2. SQL analysis** (`sql/brazilian_ecommerce_full.sql`)
- Sales trends by category, revenue by customer state, order tracking by status and time.
- Stored procedures for monthly sales and sales by payment type.
- Triggers to flag canceled orders and track late deliveries.

**3. Exploratory data analysis**
- Descriptive statistics (mean, median, mode, range, std. dev., variance, skewness, kurtosis, quartiles) for each analysis area, computed with PivotTables and Power Pivot.

**4. Dashboards**
- Calculated columns and DAX measures for KPIs such as on-time rate, delivery days, freight %, seasonality index, new vs. returning customers, and review gap (on-time vs. late).

---

## 📊 Dashboards

Each dashboard has slicers for **Year**, **Primary Payment Method** and **Order Status**.

| | |
|---|---|
| **Sales** ![](assets/dashboards/01_sales.png) | **Customers** ![](assets/dashboards/02_customer.png) |
| **Payments** ![](assets/dashboards/03_payment.png) | **Products** ![](assets/dashboards/04_product.png) |
| **Sellers** ![](assets/dashboards/05_seller.png) | **Geographic** ![](assets/dashboards/06_geographic.png) |
| **Reviews** ![](assets/dashboards/07_review.png) | **Temporal** ![](assets/dashboards/08_temporal.png) |

The earlier Excel versions of the dashboards are in [`dashboards/excel/`](dashboards/excel/).

---

## ⚠️ Notes & limitations

- **Sales vs. payments:** total sales ($13.59M) is the sum of item prices; total payments (~$16.0M) also include freight.
- **Incomplete months:** the dataset ends in Aug–Oct 2018 and 2016 has very few orders, so the last point of the sales trend (drop to 0) is a data cutoff, not a real collapse. The temporal dashboard compares 2017 vs. 2018 only.
- **Review scores** are 1–5 per order; state-level averages (e.g., the 3.61–4.19 range in the EDA) are averages of those scores.
- Statistical indicators (skewness, kurtosis) were computed on **aggregated values** (by state or month), so they describe the distribution of those aggregates, not individual orders.
- Small differences between Excel and Power BI figures can appear due to different filter-context handling.

---
## 🔗 Resources

- [Raw dataset](https://drive.google.com/drive/folders/1z12NxdpNSXAm-YVgWKvV7UZDT_QRCu8x)
- [Cleaned dataset](https://drive.google.com/drive/folders/1MaXtDnEB10NFDj8SUHG4cUMZGzQLP_Zm)
- [EDA workbook](https://docs.google.com/spreadsheets/d/1zdd57BElI3ywP_7NE4FsI7KMUQkYum69/edit?usp=drive_web)
- [Excel dashboards](https://docs.google.com/spreadsheets/d/1pp4FP3bfqE3WLdOSSFy7MtBXUZ7M1sin/edit?usp=drive_link)
- [Power BI file (.pbix)](https://drive.google.com/file/d/1tJVXK8xq4W8hgZK6YgLF37faOUnIojfn/view?usp=sharing)
- [Full project report (PDF)](docs/Brazilian_Ecommerce_Report.pdf)

---

## 🧠 What I learned

- Designing a relational model that keeps filters working across 10+ tables (bidirectional relationships and filter context were the hardest part).
- Cleaning and loading data into SQL Server despite type mismatches and missing values.
- Writing DAX measures and calculated columns for business KPIs.
- Reconciling numbers across Excel, SQL and Power BI.

---

## 👤 Author

**Jeisson Steve Rojas Velásquez** · Data Analyst
[GitHub](https://github.com/jeisteve999) · [LinkedIn](https://www.linkedin.com/) <!-- add your LinkedIn URL -->

📅 Originally published June 2025 · Dashboards redesigned and updated 2026


👨‍💻 Author: Jeisson Steve Rojas Velásquez  
📅 Date: June 2025
