SELECT 
    t.customer_id, 
    c.customer_name_clean, 
    SUM(t.revenue) AS total_revenue,
    RANK() OVER (ORDER BY SUM(t.revenue) DESC) AS revenue_rank
FROM public.stg_transactions t
LEFT JOIN public.stg_customers c ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.customer_name_clean
ORDER BY total_revenue DESC