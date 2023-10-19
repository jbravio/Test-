import requests
import json
import psycopg


# Define the URL of the COVID-19 data source
data_source_url = 'https://opendata.ecdc.europa.eu/covid19/nationalcasedeath/json/'

# Connect to the PostgreSQL database
conn = psycopg.connect("dbname=covid_data user=postgres password=Maremans@23")
cursor = conn.cursor()

try:
    # Fetch the JSON data from the source
    response = requests.get(data_source_url)
    data = response.json()
	
	
	# Find the maximum 'year_week' value in the JSON data
    max_year_in_json = max(record['year_week'] for record in data)	

    # Query the database to find the maximum 'year_week' value that was inserted
    cursor.execute("SELECT MAX(year_week) FROM covid_data")
    max_year_in_db = cursor.fetchone()[0]

    if max_year_in_json > max_year_in_db:
        # If a new version is available, insert the new records
      #  new_records = [record for record in data if record['year_week'] > max_year_in_db]

        
        for record in data:
            # Check for missing columns and replace them with None if necessary
            for column in ['country', 'country_code', 'continent', 'population', 'indicator', 'weekly_count', 'year_week', 'rate_14_day', 'cumulative_count', 'source', 'note']:
                if column not in record:
                    record[column] = None
                
            # Define the insert query
            
            insert_query = """
            INSERT INTO covid_data (country, country_code, continent, population, indicator, weekly_count, year_week, rate_14_day, cumulative_count, source, note)
            VALUES (%(country)s, %(country_code)s, %(continent)s, %(population)s, %(indicator)s, %(weekly_count)s, %(year_week)s, %(rate_14_day)s, %(cumulative_count)s, %(source)s, %(note)s);
            """
            
            # Insert the record into the database
            cursor.execute(insert_query, record)
       

        # Commit the changes to the database
        conn.commit()
    
    else:
        print("No new data available.")

except Exception as e:
    print(f"Error: {e}")

finally:
    # Close the cursor and database connection
    cursor.close()
    conn.close()