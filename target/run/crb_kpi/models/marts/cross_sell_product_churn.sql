
  create or replace   view CRBFITNESS.PUBLIC.cross_sell_product_churn
  
   as (
    SELECT 
    t.customer_id, 
    c.customer_name_clean, 
    p.product_family_clean, 
    COUNT(DISTINCT p.product_family_clean) AS cross_sell_count
FROM public.stg_transactions t
LEFT JOIN public.stg_customers c ON t.customer_id = c.customer_id
LEFT JOIN public.stg_products p ON t.product_id = p.product_id
GROUP BY t.customer_id, c.customer_name_clean, p.product_family_clean
ORDER BY cross_sell_count DESC
LIMIT 10
  );

