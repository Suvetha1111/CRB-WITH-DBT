
  create or replace   view CRBFITNESS.PUBLIC.stg_products
  
   as (
    WITH raw AS ( 
    SELECT * FROM public.products
    WHERE product_id IS NOT NULL  -- Remove rows where product_id is NULL
      AND product_family IS NOT NULL -- Remove rows where product_family is NULL
)
SELECT 
    product_id,
    COALESCE(TRIM(LOWER(product_family)), 'Unknown') AS product_family_clean -- Handle NULLs
FROM raw
  );

