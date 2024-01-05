{{ config(materialized='ephemeral') }}
WITH
SOURCE_DATA as (
    SELECT
        ACCOUNTID         as ACCOUNT_CODE,     -- TEXT
        SYMBOL            as SECURITY_CODE,    -- TEXT
        DESCRIPTION       as SECURITY_NAME,    -- TEXT
        EXCHANGE          as EXCHANGE_CODE,    -- TEXT
        {{ to_21st_century_date('REPORT_DATE') }} as REPORT_DATE,      -- DATE
        QUANTITY          as QUANTITY,         -- NUMBER
        COST_BASE         as COST_BASE,        -- NUMBER
        POSITION_VALUE    as POSITION_VALUE,   -- NUMBER
        CURRENCY          as CURRENCY_CODE,    -- TEXT
        ORDINAL_POSITION  as ORDINAL_POSITION, -- TEXT
        'SOURCE_DATA.ABC_BANK_POSITION' as RECORD_SOURCE
    FROM {{ source('abc_bank', 'ABC_BANK_POSITION') }}
),
DEFAULT_RECORD as (
    SELECT
        '-1'                as ACCOUNT_CODE,
        '-1'                as SECURITY_CODE,
        'Missing'           as SECURITY_NAME,
        '-1'                as EXCHANGE_CODE,
        '2020-01-01'        as REPORT_DATE,
        -1                  as QUANTITY,
        -1                  as COST_BASE,
        -1                  as POSITION_VALUE,
        '-1'                as CURRENCY_CODE,
        '-1'                as ORDINAL_POSITION,
        'System.DefaultKey' as RECORD_SOURCE
),
WITH_DEFAULT_RECORD as (
    SELECT * FROM SOURCE_DATA
    UNION ALL
    SELECT * FROM DEFAULT_RECORD
),
HASHED as (
    SELECT
        {{ dbt_utils.generate_surrogate_key([ 'ACCOUNT_CODE', 'SECURITY_CODE']) }} as POSITION_HKEY,
        {{ dbt_utils.generate_surrogate_key([ 'ACCOUNT_CODE', 'SECURITY_CODE',
                'SECURITY_NAME', 'EXCHANGE_CODE', 'REPORT_DATE',
                'QUANTITY', 'COST_BASE', 'POSITION_VALUE', 'CURRENCY_CODE',
                'ORDINAL_POSITION'
                ]) }} as POSITION_HDIFF,
        *,
        '{{ run_started_at }}'::timestamp as LOAD_TS_UTC
    FROM WITH_DEFAULT_RECORD
)
SELECT * FROM HASHED