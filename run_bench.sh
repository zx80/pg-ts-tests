#! /bin/bash
#
# Author: Fabien Coelho
# License: Public Domain

name=''
k=1
c='table'
t=''
x='index'
fopt=''
i2='FALSE'
w=5
piped='1'
fill="./fill"

#piped=''
#fill='echo ./fill_pq'
#psql='echo psql'

while getopts "h01234k:MWPTitucf:v:w:j:" opt ; do
  case $opt in
    # help
    h) echo -e \
	    "Usage: $0 [-h01234MWPTtuc] [-k 100] [-f ...] [-v (c|pq|pl)] [-- conn-options]\n" \
	    "  -h: show this help\n" \
	    "  -[01234]: size 0=10 Mrows, 1-4 in Grows\n" \
	    "  -k SIZE: number of thousand batches to generate\n" \
	    "  -P: simple postgres table\n" \
	    "  -T: timescaledb hyper table\n" \
	    "  -M: pg partition by month\n" \
	    "  -W: pg partition by week\n" \
	    "  -i: add a per device/ts index\n" \
	    "  -j NTHREADS: #threads for libpq version\n" \
	    "  -t: temporary table\n" \
	    "  -u: unlogged table\n" \
	    "  -f OPT: add fill option\n" \
	    "  -w WIDTH: number of data attributes\n" \
	    "  -v VER: fill version to run (default C)\n"
       exit ;;
    # storage
    P) c='table' x='index' name+='pg_' ;;
    M) c='part' x='index' name+='pm_' ;;
    W) c='week' x='index' name+='pw_' ;;
    T) x='hyper' name+='ts_' ;;
    i) i2='TRUE' name+='i' ;;
    # table type, default to standard
    t) tt='TEMPORARY' name+='T' ;;
    u) tt='UNLOGGED' name+='U' ;;
    # size
    0) k=1 name+='0' ;;
    1) k=100 name+='1' ;;
    2) k=200 name+='2' ;;
    3) k=300 name+='3' ;;
    4) k=400 name+='4' ;;
    k) k=$OPTARG name+='_' ;;
    # fill version & option
    v) case $OPTARG in
	 # C generator piped to psql
	 c|C) fill='./fill' piped=1 ;;
	 # too slow perl generator piped to psql
	 pl|perl) fill='./fill.pl' piped=1;;
	 # direct libpq connection
	 pq|PQ) fill='./fill_pq' piped= ;;
	 *) echo "unexpected version $OPTARG" >&2 ; exit 1 ;;
       esac
       ;;
    c) fopt+=" --one" name+='c' ;;
    f) fopt+=" $OPTARG" name+='f' ;;
    w) fopt+=" -w $OPTARG" w=$OPTARG name+="w$OPTARG" ;;
    j) fopt+=" -j $OPTARG" name+="j$OPTARG" fill='./fill_pq' piped= ;;
    *) echo "unexpected option $opt" >&2 ; exit 1 ;;
  esac
done
shift $(( $OPTIND - 1 ))

# number of the run
n=0
if [ -f $name.out ] ; then
  let n++
fi

while [ -f ${name}_${n}.out ] ; do
  let n++
done

name+="_$n"

echo "# name=$name t=$t k=$k x=$x i2=$i2 fopt=$fopt fill=$fill" >&2

{
  # guess the running cluster
  cluster=$(psql --csv -t -c 'SHOW cluster_name' "$@" | tr '/' ' ')
  echo "cluster is '$cluster'"

  # dropdb "$@" $USER
  psql -c "DROP DATABASE $USER" "$@ dbname=template1"
  sudo pg_ctlcluster $cluster restart
  # createdb "$@" $USER
  psql -c "CREATE DATABASE $USER" "$@ dbname=template1"
  psql -c 'SELECT NOW() AS now, VERSION() AS version' \
       -c 'SHOW ALL' \
       -c 'VACUUM FULL' \
       -c 'CHECKPOINT' \
       "$@" >> $name.log
  psql -v ttype="$tt" -v "width=$w" "$@" < create_$c.sql
  psql -v index2="$i2" "$@" < create_$x.sql
  if [ "$piped" ] ; then
    $fill --batches=${k}000 $fopt 2>> $name.log | psql "$@"
  else
    # note: fill_pq does not accept psql connection options
    $fill --batches=${k}000 $fopt "$@" 2>> $name.log
  fi
  # show final stats
  psql "$@" <<EOF
    \d+ conditions
    \dti+ conditions*
    \dti+ _timescaledb_internal._hyper_*
    SELECT
       VERSION() AS "pg version",
       pg_database_size(CURRENT_CATALOG) AS "database size",
       pg_size_pretty(pg_database_size(CURRENT_CATALOG)) AS "db size";
EOF

  echo "## $(date)" >> $name.log
} > $name.out 2> $name.err
