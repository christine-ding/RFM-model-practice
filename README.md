# RFM-model-practice
RFM model practice in R

The general goal of this task is that we try to distinguish potential high-value consumers and separate them from low-value consumers. 

Recency, frequency and monetary value (RFM) are 3 factors that we can calculate and use to do the targeting. 

In this assignment, we will work with a sample dataset from a company called CDNOW, to try and figure out the potential value of a consumer in a given month, using only historical data prior to this month. We will then classify the sample by the “RFM index” we generated and see how much it is related to actual consumer spending.

An RFM index is an weighted sum of the 3 measures, for each individual i in month t:
    RFMit = b1*Rit +b2*Fit +b3*Mit

When you have computed this measure, sort your sample according to the RFM index and split it into 10 (roughly) even-sized portions. The high RFM parts refer to individuals (in particular months) that are more valuable than the low RFM parts of your sample.
