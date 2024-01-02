{{ config(materialized='ephemeral') }}
WITH
SOURCE_DATA as (
    SELECT
        CURRENCY_CODE        as CURRENCY_CODE,       -- TEXT
        FULL_NAME            as CURRENCY_NAME,       -- TEXT
        SYMBOL               as CURRENCY_SYMBOL,      -- TEXT
        COUNTRY              as OWNING_COUNTRY_CODE, -- TEXT
        LOAD_TS              as LOAD_TS,             -- TIMESTAMP
        'SEED.CURRENCY_INFO' as RECORD_SOURCE        -- TEXT
    FROM {{ source('seeds', 'CURRENCY_INFO') }}
),
DEFAULT_RECORD as (
    SELECT
        '-1'         as CURRENCY_CODE,
        'Missing'    as CURRENCY_NAME,
        '?'          as CURRENCY_SYMBOL,
        'Missing'    as OWNING_COUNTRY_CODE,
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
        {{ dbt_utils.generate_surrogate_key([ 'CURRENCY_CODE']) }} as CURRENCY_HKEY,
        {{ dbt_utils.generate_surrogate_key([ 'CURRENCY_CODE', 'CURRENCY_NAME',
                'CURRENCY_SYMBOL', 'OWNING_COUNTRY_CODE'
                ]) }} as CURRENCY_HDIFF,
        * EXCLUDE LOAD_TS,
        LOAD_TS as LOAD_TS_UTC
    FROM WITH_DEFAULT_RECORD
)
SELECT * FROM HASHED