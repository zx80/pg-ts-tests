#
# 1 unit ~ 5000 seconds
#
# pg 11.2 on AWS r5.2xlarge, timescaledb 1.2.2
#
# ./running
# # ./already_run
# ## ./to_run_later
# ### ./cannot_run_for_some_issue
#
# 1 billion rows
#./run_bench.sh -P -1
#./run_bench.sh -T -1
#./run_bench.sh -M -1
#./run_bench.sh -W -1
# + in one tx
#./run_bench.sh -P -1 -c
#./run_bench.sh -T -1 -c
##./run_bench.sh -M -1 -c
# 1 billion rows unlogged
##./run_bench.sh -P -u -1
##./run_bench.sh -T -u -1
###./run_bench.sh -M -u -1
###./run_bench.sh -W -u -1
# 2 billion rows
#./run_bench.sh -P -2
#./run_bench.sh -T -2
##./run_bench.sh -M -2
##./run_bench.sh -W -2
# + in one tx
#./run_bench.sh -P -2 -c
#./run_bench.sh -T -2 -c
##./run_bench.sh -M -2 -c
##./run_bench.sh -W -2 -c
# 2 billion rows unlogged
##./run_bench.sh -P -u -2
##./run_bench.sh -T -u -2
###./run_bench.sh -M -u -2
###./run_bench.sh -W -u -2
# 4 billion rows
#./run_bench.sh -P -4
#./run_bench.sh -T -4
##./run_bench.sh -M -4
##./run_bench.sh -W -4
#
# pg 12dev on AWS r5.2xlarge
#
# (should probably be very similar to pg 11.2)
#
#./run_bench.sh -P -0 -- -p 5433
#./run_bench.sh -M -0 -- -p 5433
#./run_bench.sh -W -0 -- -p 5433
#
#./run_bench.sh -P -1 -- -p 5433
#./run_bench.sh -M -1 -- -p 5433
#./run_bench.sh -W -1 -- -p 5433
#
#./run_bench.sh -P -4 -- -p 5433
#./run_bench.sh -M -4 -- -p 5433
#./run_bench.sh -W -4 -- -p 5433
#
# bis repetita:
#./run_bench.sh -P -4 -- -p 5433
#./run_bench.sh -M -4 -- -p 5433
#./run_bench.sh -W -4 -- -p 5433
#
# pg 11.2 on AWS c5.xlarge: 4 vCPU, 8 GiB
#
#./run_bench.sh -P -0
#./run_bench.sh -T -0
#./run_bench.sh -M -0
#./run_bench.sh -W -0
#
#./run_bench.sh -P -1
#./run_bench.sh -T -1
#./run_bench.sh -M -1
#./run_bench.sh -W -1
#
#./run_bench.sh -P -2
#./run_bench.sh -T -2
##./run_bench.sh -M -2
##./run_bench.sh -W -2
#
#./run_bench.sh -P -4
#./run_bench.sh -T -4
#./run_bench.sh -M -4
#./run_bench.sh -W -4
#
# with another index, about 1 unit ~ 1.8 hours
#
#./run_bench.sh -P -0 -i
#./run_bench.sh -T -0 -i
#./run_bench.sh -M -0 -i
#./run_bench.sh -W -0 -i
#
#./run_bench.sh -P -0 -i -v c
#./run_bench.sh -T -0 -i -v c
#./run_bench.sh -M -0 -i -v c
#./run_bench.sh -W -0 -i -v c
#
#./run_bench.sh -P -1 -i
#./run_bench.sh -T -1 -i
#./run_bench.sh -M -1 -i
#./run_bench.sh -W -1 -i
#
#./run_bench.sh -P -1 -i -v c
#./run_bench.sh -T -1 -i -v c
#./run_bench.sh -M -1 -i -v c
#./run_bench.sh -W -1 -i -v c
#
# redo with c version
#
#./run_bench.sh -P -1 -v c
#./run_bench.sh -T -1 -v c
#./run_bench.sh -M -1 -v c
#./run_bench.sh -W -1 -v c
#
#./run_bench.sh -P -1 -i -v c
#./run_bench.sh -T -1 -i -v c
#./run_bench.sh -M -1 -i -v c
#./run_bench.sh -W -1 -i -v c
#
#./run_bench.sh -P -4 -v c
#./run_bench.sh -T -4 -v c
#./run_bench.sh -M -4 -v c
#./run_bench.sh -W -4 -v c
#
# 11.3 + timescaledb 1.3.0
#
#./run_bench.sh -T -0 -v c
#./run_bench.sh -T -0 -i -v c
#
#./run_bench.sh -T -1 -v c
#./run_bench.sh -T -1 -v c
#./run_bench.sh -T -1 -i -v c
#./run_bench.sh -T -1 -i -v c
#./run_bench.sh -T -4 -v c
#./run_bench.sh -T -4 -v c
#
# threaded version
#
#./run_bench.sh -P -0 -v pq -j 1
#./run_bench.sh -T -0 -v pq -j 1
#./run_bench.sh -M -0 -v pq -j 1
#./run_bench.sh -W -0 -v pq -j 1
#
#./run_bench.sh -P -0 -v pq -j 2
#./run_bench.sh -T -0 -v pq -j 2
#./run_bench.sh -M -0 -v pq -j 2
#./run_bench.sh -W -0 -v pq -j 2
#
#./run_bench.sh -P -0 -v pq -j 3
#./run_bench.sh -T -0 -v pq -j 3
#./run_bench.sh -M -0 -v pq -j 3
#./run_bench.sh -W -0 -v pq -j 3
#
#./run_bench.sh -P -0 -v pq -j 4
#./run_bench.sh -T -0 -v pq -j 4
#./run_bench.sh -M -0 -v pq -j 4
#./run_bench.sh -W -0 -v pq -j 4
#
#./run_bench.sh -P -0 -v pq -j 5
#./run_bench.sh -T -0 -v pq -j 5
#./run_bench.sh -M -0 -v pq -j 5
#./run_bench.sh -W -0 -v pq -j 5
#
# parallel feeding
#
# hmmm... without thread load balancing
#
#./run_bench.sh -P -1 -v pq -j 2
#./run_bench.sh -T -1 -v pq -j 2
#./run_bench.sh -M -1 -v pq -j 2
#
# with thread load balancing
#
#./run_bench.sh -W -1 -v pq -j 2

#./run_bench.sh -P -1 -v pq -j 3
#./run_bench.sh -T -1 -v pq -j 3
#./run_bench.sh -M -1 -v pq -j 3
#./run_bench.sh -W -1 -v pq -j 3

#./run_bench.sh -P -1 -v pq -j 4
#./run_bench.sh -T -1 -v pq -j 4
#./run_bench.sh -M -1 -v pq -j 4
#./run_bench.sh -W -1 -v pq -j 4

##./run_bench.sh -P -1 -v pq -j 2
##./run_bench.sh -T -1 -v pq -j 2
##./run_bench.sh -M -1 -v pq -j 2
#
# try with width 10
#
#./run_bench.sh -P -1 -w 10 -v c
#./run_bench.sh -T -1 -w 10 -v c
#./run_bench.sh -M -1 -w 10 -v c
#./run_bench.sh -W -1 -w 10 -v c
#
#./run_bench.sh -P -1 -w 10 -v pq -j 2
#./run_bench.sh -T -1 -w 10 -v pq -j 2
#./run_bench.sh -M -1 -w 10 -v pq -j 2
#./run_bench.sh -W -1 -w 10 -v pq -j 2
#
#./run_bench.sh -P -1 -w 10 -v pq -j 3
#./run_bench.sh -T -1 -w 10 -v pq -j 3
#./run_bench.sh -M -1 -w 10 -v pq -j 3
#./run_bench.sh -W -1 -w 10 -v pq -j 3
#
#./run_bench.sh -P -1 -w 10 -v pq -j 4
#./run_bench.sh -T -1 -w 10 -v pq -j 4
#./run_bench.sh -M -1 -w 10 -v pq -j 4
#./run_bench.sh -W -1 -w 10 -v pq -j 4
#
#./run_bench.sh -P -1 -w 10 -v c
#./run_bench.sh -T -1 -w 10 -v c
#./run_bench.sh -M -1 -w 10 -v c
#./run_bench.sh -W -1 -w 10 -v c
#
#./run_bench.sh -P -1 -w 10 -v pq -j 2
#./run_bench.sh -T -1 -w 10 -v pq -j 2
#./run_bench.sh -M -1 -w 10 -v pq -j 2
#./run_bench.sh -W -1 -w 10 -v pq -j 2

#./run_bench.sh -P -1 -w 10 -v c
#./run_bench.sh -T -1 -w 10 -v c
#./run_bench.sh -M -1 -w 10 -v c
#./run_bench.sh -W -1 -w 10 -v c
#
#./run_bench.sh -P -1 -w 10 -v pq -j 2
#./run_bench.sh -T -1 -w 10 -v pq -j 2
#./run_bench.sh -M -1 -w 10 -v pq -j 2
#./run_bench.sh -W -1 -w 10 -v pq -j 2

./run_bench.sh -P -1 -w 10 -v pq -j 3
./run_bench.sh -T -1 -w 10 -v pq -j 3
./run_bench.sh -M -1 -w 10 -v pq -j 3
./run_bench.sh -W -1 -w 10 -v pq -j 3

./run_bench.sh -P -1 -w 10 -v pq -j 3
./run_bench.sh -T -1 -w 10 -v pq -j 3
./run_bench.sh -M -1 -w 10 -v pq -j 3
./run_bench.sh -W -1 -w 10 -v pq -j 3

##./run_bench.sh -P -1 -i -v pq -j 2
##./run_bench.sh -T -1 -i -v pq -j 2
##./run_bench.sh -M -1 -i -v pq -j 2
##./run_bench.sh -W -1 -i -v pq -j 2

##./run_bench.sh -P -1 -i -v pq -j 3
##./run_bench.sh -T -1 -i -v pq -j 3
##./run_bench.sh -M -1 -i -v pq -j 3
##./run_bench.sh -W -1 -i -v pq -j 3

# ?
##./run_bench.sh -P -1 -v pq -j 1
##./run_bench.sh -T -1 -v pq -j 1
##./run_bench.sh -M -1 -v pq -j 1
##./run_bench.sh -W -1 -v pq -j 1

#
# pg 12dev on AWS c5.xlarge: 4 vCPU, 8 GiB
#
#./run_bench.sh -P -0 -- -p 5433
#./run_bench.sh -M -0 -- -p 5433
#./run_bench.sh -W -0 -- -p 5433
#
# *slow* variable width version…
#./run_bench.sh -P -0 -v pl -- -p 5433
#./run_bench.sh -M -0 -v pl -- -p 5433
#./run_bench.sh -W -0 -v pl -- -p 5433
#
#./run_bench.sh -P -0 -i -- -p 5433
#./run_bench.sh -M -0 -i -- -p 5433
#./run_bench.sh -W -0 -i -- -p 5433
#
# *slow* variable width version…
#./run_bench.sh -P -0 -v pl -i -- -p 5433
#./run_bench.sh -M -0 -v pl -i -- -p 5433
#./run_bench.sh -W -0 -v pl -i -- -p 5433
#
#./run_bench.sh -P -0 -- -p 5433
#./run_bench.sh -M -0 -- -p 5433
#./run_bench.sh -W -0 -- -p 5433
#
# *slow* variable width version…
#./run_bench.sh -P -0 -v pl -- -p 5433
#./run_bench.sh -M -0 -v pl -- -p 5433
#./run_bench.sh -W -0 -v pl -- -p 5433

#
# use only C filler
#
#./run_bench.sh -P -1 -- -p 5433
#./run_bench.sh -M -1 -- -p 5433
#./run_bench.sh -W -1 -- -p 5433
#
#./run_bench.sh -P -1 -i -- -p 5433
#./run_bench.sh -M -1 -i -- -p 5433
#./run_bench.sh -W -1 -i -- -p 5433
#
#./run_bench.sh -P -4 -- -p 5433
#./run_bench.sh -M -4 -- -p 5433
#./run_bench.sh -W -4 -- -p 5433
#
# one billion again
#./run_bench.sh -P -1 -- -p 5433
#./run_bench.sh -M -1 -- -p 5433
#./run_bench.sh -W -1 -- -p 5433
#
#./run_bench.sh -P -1 -i -- -p 5433
#./run_bench.sh -M -1 -i -- -p 5433
#./run_bench.sh -W -1 -i -- -p 5433
#
#
# pg12dev & parallel version
#
#PGPORT=5433 ./run_bench.sh -P -1 -v pq -j 2
#PGPORT=5433 ./run_bench.sh -M -1 -v pq -j 2
#PGPORT=5433 ./run_bench.sh -W -1 -v pq -j 2
#
#PGPORT=5433 ./run_bench.sh -P -1 -v pq -j 3
#PGPORT=5433 ./run_bench.sh -M -1 -v pq -j 3
#PGPORT=5433 ./run_bench.sh -W -1 -v pq -j 3
#
#PGPORT=5433 ./run_bench.sh -P -4 -v pq -j 2
#PGPORT=5433 ./run_bench.sh -M -4 -v pq -j 2
#PGPORT=5433 ./run_bench.sh -W -4 -v pq -j 2

#
# redo some more or less surprising results
#
#./run_bench.sh -P -1 -v pq -j 2 -- "port=5433"
#./run_bench.sh -M -1 -v pq -j 2 -- "port=5433"
#./run_bench.sh -W -1 -v pq -j 2 -- "port=5433"

#./run_bench.sh -P -1 -v pq -j 3 -- "port=5433"
#./run_bench.sh -M -1 -v pq -j 3 -- "port=5433"
#./run_bench.sh -W -1 -v pq -j 3 -- "port=5433"

#./run_bench.sh -P -1 -v pq -j 4 -- "port=5433"
#./run_bench.sh -M -1 -v pq -j 4 -- "port=5433"
#./run_bench.sh -W -1 -v pq -j 4 -- "port=5433"

#./run_bench.sh -P -1 -v pq -j 2 -- "port=5433"
#./run_bench.sh -M -1 -v pq -j 2 -- "port=5433"
#./run_bench.sh -W -1 -v pq -j 2 -- "port=5433"

#./run_bench.sh -P -1 -v pq -j 3 -- "port=5433"
#./run_bench.sh -M -1 -v pq -j 3 -- "port=5433"
#./run_bench.sh -W -1 -v pq -j 3 -- "port=5433"
