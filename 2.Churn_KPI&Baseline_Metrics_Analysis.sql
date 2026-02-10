-- =======================================================================================================================================================================
--                                            -: Step 2. Churn KPI & Baseline Metrics :-                                       
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
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =======================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================================================