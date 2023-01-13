#^^^^^^^^^^^^^^^^^^^^^^^^
# Chapter 11 Functionals
#^^^^^^^^^^^^^^^^^^^^^^^^


  
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



#------------------------------
# 11.4.2 Predicate functionals
#------------------------------

# A predicate is a function that returns a single T or F
# like is.character, all, is.NULL

# A predicate functional applies a predicate to each element
  # of a list or df

# 3 useful predicate functionals Filter(), Find(), Position()

# Filter(): selects only those elements that match the predicate
# Find(): returns the 1st element which matches the predicate 
  # or last if right = TRUE

# Position(): return the postion of the first element that matches
  # the predicate or last if right = TRUE

# where(): a custom functional that generates a logical vector
  # from a list or a df and a predicate:

where <- function(f, x) {
  vapply(x, f, logical(1))
}

df <- data.frame(x = 1:3, y = c("a", "b", "c"), stringsAsFactors = T)
df2<- data.frame(x = 1:3, y = letters[1:3])
df3 <- data.frame(x = 1:3, y = c("a", "b", "c"), 
                  z = letters[24:26],
                  stringsAsFactors = T)
identical(df, df2)
# [1] TRUE

where(f = is.factor, x = df)
where(f = is.character, x = df2)
#     x     y 
# FALSE  TRUE 

Filter(f = is.character, x = df)
Filter(is.factor, df)
#   y
#1 a
#2 b
#3 c

str(Filter(f = is.factor, x = df))
# 'data.frame':	3 obs. of  1 variable:
# $ y: Factor w/ 3 levels "a","b","c": 1 2 3


Find(is.factor, df)
# [1] a b c
# Levels: a b c

str(Find(is.factor, df))
# Factor w/ 3 levels "a","b","c": 1 2 3

# df is still a list, so the 1st element is still variable y

Position(is.factor, df)
# [1] 2
# the 2nd element of a list (df)


str(Filter(is.factor, df3))
# 'data.frame':	3 obs. of  2 variables:
# $ y: Factor w/ 3 levels "a","b","c": 1 2 3
# $ z: Factor w/ 3 levels "x","y","z": 1 2 3

str(Find(is.factor, df3))
# only find the 1st elemtent that matches the predicate
# [1] a b c
# Levels: a b c
# Factor w/ 3 levels "a","b","c": 1 2 3

Find(is.factor, df3, right = T)
# [1] x y z
# Levels: x y z
str(Find(is.factor, df3, right = T))
# Factor w/ 3 levels "x","y","z": 1 2 3

Position(is.factor, df3)
# [1] 2
Position(is.factor, df3, right = T)
# [1] 3


#==============================
# 11.5 Mathematical functionals
#==============================

# limit, maximum, 
# the roots where set of points st f(x) = 0
# definite integrals
# all functionals:
  # given a function, they return a single number or vector of numbers

# these all using an algorithm involves iteration

# use some R built-in maths functionals
# 3 functionals work with functions to returns a single numeric number

  # integrate(): finds area under the curve defined by f()
  # uniroot(): finds where f() = 0
  # optimise(): finds the location of lowest (highest) value of f()

# Example: how these 3 maths functionals work with sin() function

integrate(f = sin, lower = 0, upper = pi)
# 2 with absolute error < 2.2e-14

Int <- integrate(f = sin, lower = 0, upper = pi)
str(Int)
# List of 5
#$ value       : num 2
#$ abs.error   : num 2.22e-14
#$ subdivisions: int 1
#$ message     : chr "OK"
#$ call        : language integrate(f = sin, lower = 0, upper = pi)
#- attr(*, "class")= chr "integrate"

str(uniroot(f = sin, interval = pi * c(1/2, 3/2)))
# List of 5
#$ root      : num 3.14
#$ f.root    : num 1.22e-16
#$ iter      : int 2
#$ init.it   : int NA
#$ estim.prec: num 6.1e-05

str(optimise(f = sin, interval = c(0, 2 * pi)))
# List of 2
#$ minimum  : num 4.71
#$ objective: num -1
# often used in MLE, 
  # two sets of parameters: 
    # data: fixed
    # parameters: vary to find the maxim
# combining closures with optimisation gives rise to 
  # the following approach to solve MLE

# Example: 
  # show how we find MLE for lambda, the parameter in Poission Dis

  # 1st: create a function factory, given a data set, 
    # returns a function that computes the neg LogL for lambda
# X ~ Poisson(lambda)
# f(x) = (lambda^(x) * exp^(-lambda)) / x!
# for n data x_i
# joint distribution f(X) = Pi_{1}^{n} (lambda^(x) * exp^(-lambda)) / x!
                    # f(X) = lambda^{sum_i x_i} + exp(- n * lambda)
# logL propto sum_i x_i log(lambda) - n * lambda
# - logL propto n * lambda - sum_i x_i log(lambda)


poisson_nll <- function(x) {
  n <- length(x)
  sum_x <- sum(x)
  function(lambda) {
    n * lambda - sum_x * log(lambda)
  }
}

# the clouser allows us to precompute the values that are 
  # constant wrt the data

str(poisson_nll)


x1 <- round(rnorm(10, 30, 5 ))
x2 <- round(rnorm(12, 5, 3))

nll_1 <- poisson_nll(x1)

# function(lambda) {
#     n * lambda - sum_x * log(lambda)
#}
#<environment: 0x7fd9f0a142b0>

nll_2 <- poisson_nll(x2)
# function(lambda) {
#     n * lambda - sum_x * log(lambda)
#}
# <bytecode: 0x7fd9f289e718>
# <environment: 0x7fd9e79fdae8>


optimise(f = nll_1, interval = c(0, 100))$minimum
# $minimum
# [1] 27.10001

#$objective
#[1] -623.1736

optimise(f = nll_2, interval = c(0, 100))
# $minimum
#[1] 4.749994

#$objective
#[1] -31.81424

# to check if the lambda after optimisation is correct or not
  # since it's poisson, so optimised lambda = mean of the data

mean(x1) # [1] 27.1
mean(x2) # [1] 4.75

## optim()
  # a generalisation of optimise()
    # deal with more than one dimension
  # in Rvmmin package : provide pure R implementation
  # Rvmmin is no slower than optim(), although it's written in R not C



#=======================================
# 11.6 Loops that should be left as is
#=======================================

# some loops have no natural functional equivalent
# 3 common cases:
  # modifying in place
  # recursive functions
  # while loops


#--------------------------
# 11.6.1 Modifying in place
#--------------------------

# if just want to modify part of an existing data frame
  # better to use for loop

# Example: performs variable by variable transformation
  # by matching the names of a list of functions to
  # the names of variables in a data frame

trans <- list(
  disp = function(x) x * 0.016,
  am = function(x) factor(x, levels = c("auto", "manual"))
)

for (var in names(trans)) {
  mtcars[[var]] <- trans[[var]](mtcars[[var]])
}

trans[["disp"]] # a function
(mtcars[["disp"]]) # print the values of 
str(mtcars)

trans[["disp"]](mtcars[["disp"]]) 
# apply the function in the list on the printed data

trans[["am"]](mtcars[["am"]])


#------------------------------
# 11.6.2 Recursive relationships
#------------------------------

# hard to convert a for loop into a functional when 
  # the relationship btw elements is not independent. 

# Example: 
  # exponential smoothing works by taking average of the 
    # current and previous data points

exp_smooth <- function(x, alpha) {
  s <- numeric(length(x) + 1) # double presion float point
  for (i in seq_along(s)) {
    if (i == 1) {
      s[i] <- x[i]
    } else {
      s[i] <- alpha * x[i] + (1 - alpha) * s[i - 1]
    }
  }
  s
}

x <- runif(6)
exp_smooth(x, 0.5)

# output at postion i depends on both the input and output 
  # at position i-1


#------------------
# 11.6.3 while loop
#------------------

# keeps running until some condition is met

i <- 0
while(TRUE) {
  if (runif(1) > 0.9) break
  i <- i + 1
}


# while(TRUE) is an infinite loop as its condition is always true
# but we can break it using return


Fun <- function(n) {
  i <- 0
  while(TRUE) {
    if (i > n) {
      return(paste0("i is greater than ", n))
      } else {
        print (i)
      }
    i <- i + 1
  }
}

Fun(6)


## Rejection method (uniform envelope)
# fx is non-zero only on [a, b], and fx ≤ k.
# 1. sample X uniformly from [a, b]
# 2. sample Y uniformly from [0, k] indepdent of X
# so P(X, Y) is uniformly distributed in a rectangle [a, b]*[0, k]
# Y > fx(x) then return X

function(fx, a, b, k) {
  while(TRUE) {
    x <- runif(1, a, b)
    y <- runif(1, 0, k)
    if (fx(x) < y) return (x)
  }
}



#=============================
# 11.7 A family of functions
#=============================
# case study: use functionals to take simple building block
  # and make it powerful and general

# start with def a simple addition function
# use functionals to extend it to summing multiple numbers
# computing paralle and cummulative sums
# summing across array dimensions


add <- function(x, y) {
  stopifnot(length(x) == 1, length(y) == 1,
            is.numeric(x), is.numeric(y))
  x + y
}


# takes this simple building block and extend it to do more
# add an na.rm arg
  # a helper function will make it easier
    # if x is missing, return y,
    # if y is missing , return x
    # if both are missing, return identity


na_rm <- function(x, y, identity) {
  if (is.na(x) && is.na(y)){
    identity
  } else if (is.na(x)) {
    y
  } else {
    x
  }
}

na_rm(NA, 10, 0)
# [1] 10

na_rm(1, NA, 0)
# [1] 1

na_rm(NA, NA, 0)
# [1] 0


# now write an add() that can deal with missing values
  # if needed

add <- function(x, y, na.rm = F) {
  if (na.rm = T && (is.na(x) || is.na(y))) na_rm(x, y, 0)
    else x + y
}

add(10, NA) # with na.rm default = F
  # go work with else
# 10 + NA = NA

add(10, NA, na.rm = T)
  # with na.rm = T, work with na_rm(x, y, 0)
# [1] 10

add(NA, NA)
# na.rm is default F
  # work with else 
# NA + NA = NA

add(NA, NA, na.rm = T)
# work work na_rm(x, y, 0)
# 0


## extend to deal with more complicated inputs
# more than 2 numbers
add(add(1, 2), 3)
# can be used using Reduce()
r_add <- function(xs, na.rm = T){
  Reduce(function(x, y) add(x, y, na.rm = na.rm), xs)
}

r_add(c(1, 3, 4))
# [1] 8

# test a few special cases
r_add(NA, na.rm = TRUE)

length(numeric())
# [1] 0

Reduce()
  # if given a lenght one vector, it doesn't have anything to reduce
    # so just returns the input
  # if give it an input of length zero, 
  # it returns NULL

# to fix, use init arg of Reduce()
# this is added to the start of every input vector
# (initial value)
r_add(c(1, 4, 10))
# [1] 15

r_add <- function(xs, na.rm = T) {
  Reduce(function(x, y) add(x, y, na.rm = T), xs, init = 0) 
}

r_add(NA, na.rm = TRUE)
# [1] 0
r_add(numeric(), na.rm = T)
# [1] 0









































































































































































