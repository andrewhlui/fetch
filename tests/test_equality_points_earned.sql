{{ config(severity='warn') }}

{{ generate_comparison(ref('fct_receipt_items'), ref('dim_receipts'), attributes=['receipt_id'], measure='points_earned') }}