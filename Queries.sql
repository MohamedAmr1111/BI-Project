--Find the Top Product Categories by Total Sales above avg total price
select
	p.pname,
	c.cname,
	Sum(po.quantity * p.price) as "total price"
from MarketSchema.product p
inner join MarketSchema.category c
on p.cid = c.cid
inner join MarketSchema.product_order po
on po.pid = p.pid 
inner join MarketSchema.orders o
on o.oid = po.oid
group by  c.cname,p.pname 
having Sum(po.quantity * p.price) > (
	select Avg(total) from(
	select Sum(po.quantity * p.price) as total
	from MarketSchema.product p inner join MarketSchema.category c
	on p.cid = c.cid
	inner join MarketSchema.product_order po
	on po.pid = p.pid
	inner join MarketSchema.orders o
	on o.oid = po.oid
	group by c.cname , p.pname
	) as getavg
)
order by "total price" desc

----------------------------------------------------------
-- Get 10 Vendors Supplying the Cheapest Product
select
top(10) v.vname,
p.pname,
p.cost as "vendor cost"
from MarketSchema.vendor v inner join 
MarketSchema.vendor_product vp
on vp.vid = v.vid
inner join MarketSchema.product p
on p.pid = vp.pid
order by "vendor cost" asc
--Get Vendors Supplying the Cheapest Product
select 
v.vname,
p.pname,
p.cost as 'Vendor Cost'
from MarketSchema.vendor v inner join 
MarketSchema.vendor_product vp 
on vp.vid = v.vid
inner join MarketSchema.product p
on p.pid = vp.pid 
where p.cost = (select MIN(p.cost) from MarketSchema.product p)

-------------------------------------------------------------------------
--Create a Function to Calculate Profit Margin for a Product
create function ProfitMargin(@name varchar(50))
returns float
		begin 
			declare @profit_margin float
			select @profit_margin =  ROUND(((SUM(p.price) - SUM(p.cost)) / SUM(p.cost)) * 100, 2)
			from MarketSchema.product p 
			where p.pname = @name
			return @profit_margin
		end

-- Calling Function
select dbo.ProfitMargin('Iced Tea')

----------------------------------------------------------------------------------------
-- Trigger to make sure admin only have the permission to delete 
create trigger AdminOnlyDelete
on MarketSchema.product
instead of delete
as	
	select 'Not Allowed For User'+SUSER_NAME()

-- CHECK
delete from MarketSchema.product where pid = 1
select * from MarketSchema.product where pid = 1

-- Trigger on order
create trigger T_Orders
on MarketSchema.orders
after update
as 
	select * from inserted
	select * from deleted

--CHECK
update MarketSchema.orders
set payid = 2
where oid = 1
select * from MarketSchema.orders where oid = 1

-------------------------------------------------------------------------------------------
-- add column net salary in employee table
alter table EmployeeSchema.Employee
add Net_Salary float

--Iterate Through Employees to Calculate and Update Bonuses
declare c1 cursor
for select emp_id, salary , commission from EmployeeSchema.employee
for update 
declare @id int, @net_salary float ,@salary float,@commission float
open c1
FETCH c1 INTO @id, @salary, @commission;
while @@FETCH_STATUS = 0
	begin
		set @net_salary = @salary + @commission
		update EmployeeSchema.employee
		set Net_Salary = @net_salary
		where CURRENT of c1
		FETCH c1 INTO @id, @salary, @commission;
end;
close c1;
deallocate c1;
-- CHECK
select * from EmployeeSchema.employee where emp_id = 1
-------------------------------------------------------------------
-- update discount to be 0.02 on all product_order using cursor
declare c2 cursor
for select po.oid,po.pid,p.price 
from MarketSchema.product_order po inner join MarketSchema.product p
on po.pid=p.pid
for update 
declare @oid int, @pid int ,@discount float,@price int;
open c2
FETCH c2 INTO @oid, @pid, @price;
while @@FETCH_STATUS = 0
	begin
		set @discount = @price * 0.02
		update MarketSchema.product_order
		set discount = @discount
		where pid=@pid
		FETCH c2 INTO @oid, @pid,@price;
end;
close c2;
deallocate c2;

-- Another way update discount to be 0.02 on all product_order 
update MarketSchema.product_order 
set discount = subquery.price * 0.02
from (
	select 
	p.pid, 
	p.price,
	discount
	from MarketSchema.product p 
	inner join MarketSchema.product_order po
	on p.pid = po.pid
) as subquery
where product_order.pid = subquery.pid

-- CHECK
select * from MarketSchema.product
select * from MarketSchema.product_order

--------------------------------------------------------------------------------------------
-- Rank Employees by Sales Contribution
select * from (select o.eid ,CONCAT(e.fname,' ',e.lname) as fullname,SUM(total_price) AS total_price_sum
,ROW_NUMBER() over (order by Sum(total_price) desc) as RN
from MarketSchema.orders o inner join EmployeeSchema.employee e
on e.emp_id = o.eid
group by o.eid , e.fname,e.lname) as newtable 

-- Select top 1 to make sure
select o.eid ,CONCAT(e.fname,' ',e.lname) as fullname , SUM(total_price) as 'Top 1 Total_price'
from MarketSchema.orders o inner join EmployeeSchema.employee e
on e.emp_id = o.eid
group by o.eid ,e.fname ,e.lname
having SUM(total_price) = (SELECT MAX(total_price_sum) AS MaxTotalPrice
FROM (
    SELECT SUM(total_price) AS total_price_sum
    FROM MarketSchema.orders
    GROUP BY eid
) AS subquery)

-----------------------------------------------------------------------------------------
-- Find numbers of vendors for each product
select
newtable.pname,
sum(newtable.Vendors) as 'number of vendors for this product'
from 
(select 
	p.pname,
	Count(vp.vid) as "Vendors"
	from MarketSchema.product p
	inner join MarketSchema.vendor_product vp
	on p.pid = vp.pid
	inner join MarketSchema.vendor v
	on v.vid = vp.vid
	group by p.pname
) as newtable
group by newtable.pname

----------------------------------------------------------------------------------------------
-- Function to find vendors name for each product
alter function GetNames(@pname varchar(30))
returns table
as
return
	(
		select
		v.vname,
		p.pname
		from MarketSchema.vendor v 
		inner join MarketSchema.vendor_product vp
		on vp.vid = v.vid
		inner join MarketSchema.product p
		on p.pid = vp.pid
		where p.pname = @pname
		group by p.pname , v.vname
	)

-- CALLING		
select * from GetNames('tea')
----------------------------------------------------------------------------------------------
-- Create View vendor profit summary for each producr
create view VendorProfitSummary as
select
v.vname,
p.pname,
ROUND(((SUM(p.price) - SUM(p.cost)) / SUM(p.cost)) * 100, 2) as 'Profit Margin'
from MarketSchema.vendor v
inner join MarketSchema.vendor_product vp
		on vp.vid = v.vid
		inner join MarketSchema.product p
		on p.pid = vp.pid
group by v.vname,p.pname

-- CHECK
select * from VendorProfitSummary
----------------------------------------------------------------------------------------------
--Windowing Functions(LAG,LEAD)
SELECT emp_id, fname, lname, Net_Salary,
       PREV_FullName = CONCAT(PREV_fname, ' ', PREV_lname),
       PREV_NetSalary,
       NEX_FullName = CONCAT(NEX_fname, ' ', NEX_lname),
       NEX_NetSalary
FROM (
    SELECT emp_id, fname, lname, Net_Salary,
           LAG(fname) OVER (ORDER BY Net_Salary) AS PREV_fname,
           LAG(lname) OVER (ORDER BY Net_Salary) AS PREV_lname,
           LAG(Net_Salary) OVER (ORDER BY Net_Salary) AS PREV_NetSalary,
           LEAD(fname) OVER (ORDER BY Net_Salary) AS NEX_fname,
           LEAD(lname) OVER (ORDER BY Net_Salary) AS NEX_lname,
           LEAD(Net_Salary) OVER (ORDER BY Net_Salary) AS NEX_NetSalary
    FROM EmployeeSchema.employee
) AS newtable






























