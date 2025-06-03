{{ config(materialized = 'incremental', unique_key = 'orderID') }}

-- Ensure this model waits for load_product_landing to finish
{% set _ = ref('load_order_landing') %}

WITH source_data AS (
  SELECT 
    OrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    CURRENT_TIMESTAMP() AS CreatedDate  -- This will be overridden for updates later
  FROM {{ source('staging', 'order_landing') }}
),

-- Only for updates (existing rows)
updates AS (
  SELECT 
    s.OrderID,
    s.CustomerID,
    s.ProductID,
    s.OrderDate,
    s.Quantity,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    s.CreatedDate  -- preserve existing created date
  FROM source_data s
  JOIN {{ this }} AS existing
    ON s.orderID = existing.orderID
),

-- Only for inserts (new rows)
inserts AS (
  SELECT 
    s.OrderID,
    s.CustomerID,
    s.ProductID,
    s.OrderDate,
    s.Quantity,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    CURRENT_TIMESTAMP() AS CreatedDate
  FROM source_data s
  LEFT JOIN {{ this }} t
    ON s.orderID = t.orderID
  WHERE t.orderID IS NULL
)

SELECT * FROM updates
UNION ALL
SELECT * FROM inserts