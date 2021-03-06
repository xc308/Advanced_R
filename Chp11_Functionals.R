#***************#
# 11 Functionals
#***************#

# A higer-order function is a function that
# takes a function as an input or returns 
# a function as output. 
# one type of higher-order function is closure
  # f unctions returned by another function

# The complement to a closure is a functional
  # a function that takes a function as an input
  # and returns a vector as output. 

# the 3 common functionals: 
  # lapply(), apply(), tapply()

# all 3 take a function as a input, 
# and return a vector as an output

# common use of functional is an alternative to for loop
# for loop is very slow in R
# and not very expressive


# functionals will not always produce the fastest code
# it helps you clearly coummunicatee and build tools
# that solve a wide range of problems
# 



#==================================#
# 11.1 My first functional:lapply()
#===================================#
# lapply() takes a function, applies it to each element in a lsit
# and returns the result in the form of a list

x <- list(10, "a", 23.8)
seq_along(x) # [1] 1 2 3

# lapply() is written in C for efficiency perfomance
# but it can be written in R

lapply2 <- function(x, f, ...) {
  out <- vector(mode = "list", length = length(x))
  
  for (i in seq_along(x)) {
    out[[i]] <- f(x[[i]], ...)
  }
  
  out
}
# 
vector("list", length = length(x)) 
# produce a vector, each element is a list
#[[1]]
#NULL

#[[2]]
#NULL

#[[3]]
#NULL

# so lapply is wraper for a common for loop pattern
#

set.seed(05-01-2021)
l <- replicate(20, runif(sample(1:10, 1)), simplify = FALSE)
# generate a list of 20 different lenght of random uniform numbers

# use for loop
out <- vector("list", length = length(l))
for(i in seq_along(l)) {
  out[[i]] <- length(l[[i]])
}
unlist(out)
# [1]  9  9  7  3  6  3  4  1  5 10
# [11]  9  3  5  4  1  7  8  6  7  9


# use lapply
unlist(lapply(l, length))
# apply length function onto each element of a list
# [1]  9  9  7  3  6  3  4  1  5 10
# [11]  9  3  5  4  1  7  8  6  7  9


# since a df is also a list, so lapply can also
# be useful when want to deal with each colu of df

unlist(lapply(mtcars, class))


# divide each col by mean
lapply(lapply(mtcars, function(x) x / mean(x)), head)

mtcars[] <- lapply(mtcars, function(x) x / mean(x))

head(mtcars, 3)

mtcars[] <- lapply(mtcars, function(x) x * mean(x))
head(mtcars, 2)



# usually, the pieces of x are always the 1st arg of the function
# if want to use other arg, can use anonymous function

#mean(x, trim)
# trim: the fraction (0 - 0.5) of obs is trimmed at the end of x
# before the mean is computed 

set.seed(05-01-2021)
trims <- c(0, 0.1, 0.2, 0.5)
x <- rcauchy(1000)
system.time(lapply(trims, function(trim) mean(x, trim = trim)))

#    user  system elapsed 
#   0.002   0.000   0.001 



# use for loop
trim_mean <- numeric(length = length(trims))
system.time(for (i in seq_along(trims)) {
  trim_mean[i] <- mean(x, trim = trims[i])
  trim_mean
})

#    user  system elapsed 
#   0.004   0.000   0.003 


#------------------------#
# 11.1.1 Looping Patterns
#------------------------#
# There are three ways to loop over a vector:
  # loop over the elements: for (x in xs)
  # loop over the numeric indices: for (i in seq_along(xs))
  # loop over the names: for (nm in names(xs))


# loop over a vector:
xs <- runif(1e3)
res <- c()
system.time(for (x in xs) {
  res <- c(res, sqrt(x))
})
# quite slow, as need to copy all the existing elements
# of res


# loop over numeric indices
res <- numeric(length(xs)) # create an space for output
system.time(for (i in seq_along(xs)) {
  res[i] <- sqrt(xs[i])  # fill it in 
})



# similaly, there are three types of ways to use for loop
lapply(xs, function(x) {})
lapply(seq_along(xs), function(i) {})
lapply(names(xs), function(nm) {})


# typically, use the first form as lapply takes care for the output for me
# but if want to know the position or name of the element you are working with
# you should use the 2nd and 3rd form


#===========================#
# 11.2 for loop functionals: 
# friends of lapply()
#==========================#
# sapply() vapply() produce vectors, matrics, arrays 
# as output instead of lists

# Map() and mapply() which iterate over multiple input
# data structures in parallel

# mclapply() and mcMap(), mulit-chain lapply() and Map()

# write a new function, rollapply() to solve a new problem



#----------------------#
# 11.2.1 Vector output: 
# sapply and vapply
#-----------------------#
# both simplyfied the output to atomic vector

# sapply() guess
# vapply() takes additional arg to specify the output type



#-----------------------------------------#
# 11.2.2 Multiple inputs: Map (and mapply)
#-----------------------------------------#
# if want to find a weighted mean
# of two lists, one is obs, the other is weights


# generate some data
xs <- replicate(5, runif(10), simplify = FALSE)
ws <- replicate(5, rpois(10, 5) + 1, simplify = FALSE)

unlist(lapply(seq_along(xs), 
       function(i) weighted.mean(xs[[i]], ws[[i]])))


# an cleaner alternative is to use Map, 
# a variant of lapply(), where all arg can vary

Map()
# apply function to each element of a vector

unlist(Map(weighted.mean, xs, ws))

# this is equivalent to 

stopifnot(length(xs) == length(ws))
out <- vector(mode = "list", length = length(xs))
for (i in seq_along(xs)) {
  out[[i]] <- weighted.mean(xs[[i]], ws[[i]])
}


# there's a natural equivalence between Map and lapply
# as it's easy to convert Map to lapply that iterates over
# indices

# but map is more consice and more clearly indicates
# what you are trying to do


# Map is useful when you have two or more lists (df)
# to process parallel


# Map is equivalent to mapply(..., simplify = FALSE)


#---------------------------#
# 11.2.3 Rolling Computation
#---------------------------#
trunc(2.5) # 2
# rolling mean

roll_mean <- function(x, n) {
  out <- rep(NA, length(x))
  offsets <- trunc(n / 2)
  
  for (i in (offsets + 1) : (length(x) - n + offsets + 1)) {
    out[i] <- mean(x[(i - offsets) : (i + offsets - 1)])
  }
  
  out
}

x <- seq(1, 3, length.out = 100) + runif(1e2)
plot(x)
lines(roll_mean(x, 5), col = "red")
lines(roll_mean(x, 10), col = "blue", lwd = 2)


# but if the noise was more variable,
# then the rolling mean was too sensitive to outlieres
# instead want a rolling median
set.seed(06-01-2021)
x <- seq(1, 3, length.out = 1e2) + rt(1e2, df = 2) / 3
plot(x)
lines(roll_mean(x, 3), col = "red", lwd = 2)

# so we could just cope able code and change the mean function to median
# but instead, we would wrap the rolling summary into a function itself

roll_apply <- function(x, n, f, ...) {
  out <- rep(NA, length(x))
  offsets <- trunc(n / 2)
  
  for (i in (offsets + 1) : (length(x) - n + 1 + offsets)) {
    out[i] <- f(x[(i - offsets) : (i + offsets - 1)], ...)
  }
  
  out
}

lines(roll_apply(x, 5, median), col = "blue", lwd = 2)

legend("bottomright", legend = c("mean", "median"),
       col = c("red", "blue"), lty = 1, bty = "n", cex = 0.5)



#-----------------------#
# 11.2.4 Parallelisation
#-----------------------#
# implementation of lapply is that 
# each iteration is isolated from all others
# so the order in which they are computed does not matter

# if scrambels the order of computation, 
lapply3 <- function(x, f, ...) {
  out <- vector(mode = "list", length = length(x))
  
  for (i in sample(seq_along(x))) {
    out[[i]] <- f(x[[i]], ...)
  }
  
  out
}

unlist(lapply3(1:10, sqrt)) - unlist(lapply(1:10, sqrt))
# [1] 0 0 0 0 0 0 0 0 0 0

# This has a very important consequence:
# we can compute each element in any order
# so easy to dispatch tasks to different cores
# and compute them in parallel. 

# this is what paralle::mclapply()
# and parallel::mcMap()


install.packages("parallel")
library(parallel)

unlist(mclapply(1:10, sqrt, mc.cores = 4))
# in the case, mclapply is actually slow
# as althought individual computation cost is slow
# the additional work i.e. sent compuation to different cores
# and to collect the results are demanding


# but in a more realistic bootstrap replicates of a linear model
# mclapply has advanctages 

# define bootstrap function
boot_df <- function(x) x[sample(nrow(x), replace = T), ]
rsquared <- function(model) summary(model)$r.square
boot_lm <- function(new_data) {
  rsquared(lm(mpg ~ wt + disp, data = boot_df(mtcars)))
}

# use the fitted model to predict new data
system.time(lapply(1:500, boot_lm))
#    user  system elapsed 
#   0.836   0.023   0.942 

system.time(mclapply(1:500, boot_lm, mc.cores = 4))
#   user  system elapsed 
#  0.006   0.010   0.445 

# while increasing the number of cores will not 
# always lead to linear improvement, switching from 
# lapply() and Map() to its parallised form can dramatically
# improve computational performance


#x <- matrix(1:8, nrow = 4)
#sample(nrow(x), replace = T) # sample is to reorder,



# simulate the performance of a t-test for non-normal data
trials <- replicate(100, t.test(rpois(10, 10), rpois(7, 10)),
                    simplify = FALSE)

lapply(trials, head)

# extract the p-value for every trial
sapply(trials, function(x) x$p.value)



#===================================#
# 11.3 Manipulating matrices and df
#===================================#

# three categories of data structure functionals:
  # apply(), sweep(), outer() work with matrices
  # tapply() summerises a vector by groups defined by another vector
  # the plyr package, which generalises tapply() to make it eay to 
    # work with df, lists, arrays, as inputs and dfs, lists, or arrays as outputs




#-----------------------------------#
# 11.3.1 Matrix and array operations
#-----------------------------------#
# so far, all functionals work with 1-d input structures
# the 3 functionals apply() sweep() outer() work with higher dimensionals data structure

  # apply() is a variannt of sapply() works with matrices and arrays
  # it operate as summarises a matrix or array by 
  # collapsing each row / col to a single number
  # has 4 args:
    # X: matrix or array to summarise
    # MARGIN: an integer vector giving the dim to sum over
      # 1 = row, 2 = col
    # FUN: a summary function
    # ...: other args that passed into FUN

# typical example
a <- matrix(1:20, nrow = 5)
apply(a, 1, mean)
apply(a, 2, mean)

# but apply doesn't have simplify, so 
# can't be sure what type of output you'll get
# so it's not safe to use apply within a function
# unless you carefully check the inputs

# apply() is not idenpotent in the sense
# that if the summary function is the indentity operator
# the output is not always the same as the input

a1 <- apply(a, 1, identity)
identical(a, a1) # [1] FALSE


a2 <- apply(a, 2, identity)
identical(a, a2) # [1] TRUE

#identity(x) # returning its arg x


# sweep 
  # allows you to sweep out the values of a summaries statisc
  # often used with apply() to standardise arrays
  

# example: scale the row of matrix to allow value between 0, 1
set.seed(06-01-2021)

x <- matrix(rnorm(20, 0, 10), nrow = 4)
x[1, ]
x[2, ]
x1 <- sweep(x, 1, apply(x, 1, min), "-")
x2 <- sweep(x1, 1, apply(x1, 1, max), "/")
# apply(x1, 1, max) find the max of each row
# each element of each row  / max of each to standardise



# Final matrix functional: outer 
  # it takes multiple vector inputs
  # and creates a matrix or array output
  # where input function is run over every combination of inputs

outer(1:3, 1:10, "*")



#-------------------#
# 11.3.2 Group apply
#-------------------#
# tapply() as a generalisation to apply()
# that allows for "ragged" arrays
# arrays where each row can have different number of columns

# have pluse rate data from medical trial
# want to compare two groups

pulse <- round(rnorm(22, mean = 70, sd = 10 / 3)) + 
  rep(c(0, 5), c(10, 12))
# base = 70, flunctuation: 0 (10 people) and 5 (12 people)
Group <- rep(c("A", "B"), c(10, 12))

# tapply() 
  # 1st create a ragged data structure from a set of inputs
  # 2nd apply the function to each individual elements of that structure

tapply(pulse, Group, length)
#  A  B 
# 10 12 

tapply(pulse, Group, mean)
#   A    B 
# 70.8 74.0 

# And the 1st task is actually what split() does
  # it takes two inputs and returns a list 
  # which groups elements together from the 1st vector
  # according to elements, categories, from the 2nd vector

sp_gp <- split(pulse, Group)
# $A
#[1] 70 68 78 73 68 69 72 65 70 75

#$B
#[1] 70 73 84 71 74 75 74 73 69 74
#[11] 77 74

  # then tapply() is just the combianation of split() and sapply()


sapply(sp_gp, length)
#  A  B 
# 10 12 

sapply(sp_gp, mean)
#    A    B 
#  70.8 74.0 

tapply2 <- function(x, group, f, ..., simplify = TRUE) {
  pieces <- split(x, group)
  sapply(pieces, f)
}

tapply2(pulse, group = Group, f = length)
#  A  B 
# 10 12
tapply2(pulse, group = Group, f = mean)
#    A    B 
# 70.8 74.0 


#-------------------------#
# 11.3.3 The plyr package
#-------------------------#

# to provide consistently named functions with
# consistently named arguments and 
# covers all combinations of input and output data structure

# input   output     calling function 
# list    list        llply()
# list    df          ldply()
# list    array       laply()
# df      list        dlply()
# df      df          ddply()
# df      array       daply()
# array   list        alply()
# array   df          adply()
# array   array       aaply()

# each of the function splits up the input,
# applies a funtion to each piece and then combine the results
# the process is called "split-apply-combine"

#=========================#
# 11.4 Manipulating lists
#=========================#
# can also be thought as a set of general tools
# for altering, subsetting, and collapsing lists

# every funtionals programming language has 3 tools for this
# Map(), Reduce(), Filter()

# Reduce(): a powerful tool for extending two-arg functions
# Filter(): a member of an important class of functionals that work
# with predicates, functions that return a single T or F


#------------------#
# 11.4.1 Reduce()
#------------------#
# Reduce() reduces a vector x, to a single value 
# by recursively calling a function f, two args at a time


# it combines the first two elements with f
# then combines the result of that call with the 3rd element
# and so on

# calling Reduce(f, 1:3) is equivalent to f(f(1, 2), 3)
# Reduce also known as fold, as it folds together 
# adjacent elements in the list

# two examples show what Reduce does with an infix and prefix function:
Reduce('+', 1:3) # ((1 '+' 2) '+' 3)
Reduce(sum, 1:3) # (sum(1, 2), 3)

# The essence of Reduce is a for loop

Reduce2 <- function (f, x) {
  out <- x[[1]]
  
  for(i in 2:length(x)){
    out <- f(out, x[[i]])
  }
  
  out
}

# Reduce is an elegant way of extending a function that works with only 2 args
# to a function that can deal with any number of inputs

# so it's useful for implementing many types of recursive operations, e.g. merge, intersections

# example: have a list of numeric vectors
# want to find the values that occur in every element

l <- replicate(5, sample(1:10, 15, replace = TRUE), 
          simplify = FALSE )

str(l)

# to find the common value, can use intersect function recursively
intersect(intersect(intersect(intersect(l[[1]], l[[2]]), l[[3]]), l[[4]]), l[[5]])
# [1] 7 4 6

# but can use Reduce(), finish in an elegent way
Reduce(intersect, l)
# [1] 7 4 6


#-----------------------------#
# 11.4.2 Predicate functionals
#-----------------------------#
# A predicate is a function that returns a single TRUE or FALSE
# e.g. is.character, all, is.NULL

# A predicate functional applies a predicate to each element of a list or df
# 3 useful predicates functionals in base R:
  # Filter(), Find(), Position()


# Filter(): select those elements which match the predicate
# Find(): returns the 1st element which matches the predicate 
          # or the last one if right = TRUE
# Position(): returns the postion of the 1st element that matches the predicate
          # or the last one if right = TRUE

# where(): a custom functional that generates a logical 
# vector from a list (or df) and a predicate:
where2 <- function(f, x) {
  vapply(x, f, logical(length = 1))
}


# use of these functions with df
df <- data.frame(x = 1:3, y = c("a", "b", "c"))
where2(is.factor, df)
#    x     y 
# FALSE  TRUE 

Filter(is.factor, df) 
# filter out the elements in list that match the predicate
str(Filter(is.factor, df))
# 'data.frame':	3 obs. of  1 variable:
# $ y: Factor w/ 3 levels "a","b","c": 1 2 3

Find(is.factor, df)
# [1] a b c
# Levels: a b c

Find(is.factor, df, right = TRUE)
# [1] a b c
# Levels: a b c

Position(is.factor, df)
# [1] 2

Position(is.numeric, df)
# [1] 1


#==============================#
# 11.5 Mathematical Functionals
#==============================#
# Functionals are very common in Maths
# Limit, max, roots, definite integrals are all functionals

# Functional: take a function as input, and returns a vector as output
# so they are all functionals as given a function, 
# they will return a number or a vector of number


## 3 functionals that work with functions to return single numeric values
# integrate(): finds the area under the curve defined by f()
# uniroot(): finds where f() hits zeros
# optimise(): finds the location of lowest(highest) value of f

# example: use sin function
integrate(sin, 0, pi)
# 2 with absolute error < 2.2e-14

# find the root of sin within the interval pi * c(1 / 2, 3 / 2)
str(uniroot(sin, pi * c(1 / 2, 3 / 2)))
# List of 5
#$ root      : num 3.14
#$ f.root    : num 1.22e-16
#$ iter      : int 2
#$ init.it   : int NA
#$ estim.prec: num 6.1e-05

str(optimise(sin, c(0, 2 * pi)))
# List of 2
#$ minimum  : num 4.71
#$ objective: num -1


str(optimise(sin, c(-pi, pi), maximum = TRUE))
#List of 2
#$ maximum  : num 1.57
#$ objective: num 1

# in statistics, optimisation is often used for MLE
# which have two sets of parameters:
  # data: fixed for a given problem
  # parameters: vary as we try to find the maximum

# these two sets of parameters make the problem well suited for maximum
# combining closures with optimisation gives rise to the approach to solving MLE 

# The following example shows how to find the mle for lamda
# if the data is from a poisson distr

# create a function factory that, given a dataset
# returns a function that computes the negative log likihood (NLL)
# for parameter lambda

poisson_nll <- function(x) {
  
  n <- length(x)
  sum_x <- sum(x)
  
  function(lamda) {
    n * lamda - sum_x * log(lamda)
  }
}

x1 <- rpois(10, 38)
x1
x2 <- rpois(12, 7)
x2

nll_1 <- poisson_nll(x1)
op_1 <- optimise(nll_1, c(0, 100))
op_1$minimum # [1] 36.19999 just the mean of data in this case


nll_2 <- poisson_nll(x2)
op_2 <- optimise(nll_2, c(0, 100))
op_2$minimum # [1] 8.333325

mean(x1) # [1] 36.2
mean(x2) # [1] 8.333333


# optim() generalisation of optimise
# works with more than one dim

# explore more with Rvmmin package


#==========================================#
# 11.6 Loops have no equivalent functionals
#==========================================#
# some loops have no equivalent functionals
# three common cases:
  # modifying in place
  # recursive functions
  # while loops



#---------------------------#
# 11.6.1 Modifying in place
#---------------------------#
# performs a variable-by-variable transformation
# by matching the names of a list of functions to 
# to the names of variables in a data frame

trans <- list(
  disp = function(x) x * 0.0163871,
  am = function(x) factor(x, levels = c("auto", "manual")))

for (var in names(trans)) {
  mtcars[[var]] <- trans[[var]](mtcars[[var]])
}

trans[[var]]
# two functions 

(mtcars[[var]])
# x in the function (x)



#-------------------------------#
# 11.6.2 Recursive relationships
#--------------------------------#
# hard to convert a for loop into a functional
# when the relationship between elemnts is not indepentd
# or is defined recursively

# exponential smoothing works by taking a weighted average
# of the current and previous data points

exp_sm <- function(x, alpha) {
  s<- numeric(length(x) + 1)
  
  for(i in seq_along(s)) {
    if (i == 1) {
      s[i] <- x[i]
    } else {
      s[i] <- alpha * x[i - 1] + (1 - alpha) * s[i - 1]
    }
  }
  
  s
}

x <- runif(1e6)
exp_sm(x, 0.5)[1:10]
# [1] 0.2732649 0.2732649 0.3365668
# [4] 0.4003585 0.5436568 0.4506318
# [7] 0.4109395 0.6806436 0.6207494
# [10] 0.5019331


# can't eliminate for loop as none of the functionals 
# allow the ouput at the postion i to depend on both 
# the input and ouput at the postion i-1


#-------------------#
# 11.6.3 While loop
#-------------------#
# while loop keeps running unitl condition is met

while(TRUE) {
  i <- 0
  
  if(runif(1) >= 0.9) break
  i <- i + 1 # add count of failer until p >= 0.9 succes
  
}
# essentially a geometric rdv, so could 
# replace 
i <- rgeom(1, 0.1)



#===========================#
# 11.7 A family of functions
#===========================#
# a case study: shows how to use functionals 
# to take a simple building block and make it powerful
# and general


# start with a simple idea, adding two numbers together
# use functionals to extend it to summing mulitple numbers 
# computing parallel and cumulative sums
# and summing across array dimensions

# define a simple add function
add2 <- function(x, y) {
  stopifnot(length(x) == 1, length(y) == 1, 
            is.numeric(x), is.numeric(y))
  x + y
}


identity() 
# A trivial identity function returning its argument.


# to make the add2 function be able to deal with NAs
# write an rm.na helper function:  
# if x is missing, return y
# if y is missing, return x
# if x and y are both missing, then return identity, i.e. the arg itself

rm_na <- function(x, y, identity) {
  if (is.na(x) && is.na(y)) {
    identity
  } else if (is.na(x)) {
    y
  } else if (is.na(y)) {
    x
  }
}

# test
rm_na(NA, NA, 0)
rm_na(NA, 9, 0)
rm_na(8, NA, 19)
rm_na(NA, NA, 10)
rm_na(NA, NA, "*^-^*")


# update add2: a version of dealing with NA
add2 <- function(x, y, na.rm = FALSE) {
  if (na.rm && (is.na(x) || is.na(y))) {
    rm_na(x, y, 0)} else x + y
}

add2(10, NA)
# [1] NA

add2(10, NA, na.rm = TRUE)
# [1] 10


## One extension is to make the function
# be able to deal with more than 2 number inputs

# we can do this by iteratively adding two numbers
# if input is c(1, 2, 3) then add(add(1, 2), 3)
# which is a simple application of Reduce()

reduce_add <- function(xs, na.rm = TRUE) {
  Reduce(function(x, y) add2(x, y, na.rm = na.rm), xs)
}

# test
reduce_add(c(1, 3, 5))

# test some specialities
reduce_add(NA, na.rm = TRUE)
# [1] NA
# not right as we've already asked to romove NA

reduce_add(numeric())
# NULL not right, should get a length one numeric vector
sum(numeric()) # get a length one numeric vector
# [1] 0


# because Reduce() if given a length zero input, 
# it always returns NULL
# easiest way is to use the init arg of Reduce()
# which is added to the start of every input

reduce_add <- function(xs, na.rm = TRUE) {
  Reduce(function(x, y) add2(x, y, na.rm = na.rm), xs, init = 0)
}

# test
reduce_add(c(9, 3, 1))
reduce_add(NA, na.rm = TRUE)
# [1] 0 right!
reduce_add(numeric())
# [1] 0


## here reduce_add is equivalent to sum


# It would be nice to have a vectorised version of add()
# so we can perform addition of two vectors of numbers in element-wise fashion
# we could use Map() or vapply() to implement this, but neither is perfect
  # Map() returns a list, so need to use simplify2array()
  # vapply() returns a vector but requires to loop over a set of indices

v_add1 <- function(x, y, na.rm = FALSE) {
  stopifnot(length(x) == length(y), 
            is.numeric(x), is.numeric(y))
  
  if(length(x) == 0) return(numeric())
  
  simplify2array(Map(function(x, y) add2(x, y, na.rm = na.rm), x, y))

}


v_add2 <- function(x, y, na.rm = FALSE) {
  stopifnot(length(x) == length(y), 
            is.numeric(x), is.numeric(y))
  
  if(length(x) == 0) return(numeric())
  
  vapply(seq_along(x), function(i) add2(x[i], y[i], na.rm = na.rm),
         numeric(length = 1))
}

# test
v_add1(1:10, 2:11)
# [1]  3  5  7  9 11 13 15 17 19 21

v_add1(numeric(), numeric())
# numeric(0)

v_add1(c(1, NA), c(1, NA))
# [1]  2 NA

v_add1(c(1, NA), c(1, NA), na.rm = TRUE)
# [1] 2 0


# finally, we to deine addition for more complicated data
# sturcture like matrices. 
# could sum across over rows or cols or any arbitrary set of dimensions

row_sum <- function(X, na.rm = FALSE) {
  apply(X, 1, add2, na.rm = na.rm)
}

col_sum <- function(X, na.rm = FALSE) {
  apply(X, 2, add2, na.rm = na.rm)
}

array_sum <- function(X, na.rm = FALSE) {
  apply(X, dim, add2, na.rm = na.rm)
}


# the rol_sum = rowSums(), col_sum = colSums()
























































































































































































































































































































































































































































