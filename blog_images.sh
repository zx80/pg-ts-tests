#! /bin/bash
#
# generate images for the blog
#
# Author: Fabien Coelho
# License: Public Domain
#

font='font "sans,bold,18"'

# r5.2xl 4b rows
# pg 11.2 = 191
# ts 1.2.2 = 198
# pg 12dev = 201 202
# pw 12dev = 209 210

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "Loading 4 billion rows - Postgres vs TimescaleDB - average speed on R5.2XL"
  set xlabel "400,000 batches of 10,000 rows"
  set xrange [0:]
  set xtics 50
  set mxtics 5
  set format x "%h,000
  set ylabel "averaged loading speed in rows per second"
  set yrange [0:325]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "r52xlarge_4b_pg_ts_speed_avg.png"
  set key right bottom
  plot \
    "r52xlarge_12de_pw_4_1_210_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Weekly Postgres 12dev - 268.7 Krows/s (398 GB in 248.1 minutes)", \
    "r52xlarge_12de_pm_4_1_206_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Monthly Postgres 12dev - 257.5 Krows/s (398 GB in 258.9 minutes)", \
    "r52xlarge_12de_pg_4_1_202_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 12dev - 254.5 Krows/s (398 GB in 262.0 minutes)", \
    "r52xlarge_12de_pg_4_0_201_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 12dev - 236.4 Krows/s (398 GB in 282.0 minutes)", \
    "r52xlarge_12de_pm_4_0_205_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Monthly Postgres 12dev - 230.9 Krows/s (398 GB in 288.7 minutes)", \
    "r52xlarge_1102_pg_4_0_191_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 11.2 - 229.3 Krows/s (298 GB in 290.8 minutes)", \
    "r52xlarge_12de_pw_4_0_209_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Weekly Postgres 12dev - 228.7 Krows/s (298 GB in 291.5 minutes)", \
    "r52xlarge_1102_ts_4_0_198_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "TimescaleDB 1.2.2 - 183.7 Krows/s (457 GB in 362.9 minutes)"
EOF

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "Loading 4 billion rows - Postgres vs TimescaleDB - sorted speed on R5.2XL"
  set xlabel "400,000 batches of 10,000 rows"
  set xrange [0:]
  set xtics 50
  set mxtics 5
  set format x "%h,000
  set ylabel "averaged loading speed in rows per second"
  set yrange [0:325]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "r52xlarge_4b_pg_ts_speed_sort.png"
  set key left bottom
  plot \
    "r52xlarge_12de_pw_4_1_210_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Weekly Postgres 12dev - 268.7 Krows/s (398 GB in 248.1 minutes)", \
    "r52xlarge_12de_pm_4_1_206_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Monthly Postgres 12dev - 257.5 Krows/s (398 GB in 258.9 minutes)", \
    "r52xlarge_12de_pg_4_1_202_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 12dev - 254.5 Krows/s (398 GB in 262.0 minutes)", \
    "r52xlarge_12de_pg_4_0_201_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 12dev - 236.4 Krows/s (398 GB in 282.0 minutes)", \
    "r52xlarge_12de_pm_4_0_205_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Monthly Postgres 12dev - 230.9 Krows/s (398 GB in 288.7 minutes)", \
    "r52xlarge_1102_pg_4_0_191_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 11.2 - 229.3 Krows/s (398 GB in 290.8 minutes)", \
    "r52xlarge_12de_pw_4_0_209_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Weekly Postgres 12dev - 228.7 Krows/s (398 GB in 291.5 minutes)", \
    "r52xlarge_1102_ts_4_0_198_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "TimescaleDB 1.2.2 - 183.7 Krows/s (457 GB in 362.9 minutes)"
EOF


gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "Loading 4 billion rows - Postgres vs TimescaleDB - average speed on C5.XL"
  set xlabel "400,000 batches of 10,000 rows"
  set xrange [0:]
  set xtics 50
  set mxtics 5
  set format x "%h,000
  set ylabel "averaged loading speed in rows per second"
  set yrange [0:400]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "c5xlarge_4b_pg_ts_speed_avg.png"
  set key right bottom
  plot \
    "c5xlarge_1103_pg_4_0_51_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 11.3 - 325.6 Krows/s (406 GB in 204.8 minutes)", \
    "c5xlarge_1103_pm_4_0_70_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Monthly Postgres 11.3 - 270.6 Krows/s (406 GB in 246.3 minutes)", \
    "c5xlarge_1103_pw_4_0_89_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Weekly Postgres 11.3 - 263.8 Krows/s (406 GB in 252.7 minutes)", \
    "c5xlarge_1103_ts_4_0_116_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "TimescaleDB 1.2.2 - 226.0 Krows/s (457 GB in 295.0 minutes)"
EOF

gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "Loading 4 billion rows - Postgres vs TimescaleDB - average speed on C5.XL"
  set xlabel "400,000 batches of 10,000 rows"
  set xrange [0:]
  set xtics 50
  set mxtics 5
  set format x "%h,000
  set ylabel "averaged loading speed in rows per second"
  set yrange [0:400]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "c5xlarge_4b_pg_ts_speed_sort.png"
  set key right bottom
  plot \
    "c5xlarge_1103_pg_4_0_51_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 11.3 - 325.6 Krows/s (406 GB in 204.8 minutes)", \
    "c5xlarge_1103_pm_4_0_70_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Monthly Postgres 11.3 - 270.6 Krows/s (406 GB in 246.3 minutes)", \
    "c5xlarge_1103_pw_4_0_89_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "Weekly Postgres 11.3 - 263.8 Krows/s (406 GB in 252.7 minutes)", \
    "c5xlarge_1103_ts_4_0_116_sort.out" using (\$1/1000):(10/\$2) with lines \
      title "TimescaleDB 1.2.2 - 226.0 Krows/s (457 GB in 295.0 minutes)"
EOF

# 36 38 vs 98 103
gnuplot <<EOF
  set term png 5 size 2000,1000 $font
  set title "Loading 1 billion rows - Postgres vs TimescaleDB - average speed on C5.XL"
  set xlabel "100,000 batches of 10,000 rows"
  set xrange [0:]
  set xtics 10
  set mxtics 5
  set format x "%h,000
  set ylabel "averaged batch loading speed in rows per second"
  set yrange [0:400]
  set ytics 50
  set mytics 2
  set format y "%h,000"
  set output "c5xlarge_1b_pg_ts_speed_avg.png"
  set key right bottom
  plot \
    "c5xlarge_1103_pg_1_0_36_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "Postgres 11.3 - 316.0 Krows/s (101 GB in 52.7 minutes)", \
    "c5xlarge_1103_ts_1_1_98_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "TimescaleDB 1.3.0 - 223.9 Krows/s (114 GB in 74.4 minutes)", \
    "c5xlarge_1103_pg_1j2_0_38_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "2 threads Postgres 11.3 - 357.7 Krows/s (109 GB in 46.6 minutes)", \
    "c5xlarge_1103_ts_1j2_0_103_avg.out" using (\$1/1000):(10/\$2) with lines \
      title "2 threads TimescaleDB 1.3.0 - 292.6 Krows/s (114 GB in 57.0 minutes)"

EOF
