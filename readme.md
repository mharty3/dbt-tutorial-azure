
Follow the getting started with dbt core tutorial: 
https://docs.getdbt.com/docs/quickstarts/dbt-core/quickstart

Create venv:
* `python3 -m venv venv`
* `source venv/bin/activate` or if using fish: `source venv/bin/activate.fish`
* `pip install -U pip`
* `pip install -r requirements.txt`

Replicate data from big query to azure sql database:
* create GCP service account with big query user role
* download service account key json
* set environment variable GOOGLE_APPLICATION_CREDENTIALS to the path of the json file
* create azure sql database
* create azure sql server firewall rule to allow access from your ip address
* create .env file with connection info for azure sql database
* run ingest/bq_to_az.py to replicate data from big query to azure sql database
* confirm data is available using azure data studio

set up dbt project:
* create dbt profile for azure sql database in `~/.dbt/profiles.yml`
* create dbt project `dbt init`
* run `dbt debug` to verify dbt is set up correctly

perform first dbt run:
* run `dbt run` to create models in azure sql database

install dbt power user extension in vs code:
* to make the query results preview work with azure sql syntax, change the `Dbt: Query Template` setting for the extention to `{query} order by 1 OFFSET 0 ROWS FETCH FIRST {limit} ROWS ONLY`
* https://github.com/innoverio/vscode-dbt-power-user/blob/master/README.md#dbtquerytemplate-for-ms-sql
