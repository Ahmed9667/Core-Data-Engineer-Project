#Write a Bash script that iterates over and copies each of the CSV files into a PostgreSQL database (name the database posey
psql -d "$DB_NAME" --quiet -c "
    DROP TABLE IF EXISTS accounts, orders, region, sales_reps, web_events CASCADE;
"
if [ $? -ne 0 ]; then
    echo "Error: Failed to connect to the database or drop tables."
    exit 1
fi
echo "Dropped existing tables."

#Create the tables
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

#mport data from each CSV file using the \copy command for security and efficiency.

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

