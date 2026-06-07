# 🛒 ShopEasy Consumer Intelligence
### Funnel Analysis & Sentiment Intelligence Dashboard

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat&logo=microsoft-sql-server&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![Status](https://img.shields.io/badge/Status-Complete-639922)

---

## 📌 Project Overview

ShopEasy is a fictional e-commerce company experiencing high website traffic but low purchase conversion. This project acts as a full end-to-end data analyst workflow — from raw data generation and SQL cleaning, to Python NLP sentiment analysis and an interactive Power BI dashboard.

**The core business question:**
> *"Why are customers visiting but not buying — and what are unhappy customers actually complaining about?"*

---

## 🔍 Key Findings

| Finding | Detail |
|---|---|
| Overall Conversion Rate | 1.00% (Click to Purchase) |
| Biggest Funnel Drop-off | Click to Add to Cart stage |
| Average Customer Rating | 3.87 / 5.00 |
| Positive Sentiment | 71.46% of all reviews |
| Top Complaint Theme | Unmet Expectations |
| All 18 Products Status | Needs Attention |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| SQL Server Express | Database storage and data cleaning |
| SSMS | SQL query execution and validation |
| Python 3.13 | Data generation and NLP analysis |
| VADER Sentiment | Sentiment scoring on customer reviews |
| pandas | Data manipulation and CSV export |
| Power BI Desktop | Interactive 5-page dashboard |
| Git & GitHub | Version control and portfolio hosting |

---

## 📁 Project Structure

    shopeasy-consumer-intelligence/
    │
    ├── 01_Data_Validation.sql
    ├── 02_cleaning_transformation.sql
    ├── 03_Sentiment_analysis.ipynb
    ├── generate_data.py
    ├── customer_reviews_sentiment.csv
    ├── negative_reviews_issues.csv
    └── sentiment_distribution.png

---

## 🗄️ Database Schema

### customer_journey_cleaned
Tracks each customer's path through the purchase funnel.

| Column | Type | Description |
|---|---|---|
| JourneyID | INT | Primary key |
| CustomerID | INT | Customer identifier |
| ProductID | INT | Product (1-18) |
| VisitDate | DATE | Date of visit |
| Stage | VARCHAR | Click / Add to Cart / Checkout / Purchase |
| Action | VARCHAR | Proceeded or Drop-off |
| Duration | FLOAT | Time in seconds (NULL = dropped off) |

### customer_reviews_cleaned
Customer written reviews with star ratings.

| Column | Type | Description |
|---|---|---|
| ReviewID | INT | Primary key |
| CustomerID | INT | Customer identifier |
| ProductID | INT | Product reviewed |
| ReviewDate | DATE | Date of review |
| Rating | INT | Star rating 1-5 |
| ReviewText | VARCHAR | Written review text |

### engagement_data_cleaned
Marketing channel performance data.

| Column | Type | Description |
|---|---|---|
| EngagementID | INT | Primary key |
| ContentID | INT | Content piece identifier |
| ContentType | VARCHAR | Video / Blog / Social Media / Newsletter |
| Views | INT | Views (split from combined column) |
| Clicks | INT | Clicks (split from combined column) |
| Likes | INT | Number of likes |
| EngagementDate | DATE | Date of engagement |

---

## 🧹 Data Quality Summary

| Check | Result | Action Taken |
|---|---|---|
| Duplicate rows | 0 found | ROW_NUMBER() dedup built as safety net |
| NULL Duration values | Present | Preserved — intentional for Drop-off rows |
| Casing inconsistencies | 0 found | UPPER/LOWER standardisation applied |
| Whitespace in reviews | 0 found | LTRIM/RTRIM applied |
| Combined Views+Clicks column | Fixed | Split into 2 integer columns via CHARINDEX |
| Invalid ratings (outside 1-5) | 0 found | Validated clean |

---

## 🤖 Sentiment Analysis Methodology

Pure VADER scoring was not sufficient alone — some clearly positive phrases scored as neutral. A **hybrid approach** was used combining VADER compound score with star rating:

| Category | VADER Score | Star Rating |
|---|---|---|
| Positive | >= 0.05 | >= 4 stars |
| Negative | <= -0.05 | <= 2 stars |
| Mixed Negative | <= -0.05 | >= 3 stars |
| Mixed Positive | >= 0.05 | <= 3 stars |
| Neutral | Between -0.05 and 0.05 | Any |

**Negative review themes identified:**
- Unmet Expectations
- Product Performance
- Product Cost
- Delivery Issues

---

## 📊 Dashboard Pages

| Page | Description |
|---|---|
| Overview | KPI cards — Sessions, Purchases, Conversion Rate, Avg Rating |
| Conversion Funnel | Drop-off visualization across all funnel stages |
| Marketing Performance | Clicks by channel, Likes trend by quarter |
| Customer Sentiment | Sentiment donut chart and complaint theme breakdown |
| Product Health Scorecard | 18 products scored with Red/Amber/Green status |

---

## 💡 Business Recommendations

1. **Fix the Click to Add to Cart drop-off** — This is where most customers are lost. Improve product page clarity and add trust signals like reviews and guarantees.

2. **Address Unmet Expectations** — The top complaint theme suggests product descriptions may be misleading. Audit and rewrite product copy to set accurate expectations.

3. **All 18 products need attention** — No product currently scores as Healthy. A focused improvement campaign on the top 5 highest-traffic products is recommended first.

4. **Leverage positive sentiment** — 71.46% of customers are happy. Use positive reviews in marketing materials to build social proof and improve conversion.

---

## 🚀 How to Run This Project

**Prerequisites:**
- SQL Server Express (free)
- Python 3.x with: pandas, pyodbc, faker, vaderSentiment, matplotlib, seaborn
- Power BI Desktop (free)

**Steps:**
1. Run generate_data.py to populate the SQL Server database
2. Run 01_Data_Validation.sql in SSMS to audit the data
3. Run 02_cleaning_transformation.sql in SSMS to clean the data
4. Run 03_Sentiment_analysis.ipynb in VS Code to generate sentiment CSVs
5. Open ShopEasy_Dashboard.pbix in Power BI Desktop

---

## 👩‍💻 Author

**Sadiya**
- GitHub: [@Sadiya0505](https://github.com/Sadiya0505)

---

*Built as a data analyst portfolio project demonstrating end-to-end skills in SQL, Python NLP, and Power BI visualization.*