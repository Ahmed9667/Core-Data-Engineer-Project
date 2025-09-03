#task1

#extract
echo ">>> Step 1: Extracting file..."
mkdir -p $RAW_DIR
cp "$INPUT_FILE" "$RAW_DIR/"
if [ -f "$RAW_DIR/$INPUT_FILE" ]; then
    echo "File successfully saved in $RAW_DIR/"
else
    echo "Error: File not found in $RAW_DIR/"
    exit 1
fi

# transform
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

#load
echo ">>> Step 3: Loading data..."
mkdir -p $GOLD_DIR
cp "$TRANSFORMED_DIR/$OUTPUT_FILE" "$GOLD_DIR/"

if [ -f "$GOLD_DIR/$OUTPUT_FILE" ]; then
    echo "File successfully loaded into $GOLD_DIR/"
else
    echo "Error: File not loaded into $GOLD_DIR/"
    exit 1
fi

#Move JSON/CSV Files
echo ">>> Step 4: Moving all CSV and JSON files..."
mkdir -p $TARGET_DIR
mv *.csv *.json $TARGET_DIR/ 2>/dev/null

echo "All CSV and JSON files moved to $TARGET_DIR/"

echo ">>> ETL and Files move process are completed successfully"


#5.Cron Job Daily at 12:00 AM
#run
crontab -e

#add
0 0 * * * /bin/bash/home/ahly/CoreDataEngineers/git_linux/etl_finance.sh >> /home/ahly/CoreDataEngineers/git_linux/logs/etl_log.txt 2>&1

