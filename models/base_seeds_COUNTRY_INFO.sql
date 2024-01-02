with source as (
      select * from {{ source('seeds', 'COUNTRY_INFO') }}
),
renamed as (
    select
        {{ adapter.quote("TWO_COUNTRY_CODE") }},
        {{ adapter.quote("THREE_COUNTRY_CODE") }},
        {{ adapter.quote("FULL_NAME") }},
        {{ adapter.quote("REGION") }},
        {{ adapter.quote("SUB_REGION") }},
        {{ adapter.quote("LOAD_TS") }}

    from source
)
select * from renamed
  