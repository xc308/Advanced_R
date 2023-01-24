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



#-------------------
# 17.7 Avoid copies
#-------------------

# slow source is growing an obj with a loop
# when use c(), append(), cbind(), rbind(), paste()
  # to create a bigger obj
# R must first allocate space for the new obj
# then copy the old obj to its new home


# if repeate this many times, e.g., in a for loop, 
  # can be quite expensive

# example: 
  # first generate random strings
  # combine them either iteratively or with a loop
  # using collapse() or in a single pass using paste()
  # note the performance of collapse() gets worse as 
    # number of string grows

random_string <- function() {
  paste(sample(letters, 50, replace = T), collapse = "")
}

rstring10 <- replicate(10, random_string())
rstring100 <- replicate(100, random_string())

collapse <- function(xs) {
  out <- ""
  for (x in xs) {
    out <- paste0(out, x)
  }
  out
}

str(rstring10)
# chr [1:10] 
#[1] "mnjaypwcwlymbvebmdmuzoruyapplraqqmmmmiuqosflabkvrb"
#[2] "jiqxliulbydygstegqrlhesnzchrdiuyhbybbnabigvpxglqfl"
#[3] "etbwwvbtonylitsdjjxwsxmtbledcpxsxsqkzbsgppefmkdkru"
#[4] "ocikkpimpwmqzbezosgtxztzmamrnixkspgrtldhtvdvuhlybc"
#[5] "geumcjlrnqpvjixnvtzmdzdelekrllqpwsrssfedtkkbdevrcy"

microbenchmark(
  loop10 <- collapse(rstring10),
  loop100 <- collapse(rstring100),
  vec10 <- paste(rstring10, collapse = ""),
  vec100 <- paste(rstring100, collapse = "")
  
)


# Unit: microseconds
#expr     min
#loop10 <- collapse(rstring10)  21.792
#loop100 <- collapse(rstring100) 730.334
#vec10 <- paste(rstring10, collapse = "")   4.459
#vec100 <- paste(rstring100, collapse = "")  32.001
#lq      mean   median       uq     max neval
#22.584  23.15396  22.7920  23.1255  38.334   100
#753.042 758.89774 755.3340 759.6465 833.417   100
#4.667   5.38103   4.8135   5.0005  27.417   100
#33.188  34.10773  33.7090  34.2295  47.917   100













































