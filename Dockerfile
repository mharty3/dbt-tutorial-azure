# https://discourse.getdbt.com/t/publishing-dbt-docs-from-a-docker-container/141
# Create a Dockerfile to server docs from a container
# It will clone a repo, install dbt, and serve docs checking the remote repo for changes every 10 minutes
# note it expects a profiles.yml file in the root of the repo on the machine that builds the image

FROM python:3.10

ARG user=michael
ARG organization=mharty3
ARG repo=dbt-tutorial-azure
ARG dbt_project_folder=jaffle_shop_tutorial
ARG homedir=/home/${user}

# requred for MS SQL Server or Azure SQL
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl unixodbc-dev \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18

# Non-root group & user creation
RUN groupadd -r ${user} && \
     useradd -r -m -g ${user} ${user} && \
    mkdir ${homedir}/.ssh

COPY entrypoint.sh ${homedir}/entrypoint.sh

# # Git
ENV REMOTE_REPO git@github.com:${organization}/${repo}.git
ENV REPO_DIR ${homedir}/${repo}
RUN apt-get update && apt-get install -y git
COPY .keys/id_rsa ${homedir}/.ssh/
RUN ssh-keyscan github.com >> ${homedir}/.ssh/known_hosts

# Permissions!
RUN chmod 0700 ${homedir}/.ssh
RUN chmod 0600 ${homedir}/.ssh/id_rsa
RUN chmod 0644 ${homedir}/.ssh/known_hosts
RUN chmod 0755 ${homedir}/entrypoint.sh
RUN chown -R ${user}:${user} ${homedir}/.ssh

# DBT!
RUN pip install -U pip
RUN pip install -U dbt-sqlserver
COPY profiles.yml ${homedir}/.dbt/

# # Prep for container execution
USER ${user}
WORKDIR ${homedir}
ENV DBT_PROJECT_DIR ${REPO_DIR}/${dbt_project_folder} 
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
