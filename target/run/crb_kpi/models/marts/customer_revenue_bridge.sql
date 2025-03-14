
  create or replace   view CRBFITNESS.PUBLIC.customer_revenue_bridge
  
   as (
    WITH transaction_summary AS (
    SELECT 
        t.customer_id,
        c.customer_name_clean,
        p.product_family_clean,
        SUM(t.revenue) AS total_revenue,
        COUNT(DISTINCT t.payment_month) AS active_months,
        MIN(t.payment_month) AS first_transaction_month,
        MAX(t.payment_month) AS last_transaction_month
    FROM public.stg_transactions t
    LEFT JOIN public.stg_customers c ON t.customer_id = c.customer_id
    LEFT JOIN public.stg_products p ON t.product_id = p.product_id
    GROUP BY t.customer_id, c.customer_name_clean, p.product_family_clean
),

new_customers AS (
    SELECT 
        customer_id, 
        MIN(first_transaction_month) AS first_payment_month  
    FROM transaction_summary
    GROUP BY customer_id
),

churned_customers AS (
    SELECT 
        customer_id, 
        customer_name_clean,
        last_transaction_month
    FROM transaction_summary
    WHERE last_transaction_month < DATEADD(MONTH, -6, CURRENT_DATE)
),

cross_sell_customers AS (
    SELECT 
        customer_id, 
        customer_name_clean,
        COUNT(DISTINCT product_family_clean) AS unique_product_families
    FROM transaction_summary
    GROUP BY customer_id, customer_name_clean
    HAVING COUNT(DISTINCT product_family_clean) > 1
),

product_churn AS (
    SELECT 
        product_family_clean,
        COUNT(DISTINCT customer_id) AS customer_count,
        LAG(customer_count) OVER (
            PARTITION BY product_family_clean 
            ORDER BY first_transaction_month
        ) AS prev_customer_count,
        customer_count - LAG(customer_count) OVER (
            PARTITION BY product_family_clean 
            ORDER BY first_transaction_month
        ) AS customer_loss
    FROM transaction_summary
),

revenue_metrics AS (
    SELECT 
        SUM(CASE WHEN last_transaction_month >= DATEADD(YEAR, -1, CURRENT_DATE) THEN total_revenue ELSE 0 END) AS current_revenue,
        SUM(CASE WHEN first_transaction_month < DATEADD(YEAR, -1, CURRENT_DATE) THEN total_revenue ELSE 0 END) AS previous_revenue,
        (SUM(CASE WHEN last_transaction_month >= DATEADD(YEAR, -1, CURRENT_DATE) THEN total_revenue ELSE 0 END) * 1.0 /
         NULLIF(SUM(CASE WHEN first_transaction_month < DATEADD(YEAR, -1, CURRENT_DATE) THEN total_revenue ELSE 0 END), 0)) AS NRR,
        (SUM(CASE WHEN last_transaction_month >= DATEADD(YEAR, -1, CURRENT_DATE) THEN total_revenue ELSE 0 END) * 1.0 /
         NULLIF(SUM(CASE WHEN last_transaction_month >= DATEADD(YEAR, -1, CURRENT_DATE) THEN total_revenue ELSE 0 END), 0)) AS GRR
    FROM transaction_summary
),

lost_revenue AS (
    SELECT 
        SUM(total_revenue) AS lost_revenue
    FROM transaction_summary
    WHERE customer_id IN (SELECT customer_id FROM churned_customers)
),

ranked_products AS (
    SELECT 
        product_family_clean,
        SUM(total_revenue) AS product_revenue,
        RANK() OVER (ORDER BY SUM(total_revenue) DESC) AS revenue_rank
    FROM transaction_summary
    GROUP BY product_family_clean
),

ranked_customers AS (
    SELECT 
        customer_id,
        customer_name_clean,
        SUM(total_revenue) AS customer_revenue,
        RANK() OVER (ORDER BY SUM(total_revenue) DESC) AS revenue_rank
    FROM transaction_summary
    GROUP BY customer_id, customer_name_clean
)

SELECT * FROM new_customers
UNION ALL
SELECT * FROM churned_customers
UNION ALL
SELECT * FROM cross_sell_customers
UNION ALL
SELECT * FROM product_churn
UNION ALL
SELECT * FROM revenue_metrics
UNION ALL
SELECT * FROM lost_revenue
UNION ALL
SELECT * FROM ranked_products
UNION ALL
SELECT * FROM ranked_customers
  );

