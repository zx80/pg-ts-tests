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

-- try per month on 1970
CREATE :ttype TABLE conditions_01
  PARTITION OF conditions
  FOR VALUES FROM (MINVALUE) TO ('1970-02-01');
CREATE :ttype TABLE conditions_02
  PARTITION OF conditions
  FOR VALUES FROM ('1970-02-01') TO ('1970-03-01');
CREATE :ttype TABLE conditions_03
  PARTITION OF conditions
  FOR VALUES FROM ('1970-03-01') TO ('1970-04-01');
CREATE :ttype TABLE conditions_04
  PARTITION OF conditions
  FOR VALUES FROM ('1970-04-01') TO ('1970-05-01');
CREATE :ttype TABLE conditions_05
  PARTITION OF conditions
  FOR VALUES FROM ('1970-05-01') TO ('1970-06-01');
CREATE :ttype TABLE conditions_06
  PARTITION OF conditions
  FOR VALUES FROM ('1970-06-01') TO ('1970-07-01');
CREATE :ttype TABLE conditions_07
  PARTITION OF conditions
  FOR VALUES FROM ('1970-07-01') TO ('1970-08-01');
CREATE :ttype TABLE conditions_08
  PARTITION OF conditions
  FOR VALUES FROM ('1970-08-01') TO ('1970-09-01');
CREATE :ttype TABLE conditions_09
  PARTITION OF conditions
  FOR VALUES FROM ('1970-09-01') TO ('1970-10-01');
CREATE :ttype TABLE conditions_10
  PARTITION OF conditions
  FOR VALUES FROM ('1970-10-01') TO ('1970-11-01');
CREATE :ttype TABLE conditions_11
  PARTITION OF conditions
  FOR VALUES FROM ('1970-11-01') TO ('1970-12-01');
CREATE :ttype TABLE conditions_12
  PARTITION OF conditions
  FOR VALUES FROM ('1970-12-01') TO (MAXVALUE);

-- INSERT INTO conditions(time, device, data1, data2, data3, data4, data5)
-- VALUES ('1970-01-01 00:00:00.000000+0', 0, 0.0, 0.0, 0.0, 0.0, 0.0);
-- SELECT * FROM conditions;
