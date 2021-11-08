create database if not exists orders_directory ;
use orders_directory;

# 1) You are required to create tables for
# supplier,customer,category,product,productDetails,order,rating to store the data for
# the E-commerce with the schema definition given below

create table if not exists supplier(
SUPP_ID int primary key,
SUPP_NAME varchar(50) ,
SUPP_CITY varchar(50),
SUPP_PHONE varchar(10)
);

CREATE TABLE IF NOT EXISTS customer (
CUS_ID INT NOT NULL primary key,
CUS_NAME VARCHAR(20) NULL DEFAULT NULL,
CUS_PHONE VARCHAR(10),
CUS_CITY varchar(30) ,
CUS_GENDER CHAR
);

CREATE TABLE IF NOT EXISTS category (
CAT_ID INT NOT NULL primary key,
CAT_NAME VARCHAR(20) NULL DEFAULT NULL
);


CREATE TABLE IF NOT EXISTS product (
PRO_ID INT NOT NULL primary key,
PRO_NAME VARCHAR(20) NULL DEFAULT NULL,
PRO_DESC VARCHAR(60) NULL DEFAULT NULL,
CAT_ID INT NOT NULL,
FOREIGN KEY (CAT_ID) REFERENCES CATEGORY (CAT_ID)
);

CREATE TABLE IF NOT EXISTS product_details (
PROD_ID INT NOT NULL primary key,
PRO_ID INT NOT NULL,
SUPP_ID INT NOT NULL,
PROD_PRICE INT NOT NULL,
FOREIGN KEY (PRO_ID) REFERENCES PRODUCT (PRO_ID),
FOREIGN KEY (SUPP_ID) REFERENCES SUPPLIER(SUPP_ID)
);

CREATE TABLE IF NOT EXISTS order_details (
ORD_ID INT NOT NULL primary key,
ORD_AMOUNT INT NOT NULL,
ORD_DATE DATE,
CUS_ID INT NOT NULL,
PROD_ID INT NOT NULL,
FOREIGN KEY (CUS_ID) REFERENCES CUSTOMER(CUS_ID),
FOREIGN KEY (PROD_ID) REFERENCES PRODUCT_DETAILS(PROD_ID)
);

CREATE TABLE IF NOT EXISTS `rating` (
RAT_ID INT NOT NULL primary key,
CUS_ID INT NOT NULL,
SUPP_ID INT NOT NULL,
RAT_RATSTARS INT NOT NULL,
FOREIGN KEY (SUPP_ID) REFERENCES SUPPLIER (SUPP_ID),
FOREIGN KEY (CUS_ID) REFERENCES CUSTOMER(CUS_ID)
);

# 2)Insert the following data in the table created above
insert into supplier values (1, "Rajesh Retails", "Delhi", '1234567890');
insert into supplier values (2, "Appario Ltd.", "Mumbai", '2589631470');
insert into supplier values (3, "Knome products", "Banglore", '9785462315');
insert into supplier values (4, "Bansal Retails", "Kochi", '8975463285');
insert into supplier values (5, "Mittal Ltd.", "Lucknow", '7898456532');

insert into customer values (1, "AAKASH", '9999999999', "DELHI", "M");
insert into customer values (2, "AMAN", '9785463215', "NOIDA", "M");
insert into customer values (3, "NEHA", '9999999999', "MUMBAI", "F");
insert into customer values (4, "MEGHA", '9994562399', "KOLKATA", "F");
insert into customer values (5, "PULKIT", '7895999999', "LUCKNOW", "M");

insert into category values (1, "BOOKS");
insert into category values (2, "GAMES");
insert into category values (3, "GROCERIES");
insert into category values (4, "ELECTRONICS");
insert into category values (5, "CLOTHS");

insert into product values(1, "GTA V", "DFJDJFDJFDJFDJFJF", 2);
insert into product values(2, "TSHIRT", "DFDFJDFJDKFD", 5);
insert into product values(3, "ROG LAPTOP", "DFNTTNTNTERND", 4);
insert into product values(4, "OATS", "REURENTBTOTH", 3);
insert into product values(5, "HARRY POTTER", "NBEMCTHTJTH", 1);

insert into product_details values(1,1,2,1500);
insert into product_details values(2,3,5,30000);
insert into product_details values(3,5,1,3000);
insert into product_details values(4,2,3,2500);
insert into product_details values(5,4,1,1000);


# 3) Display the number of the customer group by their genders who have placed any order
# of amount greater than or equal to Rs.3000.

select count(c.CUS_GENDER), c.CUS_GENDER
from customer c 
join order_details o on c.CUS_ID = o.CUS_ID 
where o.ORD_AMOUNT>=3000 
group by c.CUS_GENDER;

# 4) Display all the orders along with the product name ordered by a customer having
# Customer_Id=2

select o.*, p.PRO_ID, p.PRO_NAME 
from order_details o
join product_details pd on o.PROD_ID = pd.PROD_ID 
join product p on pd.PRO_ID = p.PRO_ID 
where o.CUS_ID = 2;

# 5) Display the Supplier details who can supply more than one product.

select s.* 
from supplier s 
join product_details p on s.SUPP_ID = p.SUPP_ID
group by p.SUPP_ID
having count(p.SUPP_ID) > 1;

# 6) Find the category of the product whose order amount is minimum.

select ct.cat_name
from order_details od
join product_details pd on pd.prod_id=od.prod_id
join product p on p.pro_id=pd.pro_id
join category ct on p.cat_id=ct.cat_id
having min(od.ord_amount);

# 7) Display the Id and Name of the Product ordered after “2021-10-05”.

select p.PRO_ID, p.PRO_NAME 
from product p 
join product_details pd on p.PRO_ID = pd.PRO_ID 
join order_details od on pd.PROD_ID = od.PROD_ID 
where ORD_DATE > "2021-10-05";

# 8) Print the top 3 supplier name and id and their rating on the basis of their rating along
# with the customer name who has given the rating.

select s.supp_id, s.supp_name, r.rat_ratstars, c.cus_name
from rating r
join supplier s on s.supp_id=r.supp_id
join customer c on c.cus_id=r.cus_id
order by r.rat_ratstars desc limit 3;

# 9) Display customer name and gender whose names start or end with character 'A'.

select cus_name, cus_gender
from customer
where cus_name like '%A' or cus_name like 'A%';

# 10) Display the total order amount of the male customers.

select sum(od.ord_amount)
from order_details od
join customer c on c.cus_id=od.cus_id
where c.cus_gender='M';

# 11) Display all the Customers left outer join with the orders.

select * 
from customer c
left join order_details od on od.cus_id=c.cus_id;

# 12) Create a stored procedure to display the Rating for a Supplier if any along with the
# Verdict on that rating if any like if rating >4 then “Genuine Supplier” if rating >2 “Average
# Supplier” else “Supplier should not be considered”.

delimiter &&
create procedure display_rating()
begin
select s.supp_id, s.supp_name, r.rat_ratstars,
case
when r.rat_ratstars>4 then "Genuine Supplier"
when r.rat_ratstars>2 then "Average Supplier"
else "Supplier should not be considered"
end as Verdict
from rating r 
join supplier s on s.supp_id=r.supp_id;
end &&
call display_rating();
