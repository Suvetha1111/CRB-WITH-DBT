
  create or replace   view CRBFITNESS.PUBLIC.churned_new_customers
  
   as (
    SELECT 
    customer_id, 
    'new' AS customer_status, 
    MIN(payment_month_clean) AS first_transaction_month
FROM public.stg_transactions
GROUP BY customer_id
HAVING MIN(payment_month_clean) IS NOT NULL

UNION ALL

SELECT 
    customer_id, 
    'churned' AS customer_status, 
    MAX(payment_month_clean) AS last_transaction_month
FROM public.stg_transactions
GROUP BY customer_id
HAVING MAX(payment_month_clean) < DATEADD(MONTH, -6, CURRENT_DATE)
  );

