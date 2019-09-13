-- Author: Fabien Coelho
-- License: Public Domain

-- start time
SELECT NOW() AS start \gset
-- this one is automatically created by timescaledb
CREATE INDEX conditions_time_idx ON conditions(time);
\if :index2
CREATE INDEX conditions_dev_time_idx ON conditions(device, time);
\endif
SELECT EXTRACT(EPOCH FROM NOW() - TIMESTAMPTZ :'start') AS duration \gset
\echo ## create index :duration
\dti+ cond*
\d+ conditions
