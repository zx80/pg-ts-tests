/*
 * Fill a lot of data into a (TIMESTAMP, INT, FLOAT*5) table.
 * The output should be pipelined to command "psql".
 * Error handling is rough.
 *
 * Author: Fabien Coelho
 * License: Public Domain
 */

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

typedef enum { false, true } bool;

#include <sys/time.h>
#include <errno.h>

/* return time since the epoch as a double */
double now(void)
{
  struct timeval t;
  if (gettimeofday(&t, NULL) != 0)
  {
    fprintf(stderr, "gettimeofday error (%d)\n", errno);
    exit(1);
  }
  return t.tv_sec + t.tv_usec / 1000000.0;
}

int main(int argc, char *argv[])
{
  int nbatches = 1000;
  int nrows = 10000;
  int ndevices = 1000;
  int width = 5;
  double batch_delay = 60.0;
  bool one_tx = false;
  int opt;

  struct option lopts[] = {
    { "batches", true, NULL, 'b' },
    { "rows", true, NULL, 'r' },
    { "device", true, NULL, 'd' },
    { "delay", true, NULL, 't' },
    { "one", false, NULL, '1' },
    { "width", true, NULL, 'w' },
    { NULL, 0, NULL, 0 }
  };

  while ((opt = getopt_long(argc, argv, "b:r:d:t:w:1", lopts, NULL)) != -1)
  {
    switch (opt) {
    case 'b':
      nbatches = atoi(optarg);
      break;
    case 'r':
      nrows = atoi(optarg);
      break;
    case 'd':
      ndevices = atoi(optarg);
      break;
    case 'w':
      width = atoi(optarg);
      break;
    case 't':
      batch_delay = atof(optarg);
      break;
    case '1':
      one_tx = true;
      break;
    default:
      fprintf(stderr, "unexpected option %c\n", opt);
      exit(1);
    }
  }

  double start = now();
  double last = start;

  fprintf(stderr,
          "# generating %d batches of %d rows over %d devices %d width\n",
          nbatches, nrows, ndevices, width);;

  fprintf(stdout,
          "-- generating %d batches of %d rows over %d devices %d width\n"
          "VACUUM;\n"
          "CHECKPOINT;\n"
          "SELECT TIMEOFDAY() AS bstart \\gset\n"
          "\\set start :'bstart'\n",
          nbatches, nrows, ndevices, width);

  if (one_tx)
    fprintf(stdout, "BEGIN;\n");

  for (int i = 0; i < nbatches ; i++)
  {
    int start_delay = batch_delay * i;
    fprintf(stdout,
            "-- batch %d\n"
            "COPY conditions FROM STDIN;\n",
            i);

    for (int j = 0; j < nrows ; j++)
    {
      int device = 1 + j % ndevices;
      int t = start_delay + batch_delay * j / nrows;
      int d = ((1 + i) % 17) * ((1 + j) % 19) + (i * j % 23);

      fprintf(stdout,
              "%04d-%02d-%02d %02d:%02d:%02d.%06d\t%d",
              1970 + (t / (86400 * 28 * 12)), // year
              1 + (t / (86400 * 28) % 12), // month
              1 + (t / 86400 % 28), // days
              (t / 3600 % 24), // hours
              (t / 60 % 60), // minute
              (t % 60), // second
              (1000000 * t % 1000000), // µs
              device);

      for (int w = 0; w < width ; w++)
        fprintf(stdout, "\t%.2f", (d + w * 11) % 320 / 151.0);

      fputc('\n', stdout);
    }

    fprintf(stdout,
            "\\.\n"
            "SELECT TIMEOFDAY() AS now \\gset\n"
            "SELECT EXTRACT(EPOCH FROM TIMESTAMPTZ :'now' - TIMESTAMPTZ :'bstart') AS bduration \\gset\n"
            "\\set bstart :'now'\n"
            "\\echo # %d :bduration\n",
            i);
    fflush(stdout);

    // show generation progress & speed
    if (i % 100 == 99)
    {
      double n = now();
      fprintf(stderr, "## batch %d %.6f\n", i+1, 100 * nrows / (n - last));
      fflush(stderr);
      last = n;
    }
  }

  if (one_tx)
    fprintf(stdout,
            "COMMIT;\n"
            "SELECT TIMEOFDAY() AS now \\gset\n"
            "SELECT EXTRACT(EPOCH FROM TIMESTAMPTZ :'now' - TIMESTAMPTZ :'bstart') AS cduration \\gset\n"
            "\\echo ## commit :cduration\n");

  fprintf(stdout,
          "SELECT EXTRACT(EPOCH FROM TIMESTAMPTZ :'now' - TIMESTAMPTZ :'start') AS tduration \\gset\n"
          "\\echo ## total :tduration\n");

  // show size status
  /*
    fprintf(stdout,
    "\\d+ conditions\n"
    "\\dti+ conditions*\n"
    // more details about timescaledb automatic partitionning, if any
    "\\dti+ _timescaledb_internal._hyper_*\n"
    "SELECT pg_size_pretty(pg_database_size(CURRENT_CATALOG)) AS \"database size\"\n");
  */

  fprintf(stderr,
          "# total time for generating %d batches of %d rows: %.6f\n",
          nbatches, nrows, now() - start);

  return 0;
}
