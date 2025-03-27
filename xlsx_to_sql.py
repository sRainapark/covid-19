import pandas as pd
from sqlalchemy import create_engine

# Database connection details
username = '...'
password = '...'
host = 'localhost'         # or your db host
port = '5432'              # default PostgreSQL port
database = '...'

engine = create_engine(f'postgresql://{username}:{password}@{host}:{port}/{database}')

# excel file paths
xlsx_files = {
    'covid_vaccinations': 'path1.xlsx',
    'covid_deaths': 'path2.xlsx'
}

for table_name, file_path in xlsx_files.items():
    print(f"Reading {file_path} into table '{table_name}'...")
    df = pd.read_excel(file_path)  # ← this line is fixed
    df.to_sql(table_name, engine, if_exists='replace', index=False)
    print(f"✓ Uploaded to {table_name}")