import psycopg
import json

# Connect to the PostgreSQL database
conn = psycopg.connect("dbname=covid_data user=postgres password=Maremans@23")


# Open the JSON file and parse its contents
with open('covid_data.json', 'r') as file:
    data = json.load(file)

# Create a cursor
cur = conn.cursor()

# Loop through the JSON data and insert it into the database
for entry in data:
    insert_query = """
    INSERT INTO covid_data (country, country_code, continent, population, indicator, weekly_count, year_week, rate_14_day, cumulative_count, source, note)
    VALUES (%(country)s, %(country_code)s, %(continent)s, %(population)s, %(indicator)s, %(weekly_count)s, %(year_week)s, %(rate_14_day)s, %(cumulative_count)s, %(source)s, %(note)s);
    """
    
    # Check for missing columns and replace them with None if necessary
    for column in ['country', 'country_code', 'continent', 'population', 'indicator', 'weekly_count', 'year_week', 'rate_14_day', 'cumulative_count', 'source', 'note']:
        if column not in entry:
            entry[column] = None
    
    cur.execute(insert_query, entry)
    
# Commit the changes and close the cursor and connection
conn.commit()
cur.close()
conn.close()

print("Data inserted successfully.")