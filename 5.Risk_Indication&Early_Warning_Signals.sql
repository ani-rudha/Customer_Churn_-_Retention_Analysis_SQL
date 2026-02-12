-- =======================================================================================================================================================================
--                                         -: Step 5. Risk Indicators & Early Warning Signals :-                                       
-- =======================================================================================================================================================================
-- 5.1 Do customers with low transaction activity churn more?
SELECT 
    CASE
        WHEN txn_count >= 10 THEN 'High Activity'
        WHEN txn_count BETWEEN 5 AND 9 THEN 'Medium Activity'
        ELSE 'Low Activity'
    END AS activity_segment,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*), 2) AS churn_rate
FROM
    (SELECT 
        s.customer_id,
            s.churn_flag,
            COUNT(t.transaction_id) AS txn_count
    FROM
        subscriptions s
    LEFT JOIN transactions t ON s.customer_id = t.customer_id
    GROUP BY s.customer_id , s.churn_flag) activity_table
GROUP BY activity_segment;

-- Low Activity < Medium Activity, but the difference is very low. 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.2 Do customers with high support issues churn more?
SELECT 
    CASE
        WHEN ticket_count >= 5 THEN 'High Support Usage'
        WHEN ticket_count BETWEEN 2 AND 4 THEN 'Medium Support Usage'
        ELSE 'Low Support Usage'
    END AS support_segment,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*), 2) AS churn_rate
FROM
    (SELECT 
        s.customer_id,
            s.churn_flag,
            COUNT(st.ticket_id) AS ticket_count
    FROM
        subscriptions s
    LEFT JOIN support_tickets st ON s.customer_id = st.customer_id
    GROUP BY s.customer_id , s.churn_flag) support_table
GROUP BY support_segment;

-- Yes, High Support Usage = Maximum Churn Rate. Churned Order is High Support > Low Support > Medium Support.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.3 Do customers with longer issue resolution time churn more?
SELECT 
    CASE
        WHEN avg_resolution_days > 5 THEN 'Slow Resolution'
        ELSE 'Fast Resolution'
    END AS resolution_speed,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*), 2) AS churn_rate
FROM
    (SELECT 
        s.customer_id,
            s.churn_flag,
            AVG(st.resolution_days) AS avg_resolution_days
    FROM
        subscriptions s
    LEFT JOIN support_tickets st ON s.customer_id = st.customer_id
    GROUP BY s.customer_id , s.churn_flag) resolution_table
GROUP BY resolution_speed;

-- Yes, Fast Resolution > Slow Resolution.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.4 Do customers on certain plan types churn more?
SELECT 
    c.plan_type,
    COUNT(*) AS total_customers,
    SUM(s.churn_flag) AS churned_customers,
    ROUND(SUM(s.churn_flag) * 100.0 / COUNT(*), 2) AS churn_rate
FROM
    customers c
        JOIN
    subscriptions s ON c.customer_id = s.customer_id
GROUP BY c.plan_type
ORDER BY churn_rate DESC;

-- Basic > Standard/Premium in Churn Rate, but in case of Churned Customer; order is Basic > Standard > Premium.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.5 Are new customers more likely to churn?
SELECT 
    CASE
        WHEN
            DATEDIFF(COALESCE(end_date, CURDATE()),
                    start_date) <= 90
        THEN
            'Early Churn'
        ELSE 'Long-Term Customers'
    END AS customer_lifetime_segment,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*), 2) AS churn_rate
FROM
    subscriptions
GROUP BY customer_lifetime_segment;

-- Yes, although the count of customers are too small but churn rate is 100%
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =======================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================================================