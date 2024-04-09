# Fetch Rewards Analytics Engineering Exercise

This is my attempt to model the data provided in the exercise. 
I've included some general thoughts below on some design choices/philosophy as well as my answers to the questions.
There are quite a few choices here that I would make differently if this were an actual work project; I've skipped quite a few steps in proper design (e.g. creating a catch-all for natural keys that don't exist in their dimensions.)

## Overall Approach
- This is DBT on top of AWS Snowflake; seemed appropriate given the stack
- Take advantage of DBT's test-driven design to find all of the data quality issues while I do modelling
- Also get an opportunity to play around with my own instance of Snowflake + learn how to set up local dev on WSL

## General Thoughts

### Warnings versus Errors
In my opinion, errors should be for true code issues (something that a developer _can_ fix) and warnings should be for data issues (something that a developer _cannot_ fix). 
In a production setting we'd move true data issues into another tool/platform (e.g. Monte Carlo) to manage to avoid flooding devs with too many failing issues.
I've included all of the data quality issues as warnings and set errors only for major issues (e.g. referential integrity, uniqueness) on the `marts` layer.

### Camelcase versus Snakecase, and other naming conventions
The original data came as camelCase but Snowflake works better with identifiers that are snake_cased. I've rewritten table and column names as such. 
I've also renamed some fields to more accurately describe what kind of data they are (e.g. timestamps that were described as dates).

### Performance
Almost everything would normally be built using incremental models; larger models would be clustered as well. Since we don't have an actual loading mechanism and there are no load dates, I'm not going to bother building this out with incremental models. 

## Answers

### Q1: Data Model
![Fetch Data Model](fetch.png)

### Q2: SQL Queries
See queries in semantic layer: [here](models/semantic/)

### Q3: Data Quality
All data quality tests are set up as dbt tests. 

At a high level:
- There are referential integrity issues between brands and receipts. 
- There are duplicate users and brands.
- There are a lot of nulls where there shouldn't be.
- There is data that is internally inconsistent based on business logic (e.g. the same product has multiple brands)
- The sum of individual parts does not equal the totals (e.g. Points Earned in individual receipt items does not total to Points Earned across the entire receipt)
- There are receipts with 0 points and 0 items; all receipts should be at least 1 item (otherwise... there would be no receipt? You can't buy nothing and get a receipt.) 

<details>
  <summary>Test Outputs</summary>

    (fetch) alui@DESKTOP-T9IJE3M:~/github/fetch$ dbt test
    23:02:01  Running with dbt=1.7.11
    23:02:01  Registered adapter: snowflake=1.7.3
    23:02:02  Found 16 models, 60 tests, 0 sources, 0 exposures, 0 metrics, 552 macros, 0 groups, 0 semantic models
    23:02:02  
    23:02:02  Concurrency: 4 threads (target='dev')
    23:02:02  
    23:02:02  1 of 60 START test accepted_values_stg_receipts_rewards_receipt_status__FINISHED__PENDING__FLAGGED__REJECTED__SUBMITTED  [RUN]
    23:02:02  2 of 60 START test accepted_values_stg_users_state__WI__NH__AL__SC__IL__OH__KY__CO__NY  [RUN]
    23:02:02  3 of 60 START test accepted_values_stg_users_user_role__CONSUMER ............... [RUN]
    23:02:02  4 of 60 START test dbt_utils_expression_is_true_stg_receipts_array_size_rewards_receipt_item_array_purchased_item_count  [RUN]
    23:02:03  4 of 60 WARN 164 dbt_utils_expression_is_true_stg_receipts_array_size_rewards_receipt_item_array_purchased_item_count  [WARN 164 in 0.60s]
    23:02:03  3 of 60 WARN 2 accepted_values_stg_users_user_role__CONSUMER ................... [WARN 2 in 0.60s]
    23:02:03  5 of 60 START test dbt_utils_expression_is_true_stg_receipts_created_timestamp_finished_timestamp  [RUN]
    23:02:03  2 of 60 PASS accepted_values_stg_users_state__WI__NH__AL__SC__IL__OH__KY__CO__NY  [PASS in 0.61s]
    23:02:03  1 of 60 PASS accepted_values_stg_receipts_rewards_receipt_status__FINISHED__PENDING__FLAGGED__REJECTED__SUBMITTED  [PASS in 0.62s]
    23:02:03  6 of 60 START test dbt_utils_expression_is_true_stg_receipts_created_timestamp_modified_timestamp  [RUN]
    23:02:03  7 of 60 START test dbt_utils_expression_is_true_stg_receipts_created_timestamp_scanned_timestamp  [RUN]
    23:02:03  8 of 60 START test dbt_utils_expression_is_true_stg_receipts_finished_timestamp_points_awarded_timestamp  [RUN]
    23:02:04  7 of 60 PASS dbt_utils_expression_is_true_stg_receipts_created_timestamp_scanned_timestamp  [PASS in 0.52s]
    23:02:04  9 of 60 START test dbt_utils_expression_is_true_stg_receipts_purchased_timestamp_created_timestamp  [RUN]
    23:02:04  6 of 60 PASS dbt_utils_expression_is_true_stg_receipts_created_timestamp_modified_timestamp  [PASS in 0.53s]
    23:02:04  8 of 60 WARN 52 dbt_utils_expression_is_true_stg_receipts_finished_timestamp_points_awarded_timestamp  [WARN 52 in 0.53s]
    23:02:04  5 of 60 PASS dbt_utils_expression_is_true_stg_receipts_created_timestamp_finished_timestamp  [PASS in 0.56s]
    23:02:04  10 of 60 START test dbt_utils_expression_is_true_stg_users_created_timestamp_last_login_timestamp  [RUN]
    23:02:04  11 of 60 START test dbt_utils_unique_combination_of_columns_fct_receipt_items_receipt_id__partner_item_id  [RUN]
    23:02:04  12 of 60 START test dbt_utils_unique_combination_of_columns_int_receipt_items_receipt_id__partner_item_id  [RUN]
    23:02:04  9 of 60 WARN 13 dbt_utils_expression_is_true_stg_receipts_purchased_timestamp_created_timestamp  [WARN 13 in 0.56s]
    23:02:04  13 of 60 START test hierarchy_stg_brands_category_code__category_name .......... [RUN]
    23:02:04  12 of 60 PASS dbt_utils_unique_combination_of_columns_int_receipt_items_receipt_id__partner_item_id  [PASS in 0.55s]
    23:02:04  14 of 60 START test is_positive_stg_receipts_points_earned ..................... [RUN]
    23:02:04  10 of 60 PASS dbt_utils_expression_is_true_stg_users_created_timestamp_last_login_timestamp  [PASS in 0.74s]
    23:02:04  15 of 60 START test is_positive_stg_receipts_purchased_item_count .............. [RUN]
    23:02:04  11 of 60 PASS dbt_utils_unique_combination_of_columns_fct_receipt_items_receipt_id__partner_item_id  [PASS in 0.83s]
    23:02:04  16 of 60 START test is_positive_stg_receipts_rewards_receipt_item_array ........ [RUN]
    23:02:05  13 of 60 WARN 1 hierarchy_stg_brands_category_code__category_name .............. [WARN 1 in 0.48s]
    23:02:05  17 of 60 START test is_positive_stg_receipts_total_spent_amt_usd ............... [RUN]
    23:02:05  16 of 60 PASS is_positive_stg_receipts_rewards_receipt_item_array .............. [PASS in 0.45s]
    23:02:05  18 of 60 START test not_null_dim_brands_brand_id ............................... [RUN]
    23:02:05  14 of 60 WARN 4 is_positive_stg_receipts_points_earned ......................... [WARN 4 in 0.75s]
    23:02:05  19 of 60 START test not_null_dim_receipts_receipt_id ........................... [RUN]
    23:02:05  15 of 60 WARN 15 is_positive_stg_receipts_purchased_item_count ................. [WARN 15 in 0.68s]
    23:02:05  17 of 60 WARN 15 is_positive_stg_receipts_total_spent_amt_usd .................. [WARN 15 in 0.40s]
    23:02:05  20 of 60 START test not_null_dim_users_user_id ................................. [RUN]
    23:02:05  21 of 60 START test not_null_fct_receipt_items_receipt_id ...................... [RUN]
    23:02:05  18 of 60 PASS not_null_dim_brands_brand_id ..................................... [PASS in 0.41s]
    23:02:05  22 of 60 START test not_null_int_brands_brand_id ............................... [RUN]
    23:02:05  19 of 60 PASS not_null_dim_receipts_receipt_id ................................. [PASS in 0.46s]
    23:02:05  23 of 60 START test not_null_int_receipt_items_receipt_id ...................... [RUN]
    23:02:06  20 of 60 PASS not_null_dim_users_user_id ....................................... [PASS in 0.45s]
    23:02:06  24 of 60 START test not_null_int_receipts_receipt_id ........................... [RUN]
    23:02:06  21 of 60 PASS not_null_fct_receipt_items_receipt_id ............................ [PASS in 0.49s]
    23:02:06  25 of 60 START test not_null_int_users_user_id ................................. [RUN]
    23:02:06  22 of 60 PASS not_null_int_brands_brand_id ..................................... [PASS in 0.41s]
    23:02:06  26 of 60 START test not_null_stg_brands_brand_code ............................. [RUN]
    23:02:06  23 of 60 PASS not_null_int_receipt_items_receipt_id ............................ [PASS in 0.42s]
    23:02:06  27 of 60 START test not_null_stg_brands_brand_id ............................... [RUN]
    23:02:06  24 of 60 PASS not_null_int_receipts_receipt_id ................................. [PASS in 0.40s]
    23:02:06  28 of 60 START test not_null_stg_brands_brand_name ............................. [RUN]
    23:02:06  25 of 60 PASS not_null_int_users_user_id ....................................... [PASS in 0.39s]
    23:02:06  29 of 60 START test not_null_stg_brands_cpg_id ................................. [RUN]
    23:02:06  27 of 60 PASS not_null_stg_brands_brand_id ..................................... [PASS in 0.41s]
    23:02:06  30 of 60 START test not_null_stg_brands_is_top_brand ........................... [RUN]
    23:02:06  29 of 60 PASS not_null_stg_brands_cpg_id ....................................... [PASS in 0.38s]
    23:02:06  31 of 60 START test not_null_stg_receipts_bonus_points_earned .................. [RUN]
    23:02:06  26 of 60 WARN 234 not_null_stg_brands_brand_code ............................... [WARN 234 in 0.68s]
    23:02:06  32 of 60 START test not_null_stg_receipts_created_timestamp .................... [RUN]
    23:02:06  28 of 60 PASS not_null_stg_brands_brand_name ................................... [PASS in 0.55s]
    23:02:06  33 of 60 START test not_null_stg_receipts_finished_timestamp ................... [RUN]
    23:02:07  30 of 60 WARN 612 not_null_stg_brands_is_top_brand ............................. [WARN 612 in 0.43s]
    23:02:07  34 of 60 START test not_null_stg_receipts_modified_timestamp ................... [RUN]
    23:02:07  31 of 60 WARN 575 not_null_stg_receipts_bonus_points_earned .................... [WARN 575 in 0.42s]
    23:02:07  35 of 60 START test not_null_stg_receipts_points_earned ........................ [RUN]
    23:02:07  32 of 60 PASS not_null_stg_receipts_created_timestamp .......................... [PASS in 0.41s]
    23:02:07  36 of 60 START test not_null_stg_receipts_purchased_item_count ................. [RUN]
    23:02:07  33 of 60 WARN 551 not_null_stg_receipts_finished_timestamp ..................... [WARN 551 in 0.57s]
    23:02:07  37 of 60 START test not_null_stg_receipts_purchased_timestamp .................. [RUN]
    23:02:07  34 of 60 PASS not_null_stg_receipts_modified_timestamp ......................... [PASS in 0.48s]
    23:02:07  38 of 60 START test not_null_stg_receipts_receipt_id ........................... [RUN]
    23:02:07  35 of 60 WARN 510 not_null_stg_receipts_points_earned .......................... [WARN 510 in 0.43s]
    23:02:07  39 of 60 START test not_null_stg_receipts_rewards_receipt_item_array ........... [RUN]
    23:02:07  36 of 60 WARN 484 not_null_stg_receipts_purchased_item_count ................... [WARN 484 in 0.44s]
    23:02:07  40 of 60 START test not_null_stg_receipts_scanned_timestamp .................... [RUN]
    23:02:07  37 of 60 WARN 448 not_null_stg_receipts_purchased_timestamp .................... [WARN 448 in 0.39s]
    23:02:07  41 of 60 START test not_null_stg_receipts_total_spent_amt_usd .................. [RUN]
    23:02:08  38 of 60 PASS not_null_stg_receipts_receipt_id ................................. [PASS in 0.45s]
    23:02:08  39 of 60 WARN 440 not_null_stg_receipts_rewards_receipt_item_array ............. [WARN 440 in 0.42s]
    23:02:08  42 of 60 START test not_null_stg_users_user_id ................................. [RUN]
    23:02:08  43 of 60 START test relationships_dim_receipts_user_id__user_id__ref_dim_users_  [RUN]
    23:02:08  40 of 60 PASS not_null_stg_receipts_scanned_timestamp .......................... [PASS in 0.43s]
    23:02:08  44 of 60 START test relationships_fct_receipt_items_brand_code__brand_code__ref_dim_brands_  [RUN]
    23:02:08  41 of 60 WARN 435 not_null_stg_receipts_total_spent_amt_usd .................... [WARN 435 in 0.43s]
    23:02:08  45 of 60 START test relationships_fct_receipt_items_receipt_id__receipt_id__ref_dim_receipts_  [RUN]
    23:02:08  43 of 60 PASS relationships_dim_receipts_user_id__user_id__ref_dim_users_ ...... [PASS in 0.57s]
    23:02:08  46 of 60 START test relationships_int_receipt_items_brand_code__brand_code__ref_int_brands_  [RUN]
    23:02:08  45 of 60 PASS relationships_fct_receipt_items_receipt_id__receipt_id__ref_dim_receipts_  [PASS in 0.45s]
    23:02:08  47 of 60 START test relationships_stg_receipts_user_id__user_id__ref_stg_users_  [RUN]
    23:02:08  42 of 60 PASS not_null_stg_users_user_id ....................................... [PASS in 0.77s]
    23:02:08  48 of 60 START test test_equality_points_earned ................................ [RUN]
    23:02:08  44 of 60 WARN 1971 relationships_fct_receipt_items_brand_code__brand_code__ref_dim_brands_  [WARN 1971 in 0.72s]
    23:02:08  49 of 60 START test unique_dim_brands_brand_id ................................. [RUN]
    23:02:09  46 of 60 WARN 1971 relationships_int_receipt_items_brand_code__brand_code__ref_int_brands_  [WARN 1971 in 0.46s]
    23:02:09  50 of 60 START test unique_dim_items_barcode ................................... [RUN]
    23:02:09  49 of 60 PASS unique_dim_brands_brand_id ....................................... [PASS in 0.42s]
    23:02:09  51 of 60 START test unique_dim_receipts_receipt_id ............................. [RUN]
    23:02:09  50 of 60 PASS unique_dim_items_barcode ......................................... [PASS in 0.40s]
    23:02:09  52 of 60 START test unique_dim_users_user_id ................................... [RUN]
    23:02:09  47 of 60 WARN 148 relationships_stg_receipts_user_id__user_id__ref_stg_users_ .. [WARN 148 in 0.94s]
    23:02:09  53 of 60 START test unique_int_brands_brand_id ................................. [RUN]
    23:02:09  51 of 60 PASS unique_dim_receipts_receipt_id ................................... [PASS in 0.50s]
    23:02:09  54 of 60 START test unique_int_items_barcode ................................... [RUN]
    23:02:09  48 of 60 WARN 161 test_equality_points_earned .................................. [WARN 161 in 1.10s]
    23:02:10  55 of 60 START test unique_int_receipts_receipt_id ............................. [RUN]
    23:02:10  52 of 60 PASS unique_dim_users_user_id ......................................... [PASS in 0.45s]
    23:02:10  56 of 60 START test unique_stg_brands_brand_code ............................... [RUN]
    23:02:10  53 of 60 PASS unique_int_brands_brand_id ....................................... [PASS in 0.48s]
    23:02:10  57 of 60 START test unique_stg_brands_brand_id ................................. [RUN]
    23:02:10  54 of 60 PASS unique_int_items_barcode ......................................... [PASS in 0.48s]
    23:02:10  58 of 60 START test unique_stg_brands_brand_name ............................... [RUN]
    23:02:10  56 of 60 WARN 3 unique_stg_brands_brand_code ................................... [WARN 3 in 0.48s]
    23:02:10  59 of 60 START test unique_stg_receipts_receipt_id ............................. [RUN]
    23:02:10  55 of 60 PASS unique_int_receipts_receipt_id ................................... [PASS in 0.53s]
    23:02:10  60 of 60 START test unique_stg_users_user_id ................................... [RUN]
    23:02:10  57 of 60 PASS unique_stg_brands_brand_id ....................................... [PASS in 0.52s]
    23:02:10  58 of 60 WARN 11 unique_stg_brands_brand_name .................................. [WARN 11 in 0.48s]
    23:02:10  59 of 60 PASS unique_stg_receipts_receipt_id ................................... [PASS in 0.43s]
    23:02:11  60 of 60 WARN 70 unique_stg_users_user_id ...................................... [WARN 70 in 0.72s]
    23:02:11  
    23:02:11  Finished running 60 tests in 0 hours 0 minutes and 9.08 seconds (9.08s).
    23:02:11  
    23:02:11  Completed with 24 warnings:
    23:02:11  
    23:02:11  Warning in test dbt_utils_expression_is_true_stg_receipts_array_size_rewards_receipt_item_array_purchased_item_count (models/staging/stg_receipts.yml)
    23:02:11  Got 164 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/dbt_utils_expression_is_true_s_8f972d7e6d95bb9b1a3f284c906343c6.sql
    23:02:11  
    23:02:11  Warning in test accepted_values_stg_users_user_role__CONSUMER (models/staging/stg_users.yml)
    23:02:11  Got 2 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_users.yml/accepted_values_stg_users_user_role__CONSUMER.sql
    23:02:11  
    23:02:11  Warning in test dbt_utils_expression_is_true_stg_receipts_finished_timestamp_points_awarded_timestamp (models/staging/stg_receipts.yml)
    23:02:11  Got 52 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/dbt_utils_expression_is_true_s_cfee73900ce33cb5adbcc57eca037f22.sql
    23:02:11  
    23:02:11  Warning in test dbt_utils_expression_is_true_stg_receipts_purchased_timestamp_created_timestamp (models/staging/stg_receipts.yml)
    23:02:11  Got 13 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/dbt_utils_expression_is_true_s_0a93745d4d123aea254d4dc69446a3e4.sql
    23:02:11  
    23:02:11  Warning in test hierarchy_stg_brands_category_code__category_name (models/staging/stg_brands.yml)
    23:02:11  Got 1 result, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_brands.yml/hierarchy_stg_brands_category_code__category_name.sql
    23:02:11  
    23:02:11  Warning in test is_positive_stg_receipts_points_earned (models/staging/stg_receipts.yml)
    23:02:11  Got 4 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/is_positive_stg_receipts_points_earned.sql
    23:02:11  
    23:02:11  Warning in test is_positive_stg_receipts_purchased_item_count (models/staging/stg_receipts.yml)
    23:02:11  Got 15 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/is_positive_stg_receipts_purchased_item_count.sql
    23:02:11  
    23:02:11  Warning in test is_positive_stg_receipts_total_spent_amt_usd (models/staging/stg_receipts.yml)
    23:02:11  Got 15 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/is_positive_stg_receipts_total_spent_amt_usd.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_brands_brand_code (models/staging/stg_brands.yml)
    23:02:11  Got 234 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_brands.yml/not_null_stg_brands_brand_code.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_brands_is_top_brand (models/staging/stg_brands.yml)
    23:02:11  Got 612 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_brands.yml/not_null_stg_brands_is_top_brand.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_receipts_bonus_points_earned (models/staging/stg_receipts.yml)
    23:02:11  Got 575 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/not_null_stg_receipts_bonus_points_earned.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_receipts_finished_timestamp (models/staging/stg_receipts.yml)
    23:02:11  Got 551 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/not_null_stg_receipts_finished_timestamp.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_receipts_points_earned (models/staging/stg_receipts.yml)
    23:02:11  Got 510 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/not_null_stg_receipts_points_earned.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_receipts_purchased_item_count (models/staging/stg_receipts.yml)
    23:02:11  Got 484 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/not_null_stg_receipts_purchased_item_count.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_receipts_purchased_timestamp (models/staging/stg_receipts.yml)
    23:02:11  Got 448 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/not_null_stg_receipts_purchased_timestamp.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_receipts_rewards_receipt_item_array (models/staging/stg_receipts.yml)
    23:02:11  Got 440 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/not_null_stg_receipts_rewards_receipt_item_array.sql
    23:02:11  
    23:02:11  Warning in test not_null_stg_receipts_total_spent_amt_usd (models/staging/stg_receipts.yml)
    23:02:11  Got 435 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/not_null_stg_receipts_total_spent_amt_usd.sql
    23:02:11  
    23:02:11  Warning in test relationships_fct_receipt_items_brand_code__brand_code__ref_dim_brands_ (models/mart/fct_receipt_items.yml)
    23:02:11  Got 1971 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/mart/fct_receipt_items.yml/relationships_fct_receipt_item_e634b40a36292cc46c421e9185639ef5.sql
    23:02:11  
    23:02:11  Warning in test relationships_int_receipt_items_brand_code__brand_code__ref_int_brands_ (models/intermediate/int_receipt_items.yml)
    23:02:11  Got 1971 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/intermediate/int_receipt_items.yml/relationships_int_receipt_item_1a284eb1cda58b752b78dbf68f2e31b0.sql
    23:02:11  
    23:02:11  Warning in test relationships_stg_receipts_user_id__user_id__ref_stg_users_ (models/staging/stg_receipts.yml)
    23:02:11  Got 148 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_receipts.yml/relationships_stg_receipts_user_id__user_id__ref_stg_users_.sql
    23:02:11  
    23:02:11  Warning in test test_equality_points_earned (tests/test_equality_points_earned.sql)
    23:02:11  Got 161 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/tests/test_equality_points_earned.sql
    23:02:11  
    23:02:11  Warning in test unique_stg_brands_brand_code (models/staging/stg_brands.yml)
    23:02:11  Got 3 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_brands.yml/unique_stg_brands_brand_code.sql
    23:02:11  
    23:02:11  Warning in test unique_stg_brands_brand_name (models/staging/stg_brands.yml)
    23:02:11  Got 11 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_brands.yml/unique_stg_brands_brand_name.sql
    23:02:11  
    23:02:11  Warning in test unique_stg_users_user_id (models/staging/stg_users.yml)
    23:02:11  Got 70 results, configured to warn if != 0
    23:02:11  
    23:02:11    compiled Code at target/compiled/fetch/models/staging/stg_users.yml/unique_stg_users_user_id.sql
    23:02:11  
    23:02:11  Done. PASS=36 WARN=24 ERROR=0 SKIP=0 TOTAL=60

</details>

### Q4: Email Message

(Note -- my personal preference is to go through these kinds of questions in a meeting with users, I often have follow-ups so this is easier than doing back-and-forth emails. Also, sending this many questions in one go typically leads to worse-quality answers as people will rush through them -- I usually try to limit to 3 questions per email and `@` the individual responsible for answering that question.)

> Hey `business-leader` -- 
> 
> I got a chance to look through the data. There are some issues (for example -- some brands, like "BAKEN-ETS", are duplicated, and the file format for the `users.json.gz` file is a little different than the other files) that I'll need some help with.
> 
> Data:
> - There are some brands and users in the receipts data that aren't in the brands and users files -- who should I talk to to get that missing data?
> - There's a fair number of duplicates (e.g. multiple users with the same ID) as well as inconsistencies (the same product being mapped to different brands/categories in different receipts) -- is there someone on the business team that I can talk to, to help me work out some business logic to clean up these issues?
> 
> Separately -- I have a few questions on your use case that'll help me design the data model better.
> - How frequently will you be looking at this data (hourly, daily, monthly)?
> - What level do you normally look at this data (e.g. brand performance at a week-over-week level)?
> - How often will we get data from this source?
> - What are your expectations in terms of data freshness? (for example -- would you expect to data from 1pm at 2pm, 5pm, 9am the next day)
> - How far back into history do you need to look into? (for example -- do you need data from the last month, 52 weeks, 5 years)
> - Do you expect this data to get restated (and if so, how often)?
> - Is there someone on your team (ideally an analyst who would be working on this regularly) that I can talk to in order to get more requirements?
> 
> For some background - this dataset is transaction-level so it could get quite large and have performance (and compute cost) implications; I'm looking for ways to scale back the data size by cutting down on history or grain without impacting the ways that you want to use this data.
> 
> Thanks --
> Andrew
