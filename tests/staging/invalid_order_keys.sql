-- Ensure all orders reference valid customers and products
SELECT *
FROM {{ ref('stage_order') }} o
LEFT JOIN {{ ref('stage_customer') }} c ON o.CustomerID = c.CustomerID
LEFT JOIN {{ ref('stage_product') }} p ON o.ProductID = p.ProductID
WHERE c.CustomerID IS NULL OR p.ProductID IS NULL