# pgbouncer_pkg
A wrapper around the pgbouncer show commands

# History
**pgbouncer_pkg** is an sql extension based on an extension from David Fetter, **pgbouncer_wrapper**, which was also based on an article ("Retrieving PgBouncer Statistics via dblink") by Peter Eisentraut.  It just simplifies stuff a bit.

# Overview
**pgbouncer_pkg** just contains the query show commands, not the commands that actually do stuff, like RELOAD, etc.  You just plop these two files in the PostgreSQL extension directory for a particular cluster.  Then create the extension.

# Assumptions
* It is based on pgbouncer version, 1.16.
* Only works with onprem PG clusters.
* pgbouncer PG role is already created.

# Instructions
Download 2 files to the PostgreSQL cluster's extension directory:
* pgbouncer_pkg.control
* pgbouncer_pkg--1.16.0.sql

Run the **pg_config** command for the cluster to  find out the **SHAREDIR** location.  Then copy these to files to the **extension** directory under it.  It might look something like this:

* /usr/pgsql-9.6/share/extension

# Examples
```
select * from pgbouncer.active_sockets;
select * from pgbouncer.clients;
select * from pgbouncer.config;
select * from pgbouncer.databases;
select * from pgbouncer.dns_hosts;
select * from pgbouncer.dns_zones;
select * from pgbouncer.fds;
select * from pgbouncer.lists;
select * from pgbouncer.mem;
select * from pgbouncer.pools;
select * from pgbouncer.servers;
select * from pgbouncer.sockets;
select * from pgbouncer.stats;
select * from pgbouncer.stats_averages;
select * from pgbouncer.stats_totals;
select * from pgbouncer.totals;
select * from pgbouncer.users;
select * from pgbouncer.version;
```

