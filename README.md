# RFM-model-practice
RFM model practice in R

The general goal of this task is that we try to distinguish potential high-value consumers and separate them from low-value consumers. 

Recency, frequency and monetary value (RFM) are 3 factors that we can calculate and use to do the targeting. 

In this assignment, we will work with a sample dataset from a company called CDNOW, to try and figure out the potential value of a consumer in a given month, using only historical data prior to this month. We will then classify the sample by the “RFM index” we generated and see how much it is related to actual consumer spending.

In the raw data, the first two variables are individual ID ($id), date of the trip ($date), purchase quantity (i.e. number of CDs purchased, $qty) and total expenditure (in dollar values, $expd). Our general direction is to aggregate the data into individual-month level, so keys should be ID, year, month. Quantity and expenditure should be summed up. You also need how many trips (construct $trips) the individual has been to the shop. Of course, most people will not go to the shop and buy something every month. But we need an RFM prediction for each individual in every month (within 1997-1998). When there is no trip in a given month, replace trip, expenditure and quantity to zero. 

An RFM index is an weighted sum of the 3 measures, for each individual i in month t:
    RFMit = b1*Rit +b2*Fit +b3*Mit

When you have computed this measure, sort your sample according to the RFM index and split it into 10 (roughly) even-sized portions. Thehigh RFM parts refer to individuals (in particular months) that are more valuable than the low RFM parts of your sample.
