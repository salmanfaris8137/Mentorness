use data_analayse;
UPDATE products
SET Product_Cost = REPLACE(Product_Cost, '$', ''),
    Product_Price = REPLACE(Product_Price, '$', '');
    
-- 1. What is the total sales revenue generated by each store?
SELECT 
    stores.Store_Name,
    sales.Store_ID,
    SUM(sales.Units * products.Product_Price) AS Total_Revenue
FROM 
    sales
JOIN 
    products ON sales.Product_ID = products.Product_ID
JOIN 
    stores ON sales.Store_ID = stores.Store_ID
GROUP BY 
    stores.Store_Name, sales.Store_ID;
    
-- 2. Which products are the top-selling in  
select 
	s.Product_ID,
    p.Product_Name,
	sum(s.Units) as total_Unit_Sold
from 
    sales s
join 
    Products p ON s.Product_ID = p.Product_ID
group by
    Product_ID,Product_Name
order by
     total_unit_sold desc limit 1;

-- 3. What is the sales performance by product category? 
SELECT 
    p.Product_Category,
    sum(s.Units) AS Total_Units_Sold
FROM 
    Sales s
JOIN 
    Products p ON s.Product_ID = p.Product_ID
GROUP BY 
    p.Product_Category
ORDER BY 
     Total_Units_Sold DESC;

-- 4. What are the current inventory levels for each product at each store?

select 
   p.Product_Category,
   sum(i.Stock_On_Hand) as current_stock
from 
    inventory i
join
     Products p ON i.Product_ID = p.Product_ID
group by 
     p.Product_Category
order by
      current_stock desc;
   
-- 5.How do monthly sales trends vary across different stores?
SELECT 
    s.Date,
    SUM(s.Units) AS Total_Units_Sold,
    n.Store_Name
FROM 
    sales s
JOIN 
    stores n ON n.Store_ID = s.Store_ID
GROUP BY 
    s.Date, n.Store_Name
ORDER BY 
    Total_Units_Sold DESC;

-- 6.Which stores have the highest and lowest sales performance?
SELECT
    s.Store_ID,
    SUM(s.Units) AS total_units_sold,
	SUM(s.Units * p.Product_Price) AS total_revenue
FROM
    sales s
JOIN 
    products p ON s.Product_ID = p.Product_ID
GROUP BY
    s.Store_ID
ORDER BY
    total_revenue DESC; 


-- 7. What is the profit margin for each product?
SELECT
    Product_ID,
    Product_Name,
    Product_Price AS selling_price,
    Product_Cost AS cost,
    Product_Price - Product_Cost / Product_Price * 100 AS profit_margin
FROM
    products;

-- 8.How are sales distributed across different cities?
SELECT
    st.Store_Location,
    SUM(s.Units) AS total_units_sold,
    SUM(s.Units * p.Product_Price)  AS total_revenue
FROM
    sales s
JOIN
    products p ON s.Product_ID = p.Product_ID
JOIN
    stores st ON s.Store_ID = st.Store_ID
GROUP BY
    st.Store_Location
ORDER BY
    total_revenue DESC; 
-- 9.Which products are out of stock in each store?
SELECT
    i.Store_ID,
    p.Product_Name
FROM
    inventory i
JOIN
    products p ON i.Product_ID = p.Product_ID
WHERE
    i.Stock_On_Hand = 0
ORDER BY
    i.Store_ID, p.Product_Name;

-- 10.How do sales vary by specific dates?
select * from products;
select * from sales;
SELECT Date, SUM(Units) AS Total_Units_Sold
FROM sales 
GROUP BY Date
ORDER BY Date;

-- 11.What is the average cost of products in each category?
select * from products;
describe products;
SELECT Product_Category, AVG(Product_Cost + 0) AS Average_Cost
FROM products
GROUP BY Product_Category;

-- 12.What is the sales growth over time for the entire company?
SELECT 
    s.Store_ID,
    SUM(s.Units * p.Product_Price) AS Total_Revenue,
    SUM(s.Units) AS Total_Units_Sold
FROM 
    sales s
JOIN 
    products p ON s.Product_ID = p.Product_ID
GROUP BY 
    s.Store_ID
ORDER BY 
    Total_Revenue DESC
LIMIT 5;

-- 13.How does the store open date affect sales performance?
   WITH SalesWithStoreAge AS (
   SELECT 
        s.Store_ID,
        DATEDIFF(sd.Date, s.Store_Open_Date) / 365.25 AS Store_Age_Years,  
        sd.Units
    FROM 
        stores s
    JOIN 
        sales sd ON s.Store_ID = sd.Store_ID
)
SELECT 
    CASE 
        WHEN Store_Age_Years < 1 THEN 'Less than 1 year'
        WHEN Store_Age_Years BETWEEN 1 AND 3 THEN '1-3 years'
        WHEN Store_Age_Years BETWEEN 3 AND 5 THEN '3-5 years'
        ELSE 'More than 5 years'
    END AS Store_Age_Group,
    SUM(Units) AS Total_Sales,
    AVG(Units) AS Avg_Sales
FROM 
    SalesWithStoreAge
GROUP BY 
    Store_Age_Group
ORDER BY 
    Store_Age_Group;

-- 14.What percentage of total sales does each store contribute?
WITH StoreSales AS (
    SELECT 
        Store_ID,
        SUM(Units) AS Store_Total_Sales
    FROM 
        sales
    GROUP BY 
        Store_ID
), TotalSales AS (
    SELECT 
        SUM(Units) AS Overall_Total_Sales
    FROM 
        sales
)

SELECT 
    s.Store_ID,
    s.Store_Total_Sales,
    (s.Store_Total_Sales / t.Overall_Total_Sales) * 100 AS Percentage_Contribution
FROM 
    StoreSales s
CROSS JOIN 
    TotalSales t
ORDER BY 
    Percentage_Contribution DESC;

-- 15.How do sales compare to current stock levels for each product?
WITH ProductSales AS (
    SELECT
        Product_ID,
        SUM(Units) AS Total_Units_Sold
    FROM
        sales
    GROUP BY
        Product_ID
)
SELECT
    p.Product_ID,
    p.Stock_On_Hand,
    ps.Total_Units_Sold,
    (p.Stock_On_Hand - ps.Total_Units_Sold) AS Stock_Remaining,
    CASE
        WHEN p.Stock_On_Hand - ps.Total_Units_Sold > 0 THEN 'In Stock'
        ELSE 'Out of Stock'
    END AS Stock_Status
FROM
    inventory p
LEFT JOIN
    ProductSales ps ON p.Product_ID = ps.Product_ID
ORDER BY
    Stock_Status DESC, p.Product_ID;
