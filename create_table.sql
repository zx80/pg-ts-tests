-- Author: Fabien Coelho
-- License: Public Domain

-- create some table

DROP TABLE IF EXISTS conditions;

-- default table type is empty
\if :{?ttype}
\else
\set ttype ''
\endif
\echo ## ttype: :ttype

-- default data width is 5
\if :{?width}
\else
\set width 5
\endif
\echo ## width: :width

CREATE :ttype TABLE conditions (
  time    TIMESTAMPTZ NOT NULL,
  device  INT4        NOT NULL
);

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

\d+ conditions

-- INSERT INTO conditions(time, device, data1, data2, data3, data4, data5)
-- VALUES ('1970-01-01 00:00:00.000000+0', 0, 0.0, 0.0, 0.0, 0.0, 0.0);
-- SELECT * FROM conditions;
