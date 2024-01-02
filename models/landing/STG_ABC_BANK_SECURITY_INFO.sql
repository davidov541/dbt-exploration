{{ config(materialized='ephemeral') }}
WITH
SOURCE_DATA as (
    SELECT
        SECURITY_CODE                 as SECURITY_CODE, -- TEXT
        SECURITY_NAME                 as SECURITY_NAME, -- TEXT
        SECTOR                        as SECTOR_NAME,   -- TEXT
        INDUSTRY                      as INDUSTRY_NAME, -- TEXT
        COUNTRY                       as COUNTRY_CODE,  -- TEXT
        EXCHANGE                      as EXCHANGE_CODE, -- TEXT
        LOAD_TS                       as LOAD_TS,       -- TIMESTAMP
        'SEED.ABC_BANK_SECURITY_INFO' as RECORD_SOURCE  -- TEXT
    FROM {{ source('seeds', 'ABC_BANK_SECURITY_INFO') }}
),
DEFAULT_RECORD as (
    SELECT
        '-1'           as SECURITY_CODE
        , 'Missing'    as SECURITY_NAME
        , 'Missing'    as SECTOR_NAME
        , 'Missing'    as INDUSTRY_NAME
        , '-1'         as COUNTRY_CODE
        , '-1'         as EXCHANGE_CODE
        , '2020-01-01' as LOAD_TS
        , 'Missing'    as RECORD_SOURCE
),
WITH_DEFAULT_RECORD as(
    SELECT * FROM SOURCE_DATA
    UNION ALL
    SELECT * FROM DEFAULT_RECORD
),
HASHED as (
    SELECT
        {{ dbt_utils.generate_surrogate_key([ 'SECURITY_CODE']) }} as SECURITY_HKEY,
        {{ dbt_utils.generate_surrogate_key([ 'SECTOR_NAME', 'SECURITY_CODE',
                'SECURITY_NAME', 'EXCHANGE_CODE', 'INDUSTRY_NAME', 'COUNTRY_CODE'
                ]) }} as SECURITY_HDIFF,
        * EXCLUDE LOAD_TS,
        LOAD_TS as LOAD_TS_UTC
    FROM WITH_DEFAULT_RECORD
)
SELECT * FROM HASHED