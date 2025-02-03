DROP TABLE IF EXISTS indego_stations;
CREATE TABLE indego_stations
(
  station_id   INTEGER,
  station_name TEXT,
  go_live_date TEXT
);

COPY indego_stations
FROM '/Users/yaohanxu/Documents/GitHub/MUSA5090-GeoCloud/week02/exercises/indego-stations-2025-01-01-clean.csv'
WITH (FORMAT csv, HEADER true);

ALTER TABLE indego_stations
ALTER COLUMN go_live_date TYPE DATE
  USING to_date(go_live_date, 'MM/DD/YYYY');