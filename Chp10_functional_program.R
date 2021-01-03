#******************************#
# Chp 10 Functional Programming
#*******************************#


#================#
# 10.1 Motivation
#================#

set.seed(2-1-2021)

df <- data.frame(replicate(6, sample(c(1:10, -99), 6, replace = TRUE)))
head(df, 2)
names(df) <- letters[1:6]
df
# want to replace -99 with NA


# principle: do not repeat yourself
  # can first write a function that fixes the missing value in a single vector


fix_missing <- function(x) {
  x[x == -99] <- NA
  x
}
df$a <- fix_missing(df$a)
df
df$f <- fix_missing(df$f)
df
# can mess up the name of the variable


# the function fix_missing knows how to fix a single vector
# lapply() knows how to do the same thing to each col of df


# lapply(x, f, ...)
  # x: a list
  # f: a function
  # ...: 
  # it applies f to each element of the list x, then return a new list

# lapply is called functional, as it takes a function as its arg

# so all we need is a little trick to get back a df rather a lsit
# just need to assign the lapply result to a df[]

df[] <- lapply(df, fix_missing) # as df is a list of named vectors
df

# The key idea is composition. 
  # take two simple functions, 
  # then compose then with a powerful technique


# But now if different cols use different code for missing values
# it's better to use closures, which is afunction that
  # that make and return functions.

missing_fixer <- function(na_val) {
  function(x) {
    x[x == na_val] <- NA
    x
  }
}

fix_missing_99 <- missing_fixer(-99)
fix_missing_999 <- missing_fixer(-999)


# want to compute the same set of numerical summeries for each varaible
# one approach: write a summary function then apply it to each col

summary_fun <- function(x) {
  c(mean(x), median(x), sd(x), mad(x), IQR(x))
 
}
rm(summary)
lapply(df, summary_fun)

# Error in quantile.default(as.numeric(x), c(0.25, 0.75), na.rm = na.rm,  : 
# missing values and NaN's not allowed if 'na.rm' is FALSE 


# to remove na, need to add na.rm = TRUE

summary_fun <- function(x) {
  c(mean(x, rm.na = TRUE), 
    median(x, rm.na = TRUE), 
    sd(x, rm.na = TRUE), 
    mad(x, rm.na = TRUE), 
    IQR(x, rm.na = TRUE))

}

# but the body part of the summary_fun is repeated
# so can write into a function again

summary_closure <- function(x) {
  funs <- c(mean, median, sd, mad, IQR)
  lapply(funs, function(f) f(x, rm.na = TRUE))
}


#=========================#
# 10.2 Anonymous functions
#=========================#

# if choose not to give a function a name, 
  # you get anonymous function

lapply(mtcars, function(x) length(unique(x)))
Filter(function(x) !is.numeric(x), mtcars)
integrate(function(x) sin(x) ^ 2, 0, pi)

# anonymous functions have formals(), body(), a parent env()

formals(function(x = 4) g(x) + h(x))
# the list of args: [1] 4

body(function(x = 4) g(x) + h(x))
# g(x) + h(x)

environment(function(x = 4) g(x) + h(x))
# <environment: R_GlobalEnv>

# the most common use for anonymous functions
# is to create closures, functions made by other functions

#===============#
# 10.3 Closures
#===============#
# closures: functions written by functions
# gets its name as they include the env of the
# parent function and can access all its varaibles
# useful as it allows us to have two levels of par:
  # a parent level that controls the operation
  # a child level that does the work


power <- function(exponent) {
  function(x) {
    x ^ exponent
  }
}

square <- power(2) # fix parent level to get the def of square function
cube <- power(3) # fix parent level to get the def of cub fun

# calculate power function
square(2)
# [1] 4
cube(9)
# [1] 729


# To see the value defined in the enclosing env with their value
library(pryr)
unenclose(square)
# function (x) {
#  x^2
#}


#unenclose(cube)


# The parent env of a closure is the execution env
# of the function that actualy created it

power <- function(exponent) {
  print(environment())
  
  function(x) {
    x ^ exponent
  }
}

zero <- power(0)
environment(zero)
# <environment: 0x7f93dde9a0e0>


## The execution env normally disappers 
# after the function returns a value

# but functions capture their enclosing env
# which means when function a returns function b
# function b captures and stores the execution env of function a
# and it does not disappear


# In R, almost every function is a closure
# all functions remember the env in which they were created
# either global env, if it's a function that you've written
# or package env, if its a function that someone has written

# only exception is primitive function
# which call C code directly and don't have associated env

# closures are useful for making function factories
# and are one way to manage mutable state in R



#-----------------------#
# 10.3.2 Mutable State
#-----------------------#
# <- always assign in the current env
# <<- will keep looking up the chain of parent env
# unitl it finds a matching name

# together, a static parent env and <<- make it 
# possible to maintain state across function calls


#  a counter example
new_counter <- function() { # creates an env
  i <- 0 # initialises the counter i in this env
  
  function() { # create a new function, which is a closure, 
    # and its enclosing env is the env when new_counter is run
    i <<- i + 1
    i
  }
}

# Ordinarary, function execution env are temporaray
# but a closure maintains access to the env in which it was created


counter_one <- new_counter()
counter_one()
# [1] 1 
# [1] 2
# [1] 3
# [1] 4
# [1] 5

# so will always get a "fresh start"

# to get around,
# since the changes are made in the unchanging parent (or enclosing) env
# they are preserved across function calls



i <- 0
new_counter2 <- function() {
  i <<- i + 1 # create a variable in parent env, so i < - 0 will be updated
  i
}
new_counter2()

# 1, 2, 3, 4, ....


new_counter3 <- function() {
  i <- 0 # fixed initialization in parent env
  function() { # an enclosure, got 0 inital every run
    i <- i + 1
    i
  }
}
new_counter_three <- new_counter3()
new_counter_three()
# 1, 1, 1, ......



#========================#
# 10.4 Lists of functions
#=========================#
# the ability to store functions in a list
# makes it easier to work with groups of related functions
# similary, df makes it easier to work with groups of related vectors

# comparing the performance of multiple ways of 
# computing the mean. 
# can do by storing each approach (function) in a list:

ls()
rm("sum")

compute_mean <- list(
  base = function(x) mean(x), 
  Sum_over_n = function(x) sum(x) / length(x), 
  manual = function(x) {
    total <- 0
    n <- length(x)
    for (i in seq_along(x)) {
      total <- total + x[i] / n
    }
    total
  }
)

# now call a function from a list
# simply extract it $, [[ ]] then call it
x <- runif(1e5, 1, 10)
system.time(compute_mean$base(x))
#  user  system elapsed 
# 0.001   0.000   0.000 

system.time(compute_mean[[2]](x))
#  user  system elapsed 
# 0       0       0 

system.time(compute_mean[['manual']](x))
#   user  system elapsed 
# 0.010   0.001   0.010 

# can use lapply() to call each funtion 
# e.g. to see if different methods return the same results
# but need a calling function
lapply(compute_mean, function(f) f(x))

call_fun <- function(f, ...) f(...) 
lapply(compute_mean, call_fun, x)


# to time each function,
lapply(compute_mean, function(f) system.time(f(x)))

# $base
#user  system elapsed 
#0       0       0 

#$manual
#user  system elapsed 
#0.005   0.000   0.005 



# Another use of a list of function: 
# to summarise an obj in mulitple ways

funs <- list(
  SUM = sum, 
  MEAN = mean, 
  MEDIAN = median
)

x <- 1:10
lapply(funs, function(f) f(x))

# if want to remove na automatically for all functions
lapply(funs, function(f) f(x, na.rm = TRUE))




#-------------------------------------#
# 10.4.1 Moving lists of functions  
# to the global env
#-------------------------------------#



#======================#
# 10.5 Case study: 
# numerical integration
#======================#
# each step of development of the tool
# is driven by the desire to reduce duplication
# and to make the approach more general


# idea behind numerical integration:
  # find the area under a curve by approximating
  # the curve with simpler components
  # two simpliest approach: at the midpoint, trapezoid

      # the midpoint rule:
        # approximates a curve with a rectangle
      
      
      # the trapezoid rule:
        # approximates a curve with a trapezoid
  
  # each takes the function want to integrate, f
  # and a range of values, from a to b, to integrate over


# suppose we want to integrate sinx from 0 to pi
# A good choic for testing as it has a simple answer 2

midpoint <- function(f, a, b) {
  (b - a) * f((a + b) / 2)
}

trapezoid <- function(f, a, b) {
  (f(a) + f(b)) * (b - a) / 2
}

midpoint(sin, 0, pi) # [1] 3.141593
trapezoid(sin, 0, pi) # [1] 1.923671e-16

# but the true is 2, so neither of them is a good approximation
# using the idea of calculus, break up the range into smaller piece
# and integrate each piece using one of the simple rules able
# this is called composition integration

midpoint_composite <- function(f, a, b, n) {
  points <- seq(a, b, length.out = n + 1)
  h <- (b - a) / n
  
  area <- 0
  for (i in seq_len(n)) {
    area <- area  + f((points[i] + points[i + 1]) / 2) * h
    
  }
  area
}


trapezoid_composite <- function(f, a, b, n) {
  points <- seq(a, b, length.out = n + 1)
  h <- (b - a) / n
  
  area <- 0
  for (i in seq_len(n)) {
   area <- area + (f(points[i]) + f(points[i + 1])) * h / 2
  }
  area
}



midpoint_composite(sin, 0, pi, n = 10)
# [1] 2.008248

trapezoid_composite(sin, 0, pi, n = 10)
# [1] 1.983524


midpoint_composite(sin, 0, pi, n = 1000)
# [1] 2.000001

trapezoid_composite(sin, 0, pi, n = 1000)
# [1] 1.999998


## Notice there are lots of duplication between 
# two composite methods
# so modify our function in a general rule
composite <- function(f, a, b, n = 10, rule) {
  points <- seq(a, b, length.out = n + 1)
  
  area <- 0
  for (i in seq_len(n)) {
    area <- area + rule(f, points[i], points[i + 1])
  }
  
  area
}

composite(sin, 0, pi, n = 10, rule = midpoint)
# [1] 2.008248

composite(sin, 0, pi, n = 10, rule = trapezoid)
# [1] 1.983524

# the composite function takes two functions as arg
  # the function to integrate
  # the funtion of integration rule


install.packages("statmod")
library(statmod)

View(gauss.quad)
view(gauss.quad)












































































































































































