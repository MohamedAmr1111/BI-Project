--Category Dim
create table CategoryDim(
	cid int primary key,
	cname varchar(50),
	product_unit VARCHAR(10) 
)

insert into CategoryDim
select 
	cid,
	cname,
	product_unit
from MarketSchema.category
----------------------------------------------------------------------------------------------
--Product Dim
create table ProductDim(
	pid int primary key,
	pname varchar(50),
	cost float ,
	price float,
	cid int,
	constraint cid foreign key (cid) references CategoryDim(cid)
)

insert into ProductDim
select 
	p.pid,
	p.pname,
	p.cost,
	p.price,
	c.cid
from CategoryDim c
inner join MarketSchema.product p
on p.cid = c.cid
----------------------------------------------------------------------------------------------
--PaymentDim
create table PaymentDim(
	payid int primary key,
	ptype varchar(10)
)

insert into PaymentDim
select * from FinanceSchema.payment
----------------------------------------------------------------------------------------------
--CustomerDim
create table CustomerDim(
	customerid int primary key,
	fullname varchar(100),
	phone varchar(11),
	caddress varchar(50)
)

insert into CustomerDim
select 
	customerid,
	CONCAT(fname ,' ',lname),
	phone,
	caddress
from MarketSchema.customer
----------------------------------------------------------------------------------------------
--DepartmentDim
create table DepartmentDim(
	did int primary key,
	dname varchar(100)
)

insert into DepartmentDim
select * from EmployeeSchema.department
----------------------------------------------------------------------------------------------
--EmployeeDim
create table EmployeeDim(
	eid int PRIMARY KEY,
	fullname varchar(100),
	phone varchar(11),
	eaddress varchar(50),
	age int ,
	salary float,
	commission float,
	NetSalary float,
	did int,
	constraint did foreign key (did) references DepartmentDim(did)
)

insert into EmployeeDim
select 
	emp_id,
	CONCAT(fname,' ',lname),
	phone,
	eaddress,
	age,
	salary,
	commission,
	Net_Salary,
	d.did
from EmployeeSchema.employee e
inner join DepartmentDim d
on d.did = e.did
----------------------------------------------------------------------------------------------
--TimeDim
create table TimeDim(
	tid int  IDENTITY(1,1) primary key,
	odate date,
	oyear varchar(4),
	omonth varchar(15),
	oday varchar(5)
)

insert into TimeDim
select
	odate,
	YEAR(odate),
	MONTH(odate),
	day(odate)
from MarketSchema.orders
----------------------------------------------------------------------------------------------
--FactSales
create table FactSales(
	id int identity(1,1) primary key,
	oid int,
	odate date,
	customerid int,
	empid int,
	payid int,
	pid int,
	discount FLOAT,
    quantity INT,
    total_price FLOAT,
	constraint fk_customerid  foreign key (customerid) references CustomerDim(customerid),
	constraint fk_payid  foreign key (payid) references PaymentDim(payid),
	constraint fk_empid  foreign key (empid) references EmployeeDim(eid),
	constraint fk_pid  foreign key (pid) references ProductDim(pid),
)

insert into FactSales
select 
	o.oid,
	o.odate,
	customerid,
	o.eid,
	o.payid,
	po.pid,
	SUM(po.discount) AS discount, 
    SUM(po.quantity) AS quantity,
	o.Total_Price
from MarketSchema.orders o 
inner join MarketSchema.product_order po 
on po.oid=o.oid
GROUP BY 
o.oid, o.odate, o.customerid, o.eid,po.pid, o.payid, o.Total_Price;
----------------------------------------------------------------------------------------------








