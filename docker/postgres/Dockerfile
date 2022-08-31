FROM postgres:13.3

COPY init.sql /docker-entrypoint-initdb.d/init.sql

# NOTE: We use the JSON array form to provide arguments to the entry point set by the base image.
CMD ["postgres", "-c", "max_connections=300", "-c", "log_min_messages=LOG"]
