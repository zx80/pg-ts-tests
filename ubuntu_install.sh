#! /bin/bash
#
# Author: Fabien Coelho
# License: Public Domain

release=bionic

# up to date
sudo apt update
sudo apt upgrade

# utils
sudo apt install aptitude htop iotop

# install pgdg stuff
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-add-repository "http://apt.postgresql.org/pub/repos/apt/ $release-pgdg-testing main 11 12"
cat > /tmp/pgdg.pref <<EOF
Package: *
Pin: release o=apt.postgresql.org
Pin-Priority: 200
EOF
sudo cp /tmp/pgdg.pref /etc/apt/preferences.d/pgdg.pref
sudo apt update

# has to be forced, specific 12-related version selected manually
sudo apt install postgresql-11 postgresql-12

# timescale stuff
sudo add-apt-repository ppa:timescale/timescaledb-ppa
sudo apt install timescaledb-postgresql-11

# pg_lsclusters
sudo -u postgres createuser -s ubuntu
createdb ubuntu

PATH=/usr/lib/postgresql/11/bin:$PATH timescaledb-tune
## suggests:
# shared_preload_libraries = 'timescaledb'
# shared_buffers = 15906MB
# effective_cache_size = 47718MB
# maintenance_work_mem = 2047MB
# work_mem = 40719kB
# timescaledb.max_background_workers = 4
# max_worker_processes = 15
# max_parallel_workers_per_gather = 4
# max_parallel_workers = 8
# wal_buffers = 16MB
# min_wal_size = 4GB
# max_wal_size = 8GB
# default_statistics_target = 500
# random_page_cost = 1.1
# checkpoint_completion_target = 0.9
# max_connections = 50
# max_locks_per_transaction = 512
# effective_io_concurrency = 200

## and I added
# checkpoint_timeout = 1h

# time pgbench -i -s 200
# load 40.52 s, total 65.458 s
# load 44.69 s, total 70.867 s
