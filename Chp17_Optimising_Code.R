#=======================
# Chp 17 Optimising code
#=======================
install.packages("devtools")
devtools::install_github("hadley/lineprof")
# to understand the performance of R code

library(lineprof)
source("profiling-example.R")


#-----------------------------
# 17.2 Improving performance
#-----------------------------

# once used profiling to identify a bottleneck
# need to make it faster. 

# techniques broadly useful
  # look for existing solo
  # do less work
  # vectorise
  # parallelise
  # avoid copies
  # byte-code compile

# better technique is to write C++


#------------------------
# 17.3 Code organisation
#------------------------

# representative test case
  # big enough to capture the essense of your problem
  # small enough that it takes few seconds to run

# use this test case to check all variants return the same
# result

  # stopifnot and all.equal()

# for real problem with fewer possible outputs
  # need more tests to make sure the correct answer
    # is not an accident

# but not for the mean()
mean1 <- function(x) mean(x)
mean2 <- function(x) sum(x) / length(x)



x <- runif(100)
stopifnot(all.equal(mean1(x), mean2(x)))

microbenchmark(
  mean1(x),
  mean2(x)
)

# mean1 is slower than mean2 

# should have a target speed that
  # bottleneck is no longer the problem

# you don't want to spend time to over optimising the code


































