SELECT
    EXCHANGE_CODE,
    EXCHANGE_NAME,
    COUNTRY_CODE,
    CITY_NAME,
    TRADING_START_TIME,
    TRADING_END_TIME,
    TRADING_TIME_ZONE,
    LOAD_TS_UTC,
    EXCHANGE_HKEY,
    EXCHANGE_HDIFF,
    RECORD_SOURCE
FROM {{ ref('REF_EXCHANGE_INFO_ABC_BANK') }}