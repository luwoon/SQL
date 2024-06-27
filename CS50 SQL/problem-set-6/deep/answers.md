# From the Deep

In this problem, you'll write freeform responses to the questions provided in the specification.

## Random Partitioning

The observations will be evenly distributed because each one is randomly assigned to any one of the three boats. Or, put another way, an observation is equally likely to be sent to any boat. So, even if AquaByte most commonly collects observations between midnight and 1am, observations will be evenly spread out among the boats.

However, the researcher will need to run the query on all of the boats. Because the observations are randomly assigned to any boat, each observation between midnight and 1am could be on any one of the three boats. If a query is only run on one boat, there’s a chance it has missed observations, stored on other boats, that it should have returned.

## Partitioning by Hour

The observations will not be evenly distributed. Since most observations are collected between midnight and 1am, and because Boat A will receive all observations within the hours of 0–7 (i.e., midnight to 7:59 AM), inclusive, Boat A will receive most of the observations.

However, the researcher will need to run the query on only some of the boats. Boat A will receive all observations within the hours of 0–7 (i.e., midnight to 7:59 AM), inclusive. This means that all observations between midnight and 1am can be found on Boat A.

## Partitioning by Hash Value

The observations will be evenly distributed. A single observation is no more likely to be assigned one hash value than another, which means any single observation could be sent to any one of the three available boats.

However, the researcher will likely need to run the query on all of the boats. Each observation in a range of observations could be assigned any arbitrary hash value: the hash values themselves are not in a specified range. For that reason, the query would be best run on all boats.