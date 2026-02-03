-- =======================================================================================================================================================================
--                                                -: 7. Advanced Analysis :-
-- =======================================================================================================================================================================
-- 7.1 Customer Churn Risk Scoring
SELECT 
    s.customer_id,
    COUNT(t.transaction_id) AS txn_count,
    COUNT(st.ticket_id) AS ticket_count,
    SUM(t.amount) AS total_spend,
    (CASE
        WHEN COUNT(t.transaction_id) < 5 THEN 2
        ELSE 0
    END + CASE
        WHEN COUNT(st.ticket_id) >= 3 THEN 2
        ELSE 0
    END + CASE
        WHEN SUM(t.amount) < 300 THEN 1
        ELSE 0
    END) AS churn_risk_score
FROM
    subscriptions s
        LEFT JOIN
    transactions t ON s.customer_id = t.customer_id
        LEFT JOIN
    support_tickets st ON s.customer_id = st.customer_id
GROUP BY s.customer_id
ORDER BY churn_risk_score DESC;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.2 Convert Risk Score Into Risk Categories
SELECT 
    *,
    CASE
        WHEN churn_risk_score >= 4 THEN 'High Risk'
        WHEN churn_risk_score BETWEEN 2 AND 3 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM
    (SELECT 
        s.customer_id,
            (CASE
                WHEN COUNT(t.transaction_id) < 5 THEN 2
                ELSE 0
            END + CASE
                WHEN COUNT(st.ticket_id) >= 3 THEN 2
                ELSE 0
            END + CASE
                WHEN SUM(t.amount) < 300 THEN 1
                ELSE 0
            END) AS churn_risk_score
    FROM
        subscriptions s
    LEFT JOIN transactions t ON s.customer_id = t.customer_id
    LEFT JOIN support_tickets st ON s.customer_id = st.customer_id
    GROUP BY s.customer_id) risk_table;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.3 How Much Revenue Is At Risk?
SELECT 
    SUM(total_spend) AS revenue_at_risk
FROM
    (SELECT 
        s.customer_id,
            SUM(t.amount) AS total_spend,
            (CASE
                WHEN COUNT(t.transaction_id) < 5 THEN 2
                ELSE 0
            END + CASE
                WHEN COUNT(st.ticket_id) >= 3 THEN 2
                ELSE 0
            END + CASE
                WHEN SUM(t.amount) < 300 THEN 1
                ELSE 0
            END) AS risk_score
    FROM
        subscriptions s
    LEFT JOIN transactions t ON s.customer_id = t.customer_id
    LEFT JOIN support_tickets st ON s.customer_id = st.customer_id
    GROUP BY s.customer_id) risk_revenue
WHERE
    risk_score >= 4;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 7.4 Estimate Retention Campaign Value
SELECT 
    SUM(total_spend) * 0.25 AS potential_revenue_saved
FROM
    (SELECT 
        s.customer_id,
            SUM(t.amount) AS total_spend,
            (CASE
                WHEN COUNT(t.transaction_id) < 5 THEN 2
                ELSE 0
            END + CASE
                WHEN COUNT(st.ticket_id) >= 3 THEN 2
                ELSE 0
            END + CASE
                WHEN SUM(t.amount) < 300 THEN 1
                ELSE 0
            END) AS risk_score
    FROM
        subscriptions s
    LEFT JOIN transactions t ON s.customer_id = t.customer_id
    LEFT JOIN support_tickets st ON s.customer_id = st.customer_id
    GROUP BY s.customer_id) revenue_save
WHERE
    risk_score >= 4;


-- =======================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================================================