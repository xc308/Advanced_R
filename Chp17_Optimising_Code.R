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



#---------------
# 17.6 Vectorise
#---------------

# think entire vectors instead of components of a vector
# the loops in a vectorised function are written in C instead of R
# mush faster

# using vectorisation for performance means
# finding the existing R function that's implemented in C
# and mostly closely applies to your problem

# rowSums(), colSums(), rowMeans(), colMeans()
# vectorised matrix function will always be faster tha apply()

# vectorised subsetting can lead to big improvements in speed


# matrix algebra is a general example of vectorisation


# downside of vectorisation is harder to predict how operation will scale

# expect: looking up 10 elements will take 10* as long as looking up 1
# but it only takes 9 * longer to look up for 100 elemtens 
# than it does to look up for 1

lookup <- setNames(as.list(sample(100, 26)), letters)

x1 <- "j"
x10 <- sample(letters, 10)
x100 <- sample(letters, 100, replace = T)

microbenchmark(
  lookup[x1],
  lookup[x10],
  lookup[x100]
)
lookup["j"]
# $j
# [1] 98
lookup[["j"]]
# [1] 98

#Unit: nanoseconds
#expr  min   lq    mean median     uq   max
#lookup[x1]  209  251  269.89  251.0  271.5   918
#lookup[x10]  876  917 1004.84  918.0  959.0  5125
#lookup[x100] 2876 3501 4609.83 3875.5 5042.0 16084














































