-- Active: 1721291050538@@127.0.0.1@3306@sakila
USE sakila;

--Step 1: Create a View
--First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW customer_rental_summary AS
SELECT cu.customer_id, CONCAT(cu.first_name, ' ', cu.last_name) AS name, cu.email, COUNT(r.rental_id) AS rental_count
FROM customer AS cu
JOIN rental as r
ON cu.customer_id = r.customer_id
GROUP BY cu.customer_id;

CREATE VIEW customer_rental_summary AS
SELECT cu.customer_id, CONCAT(cu.first_name, ' ', cu.last_name) AS name, cu.email, COUNT(r.rental_id) AS rental_count
FROM customer AS cu
JOIN rental AS r
ON cu.customer_id = r.customer_id
GROUP BY cu.customer_id
ORDER BY rental_count DESC;
--Step 2: Create a Temporary Table
--Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary
SELECT cs.customer_id, SUM(pa.amount) AS total_paid_amount
FROM csr AS cs
JOIN payment as pa
ON cs.customer_id = pa.customer_id
GROUP BY cs.customer_id;

CREATE TEMPORARY TABLE customer_payment_summary AS (
    SELECT crs.customer_id, SUM(pa.amount) AS total_paid
    FROM customer_rental_summary AS crs
    JOIN rental AS r ON crs.customer_id = r.customer_id
    JOIN payment AS pa ON r.rental_id = pa.rental_id
    GROUP BY crs.customer_id
);

SELECT * FROM Total_paid

--Step 3: Create a CTE and the Customer Summary Report
--Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
 
WITH cte_csr AS (
    SELECT 
        cu.customer_id, 
        CONCAT(cu.first_name, ' ', cu.last_name) AS name, 
        cu.email, 
        COUNT(r.rental_id) AS rental_count
    FROM 
        customer AS cu
    JOIN 
        rental AS r ON cu.customer_id = r.customer_id
    GROUP BY 
        cu.customer_id, cu.first_name, cu.last_name, cu.email
)
SELECT
    ct.name,
    ct.email,
    ct.rental_count, 
    tp.total_paid_amount
FROM 
    cte_csr AS ct
JOIN 
    customer_payment_summary AS tp ON ct.customer_id = tp.customer_id;

--Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary_report AS (
    SELECT 
        crs.name,
        crs.email,
        crs.rental_count,
        cps.total_paid_amount
    FROM 
        customer_rental_summary AS crs
        JOIN customer_payment_summary AS cps ON crs.customer_id = cps.customer_id
)
SELECT 
    *,
    total_paid_amount / rental_count AS average_payment_per_rental
FROM 
    customer_summary_report
ORDER BY 
    rental_count DESC;

    WITH customer_summary_report AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM 
        customer_rental_summary AS crs
        JOIN customer_payment_summary AS cps ON crs.customer_id = cps.customer_id)
SELECT 
    *,
    total_paid / rental_count AS average_payment_per_rental
FROM 
    customer_summary_report
ORDER BY 
    rental_count DESC;