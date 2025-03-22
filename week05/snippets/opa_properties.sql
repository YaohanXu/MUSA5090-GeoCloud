CREATE OR REPLACE EXTERNAL TABLE `data_lake.phl_pwd_parcels` (
    `OBJECTID` STRING,
    `PARCELID` STRING,
    `TENCODE` STRING,
    `ADDRESS` STRING,
    `OWNER1` STRING,
    `OWNER2` STRING,
    `BLDG_CODE` STRING,
    `BLDG_DESC'` STRING,
    `BRT_ID` STRING,
    `NUM_BRT` STRING,
    `NUM_ACCOUNTS` STRING,
    `GROSS_AREA` STRING,
    `PIN` STRING,
    `PARCEL_ID` STRING,
    `Shape__Area'` STRING,
    `Shape__Length` STRING,
    `geog` STRING
)
OPTIONS (
    description = 'Philadelphia Stormwater Billing Parcels from PWD - Raw Data',
    uris = ['gs://yaohan_data_lake/phl_parcels/*.jsonl'],
    format = 'JSON',
    max_bad_records = 0
);

CREATE OR REPLACE TABLE phl.pwd_parcels
CLUSTER BY (geog)
AS (
    SELECT * REPLACE (
        ST_GeogFromGeoJSON(geog, make_valid => TRUE) AS geog
    )
    FROM data_lake.phl_pwd_parcels
);

CREATE OR REPLACE EXTERNAL TABLE `data_lake.phl_opa_properties` (
  `geog` STRING,
  `assessment_date` STRING,
  `basements` STRING,
  `beginning_point` STRING,
  `book_and_page` STRING,
  `building_code` STRING,
  `building_code_description` STRING,
  `category_code` STRING,
  `category_code_description` STRING,
  `census_tract` STRING,
  `central_air` STRING,
  `cross_reference` STRING,
  `date_exterior_condition` STRING,
  `depth` STRING,
  `exempt_building` STRING,
  `exempt_land` STRING,
  `exterior_condition` STRING,
  `fireplaces` STRING,
  `frontage` STRING,
  `fuel` STRING,
  `garage_spaces` STRING,
  `garage_type` STRING,
  `general_construction` STRING,
  `geographic_ward` STRING,
  `homestead_exemption` STRING,
  `house_extension` STRING,
  `house_number` STRING,
  `interior_condition` STRING,
  `location` STRING,
  `mailing_address_1` STRING,
  `mailing_address_2` STRING,
  `mailing_care_of` STRING,
  `mailing_city_state` STRING,
  `mailing_street` STRING,
  `mailing_zip` STRING,
  `market_value` STRING,
  `market_value_date` STRING,
  `number_of_bathrooms` STRING,
  `number_of_bedrooms` STRING,
  `number_of_rooms` STRING,
  `number_stories` STRING,
  `off_street_open` STRING,
  `other_building` STRING,
  `owner_1` STRING,
  `owner_2` STRING,
  `parcel_number` STRING,
  `parcel_shape` STRING,
  `quality_grade` STRING,
  `recording_date` STRING,
  `registry_number` STRING,
  `sale_date` STRING,
  `sale_price` STRING,
  `separate_utilities` STRING,
  `sewer` STRING,
  `site_type` STRING,
  `state_code` STRING,
  `street_code` STRING,
  `street_designation` STRING,
  `street_direction` STRING,
  `street_name` STRING,
  `suffix` STRING,
  `taxable_building` STRING,
  `taxable_land` STRING,
  `topography` STRING,
  `total_area` STRING,
  `total_livable_area` STRING,
  `type_heater` STRING,
  `unfinished` STRING,
  `unit` STRING,
  `utility` STRING,
  `view_type` STRING,
  `year_built` STRING,
  `year_built_estimate` STRING,
  `zip_code` STRING,
  `zoning` STRING,
  `pin` STRING,
  `building_code_new` STRING,
  `building_code_description_new` STRING,
  `objectid` STRING,
)
OPTIONS (
  description = 'Philadelphia OPA Properties - Raw Data',
  uris = ['gs://yaohan_data_lake/phl_opa_properties/*.jsonl'],
  format = 'JSON',
  max_bad_records = 0
)

CREATE OR REPLACE TABLE phl.opa_properties
CLUSTER BY (geog)
AS (
    SELECT * REPLACE (
        CAST(market_value AS NUMERIC) AS market_value,
        SAFE_CAST(sale_date AS TIMESTAMP) AS sale_date,
        CAST(sale_price AS NUMERIC) AS sale_price,
        CAST(year_built AS INT64) AS year_built,
        CASE
            WHEN geog = 'null' THEN NULL
            ELSE ST_GEOGFROMGEOJSON(geog, make_valid => TRUE)
        END AS geog
    )
    FROM data_lake.phl_opa_properties
);

CREATE OR REPLACE EXTERNAL TABLE `data_lake.septa_bus_stops` (
  `stop_id` STRING,
  `stop_code` STRING,
  `stop_name` STRING,
  `stop_desc` STRING,
  `stop_lat` STRING,
  `stop_lon` STRING,
  `zone_id` STRING,
  `stop_url` STRING,
  `location_type` STRING,
  `parent_station` STRING,
  `stop_timezone` STRING,
  `wheelchair_boarding` STRING
)
OPTIONS (
    description = 'Septa GTFS Bus Stops - Raw Data',
    uris = ['gs://yaohan_data_lake/septa_gtfs/bus_stops.txt'],
    format = 'csv',
    skip_leading_rows = 1,
    max_bad_records = 0,
    allow_quoted_newlines = true
);

CREATE OR REPLACE TABLE septa.bus_stops
AS (
    SELECT * REPLACE (
        CAST(stop_lon AS FLOAT64) AS stop_lon,
        CAST(stop_lat AS FLOAT64) AS stop_lat
    ),
    ST_GEOGPOINT(CAST(stop_lon AS FLOAT64), CAST(stop_lat AS FLOAT64)) AS geog
    FROM data_lake.septa_bus_stops
);