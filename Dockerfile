FROM postgres:9

MAINTAINER Jeremy PETIT "jeremy.petit@gmail.com"

# -e LANG="fr_FR.UTF-8" -e AREA="Europe" -e ZONE="Paris" -e POSTGRES_PASSWORD=test -v ./vol_test/backups:/backups -v ./vol_test/pgdata:/var/lib/postgresql/data

ENV LANG en_US.UTF-8
ENV AREA 'Europe'
ENV ZONE 'Paris'

VOLUME ["/backups", "/docker-entrypoint-initdb.d"]

ENV DATA_VOL /var/lib/postgresql/data
ENV PGDATA /var/lib/postgresql/data/pg_data
ENV WAL_DIR /var/lib/postgresql/data/pg_wal_archive

RUN  mkdir -p /var/lib/postgresql/data/pg_wal_archive /docker-entrypoint-initdb.d \
	&& chmod -R 770 /var/lib/postgresql/data/pg_wal_archive /docker-entrypoint-initdb.d \
	&& chown -R postgres:postgres /var/lib/postgresql/data/pg_wal_archive /docker-entrypoint-initdb.d
RUN  sed -i '/^[\n|\t]*exec.*$/d' docker-entrypoint.sh \
	&& mv docker-entrypoint.sh /usr/local/bin/check-initdb
		
COPY bin/* /usr/local/bin/
COPY docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d-tmp/
RUN chmod +x /usr/local/bin/*

WORKDIR "$DATA_VOL"

ENTRYPOINT ["docker-entrypoint"]
CMD ["postgres"]