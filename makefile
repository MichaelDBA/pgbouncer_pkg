# Makefile for pgbouncer_pkg PostgreSQL extension
EXTENSION    = pgbouncer_pkg
# This is a SQL-only extension, so no C source files (MODULES is empty)
MODULES      =
# List all SQL script files that constitute the extension's versions
# PGXS will handle copying these to the correct location.
DATA         = $(EXTENSION)--1.24.0.sql

# If your extension creates its own dedicated schema,
# specify it here. PGXS will make sure it's created if missing
# and associated with the extension.
# WARNING: If schema is specified here, DROP EXTENSION will drop the schema too.
# To keep schema after dropping extension, create it manually first, then use
# CREATE EXTENSION pgbouncer_pkg SCHEMA your_persistent_schema;
# in SQL, *not* by specifying it here in the Makefile.
# For this example, we will let the extension create the schema.
# SCHEMA       = pgbouncer

# Include the standard PGXS Makefile infrastructure.
# This line *must* be the last non-comment line in your Makefile.
PG_CONFIG    = pg_config
PGXS         := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)