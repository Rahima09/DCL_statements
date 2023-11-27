-- Create a new user
CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
-- Grant connection permission to the user
GRANT CONNECT ON DATABASE your_database_name TO rentaluser;

-- Grant SELECT permission for the customer table to rentaluser
GRANT SELECT ON customer TO rentaluser;

-- Check the permission by selecting all customers
SELECT * FROM customer;

-- Create a new user group
CREATE GROUP rental;
-- Add rentaluser to the rental group
GRANT rental TO rentaluser;

-- Grant INSERT and UPDATE permissions for the rental table to the rental group
GRANT INSERT, UPDATE ON rental TO rental;

-- Insert a new row and update an existing row in the rental table under the rental role
SET ROLE rental;
INSERT INTO rental (column1, column2) VALUES ('value1', 'value2');
UPDATE rental SET column1 = 'new_value' WHERE id = 1;
RESET ROLE;

-- Revoke INSERT permission for the rental table from the rental group
REVOKE INSERT ON rental FROM rental;

-- Try to insert new rows into the rental table (this action should be denied)
SET ROLE rental;
INSERT INTO rental (column1, column2) VALUES ('value3', 'value4');
RESET ROLE;

-- Create a personalized role for an existing customer
CREATE ROLE client_FirstName_LastName;
GRANT USAGE, SELECT ON payment TO client_FirstName_LastName;
GRANT USAGE, SELECT ON rental TO client_FirstName_LastName;
-- Replace FirstName and LastName with the actual customer's names

-- Configure row-level security for the personalized role
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment FORCE ROW LEVEL SECURITY;
ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental FORCE ROW LEVEL SECURITY;

-- Set the policy for accessing own data in the payment table
CREATE POLICY own_payment_policy ON payment FOR ALL TO client_FirstName_LastName USING (customer_id = current_user);

-- Set the policy for accessing own data in the rental table
CREATE POLICY own_rental_policy ON rental FOR ALL TO client_FirstName_LastName USING (customer_id = current_user);

-- Query to verify that the user sees only their own data
SET ROLE client_FirstName_LastName;
SELECT * FROM payment; -- Only see own payment data
SELECT * FROM rental; -- Only see own rental data
RESET ROLE;