with source as (
      select * from {{ source('abc_bank', 'ABC_BANK_POSITION') }}
),
renamed as (
    select
        {{ adapter.quote("ACCOUNTID") }},
        {{ adapter.quote("SYMBOL") }},
        {{ adapter.quote("DESCRIPTION") }},
        {{ adapter.quote("EXCHANGE") }},
        {{ adapter.quote("REPORT_DATE") }},
        {{ adapter.quote("QUANTITY") }},
        {{ adapter.quote("COST_BASE") }},
        {{ adapter.quote("POSITION_VALUE") }},
        {{ adapter.quote("CURRENCY") }},
        {{ adapter.quote("ORDINAL_POSITION") }}

    from source
)
select * from renamed
  