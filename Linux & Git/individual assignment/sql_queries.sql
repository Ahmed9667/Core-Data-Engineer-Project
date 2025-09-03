--Find a list of order IDs where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.
select id from orders where gloss_qty > 4000 OR poster_qty > 4000;

--Find a list of order IDs where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.
select id from orders where gloss_qty > 4000 OR poster_qty > 4000;

--Write a query that returns a list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000.
select * from orders where standard_qty = 0 and gloss_qty > 1000 OR poster_qty > 1000;

--Find all the company names that start with a 'C' or 'W', and where the primary contact contains 'ana' or 'Ana', but does not contain 'eana'.
select name from accounts where name like 'C%' OR name like 'W%' and primary_poc like '%ana%' and primary_poc not like '%eana%'

--Provide a table that shows the region for each sales rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) by account name.
with table1 as (
select r.name as region_name , sr.name as sales_rep_name , a.name as account_name
from region r
join sales_reps sr
on r.id = sr.region_id
join accounts a
on sr.id = a.sales_rep_id
where a.account_name ASC)
select * from table1;