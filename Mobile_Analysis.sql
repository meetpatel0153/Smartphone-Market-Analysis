-- Project  : Mobile Phones Market Analysis
-- Author   : Meet Patel
-- Date     : 6/1/2026

create database mobile
use mobile

-- check data
select * from mobiles_cleaned

-- all samsung phones
select * from mobiles_cleaned
where Brand = 'Samsung'

-- top 5 expensive phones
select top 5 * from mobiles_cleaned
order by Price desc

-- top 5 cheapest phones
select top 5 * from mobiles_cleaned
order by Price asc

-- total brands
select count(distinct Brand) as Total_Brands from mobiles_cleaned

-- cheapest and most expensive
select min(Price) as Cheapest_Phone, max(Price) as Most_Expensive_Phone
from mobiles_cleaned

-- total models per brand
select Brand, count(*) as Total_Models
from mobiles_cleaned
group by Brand
order by Total_Models desc

-- most expensive phone by name
select Name, max(Price) as Max_Price
from mobiles_cleaned
group by Name
order by Max_Price desc

-- phones by price category
select Price_Category, count(*) as No_of_Phones
from mobiles_cleaned
group by Price_Category
order by No_of_Phones desc

-- phones from popular brands
select Brand, Name, Price_Category
from mobiles_cleaned
where Brand in ('Samsung', 'Nokia', 'Xiaomi', 'Motorola')
order by Brand

-- top 5 samsung phones by battery
select top 5 Brand, Name, max(Battery_mAh) as Max_Battery
from mobiles_cleaned
where Brand = 'Samsung'
group by Brand, Name
order by Max_Battery desc

-- top 5 apple phones by storage
select top 5 Brand, Name, max(Storage_GB) as Max_Storage
from mobiles_cleaned
where Brand = 'Apple'
group by Brand, Name
order by Max_Storage desc

-- classify phones by ram
select Brand, Name, RAM_GB,
    case 
        when RAM_GB >= 12 then 'High End'
        when RAM_GB >= 6  then 'Mid Range'
        else 'Basic'
    end as RAM_Label
from mobiles_cleaned
order by RAM_Label desc

-- phones above average price
select Name, Brand, Price
from mobiles_cleaned
where Price > (select avg(Price) from mobiles_cleaned)
order by Price asc

-- rank phones by price within each brand
select Brand, Name, Price,
    rank() over (partition by Brand order by Price desc) as Price_Rank
from mobiles_cleaned

-- create view for flagship phones
create view Premium_Phones as
select Brand, Name, Price, RAM_GB, Storage_GB, Battery_mAh
from mobiles_cleaned
where Price_Category = 'Flagship (>80k)'

select * from Premium_Phones
order by Price desc

-- create brand info table
create table brand_info (
    Brand        varchar(100),
    Country      varchar(100),
    Founded_Year int
)

insert into brand_info values ('Samsung',  'South Korea', 1969)
insert into brand_info values ('Apple',    'USA',         1976)
insert into brand_info values ('Nokia',    'Finland',     1865)
insert into brand_info values ('Xiaomi',   'China',       2010)
insert into brand_info values ('Motorola', 'USA',         1928)
insert into brand_info values ('OnePlus',  'China',       2013)
insert into brand_info values ('Realme',   'China',       2018)
insert into brand_info values ('Vivo',     'China',       2009)
insert into brand_info values ('Oppo',     'China',       2004)
insert into brand_info values ('Sony',     'Japan',       1946)

-- join phones with brand country
select distinct m.Brand, m.Name, m.Price, b.Country
from mobiles_cleaned m
inner join brand_info b on m.Brand = b.Brand
order by m.Brand desc

-- total models and avg price by country
select b.Country, count(distinct m.Brand) as Total_Brands,
       count(m.Name) as Total_Models, round(avg(m.Price), 0) as Avg_Price
from mobiles_cleaned m
inner join brand_info b on m.Brand = b.Brand
group by b.Country
order by Total_Models desc

-- compare each phone price to its brand average
with Avg_By_Brand as (
    select Brand, round(avg(Price), 0) as Avg_Price
    from mobiles_cleaned
    group by Brand
)
select m.Brand, m.Name, m.Price, a.Avg_Price,
       m.Price - a.Avg_Price as Diff_From_Avg
from mobiles_cleaned m
join Avg_By_Brand a on m.Brand = a.Brand
order by Diff_From_Avg desc

-- stored procedure to search phones by brand
create procedure GetPhonesByBrand @Brand varchar(100)
as
    select Name, Price, RAM_GB, Storage_GB, Battery_mAh
    from mobiles_cleaned
    where Brand = @Brand
    order by Price desc

exec GetPhonesByBrand 'Samsung'
exec GetPhonesByBrand 'Apple'
exec GetPhonesByBrand 'Nokia'
