# pgbouncer_pkg
A wrapper around the pgbouncer show commands

# History
**pgbouncer_pkg** is an sql extension based on an extension from David Fetter, **pgbouncer_wrapper**, which was also based on an article ("Retrieving PgBouncer Statistics via dblink") by Peter Eisentraut.  It just simplifies the setup by just plopping 2 files in a cluster's extension directory.

# Overview
**pgbouncer_pkg** just contains the query show commands, not the commands that actually do stuff, like RELOAD, etc.  You just plop these two files in the PostgreSQL extension directory for a particular PG cluster that has pgbouncer in front of it.  Then create the extension.

# Assumptions
* It is based on pgbouncer version, 1.16.
* Only works with onprem PG clusters.
* pgbouncer PG role is already created.

# Instructions
Download 2 files to the PostgreSQL cluster's extension directory. NOTE: the owner of these files must be **root**.
* pgbouncer_pkg.control
* pgbouncer_pkg--1.16.0.sql

Run the **pg_config** command for the cluster to  find out the **SHAREDIR** location.  Then copy these to files to the **extension** directory under it.  It might look something like this:

* /usr/pgsql-9.6/share/extension

The extension is available to see with the following SQL command after you plop those 2 files in the extension directory.
```
select * from pg_available_extensions where name = 'pgbouncer_pkg';
     name      | default_version | installed_version |                          comment
---------------+-----------------+-------------------+-----------------------------------------------------------
 pgbouncer_pkg | 1.16.0          | 1.16.0            | Wrap pgbouncer output as a dblink from pgbouncer database

-- create the extension
CREATE EXTENSION pgbouncer_pkg CASCADE;
```

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
# Queries to detect serious conditions within PGBouncer

Show count of database/user connections that have sent queries but have not yet got a server connection.
* select count(*) from pgbouncer.pools where cl_waiting > 0;
* select database, user, cl_waiting from pgbouncer.pools where cl_waiting > 0;

Show databases whose current connections are within 5 of the max connections
* select count(*) from pgbouncer.databases where max_connections - current_connections < 6;
* select database, max_connections, current_connections from pgbouncer.databases where max_connections - current_connections < 6;

Show free clients and servers that are close to zero.
* select count(*) free_clients from pgbouncer.lists where list = 'free_clients' and items < 5;
* select count(*) free_servers from pgbouncer.lists where list = 'free_servers' and items < 5;

Show caches that are low in free memory.
* select name, size, free, round(round((free/size::decimal)::decimal,2) * 100) percent_free from pgbouncer.mem where  round(round((free/size::decimal)::decimal,2) * 100) < 10;

Join with pg_stat_activity to see pgbouncer relates stuff:
* select sa.pid, sa.state, s.user, s.database, s.state s_state, c.state c_state, c.addr as client_addr,  cast(EXTRACT(EPOCH FROM (s.request_time - s.connect_time)) as integer) as connsec, (case when sa.state <> 'active' then cast(EXTRACT(EPOCH FROM (now() - sa.state_change)) as integer) else -1 end) as idlesec,s.connect_time as s_conn_time, s.request_time as s_req_time,  s.wait as s_wait, s.wait_us as s_waitus, c.wait as c_wait, c.wait_us as c_waitus, s.close_needed as s_clneed, c.close_needed as c_clneed, substring(sa.query,1,30) as query FROM pgbouncer.servers s, pgbouncer.clients c, pg_stat_activity sa where s.link is not null and s.link = c.ptr and c.ptr is not null and s.remote_pid = sa.pid order by 2,8 limit 100;

