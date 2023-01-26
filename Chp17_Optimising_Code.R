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



#-----------------------------
# 17.8 Byte Code Compilation
#-----------------------------

# speed up using compiling

lapply2 <- function(x, f, ...) {
  out <- vector("list", length(x))
  for (i in seq_along(x)) {
   out[[i]] <- f(x[[i]], ...)
  }
  out
}
lapply2_cmpil <- compiler::cmpfun(lapply2)

#compiler::cmpfun()
  # provide a interfact to a byte code compiler for R

x <- list(1:10, letters, c(F, T), NULL)
microbenchmark(
  lapply2(x, is.null),
  lapply2_cmpil(x, is.null),
  lapply(x, is.null)
)

# Unit: microseconds
# expr   min    lq
# lapply2(x, is.null) 2.209 2.334
# lapply2_cmpil(x, is.null) 2.250 2.334
# lapply(x, is.null) 1.667 1.793
# mean median     uq      max neval
# 29.45064 2.3760 2.4175 2707.834   100
# 2.57272 2.3760 2.4180   18.542   100
# 1.92268 1.8755 1.9385    5.917   100

# compilation helps here,
  # all R functions are byte code compiled
  # by default



#-----------------------
# 17.9 Case study: t-test
#------------------------

# 1000 experiments (rows) 
  # each collects data on 50 individuals (cols)

# first 25 individuals in each row (exp) are grp 1
# the 2nd 25 in each row (experiment) are grp2

m <- 1000
n <- 50
X <- matrix(rnorm(m * n, mean = 10, sd = 3), nrow = m)
grp <- rep(1:2, each = n/2)

# two ways for t-test
  # interface or
  # two vectors


system.time(for (i in 1:m) t.test(X[i, ] ~ grp)$stat)
#   user  system elapsed 
# 0.371   0.009   0.391 

system.time(
  for (i in 1:m) t.test(X[i, grp ==1], X[i, grp == 2])$stat
)

#   user  system elapsed 
# 0.144   0.004   0.148 

## interface is slower

# can also build a function

cmpT <- function(x, grp) {
  t.test(x[grp == 1], x[grp == 2])$stat
}

system.time(t1 <- apply(X, 1, cmpT, grp = grp)) 
# user  system elapsed 
# 0.136   0.001   0.138 


## to make this faster
  # notice in stats:::t.test.default()
  # it does more than just compute the t-statistic
  # also computes the p-value and formats for print output

# strip out these pieces to go faster

View(stats:::t.test.default)


my_t <- function(x, grp) {
  t_stat <- function(x) {
    m <- mean(x)
    n <- length(x)
    var <- sum((x - m)^2) / (n - 1)
    
    list(m = m, n = n, var = var)
  }
  
  g1 <- t_stat(x[grp == 1])
  g2 <- t_stat(x[grp == 2])
  
  se_total <- sqrt(g1$var / g1$n + g2$var / g2$n)
  (g1$m - g2$m) / se_total
  
}

system.time(t2 <- apply(X, 1, my_t, grp = grp))
#  user  system elapsed 
# 0.038   0.002   0.046 

system.time(t1 <- apply(X, 1, cmpT, grp = grp)) 
# user  system elapsed 
# 0.136   0.001   0.138 


all.equal(t1, t2)
# [1] TRUE
stopifnot(all.equal(t1, t2))


## can make it faster by vectorising it
# instead of looping over the array outside the function
# modify t_stat() to work with a matrix of values
  # mean -> rMeans()
  # length -> ncol()
  # sum -> rowSums()

rowstat <- function(X, grp) {
  t_stat <- function(X) {
    m <- rowMeans(X)
    n <- ncol(X)
    var <- rowSums((X - m)^2) / (n -1)
    
    list(m = m, n = n, var = var)
  }
  
  g1 <- t_stat(X[, grp == 1])
  g2 <- t_stat(X[, grp == 2])
  
  se_total <- sqrt(g1$var / g1$n + g2$var / g2$n)
  
  (g1$m - g2$m) / se_total

}

system.time(t3 <- rowstat(X, grp))
# user  system elapsed 
# 0.016   0.000   0.017 


system.time(t2 <- apply(X, 1, my_t, grp = grp))
#  user  system elapsed 
# 0.038   0.002   0.046 

system.time(t1 <- apply(X, 1, cmpT, grp = grp)) 
# user  system elapsed 
# 0.136   0.001   0.138 

all.equal(t1, t3)
# [1] TRUE

## try byte code compilation 
  # to see if can speed up again

rowstat_compile <- compiler::cmpfun(rowstat)

microbenchmark(
  rowstat(X, grp),
  rowstat_compile(X, grp),
  unit = "ms"
)

# Unit: milliseconds
# expr      min       lq
# rowstat(X, grp) 7.630042 7.772543
# rowstat_compile(X, grp) 7.621917 7.742126
# mean   median       uq      max neval
# 8.068398 7.891042 8.045355 14.85996   100
#8.224489 7.893000 7.994042 18.28679   100
> 
# this example compiler does not help at all! 





























































