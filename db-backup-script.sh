#!/bin/bash -x

###################################################
# First Bash Shell script to execute psql command
###################################################


# Set variables
HOST=""
PORT=""
USERNAME=""
DATABASE=""
PASSWORD=''
DB_DUMP_FILE=""

EXCLUDE_TABLES=(test)

export PGPASSWORD=$PASSWORD;
# Execute pg_dump command
pg_dump -h $HOST -p $PORT -U $USERNAME -d org > $DB_DUMP_FILE

# Check if pg_dump was successful
if [ $? -eq 0 ]; then
  echo "Database dump successful. Output file: $DB_DUMP_FILE"
else
  echo "Error: Database dump failed."
fi

# Set the database RESTORE connection parameters
RESTORE_HOST=""
RESTORE_PORT=""
RESTORE_USERNAME=""
RESTORE_PASSWORD=''
RESTORE_DATABASE=""


INPUT_FILE=$DB_DUMP_FILE

# Define variables
RESTORE_DATABASE_NAME="org_`date +%d%m%Y`"
# RESTORE_DATABASE_NAME=$DB_DUMP_FILE


export PGPASSWORD=$RESTORE_PASSWORD;
# Execute the SQL command using psql
psql -h $RESTORE_HOST -p $RESTORE_PORT -U $RESTORE_USERNAME -d org -c "CREATE DATABASE $RESTORE_DATABASE_NAME;"

# Check if the command executed successfully
if [ $? -eq 0 ]; then
  echo "Database $RESTORE_DATABASE_NAME created successfully."
else
  echo "Error: Failed to create database $RESTORE_DATABASE_NAME."
  echo "Recreating database $RESTORE_DATABASE_NAME"
  psql -h $RESTORE_HOST -p $RESTORE_PORT -U $RESTORE_USERNAME -d org -c "DROP DATABASE $RESTORE_DATABASE_NAME;"
  psql -h $RESTORE_HOST -p $RESTORE_PORT -U $RESTORE_USERNAME -d org -c "CREATE DATABASE $RESTORE_DATABASE_NAME;"
fi

# Execute psql command for database restoration
psql -h $RESTORE_HOST -p $RESTORE_PORT -U $RESTORE_USERNAME -d $RESTORE_DATABASE_NAME < $INPUT_FILE

# Check if psql command was successful
if [ $? -eq 0 ]; then
  echo "Database restoration successful."
else
  echo "Error: Database restoration failed."
fi

echo "Truncating data from unrequired tables..."
for each_table in ${EXCLUDE_TABLES[@]}
do
    sleep 1s
    echo "Truncating table $each_table"
    # psql -h $RESTORE_HOST -p $RESTORE_PORT -U $RESTORE_USERNAME -d $RESTORE_DATABASE_NAME -c "DROP TABLE if exists $each_table cascade"
    psql -h $RESTORE_HOST -p $RESTORE_PORT -U $RESTORE_USERNAME -d $RESTORE_DATABASE_NAME -c "TRUNCATE $each_table CASCADE;"
    echo "Table $each_table truncated..."
done

echo "Database $RESTORE_DATABASE_NAME restored successfully..." 