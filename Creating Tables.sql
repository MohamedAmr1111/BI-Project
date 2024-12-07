CREATE SCHEMA MarketSchema
CREATE SCHEMA EmployeeSchema
CREATE SCHEMA FinanceSchema

create table EmployeeSchema.employee(
	eid int IDENTITY(1,1) PRIMARY KEY,
	fname varchar(20) NOT NULL,
	lname varchar(20) NOT NULL,
	phone varchar(11) UNIQUE NOT NULL,
	eaddress varchar(50) default 'cairo',
	age int check(age>20),
	salary float check(salary>=7000),
	commission float check(commission between 500 and 1500),
	did int,
	constraint did foreign key (did) references EmployeeSchema.department(did)
)


create table EmployeeSchema.department(
	did int primary key,
	dname varchar(100) NOT NULL
)

create table MarketSchema.vendor(
	vid int primary key,
	vname varchar(30) NOT NULL,
	vphone varchar(11) UNIQUE NOT NULL
)

create table MarketSchema.category(
	cid int primary key,
	cname varchar(50) NOT NULL,
	product_unit VARCHAR(10) CHECK (product_unit IN ('Weight', 'Piece')) NOT NULL
)

create table MarketSchema.product(
	pid int primary key,
	pname varchar(50),
	cost float CHECK(cost > 0),
	price float CHECK(price > 0),
	quantity int,
	cid int,
	constraint cid foreign key (cid) references MarketSchema.category(cid)
)

create table MarketSchema.vendor_product(
	vid int,
	pid int,
	constraint vid foreign key (vid) references MarketSchema.vendor(vid),
	constraint pid foreign key (pid) references MarketSchema.product(pid)
)

create table MarketSchema.product_order(
	oid int,
	pid int,
	discount float,
	constraint fk_product_order_oid  foreign key (oid) references MarketSchema.orders(oid),
	constraint fk_product_order_pid  foreign key (pid) references MarketSchema.product(pid)
)

create table MarketSchema.customer(
	customerid int primary key,
	fname varchar(20),
	lname varchar(20),
	phone varchar(11),
	caddress varchar(50)
)

create table MarketSchema.orders(
	oid int primary key,
	odate date,
	customerid int,
	payid int,
	emp int,
	constraint customerid foreign key (customerid) references MarketSchema.customer(customerid),
	constraint payid foreign key (payid) references FinanceSchema.payment(payid),
	constraint eid foreign key (eid) references EmployeeSchema.employee(emp_id)
)

create table FinanceSchema.payment(
	payid int primary key,
	ptype varchar(10) NOT NULL
)

alter table MarketSchema.orders
add Total_Price float


-- update quantity column to be in product_order table
alter table MarketSchema.orders
add Total_Price float

update po
set po.quantity = o.quantity
from MarketSchema.orders o inner join 
MarketSchema.product_order po
on po.oid = o.oid

alter table MarketSchema.orders
drop column quantity

-- calculate total price per order
UPDATE o
SET o.total_price = subquery.TotalPrice
FROM MarketSchema.orders o
INNER JOIN (
    SELECT po.oid, SUM(p.price * po.quantity) AS TotalPrice
    FROM MarketSchema.product p
    INNER JOIN MarketSchema.product_order po
        ON p.pid = po.pid
    GROUP BY po.oid
) AS subquery
    ON o.oid = subquery.oid;
	

ALTER TABLE MarketSchema.product_order
ADD CONSTRAINT pk_product_order PRIMARY KEY (oid, pid)

ALTER TABLE MarketSchema.orders
DROP CONSTRAINT eid;

ALTER TABLE MarketSchema.orders
ADD emp_id INT;

ALTER TABLE MarketSchema.orders
ADD CONSTRAINT FK_emp_id FOREIGN KEY (emp_id) REFERENCES EmployeeSchema.employee(emp_id);


