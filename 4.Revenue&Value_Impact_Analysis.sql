-- =======================================================================================================================================================================
--                                         -: Step 4. Revenue & Value Impact Analysis :-                                       
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