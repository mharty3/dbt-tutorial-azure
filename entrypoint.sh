#!/usr/bin/env bash
git clone $REMOTE_REPO
cd $DBT_PROJECT_DIR
dbt deps 
dbt docs generate --target dev 
dbt docs serve > /dev/null 2>&1 &
while [ True ]
do
    sleep 600
    if [ `git rev-parse --short HEAD` != `git rev-parse --short origin/master` ]; then
        git fetch --all
        git reset --hard origin/master 
        dbt deps --profiles-dir .
        dbt docs generate --target prod --profiles-dir .
    fi
done