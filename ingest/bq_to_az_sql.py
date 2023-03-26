import os
from dotenv import load_dotenv
from google.cloud import bigquery
import pandas as pd
import pyodbc
import sqlalchemy


def bq_to_az_sql(table_name, schema_name, sql_table_name, sql_schema_name, bq_client, azsql_engine):
    query_job = bq_client.query(
        f"""
        select * from `{schema_name}.{table_name}`;
        """
    )
    df = query_job.to_dataframe()
    df.to_sql(name=sql_table_name, schema=sql_schema_name, con=azsql_engine, if_exists='replace', index=False)

# get variables from .env file
load_dotenv()
server = os.getenv('AZURE_SQL_SERVER_NAME')
database = os.getenv('AZURE_SQL_DB_NAME')
username = os.getenv('AZURE_SQL_ADMIN_USER')
password = os.getenv('AZURE_SQL_ADMIN_PWD')
driver = 'ODBC Driver 18 for SQL Server'

# connect to bigquery and azure sql 
client = bigquery.Client()
engine = sqlalchemy.create_engine(f'mssql+pyodbc://{username}:{password}@{server}/{database}?driver={driver}')


bq_to_az_sql('customers', 'dbt-tutorial.jaffle_shop', 'customers', 'jaffle_shop', client, engine)
bq_to_az_sql('orders', 'dbt-tutorial.jaffle_shop', 'orders', 'jaffle_shop', client, engine)
bq_to_az_sql('payment', 'dbt-tutorial.stripe', 'payment', 'stripe', client, engine)


# https://cloud.google.com/bigquery/docs/quickstarts/quickstart-client-libraries#client-libraries-install-python
# https://cloud.google.com/bigquery/docs/samples/bigquery-query-results-dataframe
# https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver16&tabs=alpine18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline
# https://learn.microsoft.com/en-us/azure/azure-sql/database/connect-query-python?view=azuresql
# https://pypi.org/project/python-dotenv/
# https://stackoverflow.com/questions/37692780/error-28000-login-failed-for-user-domain-user-with-pyodbc