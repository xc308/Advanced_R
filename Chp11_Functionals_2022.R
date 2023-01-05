#^^^^^^^^^^^^^^^^^^^^^^^^
# Chapter 11 Functionals
#^^^^^^^^^^^^^^^^^^^^^^^^

=^.^=
  
# A higher-order function is a function that takes
    # a function as an input or returns a function as output
  
# one type of higher-order function: closer
    # functions returned by another function
  
  # complement to a closer is functional
    # a function that takes a function as an input and 
    # returns a vector as output
  
randomise <- function(f) f(runif(1e3))
# input is a function f
# then call the function with 1000 rd uniform numbers
randomise(mean)
# [1] 0.5029821
randomise(sum)
# [1] 509.8326


## common use of functional is an alternative for loop
  # downside of loop:
    # slow
    # not very expressive

## pros of loop:
# instead of using for loop
  # better to use functionals

# also useful for encapsulating common data manipulation task
  # e.g., split-apply-combine

# reduce bug

# communicate clearly 

# build tools for a wide range of problems

# once have a clear, correct code, then can speed up using Chp17 RCpp



#==============
# 11.1 lapply()
#==============

# apply a function onto each element of a list
  # returns a list

# essense of the lapply()
lapply2 <- function(x, f, ...) {
  x <- vector("list", length(x))
  for(i in seq_along(x)){
    out[[i]] <- f(x[[i]],...)
  }
  out
}

## other functionals are just variations of this theme:
  # they just use different types of input and output

l <- replicate(20, runif(sample(1:10, 1)), simplify = F)
str(l)
# List of 20

# with a for loop
out <- vector("list", length(l))
for(i in seq_along(l)) {
  out[[i]] <- length(l[[i]])
}
unlist(out)


# with lapply
unlist(lapply(l, length)) 
# from list output to a vector to make it more compact

# since dfs are also list
# lapply is useful when want to do something to each col of df


# what class is each col of mtcars
unlist(lapply(mtcars, class))

# divide each col by mean
mtcars[] <- lapply(mtcars, function(x) x / mean(x))
str(mtcars)


## Note that in lapply(x, f, ...) 
  # each picecs of x are always supplied as the 1st arg of f

# example: vary the amount of trim when computing mean(x)
trims <- c(0, 0.1, 0.2, 0.5)
x <- rcauchy(1000)
unlist(lapply(trims, function(trim) mean(x, trim = trim)))
# each piece of x is the first arg of function()



#========================
# 11.1.1 looping patterns
#========================

# 3 ways to loop over a vector:
  #1. loop over the elements: for (x in xs)
  #2. loop over the numeric indices: for (i in seq_along(xs))
  #3. loop over the names: for (nm in names(xs))

# 1. not good: inefficient ways of saving output
  #  as has to copy all of the existing elements of the vector
    # then expand it with new element

# more efficient way is to create a space for the desired output
  # then fill it in. 
# so the 2nd form is the easier way
xs <- runif(1e3)
res <- numeric(length(xs))  # create a double-precision vector
for (i in seq_along(xs)) {
  res[i] <- sqrt(xs[i])
  }


## 3 basic ways for lapply()
# 1. lapply(xs, function(x) {})
# 2. lapply(seq_along(xs), function(i) {})
# 3. lapply(names(xs), function(nm) {})

# normally use the 1st one, 
  # but when what to know the position or name of the element
  # work with the 2nd and 3rd



##============================================
# 11.2 For loop functional: friends of lapply()
##============================================

# sapply() vapply(): 
  # variants of lapply() that produces
  # vectors, matrices, arrays as output, instead of list

# Map() and mapply():
  # iterates over multiple input data structures in parallel

# mclapply() and mcMap() :
  # multi-core
  # so parallel version of lapply() and Map()

# rollapply():
  # write a new function to solve a new problem


#----------------------------------------
# 11.2.1 Vector output:sapply and vapply
#----------------------------------------

# simplify output of lapply to atomic vector

# sapply():
  # good for interactive use as saving typing
  # not good for inside of a function 
    # will get errors if the supply the wrong input 

# vapply():
  # need an arg to specify the output type
  # gives more information on error
  # never silent failure
  # better suited for inside other functions

# when given a data frame, 
  # sapply() and vapply() gives the same result

# when given an empty list
  # sapply() returns an empty list 
    # not the more correct one a zero length logical vector

sapply(mtcars, is.numeric)
# mpg  cyl disp   hp drat   wt qsec   vs 
#TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE 
#am gear carb 
#TRUE TRUE TRUE

length(logical(1)) 
# [1] 1
# If length(FUN.VALUE) == 1 a vector of the same length as X is returned, 
# otherwise an array. 

#vapply(X, FUN, FUN.VALUE)
vapply(mtcars, is.numeric, 1)
vapply(mtcars, is.numeric, logical(1))

length(mtcars) # 11
str(mtcars)
# 'data.frame':	32 obs. of  11 variables:

logical(0) # logical(0)
logical(1) # [1] FALSE
logical(2) # [1] FALSE FALSE
logical(3) # [1] FALSE FALSE FALSE


sapply(list(), is.numeric)
# list()
vapply(list(), is.numeric, logical(1))
# logical(0)


## if a function returns results of different types or lenths
  # sapply() silently return a list
  # vapply() throw an error


# Example: extracting the class of col in a data frame
  # if falsely assume that class only has one value
  # and thus use sapply()
  # won't find out the problem until some future function 
    # is given a list instead of a character vector

df <- data.frame(x = 1:10, y = letters[1:10])
# two variables one is x the other is y

sapply(df, class)
#         x           y 
#   "integer" "character" 
vapply(df, class, character(1))
#         x           y 
#   "integer" "character" 

df2 <- data.frame(x = 1:10, y = Sys.time() + 1:10)

sapply(df2, class)
# $x
#[1] "integer"

#$y
#[1] "POSIXct" "POSIXt"

vapply(df2, class, character(1))
# Error in vapply(df2, class, character(1)) : values must be length 1,
# but FUN(X[[2]]) result is length 2

# > character(1)
#[1] ""
#> character(2)
#[1] "" ""


## sapply():
  # a thin wrapper around lapply() that transform the
    # list output into a vector

## vapply():
  # an implementation of lapply() that assigns results
    # to a vector or a matrix of appropriate type instead of a list


function(x, f, f.value, ...) {
  out <- matrix(rep(f.value, length(x)), nrow = length(x))
  for (i in seq_along(x)) {
  res <- f(x[i], ...)
  stopifnot(
    length(res) == length(f.value),
    typeof(res) == typeof(f.value)
  )
  out[i, ] <- res
  }
  out
}



#=========================================
# 11.2.2 Multiple inputs: Map ( and mapply)
#=========================================

# With lapply(), 
  # only one argument to the function can vary
  # the others are fixed

# situation: when have two lists, one is obs
  # the other is weight

# want to know the weighted mean

xs <- replicate(5, runif(10), simplify = F)
str(xs)
# List of 5
# $ : num [1:10] 0.319 0.438 0.744 0.715 0.445 ...
# $ : num [1:10] 

ws <- replicate(5, rpois(10, 5) + 1, simplify = F)

# for unweighted mean
unlist(lapply(xs, mean))

weigthed.mean()

# can do

unlist(lapply(seq_along(xs), function(i) {
  weighted.mean(xs[[i]], ws[[i]])
}))

# but more neat method is 

unlist(Map(weighted.mean, xs, ws))

# can convert Map to lapply that iterates over indices

# Map is useful when have two or more lists or a data frames
# that need to process in parallel. 

# e.g. standardising columns
  # 1st compute the mean, then divide by them
  # can do this with lapply but better to do each step

mtmeans <- lapply(mtcars, mean)
str(mtmeans)
Map("/", mtcars, mtmeans)


# or 
mtcars[] <- lapply(mtcars, function(x) x / mean(x))
str(mtcars)


# if some arg of the function should be fixed, 
  # then use anonymous function in the Map

Map(function(x, w) weighted.mean(x, w, na.rm = T), xs, ws)



#============================
# 11.2.3 Rolling computations
#============================

# need a for loop replacement not exist in R
  # can create your own by recognising common looping structures
  # implementing your own wraper

# smoothing your data using a rolling mean function;

rollmean <- function(x, n) {
  out <- rep(NA, length(x))
  ofset <- trunc(n / 2) # take int part
  for (i in (ofset + 1):(length(x) - n + ofset + 1)){
    out[i] <- mean(x[(i - ofset):(i + ofset - 1)])
  }
  out
}

x <- seq(1, 3, length = 1e2) + runif(1e2)
plot(x)

lines(rollmean(x, 5), col = "blue", lwd = 2)
lines(rollmean(x, 10), col = "red", lwd = 3)

# but when noise is more variable, will worry rolling mean
  # is too sensitive to outliers
  # will compute a rolling mean instead

rollapply <- function(x, n, f, ...) {
  out <- rep(NA, length(x))
  ofset <- trunc(n/2)
  for (i in (ofset + 1):(length(x) - n + ofset + 1)) {
    out[i] <- f(x[(i - ofset):(i + ofset)], ...)
  }
  out
}

plot(x)
lines(rollapply(x, 5, median), col = "red", lwd = 2)

# internal structure is looks like vapply
# so modify inner for loop

roll_apply <- function(x, n, f, ...) {
  ofset <- trunc(n/2)
  loc <- (ofset + 1):(length(x) - n + ofset + 1)
  num <- vapply(loc, 
         function(i) f(x[(i - ofset):(i + ofset)], ...),
         numeric(1))
  #num
  c(rep(NA, ofset), num)
}
roll_apply(x, 5, median)
#  [1]       NA       NA 1.616686 1.664508
# [5] 1.734135 1.790946 1.899057 1.969393

# the same as zoo::rollapply()
# provide more features and more error checking




#=======================
# 11.2.4 Parallelisation
#=======================

# lapply() each iteration is isolated from others
  # the order in which they are computed doesn't matter

# Example: scramble the order of computation doesn't matter
lapply3 <- function(x, f, ...) {
  out <- vector("list", length(x))
  for (i in sample(seq_along(x))) {
    out[[i]] <- f(x[[i]], ...)
  }
  out
}

unlist(lapply3(1:10, sqrt)) == unlist(lapply(1:10, sqrt))
# [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE
# [8] TRUE TRUE TRUE
# the same

# since we can compute each element in a list in any order
  # it's easy to dispatch the tasks to differnt cores
  # and compute them in parallel

# parallel::mclapply() and parallel::mcMap()

library(parallel)
system.time(unlist(mclapply(1:10, sqrt, mc.cores = 4)))
#user  system elapsed 
#0.004   0.026   0.023
system.time(unlist(lapply(1:10, sqrt)))
# user  system elapsed 
# 0       0       0 
# this case multi-core is slow due to need to 
  # assign to cores, and to collect the results from each of them


# but if more practical examples:
  # generating bootstrap replicates of a linear model

boot_df <- function(x) x[sample(nrow(x), replace = T), ]
rsqured <- function(mod) summary(mod)$r.square
boot_lm <- function(i) {
  rsquared(lm(mpg ~ wt + disp, data = boot_df(mtcars)))
}

system.time(lapply(1:500, boot_lm))
#  user  system elapsed 
# 0.321   0.004   0.333 

system.time(mclapply(1:500, boot_lm, mc.cores = 3))
# user  system elapsed 
# 0.002   0.016   0.265 

system.time(mclapply(1:500, boot_lm, mc.cores = 2))
#    user  system elapsed 
# 0.001   0.012   0.303 

# while increasing the number of cores will not always 
# lead to linear improvement
# switching from lapply() and Map() to mclapply() mcMap()
  #  to paralle the computation can dramatically improve
  # computational performance. 



nrow(mtcars) # 32
sample(nrow(mtcars)) 
# generate row index [1]  9  3  8 21 31 19 29 25 30 18 12 10
#[13]  2  1 26 27 28 13  5 15 16  6  4 20
#[25] 17 32 22 11 23 24 14  7
#x[sample(nrow(mtcars)), ] to extract these rows



#==================================
# 11.3 Manipulating matrices and df
#==================================

# functional can eliminate loops
# 3 categories of data structure functionals:
  # apply(), sweep(), outer() for matrices
  # tapply() summarise a vector by groups defined by another vector
  # plyr package, generalise tapply() to make it easy to work with
    # df, lists, arrays as inputs
    # and df, lists or arrays as outputs


#-----------------------------------
# 11.3.1 Matrix and array operations
#-----------------------------------

# apply(), sweep(), outer() works with high-dim data structure
  # apply(): a variant of sapply() works with matrices and arrays
    # 1. an operation that summarises a matrix or array 
      # by collapsing each row or col to a single number
    # 2. has 4 args:
      # X: matrix or array to summarise
      # MARGIN: int vector giving dim to summarize over
        # 1 = rows
        # 2 = cols
      # FUN: summarise functions
      # ... other arg to pass into FUN

# example:
a <- matrix(1:20, nrow = 5) 
#      [,1] [,2] [,3] [,4]
# [1,]    1    6   11   16
# [2,]    2    7   12   17
# [3,]    3    8   13   18
# [4,]    4    9   14   19
# [5,]    5   10   15   20
apply(a, 1, max)
# [1] 16 17 18 19 20
apply(a, 2, max)
# [1]  5 10 15 20

# Remark:
  # not completely sure what type of output you'll get
    # so not safe to use inside a function
  # not idempotent if summary function is identity operator
    # the output is not always the same as input

a1 <- apply(a, 1, identity)
#     [,1] [,2] [,3] [,4] [,5]
# [1,]    1    2    3    4    5
# [2,]    6    7    8    9   10
# [3,]   11   12   13   14   15
# [4,]   16   17   18   19   20

identical(a, a1)
# [1] FALSE

a2 <- apply(a, 2, identity)
identical(a2, a) # [1] TRUE


## sweep()
  # sweep out the values of a summary statistic
  # often used with apply() to standardise arrays

  # x: array or matrix
  # MARGIN: 1= rows; 2=cols
  # STATS: the summary statistic to be sweep out
  # FUN: the function used to carry out sweep

x <- matrix(1:20, nrow = 4)
#     [,1] [,2] [,3] [,4] [,5]
#[1,]    1    5    9   13   17
#[2,]    2    6   10   14   18
#[3,]    3    7   11   15   19
#[4,]    4    8   12   16   20
x1 <- sweep(x, 1, apply(x, 1, min), "-")
#    [,1] [,2] [,3] [,4] [,5]
#[1,]    0    4    8   12   16
#[2,]    0    4    8   12   16
#[3,]    0    4    8   12   16
#[4,]    0    4    8   12   16
# each row of x "minus" the min of each row


sweep(x1, 1, apply(x1, 1, max), "/")
#      [,1] [,2] [,3] [,4] [,5]
#[1,]    0 0.25  0.5 0.75    1
#[2,]    0 0.25  0.5 0.75    1
#[3,]    0 0.25  0.5 0.75    1
#[4,]    0 0.25  0.5 0.75    1
# each row of x "/" the max of each row of x1


# one more example:
x <- matrix(rnorm(20, 0, 10), nrow = 4)

x1 <- sweep(x, 1, apply(x, 1, min), "-")
sweep(x1, 1, apply(x1, 1, max), "/")



## outer
  # takes multiple vector inputs
  # create a matrix or array output 
      # where input function is run over all combination of the inputs
outer(1:3, 1:10, "*")
# 1*1, 1*2, 1*3, ...1*10
# 2*1, 2*2, 2*3, ...2*10
# 3*1, 3*2, 3*3, ...3*10



#--------------------
# 11.3.2 Group apply
#--------------------

# tapply() a generalisation to apply()
  # where raged arrays i.e., each row can have different number of cols
  # often needed when try to summarise a data set

# Example
  # collected pulse rate data from medical trial
  # want to compare two groups:

rep(c(0, 5), c(10, 12))
# [1] 0 0 0 0 0 0 0 0 0 0 5 5 5 5 5 5 5 5 5 5 5 5
pulse <- round(rnorm(22, 70, 10/3)) + rep(c(0, 5), c(10, 12)) 
str(pulse)
# num [1:22] 69 70 72 74 71 73 68 70 74 6

group <- rep(c("A", "B"), c(10, 12))

tapply(X = pulse, INDEX = group, FUN = length)
#  A  B 
# 10 12 

tapply(pulse, group, mean)
#       A        B 
# 71.00000 76.08333 

## essentially a combination of split and sapply
  # split() takes two inputs and returns a list
    # that groups elements together from the 1st input arg
    # according to the 2nd arg

pulse_list <- split(pulse, group)
# $A
#[1] 69 70 72 74 71 73 68 70 74 69

#$B
#[1] 78 77 75 75 69 75 80 77 76 75 79 77

sapply(pulse_list, mean)
#      A        B 
# 71.00000 76.08333

tapply2 <- function(x, group, f, ..., simplify = T) {
  pieces <- split(x, group)
  sapply(pieces, f, simplify = simplify)
}

tapply2(pulse, group, mean)
#        A        B 
# 71.00000 76.08333


#-----------------
# The plyr package
#-----------------

# The split-apply-combine strategy for data analysis



#=========================
# 11.4 Manipulating lists
#=========================

# Another way to think about functionals is 
  # a set of tools for altering, subsetting, and collapsing lists

# Map()
# Reduce()
# Filter()

#---------
# Reduce()
#--------

# reduce a vector to a single value 
  # by recursively calling a function f and two args at a time
# it combines first two elements with f, 
  # then combines the result of that call with 3rd element,...

Reduce(f, 1:3) = f(f(1, 2), 3)
# also known as fold, it fold together adjacent elements in the list

Reduce(`+`, 1:3)
# [1] 6

# Reduce can deal with any number of inputs
  # useful in implementing recursive operations, merges and intersections

# e.g. have a list of numeric vectors, 
  # want to find the values that occur in every element

l <- replicate(5, sample(1:10, 15, replace = T), simplify = F)

str(l)
intersect(intersect(intersect(intersect(l[[1]], l[[2]]), l[[3]]), l[[4]]), l[[5]])
#[1] 1 6 4

# but too clummsy
Reduce(intersect, l)
# [1] 1 6 4












































































































































