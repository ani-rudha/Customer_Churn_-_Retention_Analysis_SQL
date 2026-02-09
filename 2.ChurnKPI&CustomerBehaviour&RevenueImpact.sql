-- =======================================================================================================================================================================
--                                            -: 2. Churn KPI & Baseline Metrics :-                                       
-- =======================================================================================================================================================================
-- 2.1 What percentage of customers have churned?
SELECT 
    COUNT(*) AS total_subscriptions,
    SUM(churn_flag) AS churned_customers,
    ROUND((SUM(churn_flag) * 100.0) / COUNT(*), 2) AS churn_rate_percent
FROM
    subscriptions;

-- The overall churn rate stands at approximately 68%
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.2 How many customers are active vs churned?
SELECT 
    CASE
        WHEN churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS customer_status,
    COUNT(*) AS customers
FROM
    subscriptions
GROUP BY customer_status;

-- There are 93 Active and 196 Churned customers.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.3 Which customer demographics (Gender) contributes more in churn?
SELECT 
    c.gender,
    CASE
        WHEN s.churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,
    COUNT(*) AS customers
FROM
    customers c
        JOIN
    subscriptions s ON c.customer_id = s.customer_id
GROUP BY c.gender , churn_status
ORDER BY c.gender;

-- Out of 93 Active customers 39 are female and 54 are male & Out of 196 Churned customers 96 are female and 100 are male.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.4 Are certain regions losing more customers?
SELECT 
    c.region,
    CASE
        WHEN s.churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,
    COUNT(*) AS customers
FROM
    customers c
        JOIN
    subscriptions s ON c.customer_id = s.customer_id
GROUP BY c.region , churn_status
ORDER BY customers DESC;

-- The 'WEST' region shows the highest churn concentration, whereas 'EAST' region demonstrates better customer stability.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.5 Which subscription plans have the highest churn percentage?
SELECT 
    c.plan_type,
    COUNT(*) AS total_customers,
    SUM(s.churn_flag) AS churned_customers,
    ROUND((SUM(s.churn_flag) * 100.0) / COUNT(*),
            2) AS churn_rate_percent
FROM
    customers c
        JOIN
    subscriptions s ON c.customer_id = s.customer_id
GROUP BY c.plan_type
ORDER BY churn_rate_percent DESC;

-- Customers using 'Basic' plan showing minimum churn rate, appr. 69% and 'Standard' with 'Premium' showing maximum churn rate appr. 70%
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.6 Is churn increasing 'Monthly'?
SELECT 
    DATE_FORMAT(end_date, '%Y-%m') AS churn_month,
    COUNT(*) AS churned_customers
FROM
    subscriptions
WHERE
    churn_flag = 1 AND end_date IS NOT NULL
GROUP BY churn_month
ORDER BY churn_month;

-- Actually the churn rate is not showing linear increasing order but overall its mentation same churn rate
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.7 What percentage of customers are still active?
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE
        WHEN churn_flag = 0 OR churn_flag IS NULL THEN 1
        ELSE 0
    END) AS active_customers,
    ROUND((SUM(CASE
                WHEN churn_flag = 0 OR churn_flag IS NULL THEN 1
                ELSE 0
            END) * 100.0) / COUNT(*),
            2) AS active_customer_percent
FROM
    subscriptions;

-- Approximately 32% are active right now.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.8 How long customers stay before leaving?
SELECT 
    ROUND(AVG(DATEDIFF(end_date, start_date)), 0) AS avg_customer_lifetime_days
FROM subscriptions
WHERE churn_flag = 1
AND end_date IS NOT NULL;

-- On an average, customers stay 512 days before leaving.


-- =======================================================================================================================================================================
--                                         -: 3. Customer Behaviour & Churn Risk Drivers :-                                       
-- =======================================================================================================================================================================
-- 3.1 Do customers who spend less or transact less churn more?
SELECT 
    CASE
        WHEN s.churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,
    COUNT(DISTINCT t.customer_id) AS customer_count,
    ROUND(AVG(t.amount), 2) AS avg_transaction_value,
    COUNT(t.transaction_id) AS total_transactions
FROM
    subscriptions s
        LEFT JOIN
    transactions t ON s.customer_id = t.customer_id
GROUP BY churn_status;

-- Yes. Customers who spend more per transaction, are churned more.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.2 Does poor support experience increase churn risk?
SELECT 
    CASE
        WHEN s.churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,
    COUNT(st.ticket_id) AS total_tickets,
    ROUND(AVG(st.resolution_days), 2) AS avg_resolution_time
FROM
    subscriptions s
        LEFT JOIN
    support_tickets st ON s.customer_id = st.customer_id
GROUP BY churn_status;

-- Not likely, but the churned rate due to poor support is also high. 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.3 Does payment behaviour influence customer churn?
SELECT 
    t.payment_method,
    CASE
        WHEN s.churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,
    COUNT(DISTINCT t.customer_id) AS customers
FROM
    transactions t
        JOIN
    subscriptions s ON t.customer_id = s.customer_id
GROUP BY t.payment_method , churn_status
ORDER BY customers DESC;

-- Yes, customers who use 'Card' are often followed by 'Wallet' and 'UPI'. On other hand 'UPI' shows more active customers.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.4 Do long-term customers churn less compared to short-tenure customers?
SELECT 
    CASE
        WHEN churn_flag = 1 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,
    ROUND(AVG(DATEDIFF(IFNULL(end_date, CURDATE()), start_date)),
            0) AS avg_tenure_days
FROM
    subscriptions
GROUP BY churn_status;

-- Yes, short-tenure customers with avg.512 tenure days are most likely churned.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.5 What are the top reasons customers churn?
SELECT 
    churn_reason, COUNT(*) AS churn_count
FROM
    subscriptions
WHERE
    churn_flag = 1
GROUP BY churn_reason
ORDER BY churn_count DESC;

-- 'Price' is the most common reason for churn(count = 60), followed by 'Support' and others(not defined).


-- =======================================================================================================================================================================
--                                         -: 4. Revenue & Value Impact Analysis :-                                       
-- =======================================================================================================================================================================
-- 4.1 How much revenue comes from Active vs Churned customers?
SELECT 
    s.churn_flag,
    COUNT(DISTINCT t.customer_id) AS customers,
    ROUND(SUM(t.amount), 2) AS total_revenue,
    ROUND(AVG(t.amount), 2) AS avg_transaction_value
FROM
    transactions t
        JOIN
    subscriptions s ON t.customer_id = s.customer_id
GROUP BY s.churn_flag;

-- Revenue from churned customers are more, suggesting churn customers were valuable.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.2 Do churned customers spend less before leaving?
SELECT 
    s.customer_id,
    s.churn_flag,
    ROUND(SUM(t.amount), 2) AS lifetime_revenue
FROM
    subscriptions s
        JOIN
    transactions t ON s.customer_id = t.customer_id
GROUP BY s.customer_id , s.churn_flag;

-- Yes, churned customers spend less before leaving. 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.3 Which subscription plans generate highest revenue?
SELECT 
    c.plan_type,
    ROUND(SUM(t.amount), 2) AS total_revenue,
    COUNT(DISTINCT t.customer_id) AS customers,
    ROUND(AVG(t.amount), 2) AS avg_transaction
FROM
    transactions t
        JOIN
    customers c ON t.customer_id = c.customer_id
GROUP BY c.plan_type
ORDER BY total_revenue DESC;

-- 'Basic' plans generate more revenue than any other plans but 2nd in generating average transactions.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.4 Are High-Value Customers Churning?
SELECT 
    churn_flag,
    ROUND(AVG(customer_revenue), 2) AS avg_customer_revenue,
    COUNT(*) AS total_customers,
    SUM(CASE
        WHEN revenue_category = 'High Value' THEN 1
        ELSE 0
    END) AS high_value_customers,
    SUM(CASE
        WHEN revenue_category = 'Medium Value' THEN 1
        ELSE 0
    END) AS medium_value_customers,
    SUM(CASE
        WHEN revenue_category = 'Low Value' THEN 1
        ELSE 0
    END) AS low_value_customers
FROM
    (SELECT 
        s.customer_id,
            s.churn_flag,
            SUM(t.amount) AS customer_revenue,
            CASE
                WHEN SUM(t.amount) > 5000 THEN 'High Value'
                WHEN SUM(t.amount) > 2000 THEN 'Medium Value'
                ELSE 'Low Value'
            END AS revenue_category
    FROM
        subscriptions s
    JOIN transactions t ON s.customer_id = t.customer_id
    GROUP BY s.customer_id , s.churn_flag) AS revenue_table
GROUP BY churn_flag
ORDER BY churn_flag;

-- Yes, our 'High Value' customers were churned.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.5 How much estimated revenue loss we faced from churn?
SELECT 
    ROUND(SUM(t.amount), 2) AS revenue_lost_due_to_churn
FROM
    transactions t
        JOIN
    subscriptions s ON t.customer_id = s.customer_id
WHERE
    s.churn_flag = 1;

-- We lost almost Rs.1585653 due to churn.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.6 Customer Lifetime Revenue Contribution
SELECT 
    s.customer_id,
    DATEDIFF(IFNULL(s.end_date, CURDATE()),
            s.start_date) AS lifetime_days,
    ROUND(SUM(t.amount), 2) AS lifetime_revenue
FROM
    subscriptions s
        JOIN
    transactions t ON s.customer_id = t.customer_id
GROUP BY s.customer_id , s.start_date , s.end_date
ORDER BY lifetime_revenue DESC
LIMIT 10;


-- =======================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================================================