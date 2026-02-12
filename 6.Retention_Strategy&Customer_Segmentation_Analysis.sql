-- =======================================================================================================================================================================
--                                         -: Step 6. Retention Strategy & Customer Segmentation :-                                       
-- =======================================================================================================================================================================
-- 6.1 Can We Classify Customers Into Risk Segments?
SELECT 
    s.customer_id,
    COUNT(t.transaction_id) AS txn_count,
    COUNT(st.ticket_id) AS ticket_count,
    CASE
        WHEN
            COUNT(t.transaction_id) < 5
                AND COUNT(st.ticket_id) >= 3
        THEN
            'High Risk'
        WHEN COUNT(t.transaction_id) BETWEEN 5 AND 9 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_segment
FROM
    subscriptions s
        LEFT JOIN
    transactions t ON s.customer_id = t.customer_id
        LEFT JOIN
    support_tickets st ON s.customer_id = st.customer_id
GROUP BY s.customer_id;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.2 Which Risk Segment Contains Most Churned Customers?
SELECT 
    risk_segment,
    COUNT(*) AS total_customers,
    SUM(churn_flag) AS churned_customers,
    ROUND(SUM(churn_flag) * 100.0 / COUNT(*), 2) AS churn_rate
FROM
    (SELECT 
        s.customer_id,
            s.churn_flag,
            CASE
                WHEN
                    COUNT(t.transaction_id) < 5
                        AND COUNT(st.ticket_id) >= 3
                THEN
                    'High Risk'
                WHEN COUNT(t.transaction_id) BETWEEN 5 AND 9 THEN 'Medium Risk'
                ELSE 'Low Risk'
            END AS risk_segment
    FROM
        subscriptions s
    LEFT JOIN transactions t ON s.customer_id = t.customer_id
    LEFT JOIN support_tickets st ON s.customer_id = st.customer_id
    GROUP BY s.customer_id , s.churn_flag) risk_table
GROUP BY risk_segment
ORDER BY churn_rate DESC;

-- Churned customer order is Low Risk > Medium Risk > High Risk.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.3 Which Segment Generates Highest Revenue?
SELECT 
    risk_segment, SUM(total_spend) AS segment_revenue
FROM
    (SELECT 
        s.customer_id,
            SUM(t.amount) AS total_spend,
            CASE
                WHEN
                    COUNT(t.transaction_id) < 5
                        AND COUNT(st.ticket_id) >= 3
                THEN
                    'High Risk'
                WHEN COUNT(t.transaction_id) BETWEEN 5 AND 9 THEN 'Medium Risk'
                ELSE 'Low Risk'
            END AS risk_segment
    FROM
        subscriptions s
    LEFT JOIN transactions t ON s.customer_id = t.customer_id
    LEFT JOIN support_tickets st ON s.customer_id = st.customer_id
    GROUP BY s.customer_id) revenue_table
GROUP BY risk_segment
ORDER BY segment_revenue DESC;

-- The Order is Low Risk > Medium Risk > Low risk.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.4 Which Customers Should Retention Teams Target First?
SELECT 
    c.plan_type,
    SUM(t.amount) AS total_spend_by_plan,
    COUNT(DISTINCT s.customer_id) AS customer_count,
    AVG(t.amount) AS avg_spend_per_customer,
    SUM(st.ticket_count) AS total_tickets,
    AVG(st.ticket_count) AS avg_tickets_per_customer
FROM
    subscriptions s
        JOIN
    customers c ON s.customer_id = c.customer_id
        JOIN
    (SELECT 
        customer_id, SUM(amount) AS amount
    FROM
        transactions
    GROUP BY customer_id
    HAVING SUM(amount) > 500) t ON s.customer_id = t.customer_id
        JOIN
    (SELECT 
        customer_id, COUNT(ticket_id) AS ticket_count
    FROM
        support_tickets
    GROUP BY customer_id
    HAVING COUNT(ticket_id) >= 3) st ON s.customer_id = st.customer_id
WHERE
    s.churn_flag = 0
GROUP BY c.plan_type
ORDER BY total_spend_by_plan DESC;

-- Retention Teams should target 'Standers' plan_type customers first.
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =======================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =======================================================================================================================================================================