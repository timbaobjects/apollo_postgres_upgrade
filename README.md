Apollo 3 PostgreSQL/PostGIS upgrade utility
===========================================

This utility enables an administrator to upgrade an existing Apollo 3.0 database 
container using PostgreSQL 10 (and PostGIS 2.5) to the more recently used version 
PostgreSQL 12 (and PostGIS 3.0)

Usage
-----

A prebuilt version of this image can be downloaded at [timbaobjects/apollo_postgres_upgrade](https://hub.docker.com/r/timbaobjects/apollo_postgres_upgrade)

In order to use this utility, you would need to know the name for the database 
storage volume. In this example, `dev-elections_postgres_data` is the name used 
for the database storage volume.

If you apollo image repository is at the latest version, you'll need to checkout 
the version just before the upgrade. This would usually be the commit `e0f5dafb710adf19c41706dbcac8b6a067a15bb6`.

```
git checkout e0f5dafb710adf19c41706dbcac8b6a067a15bb6
```

If you have your container running, you'll need to shut it down:

```
docker-compose down
```

The next step will be to copy the database data volume to a new one called `pgdata10`.
Note the use of the volume name `dev-elections_postgres_data`. This should be 
whatever is in use by your own deployment. If in doubt, running `docker volume ls` 
should list all the volumes and you should be able to locate the postgres_data 
volume name.

```
docker run --rm -it -v dev-elections_postgres_data:/from -v pgdata10:/to alpine ash -c "cd /from; cp -av . /to"
```

After copying the volume data to another volume. We can safely delete the old volume. 
This will save us an additional step when upgrading the old container to the new one.

```
docker-compose down -v
```

This will stop the current deployment and then remove any of the existing volumes 
being used by the deployment.

Next is the actual upgrade itself:

```
docker run --rm -v pgdata10:/var/lib/postgresql/10/data:Z -v dev-elections_postgres_data:/var/lib/postgresql/12/data:Z timbaobjects/apollo_postgres_upgrade
```

This will upgrade the volume with the old PostgreSQL 10 database files to a new one 
based on PostgreSQL 12. It will also upgrade the PostGIS version as well. Note 
the use of the `dev-elections_postgres_data` volume name again. This should be 
modified to whatever is in use by your deployment.

On completion, checkout the latest version of Apollo 3.0 (or the tagged version) 
and then rebuild the containers.

```
git checkout develop
docker-compose up -d --build
```

