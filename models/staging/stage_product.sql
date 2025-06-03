{{ config(materialized = 'incremental', unique_key = 'ProductID') }}

-- Ensure this model waits for load_product_landing to finish
{% set _ = ref('load_product_landing') %}

WITH source_data AS (
  SELECT 
    ProductID,
    Description,
    Code,
    Price,
    Discount,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    CURRENT_TIMESTAMP() AS CreatedDate  -- This will be overridden for updates later
  FROM {{ source('staging', 'product_landing') }}
),

-- Only for updates (existing rows)
updates AS (
  SELECT 
    s.ProductID,
    s.Description,
    s.Code,
    s.Price,
    s.Discount,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    s.CreatedDate  -- preserve existing created date
  FROM source_data s
  JOIN {{ this }} AS existing
    ON s.ProductID = existing.ProductID
),

-- Only for inserts (new rows)
inserts AS (
  SELECT 
    s.ProductID,
    s.Description,
    s.Code,
    s.Price,
    s.Discount,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    CURRENT_TIMESTAMP() AS CreatedDate
  FROM source_data s
  LEFT JOIN {{ this }} t
    ON s.ProductID = t.ProductID
  WHERE t.ProductID IS NULL
)

SELECT * FROM updates
UNION ALL
SELECT * FROM inserts