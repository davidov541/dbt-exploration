{{ config(materialized='ephemeral') }}
WITH
SOURCE_DATA as (
    SELECT
        EXCHANGE_CODE                 as EXCHANGE_CODE,      -- TEXT
        EXCHANGE_NAME                 as EXCHANGE_NAME,      -- TEXT
        COUNTRY                       as COUNTRY_CODE,       -- TEXT
        CITY                          as CITY_NAME,          -- TEXT
        TRADING_START                 as TRADING_START_TIME, -- TEXT
        TRADING_END                   as TRADING_END_TIME,   -- TEXT
        TIMEZONE                      as TRADING_TIME_ZONE,  -- TEXT
        LOAD_TS                       as LOAD_TS,            -- TIMESTAMP
        'SEED.ABC_BANK_EXCHANGE_INFO' as RECORD_SOURCE       -- TEXT
    FROM {{ source('seeds', 'ABC_BANK_EXCHANGE_INFO') }}
),
DEFAULT_RECORD as (
    SELECT
        '-1'         as EXCHANGE_CODE,
        'Missing'    as EXCHANGE_NAME,
        '-1'         as COUNTRY_CODE,
        'Missing'    as CITY_NAME,
        'Missing'    as TRADING_START_TIME,
        'Missing'    as TRADING_END_TIME,
        'Missing'    as TRADING_TIME_ZONE,
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
        {{ dbt_utils.generate_surrogate_key([ 'EXCHANGE_CODE']) }} as EXCHANGE_HKEY,
        {{ dbt_utils.generate_surrogate_key([ 'EXCHANGE_CODE', 'EXCHANGE_NAME',
                'COUNTRY_CODE', 'CITY_NAME', 'TRADING_START_TIME', 'TRADING_END_TIME',
                'TRADING_TIME_ZONE'
                ]) }} as EXCHANGE_HDIFF,
        * EXCLUDE LOAD_TS,
        LOAD_TS as LOAD_TS_UTC
    FROM WITH_DEFAULT_RECORD
)
SELECT * FROM HASHED