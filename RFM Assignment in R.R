# # ===================================================
# GBA464: RFM analysis on CDNOW data
# Description: Lab on functions and loops
# Data: CDNOW customer data (this time full data)
# Source: provided by Professor Bruce Hardie on
#   http://www.brucehardie.com/datasets/CDNOW_sample.zip
# ===================================================

# ====== CLEAR EVERYTHING ======
rm(list = ls())

# ====== READ TRIAL DATA =======

url <- 'https://dl.dropboxusercontent.com/u/13844770/rdata/assignment_3/CDNOW_sample.txt'
if (!file.exists('CDNOW_sample.txt')) {     # check whether data exists in local folder (prevents downloading every time)
    download.file(url, 'CDNOW_sample.txt')
}
df.raw <- read.fwf('CDNOW_sample.txt', width = c(6, 5, 9, 3, 8), stringsAsFactors = F)  # load data

# ====== Section 2: loading the data ======

df.raw[[1]] <- NULL # drop old id
names(df.raw) <- c("id", "date", "qty", "expd")

# a) generate year and month

date <- as.Date(as.character(df.raw$date), "%Y%m%d")
year <- format(date, "%Y")
month <- format(date, "%m")
df <- cbind(df.raw, year, month)


# b) aggregate into monthly data with number of trips and total expenditure

df.monthly <- aggregate(x = list(qty = df$qty,
                                 expd = df$expd),
                        by = list(ID = df$id,
                                  year = df$year,
                                  month = df$month),
                        FUN = sum)

df.trip <- aggregate(x = list(trip = df$qty),
                     by = list(ID = df$id,
                                year = df$year,
                                month = df$month),
                     FUN = length)

# c) generate a table of year-months, merge, replace no trip to zero.
# Hint: how do you deal with year-months with no trip? These periods are not in the original data,
#   but you might need to have these periods when you calcualte RFM, right?
# Consider expanding the time frame using expand.grid() but you do not have to.

df.mtrip <- merge(df.monthly, df.trip, by = c('ID', 'year', 'month'))
df1 <- expand.grid(ID = seq(1, 1000, 1), year = seq(1997, 1998,1), month = sprintf('%0.2d', 1:12))
df2 <- merge(df1, df.mtrip, by = c('ID', 'year', "month"), all.x = TRUE)

df2[is.na(df2)] <- 0


# now we should have the dataset we need; double check to make sure that every consumer is in every period


# ====== Section 3.1: recency ======
# use repetition statement, such as a "for-loop", to generate a recency measure for each consumer 
#   in each period. Hint: if you get stuck here, take a look at Example 3 when we talked about "for-loops"
#   call it df$recency

df2$recency <- 0

for (i in 1 : 1000){
    for (m in 1 : 23){
      if (m == 1){
        df2$recency[24 * (i - 1) + m] <- NA}
      
      if (df2$trip[24 * (i - 1) + m] != 0){
          df2$recency[24 * (i - 1) + m + 1] <- 1
          }else{
            df2$recency[24 * (i - 1) + m + 1] <-  df2$recency[24 * (i - 1) + m] + 1
          }
    }
}


# ====== Section 3.2: frequency ======
# first define quarters and collapse/merge data sets
#   quarters should be e.g. 1 for January-March, 1997, 2 for April-June, 1997, ...
#   and there should be 8 quarters in the two-year period
#   Next, let's define frequency purchase occasions in PAST QUARTER
#   Call this df$frequency

df2$quarter <- rep(1:8, each = 3, times = 1000)
df2$frequency <- 0

for (i in 1 : 1000){
  for (q in 1 : 8){
    if (q == 1){
      df2$frequency[(24 * (i - 1) + 3 * q - 2) : (24 * (i - 1) + 3 * q)] <- NA
    }else{
      df2$frequency[(24 * (i - 1) + 3 * q - 2) : (24 * (i - 1) + 3 * q)] <- sum(df2$trip[(24 * (i - 1) + 3 * (q - 1) - 2) : (24 * (i - 1) + 3 * (q - 1))])
    }
  }
}



# ====== Section 3.3: monetary value ======
# average monthly expenditure in the months with trips (i.e. when expenditure is nonzero)
#   for each individual in each month, find the average expenditure from the beginning to 
#   the PAST MONTH. Call this df$monvalue

library(Matrix)   # Use nnzero function in this package

df2$monvalue <- 0

for (i in 1 : 1000){
  for (m in 1 : 23){
    if(m == 1){
      df2$monvalue[24 * (i - 1) + m] <- NA}

    if(df2$trip[24 * (i - 1) + m] != 0){
        df2$monvalue[24 * (i - 1) + m + 1] <- sum(df2$expd[(24 * (i - 1) + 1) : (24 * (i - 1) + m)]) / nnzero(df2$trip[(24 * (i - 1) + 1) : (24 * (i - 1) + m)])
        }else{
          df2$monvalue[24 * (i - 1) + m + 1] <- df2$monvalue[24 * (i - 1) + m]
        }
  }
}



# ====== Section 4: Targeting using RFM ======
# now combine these and construct an RFM index
#   You only need to run this section.

b1 <- -0.1
b2 <- 3.5
b3 <- 0.2

df2$index <- b1 * df2$recency + b2 * df2$frequency + b3 * df2$monvalue


# validation: check whether the RFM index predict customer purchase patterns
# Order your sample (still defined by keys of consumer-year-month) based on the RFM index. 
#   Split your sample into 10 groups. The first group is top 10% in terms of
#   the RFM index; second group is 10%-20%, etc.
# Make a bar plot on the expected per-trip revenue that these consumers generate and comment on 
#   whether the RFM index help you segment which set of customers are "more valuable"

group <- quantile(df2$index, na.rm = TRUE, probs = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)/100)

for (i in 1:24000) {
  if (is.na(df2$index[i])) {
    df2$group[i] <- NA
    } else {
      for (g in 1:10) {
        if (df2$index[i] >= group[g] & df2$index[i] < group[g + 1]) {
          df2$group[i] <- g
        }
      }
    }
}


RFM <- aggregate(
  x = list(expenditure = df2$expd), 
  by = list(deciles = df2$group),
  FUN = mean
)

barplot(RFM$expenditure, names.arg=RFM$deciles,las=0,
        main = 'Average expenditure by deciles in the RFM index',
        ylab = 'average expenditure',
        xlab = 'deciles in the RFM index'
)

