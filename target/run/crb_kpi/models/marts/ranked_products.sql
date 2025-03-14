
  create or replace   view CRBFITNESS.PUBLIC.ranked_products
  
   as (
    SELECT 
    p.product_family_clean, 
    SUM(t.revenue) AS total_revenue,
    RANK() OVER (ORDER BY SUM(t.revenue) DESC) AS revenue_rank
FROM public.stg_transactions t
LEFT JOIN public.stg_products p ON t.product_id = p.product_id
GROUP BY p.product_family_clean
ORDER BY total_revenue DESC
  );

