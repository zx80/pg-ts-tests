/*
 * threaded & direct connection
 *
 * note that for one thread this is worse than the piped version
 * because generating data is not pipelined, so if the ingestion is
 * cpu bound the sequential filling will generate a delay.
 *
 * error management is basically non existant.
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
#include <assert.h>
#include <pthread.h>

#include "libpq-fe.h"

static double now(void)
{
  struct timeval t;
  if (gettimeofday(&t, NULL) != 0)
  {
    fprintf(stderr, "gettimeofday error (%d)\n", errno);
    exit(1);
  }
  return t.tv_sec + t.tv_usec / 1000000.0;
}

static ExecStatusType
pg_accept(PGresult *res)
{
  ExecStatusType status = PQresultStatus(res);
  switch (status)
  {
  case PGRES_EMPTY_QUERY:
  case PGRES_COMMAND_OK:
  case PGRES_TUPLES_OK:
  case PGRES_COPY_OUT:
  case PGRES_COPY_IN:
  case PGRES_COPY_BOTH:
  case PGRES_SINGLE_TUPLE:
    PQclear(res);
    return status;
    break;
  case PGRES_BAD_RESPONSE:
  case PGRES_FATAL_ERROR:
  case PGRES_NONFATAL_ERROR:
  default:
    fprintf(stderr, "bad result status %s (%s)\n",
            PQresStatus(status), PQresultErrorMessage(res));
    abort();
  }
}

/* fill input data buffer, which is expected to be large enough */
static int fill_buffer(
  char *buffer, int bsize,
  double delay, int i, int nrows, int ndevices, int width)
{
  int start_delay = delay * i;
  char * buf_start = buffer;
  for (int j = 0; j < nrows ; j++)
  {
    int t = start_delay + delay * j / nrows;

    buffer +=
      sprintf(buffer,
              "%04d-%02d-%02d %02d:%02d:%02d.%06d\t%d",
              1970 + (t / (86400 * 28 * 12)), // year
              1 + (t / (86400 * 28) % 12), // month
              1 + (t / 86400 % 28), // days
              (t / 3600 % 24), // hours
              (t / 60 % 60), // minute
              (t % 60), // second
              (1000000 * t % 1000000), // µs
              1 + j % ndevices);

    int d = ((1 + i) % 17) * ((1 + j) % 19) + (i * j % 23);
    for (int w = 0; w < width ; w++)
      buffer += sprintf(buffer, "\t%.2f", (d + w * 11) % 320 / 151.0);

    *buffer++ = '\n';
  }

  int size = buffer - buf_start;
  assert(size < bsize);
  return size;
}

/*
static void pg_exec(PGconn *conn, const char * cmd)
{
  fprintf(stderr, "sending: %s\n", cmd);
  int ok = PQsendQuery(conn, cmd);
  assert(ok);
  PGresult *res;
  while ((res = PQgetResult(conn)) != NULL)
    pg_accept(res);
}
*/

/* thread stuff */

static pthread_mutex_t iteration_lock;
static int iteration_index = 0;

static int next_iteration_index(void)
{
  pthread_mutex_lock(&iteration_lock);
  int index = iteration_index++;
  pthread_mutex_unlock(&iteration_lock);
  return index;
}

typedef struct {
  int thread;
  int nbatches;
  int nrows;
  int ndevices;
  int width;
  double delay;
  const char *connstr;
} thread_data_t;

static void * run(void *raw)
{
  thread_data_t *data = (thread_data_t *) raw;

  // safe byte size is (26 (ts) + 1 + 10 (dev) + (1 + 4) * width) * nrows
  int safe_size = (26 + 1 + 10 + 10 * data->width) * data->nrows + 1024;
  char *buffer = malloc(safe_size);
  assert(buffer != NULL);

  PGconn * conn = PQconnectdb(data->connstr);
  assert(conn != NULL);

  double last = now(), bstart = last;
  int c = 0;

  for (int i; (i = next_iteration_index()) < data->nbatches; c++)
  {
    int ok = PQsendQuery(conn, "COPY conditions FROM STDIN;");
    assert(ok);

    // this induces a delay
    int size = fill_buffer(buffer, safe_size, data->delay, i,
                           data->nrows, data->ndevices, data->width);
    assert(size <= safe_size);

    PGresult *res = PQgetResult(conn);
    assert(PQresultStatus(res) == PGRES_COPY_IN);
    PQputCopyData(conn, buffer, size);
    PQputCopyEnd(conn, NULL);
    PQclear(res);

    res = PQgetResult(conn);
    assert(pg_accept(res) == PGRES_COMMAND_OK);

    res = PQgetResult(conn);
    assert(res == NULL);

    double t = now();
    fprintf(stdout, "# %d %.6f\n", i, t - bstart);
    bstart = t;

    // show generation progress & speed every 100 iterations
    if (c % 100 == 99)
    {
      fprintf(stderr, "## batch %d-%d %.6f\n",
              data->thread, c+1, 100 * data->nrows / (t - last));
      last = t;
    }
  }

  free(buffer);
  PQfinish(conn);
  return NULL;
}

int main(int argc, char *argv[])
{
  int nbatches = 1000;
  int nrows = 10000;
  int ndevices = 1000;
  int width = 5;
  int nthreads = 1;
  double batch_delay = 60.0;
  int opt;

  struct option lopts[] = {
    { "batches", true, NULL, 'b' },
    { "rows", true, NULL, 'r' },
    { "device", true, NULL, 'd' },
    { "delay", true, NULL, 't' },
    { "width", true, NULL, 'w' },
    { "thread", true, NULL, 'j' },
    { NULL, 0, NULL, 0 }
  };

  while ((opt = getopt_long(argc, argv, "b:r:d:t:w:j:", lopts, NULL)) != -1)
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
    case 'j':
      nthreads = atoi(optarg);
      break;
    default:
      fprintf(stderr, "unexpected option %c\n", opt);
      exit(1);
    }
  }

  const char * connstr = optind < argc ? argv[optind] : "";

  fprintf(stderr,
          "# generating %d batches of %d rows over %d devices %d width %d threads\n",
          nbatches, nrows, ndevices, width, nthreads);

  // initial cleanup? better in the outer script?
  /*
  PGconn * conn = PQconnectdb(connstr);
  assert(conn != NULL);
  pg_exec(conn, "VACUUM");
  pg_exec(conn, "CHECKPOINT");
  PQfinish(conn);
  */

  double start = now();

  int err = pthread_mutex_init(&iteration_lock, NULL);
  assert(err == 0);

  // start filling threads
  pthread_t threads[nthreads];
  thread_data_t tdatas[nthreads];

  for (int j = 0; j < nthreads; j++)
  {
    tdatas[j] = (thread_data_t) {
      .thread = j,
      .nbatches = nbatches,
      .nrows = nrows,
      .ndevices = ndevices,
      .width = width,
      .delay = batch_delay,
      .connstr = connstr
    };
    int err = pthread_create(&threads[j], NULL, run, &tdatas[j]);
    assert(err == 0);
  }

  // wait for completion
  for (int j = 0; j < nthreads; j++)
  {
    int err = pthread_join(threads[j], NULL);
    assert(err == 0);
  }

  pthread_mutex_destroy(&iteration_lock);

  // final summary
  fprintf(stdout, "## total %.6f\n", now() - start);
  fprintf(stderr,
          "# total time for generating %d batches of %d rows %d width %d threads: %.6f\n",
          nbatches, nrows, width, nthreads, now() - start);

  return 0;
}
