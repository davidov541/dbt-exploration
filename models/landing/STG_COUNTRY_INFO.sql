{{ config(materialized='ephemeral') }}
WITH
SOURCE_DATA as (
    SELECT
        TWO_COUNTRY_CODE    as TWO_COUNTRY_CODE,   -- TEXT
        THREE_COUNTRY_CODE  as THREE_COUNTRY_CODE, -- TEXT
        FULL_NAME           as COUNTRY_NAME,       -- TEXT
        REGION              as REGION_NAME,        -- TEXT
        SUB_REGION          as SUB_REGION_NAME,    -- TEXT
        LOAD_TS             as LOAD_TS,            -- TIMESTAMP
        'SEED.COUNTRY_INFO' as RECORD_SOURCE       -- TEXT
    FROM {{ source('seeds', 'COUNTRY_INFO') }}
),
DEFAULT_RECORD as (
    SELECT
        '-1'         as TWO_COUNTRY_CODE,
        '-1     '    as THREE_COUNTRY_CODE,
        'Missing'    as COUNTRY_NAME,
        'Missing'    as REGION_NAME,
        'Missing'    as SUB_REGION_NAME,
        '2020-01-01' as LOAD_TS,
        'Missing'    as RECORD_SOURCE
),
WITH_DEFAULT_RECORD as(
    SELECT * FROM SOURCE_DATA
    UNION ALL
    SELECT * FROM DEFAULT_RECORD
),
HASHED as (
    SELECT
        {{ dbt_utils.generate_surrogate_key([ 'THREE_COUNTRY_CODE']) }} as COUNTRY_HKEY,
        {{ dbt_utils.generate_surrogate_key([ 'TWO_COUNTRY_CODE', 'THREE_COUNTRY_CODE',
                'COUNTRY_NAME', 'REGION_NAME', 'SUB_REGION_NAME'
                ]) }} as COUNTRY_HDIFF,
        * EXCLUDE LOAD_TS,
        LOAD_TS as LOAD_TS_UTC
    FROM WITH_DEFAULT_RECORD
)
SELECT * FROM HASHED