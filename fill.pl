#! /usr/bin/perl
#
# generate batches of rows along a time line
# this variable width version is not fast enough for a fast enough SSD
#
# Author: Fabien Coelho
# License: Public Domain

use strict;
use warnings;

use Getopt::Long;
use Time::HiRes qw( time );

# laptop pg11:
# - 1 second for 1 M rows, 81 MB data, 30 MB index
# - 34 seconds for 10 M rows, 806 MB, 300 MB index
# - ??? 1 G rows ~ 1 hour, 80 GB table, 30 GB index ?
# laptop pg12:
# - 42 seconds for 10 M rows

# advertised best practice: 1 period table + index ~ 25% of memory
# default period is 1 week (chunk_time_interval)
# 10 Mrows ~ 1.1 GB (800 MB table + 300 MB index)
# 1 Grows ~ 110 GB (80 GB table + 30 GB index)

# we take 1 Grows = 8 weeks (could be 2 weeks?)
# => 125 Mr per week, 12,500 batches per week
# one batch every 48 seconds

# number of batches (target = 100,000)
my $nbatches = 1_000;

# number of rows in a batch
my $nrows = 10_000;

# number of devices
my $ndevices = 1000;

# number of data per row beyond time & device
my $width = 5;

# realtime between batches, in seconds
# 60s per batch = 1440 batches per day
# 1b rows = 100_000 batches ~ 70 days
# 4b rows = 400_000 batches ~ 278 days
my $batch_delay = 60.0;

# whether everything is included in one transaction
my $one_tx = 0;

GetOptions(
    "batches=i" => \$nbatches,
    "rows=i" => \$nrows,
    "devices=i" => \$ndevices,
    "delay=f" => \$batch_delay,
    "1|one" => \$one_tx,
    "width=i" => \$width)
    or die "Error in command line arguments";

my $start = time();
my $last = $start;

print STDERR
    "# generating $nbatches batches of $nrows rows over $ndevices devices width $width\n";

print
    "-- generating $nbatches batches of $nrows rows over $ndevices devices width $width\n",
    "VACUUM;\n",
    "CHECKPOINT;\n",
    "SELECT TIMEOFDAY() AS bstart \\gset\n",
    "\\set start :'bstart'\n";

print "BEGIN;\n" if $one_tx;

for (my $i = 0; $i < $nbatches ; $i++)
{
    my $t0 = time();
    my $start_delay = $batch_delay * $i;
    print
	"-- batch $i\n",
	"COPY conditions FROM STDIN;\n";
    for (my $j = 0; $j < $nrows ; $j++)
    {
	my $device = 1 + $j % $ndevices; # round robin
	my $t = $start_delay + $batch_delay * $j / $nrows; # linear
	my $d = ((1 + $i) % 17) * ((1 + $j) % 19) + ($i * $j % 23);

	printf "%04d-%02d-%02d %02d:%02d:%02d.%06d\t%d",
	       1970 + int($t / (86400 * 28 * 12)), # year
	       1 + int($t / (86400 * 28) % 12), # month
	       1 + int($t / 86400 % 28), # days
	       int($t / 3600 % 24), # hours
	       int($t / 60 % 60), # minutes
	       int($t % 60), # second
	       int(1000000 * $t % 1000000), # µs
	       $device;

	for (my $w = 0 ; $w < $width ; $w++)
	{
	    printf "\t%.2f", ($w * 11 + $d) % 320 / 151.0;
	}

	printf "\n";
    }

    print
	"\\.\n",
	"SELECT TIMEOFDAY() AS now \\gset\n",
	"SELECT EXTRACT(EPOCH FROM TIMESTAMPTZ :'now' - TIMESTAMPTZ :'bstart') AS bduration \\gset\n",
	"\\set bstart :'now'\n",
	"\\echo # $i :bduration\n";

    # show generation progress & speed
    if ($i % 100 == 99)
    {
	my $now = time();
	printf STDERR "## batch %d %.6f\n", $i+1, 100 * $nrows / ($now - $last);
	$last = $now;
    }
}

if ($one_tx)
{
    print
	"COMMIT;\n",
	"SELECT TIMEOFDAY() AS now \\gset\n",
	"SELECT EXTRACT(EPOCH FROM TIMESTAMPTZ :'now' - TIMESTAMPTZ :'bstart') AS cduration \\gset\n",
	"\\echo ## commit :cduration\n";
}

print
    "SELECT EXTRACT(EPOCH FROM TIMESTAMPTZ :'now' - TIMESTAMPTZ :'start') AS tduration \\gset\n",
    "\\echo ## total :tduration\n";

# show size status
#print
#    "\\d+ conditions\n",
#    "\\dti+ conditions*\n",
#    # more details about timescaledb automatic partitionning, if any
#    "\\dti+ _timescaledb_internal._hyper_*\n",
#    "SELECT pg_size_pretty(pg_database_size(CURRENT_CATALOG)) AS \"database size\"\n";

printf STDERR
    "# total time for generating %d batches of %d rows: %.6f\n",
    $nbatches, $nrows, time() - $start;
