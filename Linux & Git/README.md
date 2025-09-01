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
    echo "✅ File successfully loaded into $GOLD_DIR/"
else
    echo "❌ Error: File not loaded into $GOLD_DIR/"
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

-Add
```python
0 0 * * * /bin/bash /home/ahly/CoreDataEngineers/git_linux/etl_finance.sh >> /home/ahly/CoreDataEngineers/git_linux/logs/etl_log.txt 2>&1
```
