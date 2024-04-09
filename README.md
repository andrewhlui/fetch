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
- There is data that defies business logic. 
- There are items that do not sum up to their totals.

### Q4: Email Message

(Note -- my personal preference is to go through these kinds of questions in a meeting with users, I often have follow-ups so this is easier than doing back-and-forth emails. Also, sending this many questions in one go typically leads to worse-quality answers as people will rush through them -- I usually try to limit to 3 questions per email and `@` the individual responsible for answering that question.)

Hey `business-leader` -- 

I got a chance to look through the data. There are some issues (for example -- some brands, like "BAKEN-ETS", are duplicated, and the file format for the `users.json.gz` file is a little different than the other files) that I'll need some help with.

Data:
- There are some brands and users in the receipts data that aren't in the brands and users files -- who should I talk to to get that missing data?
- There's a fair number of duplicates (e.g. multiple users with the same ID) as well as inconsistencies (the same product being mapped to different brands/categories in different receipts) -- is there someone on the business team that I can talk to, to help me work out some business logic to clean up these issues?

Separately -- I have a few questions on your use case that'll help me design the data model better.
- How frequently will you be looking at this data (hourly, daily, monthly)?
- What level do you normally look at this data (e.g. brand performance at a week-over-week level)?
- How often will we get data from this source?
- What are your expectations in terms of data freshness? (for example -- would you expect to data from 1pm at 2pm, 5pm, 9am the next day)
- How far back into history do you need to look into? (for example -- do you need data from the last month, 52 weeks, 5 years)
- Do you expect this data to get restated (and if so, how often)?
- Is there someone on your team (ideally an analyst who would be working on this regularly) that I can talk to in order to get more requirements?

For some background - this dataset is transaction-level so it could get quite large and have performance (and compute cost) implications; I'm looking for ways to scale back the data size by cutting down on history or grain without impacting the ways that you want to use this data.

Thanks --
Andrew

What questions do you have about the data?
How did you discover the data quality issues?
What do you need to know to resolve the data quality issues?
What other information would you need to help you optimize the data assets you're trying to create?
What performance and scaling concerns do you anticipate in production and how do you plan to address them?