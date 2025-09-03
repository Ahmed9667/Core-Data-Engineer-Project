## First Task:

### Step 1: Extract (save raw CSV file into raw/)
### Step 2: Transform (rename column, select columns)
### Step 3: Load (save transformed file into gold/)
### Step 4: Move all CSV/JSON files into json_and_CSV/

##### Environmental Variables

```python
RAW_DIR="raw"
TRANSFORMED_DIR="transformed"
GOLD_DIR="gold"
TARGET_DIR="json_and_CSV"
INPUT_FILE="annual-enterprise-survey-2023-financial-year-provisional.csv"
OUTPUT_FILE="2023_year_finance.csv"
```

##### 1.Extract

```python
echo ">>> Step 1: Extracting file..."
mkdir -p $RAW_DIR
cp "$INPUT_FILE" "$RAW_DIR/"
if [ -f "$RAW_DIR/$INPUT_FILE" ]; then
    echo "File successfully saved in $RAW_DIR/"
else
    echo "Error: File not found in $RAW_DIR/"
    exit 1
fi
```

##### 2.Transform
Use awk to:
- Replace 'Variable_code' with 'variable_code'
- Select columns: year, Value, Units, variable_code

```python
awk -F',' 'NR==1 {
    for (i=1; i<=NF; i++) {
        if ($i=="Variable_code") $i="variable_code"
        col[$i]=i
    }
    print "year,Value,Units,variable_code"
}
NR>1 {
    print $(col["year"])","$(col["Value"])","$(col["Units"])","$(col["variable_code"])
}' "$RAW_DIR/$INPUT_FILE" > "$TRANSFORMED_DIR/$OUTPUT_FILE"

if [ -f "$TRANSFORMED_DIR/$OUTPUT_FILE" ]; then
    echo "Transformed file successfully saved in $TRANSFORMED_DIR/"
else
    echo "Error: Transformation failed."
    exit 1
fi
```

##### 3.Load

```python
echo ">>> Step 3: Loading data..."
mkdir -p $GOLD_DIR
cp "$TRANSFORMED_DIR/$OUTPUT_FILE" "$GOLD_DIR/"

if [ -f "$GOLD_DIR/$OUTPUT_FILE" ]; then
    echo "File successfully loaded into $GOLD_DIR/"
else
    echo "Error: File not loaded into $GOLD_DIR/"
    exit 1
fi

```

##### 4.Move JSON/CSV Files

```python
echo ">>> Step 4: Moving all CSV and JSON files..."
mkdir -p $TARGET_DIR
mv *.csv *.json $TARGET_DIR/ 2>/dev/null

echo "All CSV and JSON files moved to $TARGET_DIR/"

echo ">>> ETL and Files move process are completed successfully"
```

##### 5.Cron Job Daily at 12:00 AM

- Run
```python
crontab -e
```

- Add
```python
0 0 * * * /bin/bash /home/ahly/CoreDataEngineers/git_linux/etl_finance.sh >> /home/ahly/CoreDataEngineers/git_linux/logs/etl_log.txt 2>&1
```
# =====================================

## Second Task

##### Write a Bash script that iterates over and copies each of the CSV files into a PostgreSQL database (name the database posey

```python
psql -d "$DB_NAME" --quiet -c "
    DROP TABLE IF EXISTS accounts, orders, region, sales_reps, web_events CASCADE;
"
if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to the database or drop tables."
    exit 1
fi
echo "Dropped existing tables."
```

##### Create the tables

```python
psql -d "$DB_NAME" --quiet -c "
    CREATE TABLE region (
        id INT PRIMARY KEY,
        name VARCHAR(255)
    );

    CREATE TABLE sales_reps (
        id INT PRIMARY KEY,
        name VARCHAR(255),
        region_id INT REFERENCES region(id)
    );

    CREATE TABLE accounts (
        id INT PRIMARY KEY,
        name VARCHAR(255),
        website VARCHAR(255),
        lat NUMERIC,
        long NUMERIC,
        primary_poc VARCHAR(255),
        sales_rep_id INT REFERENCES sales_reps(id)
    );
    
    CREATE TABLE web_events (
        id INT PRIMARY KEY,
        account_id INT REFERENCES accounts(id),
        occurred_at TIMESTAMP,
        channel VARCHAR(255)
    );

    CREATE TABLE orders (
        id INT PRIMARY KEY,
        account_id INT REFERENCES accounts(id),
        occurred_at TIMESTAMP,
        standard_qty INT,
        gloss_qty INT,
        poster_qty INT,
        total INT,
        standard_amt_usd NUMERIC,
        gloss_amt_usd NUMERIC,
        poster_amt_usd NUMERIC,
        total_amt_usd NUMERIC
    );
"

echo "Tables created successfully."
```

##### Import data from each CSV file using the \copy command for security and efficiency.

```python
psql -d "$DB_NAME" --quiet -c "\copy region FROM '${FILES_PATH}/region.csv' DELIMITER ',' CSV HEADER;"
psql -d "$DB_NAME" --quiet -c "\copy sales_reps FROM '${FILES_PATH}/sales_reps.csv' DELIMITER ',' CSV HEADER;"
psql -d "$DB_NAME" --quiet -c "\copy accounts FROM '${FILES_PATH}/accounts.csv' DELIMITER ',' CSV HEADER;"
psql -d "$DB_NAME" --quiet -c "\copy web_events FROM '${FILES_PATH}/web_events.csv' DELIMITER ',' CSV HEADER;"
psql -d "$DB_NAME" --quiet -c "\copy orders FROM '${FILES_PATH}/orders.csv' DELIMITER ',' CSV HEADER;"

if [ $? -eq 0 ]; then
    echo "Data import complete. All files have been successfully copied into the '${DB_NAME}' database."
else
    echo "Error: Data import failed. Please check the file paths and permissions."
    exit 1
fi
```

##### SQL Queries:

###### Find a list of order IDs where either gloss_qty or poster_qty is greater than 4000. Only include the id field in the resulting table.

```python
select id from orders where gloss_qty > 4000 OR poster_qty > 4000;
```

###### Write a query that returns a list of orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000.

```python
select * from orders where standard_qty = 0 and gloss_qty > 1000 OR poster_qty > 1000;
```

###### Find all the company names that start with a 'C' or 'W', and where the primary contact contains 'ana' or 'Ana', but does not contain 'eana'.

```python
select name from accounts where name like 'C%' OR name like 'W%' and primary_poc like '%ana%' and primary_poc not like '%eana%'
```

######  Provide a table that shows the region for each sales rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) by account name.

```python
with table1 as (
select r.name as region_name , sr.name as sales_rep_name , a.name as account_name
from region r
join sales_reps sr
on r.id = sr.region_id
join accounts a
on sr.id = a.sales_rep_id
where a.account_name ASC)
select * from table1;
```
