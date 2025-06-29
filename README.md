# pgbouncer_pkg
A wrapper around the pgbouncer show commands

# History
**pgbouncer_pkg** is an sql extension based on an extension from David Fetter, [pgbouncer_wrapper](https://github.com/davidfetter/pgbouncer_wrapper), which was also based on an article ([Retrieving PgBouncer Statistics via dblink](https://peter.eisentraut.org/blog/2015/03/25/retrieving-pgbouncer-statistics-via-dblink)) by Peter Eisentraut.  The latest version handles PGBouncer version 1.24, although you could download older versions instead.

# Overview
**pgbouncer_pkg** converts the PGBouncer SHOW commands into PG views on the PG server.  It only contains query views, not anything that would actually update PGBouncer, like RELOAD, etc.  For instance, "select * from pgbouncer.pools;".  The neat thing about this functionality is that you can now join these PGBouncer views with the pg_stat_activity table to actually see what SQL statement a PGBouncer connection transaction is running.

# Assumptions
* It is based on pgbouncer version, 1.16, 1.18, 1.21, or 1.24
* Only works with onprem PG clusters.
* pgbouncer PG role is already created.
* the password for the pgbouncer role needs to be changed in the SQL file prior to the installation.

# Instructions
Download the zip file or the git project file.  Assuming it's the zip file and as the root user do the following:
* wget https://github.com/MichaelDBA/pgbouncer_pkg/archive/refs/heads/main.zip
* unzip main.zip
* cd pgbouncer_pkg-main
* You need to change the password for pgbouncer (user mapping command) in the SQL file you are using.  Right now it is set to "pgpass".  Change that to what your PG user password is for the pgbouncer role.
* make PG_CONFIG=/usr/pgsql-17/bin/pg_config install  
Note that I am pointing to a specific pg_config file which you have to do if you have multiple versions of PG on your machine. By default, it will install the latest version, 1.24.0.  If you want an older version, modify the **pgbouncer_pkg.control** file accordingly before running the **make install**. At this point, the extension should be available to that PG server.  
```
select * from pg_available_extensions where name = 'pgbouncer_pkg';
     name      | default_version | installed_version |                          comment
---------------+-----------------+-------------------+-----------------------------------------------------------
 pgbouncer_pkg | 1.24.0          | 1.24.0            | Wrap pgbouncer output as a dblink from pgbouncer database

Create the extension.  Note you must specify the pgbouncer SCHEMA so that this extension does not own the schema and cannot drop it later if you drop the extension.  
CREATE EXTENSION pgbouncer_pkg SCHEMA pgbouncer;
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
# Query to join pgbouncer with pg_stat_activity
```
select sa.pid, sa.state, s.user, s.database, s.state s_state, c.state c_state, c.addr as client_addr,  cast(EXTRACT(EPOCH FROM (s.request_time - s.connect_time)) as integer) as connsec, (case when sa.state <> 'active' then cast(EXTRACT(EPOCH FROM (now() - sa.state_change)) as integer) else -1 end) as idlesec,s.connect_time as s_conn_time, s.request_time as s_req_time,  s.wait as s_wait, s.wait_us as s_waitus, c.wait as c_wait, c.wait_us as c_waitus, s.close_needed as s_clneed, c.close_needed as c_clneed, substring(sa.query,1,30) as query FROM pgbouncer.servers s, pgbouncer.clients c, pg_stat_activity sa where s.link is not null and s.link = c.ptr and c.ptr is not null and s.remote_pid = sa.pid order by 2,8 limit 100;
```
# Queries to detect serious conditions within PGBouncer

Show count of database/user connections that have sent queries but have not yet got a server connection.
```
select count(*) from pgbouncer.pools where cl_waiting > 0;
select database, user, cl_waiting from pgbouncer.pools where cl_waiting > 0;
```
Show databases whose current connections are within 5 of the max connections
```
select count(*) from pgbouncer.databases where max_connections - current_connections < 6;
select database, max_connections, current_connections from pgbouncer.databases where max_connections - current_connections < 6;
```
Show free clients and servers that are close to zero.
```
select count(*) free_clients from pgbouncer.lists where list = 'free_clients' and items < 5;
select count(*) free_servers from pgbouncer.lists where list = 'free_servers' and items < 5;
```
Show caches that are low in free memory.
```
select name, size, free, round(round((free/size::decimal)::decimal,2) * 100) percent_free from pgbouncer.mem where  round(round((free/size::decimal)::decimal,2) * 100) < 10;
```

