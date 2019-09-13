#! /bin/bash
#
# generate image from run
#
# Author: Fabien Coelho
# License: Public Domain

# default is to generate all possible images
if [ $# -eq 0 ] ; then
  set -- $(psql -At -R ' ' -c 'SELECT rid FROM run')
fi

for n ; do

echo "# generating $n..." >&2

# import various stuff
eval $(psql -tA -F ' ' <<EOF
  SELECT
   'file=' || file,
   'store=' || store,
   'load=' || load,
   'pgver=' || pgver,
   'tsver=' || tsver,
   'width=' || width,
   'batches=' || batches, -- in thousands
   'total=' || ROUND((total/60.0)::NUMERIC, 1),
   'instance=' || instance,
   'speed=' || ROUND((10000.0*batches/total)::NUMERIC, 1)
  FROM run WHERE rid=$n
EOF
  )

#echo "speed=$speed"

[ "$file" ] || exit 1

prefix=${file%.out}
prefix="${prefix//\//_}_$n"

psql -tA -F ' ' -c "
  SELECT batch, delay FROM perf WHERE rid=$n ORDER BY batch
" > ${prefix}_raw.out

psql -tA -F ' ' <<EOF  > ${prefix}_speed.out
  -- load corrected speed
  SELECT CASE WHEN load <= 1 THEN 1 ELSE load END AS load
    FROM run WHERE rid=$n \gset
  SELECT batch, 10000.0 * :load / delay
    FROM perf WHERE rid=$n ORDER BY batch
EOF

# cost is prohibitive and the result is unconvincing
#psql -tA -F ' ' \
#     -c "SELECT
#           AVG(delay)
#           OVER (ORDER BY batch ROWS BETWEEN 1000 PRECEDING AND 1000 FOLLOWING)
#         FROM perf WHERE rid=$n ORDER BY batch" > ${n}_avg.out

# number of batches averaged depends on #batches
avg=${batches}0
psql -tA -F ' ' <<EOF > ${prefix}_avg.out
  SELECT $avg / 2 + batch / $avg * $avg, AVG(delay)
  FROM perf
  WHERE rid=$n
  GROUP BY batch / $avg
  ORDER BY 1 ASC
EOF

psql -tA -F ' ' <<EOF > ${prefix}_sort.out
  SELECT RANK() OVER (ORDER BY delay), delay
  FROM perf
  WHERE rid=$n
  ORDER BY 2
EOF

psql -tA -F ' ' <<EOF > ${prefix}_dist.out
  SELECT TRUNC(delay::NUMERIC, 2) AS delay, COUNT(*)
  FROM perf
  WHERE rid=$n AND delay < 1.0
  GROUP BY 1
  ORDER BY 1
EOF

case $pgver in
  1102) pgver=11.2 ;;
  1103) pgver=11.3 ;;
esac

case $store in
  ts) store="timescaledb $tsver with postgres $pgver" ;;
  pg) store="standard postgres $pgver" ;;
  pw) store="weekly postgres $pgver" ;;
  pm) store="monthly postgres $pgver" ;;
  *) exit 1;
esac

case $load in
  -1|0) load='' ;;
  *) load="$load threads" ;;
esac

title="$load $store on $instance in $total minutes"
font='font "sans,bold,18"'

# time performance

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "$title - raw loading time"
  set xlabel "$batches,000 batches of 10,000 rows"
  set xrange [0:]
  set format x "%h,000
  set ylabel "loading time in second"
  set yrange [0.0:0.5]
  set ytics 0.1
  set mytics 2
  set output "${prefix}_time_raw.png"
  plot "${prefix}_raw.out" using (\$1/1000):(\$2) with dots notitle
EOF
# "${prefix}_avg.out" with lines notitle

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "$title - sorted loading time"
  set xlabel "$batches,000 batches of 10,000 rows"
  set xrange [0:]
  set format x "%h,000
  set ylabel "loading time in second"
  set yrange [0.0:0.5]
  set ytics 0.1
  set mytics 2
  set output "${prefix}_time_sort.png"
  plot "${prefix}_sort.out"  using (\$1/1000):(\$2) with dots notitle
EOF

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "$title - average loading time"
  set xlabel "$batches,000 batches of 10,000 rows"
  set xrange [0:]
  set format x "%h,000
  set ylabel "loading time in second"
  set yrange [0.0:0.5]
  set ytics 0.1
  set mytics 2
  set output "${prefix}_time_avg.png"
  plot "${prefix}_avg.out" using (\$1/1000):(\$2) with lines notitle
EOF

# SPEED performance

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "$title - raw speed"
  set xlabel "$batches,000 batches of 10,000 rows"
  set format x "%h,000
  set ylabel "raw loading speed in rows per second"
  set yrange [0:400]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "${prefix}_speed_raw.png"
  plot "${prefix}_raw.out" using (\$1/1000):(10/\$2) \
    with dots title "average speed is $speed Krows/s"
EOF

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "$title - sorted speed"
  set xlabel "$batches,000 batches of 10,000 rows"
  set format x "%h,000
  set ylabel "sorted loading speed in rows per second"
  set yrange [0:400]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "${prefix}_speed_sort.png"
  plot "${prefix}_sort.out" using (\$1/1000):(10/\$2) \
    with dots title "average speed is $speed Krows/s"
EOF

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "$title - average speed"
  set xlabel "$batches,000 batches of 10,000 rows"
  set xrange [0:]
  set format x "%h,000
  set ylabel "averaged loading speed in rows per second"
  set yrange [0:400]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "${prefix}_speed_avg.png"
  plot "${prefix}_avg.out" using (\$1/1000):(10/\$2) \
    with lines title "average speed is $speed Krows/s"
EOF

#
# DISTRIBUTION
#

gnuplot <<EOF
  set term png size 1600,1000 $font
  set title "$title - loading time distribution"
  set xlabel "loading time in second"
  set xrange [0.0:0.5]
  set xtics 0.1
  set ylabel "number of batches"
  set output "${prefix}_dist_lin.png"
  plot "${prefix}_dist.out" with boxes notitle
EOF

gnuplot <<EOF
  set term png size 1600,1000 $font
  set title "$title - loading time distribution"
  set xlabel "loading time in second"
  set xrange [0.0:0.5]
  set logscale y 10
  set ylabel "number of batches"
  set output "${prefix}_dist_log.png"
  plot "${prefix}_dist.out" with boxes notitle
EOF

done
