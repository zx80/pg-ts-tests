#! /usr/bin/perl
#
# extract useful data from bench output
#
# Author: Fabien Coelho
# License: Public Domain
#

use warnings;
use strict;

print <<EOF;
DROP TABLE IF EXISTS perf, run;

CREATE TABLE run(
  rid INT PRIMARY KEY,
  ended TIMESTAMP, -- when the run ended, not always available
  file TEXT NOT NULL, -- path of performance file
  instance TEXT NOT NULL, -- AWS instance used in tests
  pgver TEXT NOT NULL, -- postgres version
  tsver TEXT NOT NULL, -- timescaledb version
  store CHAR(2) NOT NULL, -- pg pw pm ts
  nindex INT NOT NULL, -- number of indexes
  batches INT NOT NULL, -- number of batches
  load INT NOT NULL, -- -1=pl, 0=c, else pq
  width INT NOT NULL, -- number of data attributes per row
  tsize INT8 NOT NULL, -- table size (not always available)
  isize INT8 NOT NULL, -- index size (idem)
  dbsize INT8 NOT NULL, -- database size
  total FLOAT4 NOT NULL, -- time to load in second
  num INT NOT NULL -- number of the test, if repeated
);

CREATE TABLE perf(
  rid INT NOT NULL REFERENCES run,
  batch INT NOT NULL, -- number of batch in run
  delay FLOAT4 NOT NULL, -- time to load in second
  UNIQUE(rid, batch)
);
EOF

my $n = 0;

sub size2int($)
{
  my ($s) = @_;
  die "unexpected size format for '$s'" unless $s =~ /^(\d+)\s*(bytes|[KMG]B|)$/;
  my ($i, $u) = ($1, $2);
  return $i if $u eq 'bytes' or $u eq '' ;
  return $i * 1024 if $u eq 'KB';
  return $i * 1024 * 1024 if $u eq 'MB';
  return $i * 1024 * 1024 * 1024 if $u eq 'GB';
  die "unexpected unit '$u' for '$i'";
}

sub prettysize($)
{
  my ($size) = @_;
  return int($size / (1024 ** 3)) . " GB" if $size > 10 * 1024 ** 3;
  return int($size / (1024 ** 2)) . " MB" if $size > 10 * 1024 ** 2;
  return int($size / (1024 ** 1)) . " KB" if $size > 10 * 1024 ** 1;
  return "$size B";
}

for my $file (sort @ARGV)
{
  my ($instance, $pgver, $setup, $size, $index, $width, $thread, $num);

  if ($file =~ m,(\w+)arge_(\w+)/(pg|pm|pw|ts)_([01234])(i?)(w\d+)?(j\d+)?_(\d+)\.,)
  {
    ($instance, $pgver, $setup, $size, $index, $width, $thread, $num) =
      ($1, $2, $3, $4, $5, $6, $7, $8);
  }
  elsif ($file =~ m,(\w+)arge_(\w+)/(pg|pm|pw|ts)_([01234])\.,)
  {
    # format used in early tests: ignoring c (1 tx) and U (unlogged)
    ($instance, $pgver, $setup, $size, $index, $width, $thread, $num) =
      ($1, $2, $3, $4, 1, 5, '', 0);
  }
  else
  {
      warn "ignoring: $file\n";
      next;
  }

  $n++;

  $instance =~ s/(.5)(.?xl)/$1.$2/;

  # adjust values with defaults
  $width = 5 unless defined $width;
  $width =~ s/^w//;

  $thread = '' unless defined $thread;
  $thread =~ s/^j//;

  my $load = 0;
  $load = -1 if $instance eq 'r5.2xl'; # ??? probably some others too
  $load = $thread if defined $thread and $thread ne '';

  $index = $index eq 'i' ? '2' : '1';

  my $log = $file;
  my $ended = 'NULL';
  $log =~ s/\.out$/.log/;
  if (-e $log)
  {
    # get some data from log file
    open LOG, $log or die "cannot open $log";
    my @logs = <LOG>;
    close LOG or die "cannot close $log";
    if ($logs[-1] =~ '^## ([A-Z][a-z]{2} .* 2019)$')
    {
      $ended = "'$1'";
    }
  }
  else
  {
      warn "missing log file: $log";
  }

  # open err file to get ts version if any
  my $ts = 'none';
  if ($setup eq 'ts')
  {
    my $err = $file;
    $err =~ s/\.out$/.err/;
    if (-e $err)
    {
      open ERR, $err or die "cannot open $err";
      while (<ERR>)
      {
        $ts = $1 if /Running version (\d+\.\d+\.\d+)/;
      }
      close ERR or die "cannot close $err";
    }
    else
    {
      warn "missing err file: $err";
    }
  }

  # performance data
  open FILE, $file or die "cannot open $file";
  print
    "\n",
    "-- file: $file\n";
  my ($tsize, $isize, $dbsize) = (0, 0, 0);
  my $total;
  my @perf = ();
  my $repeat = 0; # some traces include a \dt+ twice

  while (<FILE>)
  {
    $perf[$1] = $2 if /^# (\d+) (\d+\.\d+)$/;
    $total = $1 if /^## total (\d+\.\d+)$/;

    # get sizes if available after total has been seen
    if (defined $total)
    {
      $tsize += size2int($1)
        if /\w+ \| \w+\s* \| table\s* \| \w+ \| .* \| (\d+ (.B|bytes))\s* \|/;
      $isize += size2int($1)
        if /\w+ \| \w+\s* \| index\s* \| \w+ \| .* \| (\d+ (.B|bytes))\s* \|/;
      # database size comes in two formats
      ($dbsize, $repeat) = (size2int($1), $repeat + 1)
        if /^\s+(\d+ (bytes|[KMG]B))$/;
      ($dbsize, $repeat) = (size2int($1), $repeat + 1)
        if /\s+(\d+)\s+\|\s+\d+ (bytes|[KMG]B)$/
    }
}
  close FILE or die "cannot close $file";

  # fix repeated size dumps
  if ($repeat > 1)
  {
      $tsize /= $repeat;
      $isize /= $repeat;
  }

  # adjust some contents
  my $batches = $size > 0 ? $size * 100 : 1;

  warn "$file: i=$instance pg=$pgver ts=$ts l=$load ini=$setup sz=$size ",
  "idx=$index w=$width t=$thread n=$num ",
  "tsz=", prettysize($tsize), " isz=", prettysize($isize), " ",
  "dsz=", prettysize($dbsize), " total=$total",
  ": ", sprintf("%.1f", $dbsize / (1024*1024*$total)), " MB/s\n";

  print
    "INSERT INTO\n",
    "  run(rid, file, ended, instance, pgver, tsver, store, nindex, batches,\n",
    "      load, width, tsize, isize, dbsize, total, num)\n",
    "VALUES($n, '$file', $ended, '$instance', '$pgver', '$ts', '$setup', $index, $batches,\n",
    "       $load, $width, $tsize, $isize, $dbsize, $total, $num);\n";

  print "COPY perf(rid, batch, delay) FROM STDIN;\n";
  for my $i (0 .. @perf - 1)
  {
      print "$n\t$i\t$perf[$i]\n";
  }
  print "\\.\n\n";

}

print "VACUUM FULL ANALYZE run, perf;\n";
