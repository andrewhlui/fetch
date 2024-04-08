# Fetch Rewards Analytics Engineering Exercise

This is my attempt to model the data provided in the exercise. Included some general thoughts below on some design choices/philosophy.
This is based off of my experience; if you disagree I'm down to debate about it. 

## General Thoughts

### Warnings versus Errors
In my opinion, errors should be for true code issues (something that a developer _can_ fix) and warnings should be for data issues (something that a developer _cannot_ fix). 
In a production setting we'd move true data issues into another tool/platform (e.g. Monte Carlo) to manage to avoid flooding devs with too many failing issues.
