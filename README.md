# 📊 Customer Churn & Retention Analysis (SQL | MySQL)

## 📌 Project Overview
This project analyzes customer churn behavior using SQL to identify high-risk customer segments, understand retention drivers, and support data-driven retention strategies.

The analysis simulates a real subscription-based business environment where customer lifecycle, transaction activity, and support interactions influence churn decisions.

The project demonstrates how SQL can be used not only for data extraction but also for business intelligence, customer segmentation, and churn risk identification.

---

## 🎯 Business Objectives

- Measure overall churn rate and customer retention performance
- Identify customer segments with higher churn risk
- Analyze revenue impact of customer churn
- Detect early warning signals before churn occurs
- Provide actionable retention strategies for business stakeholders

---

## 🗂 Dataset Description

The project uses four relational tables:

### 👤 Customers Table
| Column | Description |
|----------|-------------|
| customer_id | Unique customer identifier |
| signup_date | Customer onboarding date |
| gender | Customer demographic attribute |
| age | Customer age |
| region | Customer geographic location |
| plan_type | Subscription plan category |

---

### 📄 Subscriptions Table
| Column | Description |
|-------------|-------------|
| subscription_id | Unique subscription record |
| customer_id | Linked customer |
| start_date | Subscription start date |
| end_date | Subscription end date |
| churn_flag | 1 = churned, 0 = active |
| churn_reason | Reason for churn |

---

### 💳 Transactions Table
| Column | Description |
|-------------|-------------|
| transaction_id | Transaction record |
| customer_id | Linked customer |
| transaction_date | Purchase date |
| amount | Transaction value |
| payment_mode | Payment method |

---

### 🎧 Support Tickets Table
| Column | Description |
|-------------|-------------|
| ticket_id | Support interaction record |
| customer_id | Linked customer |
| ticket_date | Support contact date |
| issue_type | Type of customer issue |
| resolution_days | Time taken to resolve issue |

---

## 🔍 Analysis Workflow

---

### 🧭 Step 1: Business Understanding & Data Exploration
- Understand customer lifecycle structure
- Validate table relationships and data consistency
- Explore dataset size, structure, and coverage

---

### 📊 Step 2: Churn KPI & Baseline Metrics
Key Questions:
- What percentage of customers churned?
- What percentage of customers remain active?
- How long do customers typically stay before churn?

Key Insights:
- Established baseline churn rate
- Measured customer lifetime duration
- Built churn performance benchmarks

---

### 📉 Step 3: Customer Behavior & Revenue Analysis
Key Questions:
- Do churned customers generate less revenue?
- Does transaction frequency impact churn?
- Does payment behavior correlate with retention?

Key Insights:
- Identified revenue differences between churned vs retained customers
- Discovered behavioral patterns impacting retention
- Highlighted payment mode preferences

---

### ⚠️ Step 4: Customer Support & Experience Impact
Key Questions:
- Do support tickets increase churn risk?
- Does slow issue resolution drive customer loss?

Key Insights:
- Higher support interaction frequency linked with churn
- Long resolution times increased churn probability
- Support experience plays a major role in retention

---

### 🚨 Step 5: Churn Risk Indicators & Early Warning Signals
Risk signals identified:

- Low transaction frequency
- Reduced customer spending
- Frequent support tickets
- Long ticket resolution time
- Short customer tenure

This step simulates proactive churn prediction signals used by real businesses.

---

### 🎯 Step 6: Retention Strategy & Customer Segmentation
Customers segmented into:

- High-Value Customers
- Medium-Value Customers
- Low-Value Customers
- At-Risk Customers

Segmentation helps prioritize retention budgets and marketing strategies.

---

### 🧠 Step 7: Advanced Business Insights
Combined analysis across:

- Customer lifetime value
- Support behavior
- Subscription tenure
- Revenue patterns

This step provides multi-dimensional churn intelligence.

---

## 📊 Key Findings

- Customers with frequent support issues show significantly higher churn rates
- High-value customers still churn when service experience is poor
- Short tenure customers are more likely to churn
- Payment behavior impacts customer retention patterns
- Transaction inactivity is a strong early churn indicator

---

## 💼 Business Recommendations

### 🎯 Proactive Retention Monitoring
Develop early warning dashboards tracking:
- Transaction frequency drop
- Increased support activity
- Spending decline

---

### 🤝 Customer Experience Improvements
- Reduce support ticket resolution time
- Improve onboarding for new customers
- Provide faster escalation for high-value users

---

### 💰 Revenue Protection Strategy
- Focus retention efforts on high-value churn risk customers
- Offer loyalty benefits and renewal incentives

---

### 📢 Targeted Engagement Campaigns
- Personalized retention campaigns for at-risk segments
- Automated alerts for inactivity detection

---

## 🛠 SQL Concepts Used

- Joins (INNER JOIN)
- Aggregations (SUM, AVG, COUNT)
- Conditional Logic (CASE WHEN)
- Grouping & Segmentation
- Subqueries
- Churn KPI calculations
- Customer lifetime calculations
- Business metric derivation

---

## 📈 Project Skills Demonstrated

- Business problem solving using SQL
- Customer lifecycle analysis
- Retention strategy design
- Data quality validation
- KPI development and interpretation
- Translating data into business insights

---

## 🚀 Business Impact

This project demonstrates how SQL can be used to:

- Identify churn drivers
- Support retention strategy design
- Improve customer lifetime value
- Enable proactive business decision-making

---

## 🧾 Tools Used

- MySQL Workbench
- SQL
- Relational Database Design
