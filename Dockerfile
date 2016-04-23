FROM postgres:9

MAINTAINER Jeremy PETIT "jeremy.petit@gmail.com"

# Default locale settings
ENV LANG en_US.UTF-8
ENV AREA "Europe"
ENV ZONE "Paris"

VOLUME ["/var/lib/borg/backups", "/var/lib/borg/cache", "/docker-entrypoint-initdb.d"]

# DEFAULT DATA PATHS
ENV DATA_VOL /var/lib/postgresql/data
ENV PGDATA /var/lib/postgresql/data/pg_data
ENV WAL_DIR /var/lib/postgresql/data/pg_wal_archive

# BORGBACKUP settings
ENV BORG_PASSPHRASE "changeme"
ENV BORG_REPO "/var/lib/borg/backups"
ENV BORG_CACHE_DIR "/var/lib/borg/cache"

# Prepare WAL archiving
RUN  mkdir -p /var/lib/postgresql/data/pg_wal_archive /docker-entrypoint-initdb.d \
	&& chmod -R 770 /var/lib/postgresql/data/pg_wal_archive /docker-entrypoint-initdb.d \
	&& chown -R postgres:postgres /var/lib/postgresql/data/pg_wal_archive /docker-entrypoint-initdb.d
# Disable default entrypoint and rename it "check-initdb"
RUN  sed -i '/^[\n|\t]*exec.*$/d' docker-entrypoint.sh \
	&& mv docker-entrypoint.sh /usr/local/bin/check-initdb
# Install borgbackup
RUN apt-get update && apt-get install -y --no-install-recommends curl \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl --silent --show-error --output "/usr/local/bin/borg" "https://github.com/borgbackup/borg/releases/download/1.0.2/borg-linux64" \
	&& chmod 755 "/usr/local/bin/borg"

# COPY scripts		
COPY bin/* /usr/local/bin/
COPY docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d-tmp/
RUN chmod +x /usr/local/bin/*

WORKDIR "$DATA_VOL"

ENTRYPOINT ["docker-entrypoint"]
CMD ["postgres"]