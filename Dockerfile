FROM postgres:12

RUN sed -i 's/$/ 10/' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends \
		postgresql-10=10.11-1.pgdg100+1 postgresql-10-postgis-2.5=2.5.3+dfsg-2.pgdg100+1 postgresql-12-postgis-2.5=2.5.3+dfsg-2.pgdg100+1 postgresql-12-postgis-3=3.0.0+dfsg-2~exp1.pgdg100+1 \
	&& rm -rf /var/lib/apt/lists/*

ENV PGBINOLD /usr/lib/postgresql/10/bin
ENV PGBINNEW /usr/lib/postgresql/12/bin

ENV PGDATAOLD /var/lib/postgresql/10/data
ENV PGDATANEW /var/lib/postgresql/12/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
	&& chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]
