{{ config(materialized = 'table') }}

SELECT o.*, c.firstname, c.lastname, p.description
FROM {{ ref('stage_order') }} o
JOIN {{ ref('stage_customer') }} c ON o.CustomerID = c.CustomerID
JOIN {{ ref('stage_product') }} p ON o.ProductID = p.ProductID