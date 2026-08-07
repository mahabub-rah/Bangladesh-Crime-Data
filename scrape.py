from selenium import webdriver
from selenium.webdriver.common.by import By
import time
import pandas as pd
import requests
from google import genai
import os
from sqlalchemy import create_engine, text
import json
from dotenv import load_dotenv
from collections import OrderedDict


# Read variables
load_dotenv()
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
API_KEY = os.getenv("API_KEY")

# MySQL connection
engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# Gemini Client
client = genai.Client(api_key=API_KEY)

#set varibales
last_updated = '2026-07-07 00:00:00' 
last_updated_dt = pd.to_datetime(last_updated)
download_url = None
json_file = None

#call the url
driver = webdriver.Chrome()  
driver.get('https://www.police.gov.bd/en/january_2020')
time.sleep(5)  

rows = driver.find_elements(By.XPATH, '//table/tbody/tr')

for row in rows:
    cells = row.find_elements(By.TAG_NAME, 'td')
    if len(cells) >= 4:
        date_text = cells[3].text.strip()        
        try:
            date_dt = pd.to_datetime(date_text, format='%d-%m-%Y')
            if date_dt >last_updated_dt:
                download_link_element = cells[5].find_element(By.TAG_NAME, 'a')
                download_url = download_link_element.get_attribute('href')
                last_updated_dt = date_dt  
                break
        except Exception as e:
            print(f"Error parsing date '{date_text}': {e}")
driver.quit()

#get the response
response = requests.get(download_url)
if response.status_code == 200:
    with open (f'crime_data_{last_updated_dt.strftime("%Y-%m-%d")}.pdf', 'wb') as f:
        f.write(response.content)

# Upload PDF
uploaded = client.files.upload(
    file=f"crime_data_{last_updated_dt.strftime('%Y-%m-%d')}.pdf"
)

# Wait until the file is ready
while uploaded.state.name == "PROCESSING":
    print("Processing PDF...")
    time.sleep(2)
    uploaded = client.files.get(name=uploaded.name)

if uploaded.state.name != "ACTIVE":
    raise RuntimeError(f"File is not ready: {uploaded.state.name}")

prompt = """
Extract every row from the crime statistics table.

Return ONLY valid JSON.

Schema:

[
 {
   "year":2025,
   "month":"December",
   "unit":"",
   "dacoity":0,
   "robbery":0,
   "murder":0,
   "speedy_trial":0,
   "riot":0,
   "woman_child_repression":0,
   "kidnapping":0,
   "police_assault":0,
   "burglary":0,
   "theft":0,
   "other_cases":0,
   "recovery_cases":0,
   "total_cases":0
 }
]
"""

# Retry on temporary server errors
for attempt in range(5):
    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[uploaded, prompt]
        )
        t = response.text
        t = t.replace("```json", "").replace("```", "").strip()
        json_file_name = f"crime_data_{last_updated_dt.strftime('%Y-%m-%d')}.json"
        with open(json_file_name, "w", encoding="utf-8") as f:
            f.write(t)
        break

    except Exception as e: 
        print(f"Attempt {attempt + 1} failed: {e}")

        if attempt == 4:
            raise

        time.sleep(2 ** attempt)


# Read JSON 
filename = f"crime_data_{last_updated_dt.strftime('%Y-%m-%d')}.json"

with open(filename, "r", encoding="utf-8") as f:
    data = json.load(f)

# for write the in sql
def append_sql_file(data, sql_path=f'month_{last_updated_dt.year}.sql'):
    if not data:
        return

    groups = OrderedDict()
    for row in data:
        key = (row["year"], row["month"])
        groups.setdefault(key, []).append(row)

    columns = [
        "year", "month", "unit", "dacoity", "robbery", "murder",
        "speedy_trial", "riot", "woman_child_repression", "kidnapping",
        "police_assault", "burglary", "theft", "other_cases",
        "recovery_cases", "total_cases"
    ]

    blocks = []
    for (year, month), rows in groups.items():
        header = f"-- Insert {month} {year} data"
        insert_line = f"INSERT INTO crime_data ({', '.join(columns)}) VALUES"

        value_lines = []
        for row in rows:
            vals = []
            for col in columns:
                v = row.get(col, 0)
                if isinstance(v, str):
                    v = v.replace("'", "''")  # escape quotes
                    vals.append(f"'{v}'")
                else:
                    vals.append(str(v))
            value_lines.append(f"({', '.join(vals)})")

        block = f"\n\n{header}\n{insert_line}\n" + ",\n".join(value_lines) + ";\n"
        blocks.append(block)

    with open(sql_path, "a", encoding="utf-8") as f:
        f.write("\n\n".join(blocks) + "\n\n")

    print(f"SQL statements appended to {sql_path}")

# Append to the running .sql
append_sql_file(data)


# Parameterized SQL
sql = text("""
INSERT INTO crime_data (
    year, month, unit, dacoity, robbery, murder, speedy_trial,
    riot, woman_child_repression, kidnapping, police_assault,
    burglary, theft, other_cases, recovery_cases
)
VALUES (
    :year, :month, :unit, :dacoity, :robbery, :murder,
    :speedy_trial, :riot, :woman_child_repression,
    :kidnapping, :police_assault, :burglary,
    :theft, :other_cases, :recovery_cases
)
""")

# Insert all rows into database
with engine.begin() as conn:
    conn.execute(sql, data)



df = pd.read_json(f"crime_data_{last_updated_dt.strftime('%Y-%m-%d')}.json")
df_crime = pd.read_csv('crime_data.csv')
updated_df = pd.concat([df_crime, df], ignore_index=True)
updated_df = updated_df.drop_duplicates() #drop duplicated
# Save 
updated_df.to_csv("crime_data.csv", index=False)
print("CSV updated successfully.")

#clear file
for file in [
    f"crime_data_{last_updated_dt.strftime('%Y-%m-%d')}.json",
    f"crime_data_{last_updated_dt.strftime('%Y-%m-%d')}.pdf"
]:
    if os.path.exists(file):
        os.remove(file)
print(f"last_updated_dt: {last_updated_dt}")