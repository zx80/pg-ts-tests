-- Author: Fabien Coelho
-- License: Public Domain

-- Extend the database with TimescaleDB
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- This creates a hypertable that is partitioned by time
--   using the values in the `time` column.

SELECT create_hypertable('conditions', 'time');

-- and possibly throw in another index
\if :index2
CREATE INDEX conditions_device_time_idx ON conditions(device, time);
\endif

-- This creates a hypertable partitioned on both time and `location`.
-- In this example, the hypertable will partition `location` into 4 partitions.

--  SELECT create_hypertable('conditions', 'time', 'location', 4);
