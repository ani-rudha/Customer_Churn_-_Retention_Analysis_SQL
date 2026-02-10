-- =======================================================================================================================================================================
--                                         -: Step 3. Customer Behaviour & Churn Risk Drivers :-                                       
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
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =======================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================================================