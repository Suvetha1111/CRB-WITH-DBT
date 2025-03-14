
  create or replace   view CRBFITNESS.PUBLIC.revenue_lost
  
   as (
    SELECT 
    t.payment_month_clean AS period, 
    SUM(t.revenue) AS total_revenue_lost
FROM public.stg_transactions t
WHERE t.customer_id IN (
    SELECT customer_id 
    FROM public.stg_transactions 
    GROUP BY customer_id 
    HAVING MAX(payment_month_clean) < DATEADD(MONTH, -6, CURRENT_DATE)
)
GROUP BY t.payment_month_clean
ORDER BY t.payment_month_clean
  );

