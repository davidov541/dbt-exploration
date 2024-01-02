{% snapshot SNSH_ABC_BANK_SECURITY_INFO %}

{{
    config(
      unique_key= 'SECURITY_HKEY',
      strategy='check',
      target_schema='PROCESSED_LANDING',
      check_cols=['SECURITY_HDIFF'],
    )
}}

select * from {{ ref('STG_ABC_BANK_SECURITY_INFO') }}

{% endsnapshot %}