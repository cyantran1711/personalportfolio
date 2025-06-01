
--1. List product information including the following fields: product_id, product_name, brand_name, category_name, model_year, and list_price.

select	a.product_id, 
		a.product_name, 
		b.brand_name, 
		c.category_name, 
		a.model_year, 
		a.list_price
from production.products a 
	join production.brands b on a.brand_id = b.brand_id
	join production.categories c on a.category_id = c.category_id
	
--2. Calculate the number of products in each category (in row format) using aggregate functions.

select a.category_name, count(b.category_id) as SoLuongSanPham
from production.categories a right join production.products b 
	on a.category_id=b.category_id
group by a.category_name

--3. Calculate the number of products in each category displayed as columns (using pivot).
/*If PIVOT is not allowed (assuming SQL Server is not used), how would you write this query alternatively?*/

/*Approach 1*/
create table #Temp_SoLuongSP(
	category_name NVARCHAR(4000),
	SoLuongSanPham INT);

Insert into #Temp_SoLuongSP
select a.category_name, count(b.category_id) as SoLuongSanPham
from production.categories a join production.products b 
	on a.category_id=b.category_id
group by b.category_id, a.category_name;

select * from #Temp_SoLuongSP

select *
from #Temp_SoLuongSP 
	PIVOT
(
	sum(SoLuongSanPham) 
	for category_name in([Children Bicycles],
						[Comfort Bicycles],
						[Cruisers Bicycles],
						[Cyclocross Bicycles],
						[Electric Bikes],
						[Mountain Bikes],
						[Road Bikes])
) as PivotSoLuongSP; 

/*Approach 2*/

select * 
from (select a.category_name, b.product_id
		from production.categories a inner join production.products b
		on a.category_id = b.category_id
	) as dataset
PIVOT(count(product_id)
		For	category_name in ([Children Bicycles],
						[Comfort Bicycles],
						[Cruisers Bicycles],
						[Cyclocross Bicycles],
						[Electric Bikes],
						[Mountain Bikes],
						[Road Bikes])
	) as PivotTable

/*Approach 3*/
select *
from 
(select a.category_name, count(b.category_id) as SoLuongSanPham
	from production.categories a join production.products b
	on a.category_id=b.category_id
	group by a.category_name
	) as dataset
PIVOT(sum(SoLuongSanPham)
		for category_name in ([Children Bicycles],
						[Comfort Bicycles],
						[Cruisers Bicycles],
						[Cyclocross Bicycles],
						[Electric Bikes],
						[Mountain Bikes],
						[Road Bikes])
	) as PivotTable

/*If PIVOT is not allowed (assuming SQL Server is not used)*/

SELECT
    count(CASE WHEN a.category_name = 'Children Bicycles' THEN 1 end) AS Children_Bicycles,
    count(CASE WHEN a.category_name = 'Comfort Bicycles' THEN 1 end) AS Comfort_Bicycles,
    count(CASE WHEN a.category_name = 'Cruisers Bicycles' THEN 1 end) AS Cruisers_Bicycles,
	count(CASE WHEN a.category_name = 'Cyclocross Bicycles' THEN 1 end) AS Cyclocross_Bicycles,
    count(CASE WHEN a.category_name = 'Electric Bikes' THEN 1 end) AS Electric_Bikes,
	count(CASE WHEN a.category_name = 'Mountain Bikes' THEN 1 end) AS Mountain_Bikes,
	count(CASE WHEN a.category_name = 'Road Bikes' THEN 1 end) AS Road_Bikes
FROM production.categories a join production.products b
	on a.category_id=b.category_id



--4. Calculate the number of products by model_year within each category using a two-dimensional pivot table.
/*If the company adds new product categories, how can the pivot query automatically adapt without manually updating category codes?*/
/*Approach 1*/
select * 
from (select a.category_name, b.product_id, b.model_year
		from production.categories a inner join production.products b
		on a.category_id = b.category_id
	) as dataset
PIVOT(count(product_id)
		For	category_name in ([Children Bicycles],
						[Comfort Bicycles],
						[Cruisers Bicycles],
						[Cyclocross Bicycles],
						[Electric Bikes],
						[Mountain Bikes],
						[Road Bikes])
	) as PivotTable
	
/*Approach 2*/
select	Chil.NumberOfProducts as [Children Bicycles],
		Com.NumberOfProducts as [Comfort Bicycles],
		Cru.NumberOfProducts as [Cruisers Bicycles],
		Cyc.NumberOfProducts as [Cyclocross Bicycles],
		Ele.NumberOfProducts as [Electric Bikes],
		Mou.NumberOfProducts as [Mountain Bikes],
		Roa.NumberOfProducts as [Road Bikes]
from 
	(select a.category_name, count(b.product_id) as NumberOfProducts
		from production.categories a inner join production.products b
		on a.category_id = b.category_id and a.category_name = 'Children Bicycles'
		group by a.category_name
	) Chil
	
	,(select a.category_name, count(b.product_id) as NumberOfProducts 
		from production.categories a inner join production.products b
		on a.category_id = b.category_id and a.category_name = 'Comfort Bicycles'
		group by a.category_name
	) Com

	,(select a.category_name, count(b.product_id) as NumberOfProducts 
		from production.categories a inner join production.products b
		on a.category_id = b.category_id and a.category_name = 'Cruisers Bicycles'
		group by a.category_name
	) Cru

	,(select a.category_name, count(b.product_id) as NumberOfProducts 
		from production.categories a inner join production.products b
		on a.category_id = b.category_id and a.category_name = 'Cyclocross Bicycles'
		group by a.category_name
	) Cyc

	,(select a.category_name, count(b.product_id) as NumberOfProducts 
		from production.categories a inner join production.products b
		on a.category_id = b.category_id and a.category_name = 'Electric Bikes'
		group by a.category_name
	) Ele

	,(select a.category_name, count(b.product_id) as NumberOfProducts 
		from production.categories a inner join production.products b
		on a.category_id = b.category_id and a.category_name = 'Mountain Bikes'
		group by a.category_name
	) Mou

	,(select a.category_name, count(b.product_id) as NumberOfProducts 
		from production.categories a inner join production.products b
		on a.category_id = b.category_id and a.category_name = 'Road Bikes'
		group by a.category_name
	) Roa


--5. Based on the database and available data, what insights or information do you think can be extracted?
--•	Number of products and Sales value following: Store, staff, customer, category, brand, model
--•	Customer category following: product, brand, location, discount
--•	Shipped days following: product, location, store
