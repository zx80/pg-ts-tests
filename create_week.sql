-- Author: Fabien Coelho
-- License: Public Domain

-- create some table

DROP TABLE IF EXISTS conditions;

-- default type is empty
\if :{?ttype}
\else
\set ttype ''
\endif
\echo ## ttype: :ttype

CREATE :ttype TABLE conditions (
  time    TIMESTAMPTZ NOT NULL,
  device  INT4        NOT NULL
)
  PARTITION BY RANGE (time);

-- append a number of data columns
CREATE OR REPLACE PROCEDURE add_conditions_data(n INT) AS $$
DECLARE
  i INT;
BEGIN
  FOR i IN 1 .. n LOOP
    EXECUTE 'ALTER TABLE conditions ADD COLUMN data' || i || ' FLOAT8 NULL';
  END LOOP;
END
$$ LANGUAGE plpgsql;
CALL add_conditions_data(:width);
DROP PROCEDURE add_conditions_data(INT);

DO LANGUAGE plpgsql $$
DECLARE
  deb TIMESTAMPTZ DEFAULT NULL;
  fin TIMESTAMPTZ DEFAULT NULL;
  i INTEGER;
BEGIN
  CREATE TABLE conditions_first
    PARTITION OF conditions
    FOR VALUES FROM (MINVALUE) TO ('1970-01-01');
  FOR i IN 0 .. 52 LOOP
    -- RAISE NOTICE 'i=%', i;
    deb := TIMESTAMPTZ '1970-01-01'+ (i || ' week')::INTERVAL;
    fin := TIMESTAMPTZ '1970-01-01'+ ((i+1) || ' week')::INTERVAL;
    EXECUTE
     'CREATE TABLE conditions_' || i || ' PARTITION OF conditions'
     '  FOR VALUES FROM (''' || deb || ''') TO (''' || fin || ''')';
  END LOOP;
  EXECUTE
    'CREATE TABLE conditions_last PARTITION OF conditions'
    '  FOR VALUES FROM (''' || fin || ''') TO (MAXVALUE)';
END; $$ ;
