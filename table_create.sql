
--Bank Table Creation
DROP TABLE IF EXISTS bank;

CREATE TABLE bank (
    branch_id INT PRIMARY KEY,
    city VARCHAR(50),
    region VARCHAR(50),
    firm_revenue NUMERIC(20,2),
    expenses NUMERIC(20,2),
    profit_margin NUMERIC(15,2)
);

select * from bank;

--customer Table create
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    age INT,
    customer_type VARCHAR(50),
    city VARCHAR(50),
    region VARCHAR(50),
    bank_name VARCHAR(100),
    branch_id INT,
	FOREIGN KEY (branch_id) REFERENCES bank(branch_id)
);

select * from customer;

--transaction table create

DROP TABLE IF EXISTS transaction_data;

CREATE TABLE transaction_data (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    total_balance NUMERIC(20,2),
    transaction_amount NUMERIC(20,2),
    investment_amount NUMERIC(20,2),
    investment_type VARCHAR(50),
    transaction_date DATE,
	foreign key(customer_id) REFERENCES customer(customer_id)
);

select * from transaction_data;
