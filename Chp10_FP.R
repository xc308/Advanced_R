#===============================
# Chp10 Functional programming (FP)
#===============================

# Three building blocks of functional programming:
  # anonymous functions
  # closures (functions written by functions)
  # lists of funcitons

# then twined together to build a suit of tools

# theme of FP:
  # start small
  # easy to understand building blocks
  # combine them into more complex structure
  # apply them with confidence

# Chp11 : 
  # takes functions as argument
  # return vectors as output

# Chp12:
  # takes functions as input
  # return them as output


#-----------------
# 10.1 Motivation
#-----------------

# want to replace -99 with Nas

set.seed(12-12-2022)
sample(c(1:10, -99), 6 , replace = T)

df <- data.frame(replicate(6, sample(c(1:10, -99), 6 , replace = T)))
df
names(df) <- letters[1:6]
df

# instead of doing 
df$e[df$e == -99] <- Na
# which will involve lots of self-repeating

# we can write a function that fix the missing value in a single vector
fix_miss <- function(x) {
  if(!is.vector(x)) stop("input a vector")
  
  x[x == -99] <- NA
  x
}

fix_miss(df)
# Error in fix_miss(df) : input a vector

df$a <- fix_miss(df$a)
fix_miss(df$b)
# [1]  7  4  7 10  6 NA

# but still have error risk of miss-typing col names
# so need to combine to two functions:
  # one, fix_missing() that knows how to remove Nas
  # two, know how to do these to each collum of df lappy()


lapply(df, fix_missing)
# replace-99 with NA, and return a list
# if want a df as a return result

df[] <- lapply(df, fix_miss)
df

# can also apply to a subset of colums 
df[1:5] <- lapply(df[1:5], fix_miss)

df


# if different cols have different codes for missing values
# some cols use -99, some use -999

# can use closers: functions that create and return functions

missing_fixer <- function(na_value) {
  function(x) {
    x[x == na_value] <- NA
    x
  }
}

# when input a na_value, 
  # this function will return a function needs vector x as input

fix_missing_99 <- missing_fixer(-99)
fix_missing_999 <- missing_fixer(-999)

str(fix_missing_99)
# function (x) 
fix_missing_99(c(-99, -999))
# [1]   NA -999
fix_missing_999(c(-99, -999))
# [1] -99  NA


# if want to get numerical summaries for each variable
# solo 1:
summary_1 <- function(x) {
  c(mean(x), median(x), sd(x), mad(x), IQR(x))
}
lapply(df, summary_1)
# but haven't remove na

# so modify

summary_2 <- function(x) {
  c(mean(x, na.rm = T),
    median(x, na.rm = T),
    sd(x, na.rm = T),
    mad(x, na.rm = T),
    IQR(x, na.rm = T))
}

# but require lots of self-repeating, 
# want to apply a function can remove the na automatically

summary_3 <- function(x) {
  funs <- c(mean, median, sd, mad, IQR)
  lapply(funs, function(f) f(x, na.rm = T))
}
# in lapply, in input of the function is also a function, 
  # i.e., mean(), median(), etc. so each of these function
  # na will be removed. 



#==========================
# 10.2 Anonymous functions
#==========================

# when create a function without giving a name
  # it's an annonymous function
install.packages("dplyr")
library(dplyr)

str(mtcars) # 'data.frame':	32 obs. of  11 variables:

lapply(mtcars, function(x) length(unique(x)))

Filter(function(x) !is.numeric(x), mtcars) # extract elements of a vector
# data frame with 0 columns and 32 rows

integrate(function(x) sin(x)^2, 0, 2*pi)


## Anonymous functions have
  # formals()
  # body()
  # a parent environment()

formals(function(x = 4) g(x) + h(x))
# $x
#[1] 4

body(function(x = 4) g(x) + h(x))
# g(x) + h(x)

environment(function(x = 4) g(x) + h(x))
# <environment: R_GlobalEnv>


## can call anonymous function without giving it a name
# but the code is little tricky to read 
  # need to use parentheses in two ways:
    # 1st, to call a function
    # 2nd, to make clear want to call the anonymous function itself


(function(x) 3) # anonymous function
# make clear want to call this anonymous function
(function(x) 3)()
# [1] 3

(function(x) x + 3)(10)
# [1] 13

# behaves exactly as 
f <- function(x) x + 3
f(10)
# [1] 13


## one of the most common uses for anonymous functions
  # is to creat clousers, a function made by other functions



#==============
# 10.3 Closures
#==============

# closure get their names because
  # they enclose the environment of the parent function
  # and can access all its variables
  # useful because it allows us to have two levels of parameters:
    # a parent level that controls operation and 
    # a child level that does the work


# use this idea to generate a family of power functions
  # a parent function (power()) creates two child functions
    # square() and cube()
  
power <- function(exponent) {
  function(x)
    x^exponent
}

Square <- power(2)
Cube <- power(3)

# print out a closure
Square
# function(x)
# x^exponent
# <environment: 0x7fd9e02c83e0>

Cube
#function(x)
#  x^exponent
#<bytecode: 0x7fd9f104d288>
#  <environment: 0x7fd9e4788dc8>

# the difference is the enclosing environment
environment(Square)
# <environment: 0x7fd9e02c83e0>
environment(Cube)
# <environment: 0x7fd9e4788dc8>



# the parent env of a closure is the execution env of the function
  # that created it (upper level function). 

# in R, all functions remeber the env in which they were created
  # either global env or a package env


#--------------------------
# 10.3.1 Function factories
#--------------------------

# a factory for making new functions
  # e.g., power()

# useful for maximum likelihood problem


#--------------------
# 10.3.2 Mutable state
#--------------------

# having varaibles at two levels allow to maintain state
  # across function invocations
# when the execution env is refreshed every time, 
  # the enclosing env is constant

# the key to managing variables at different levels is
  # <<-
  # does not assign in the current evn
    # but keep looking up the chain of parent envs
    # it finds a matching name

# a static parent env and <<- make it possible
  # to maintain state across function calls

# Example:
new_counter <- function() { # create a new env to excuete below
  i <- 0  # initiate i in this env
  function() { # a new function whose parent env is new_counter's execution env
    i <<- i + 1  # i will look up into its parent env 
                 # and assign the value to the var in the parent that match the names
    i
  }
}

count_one <- new_counter()
#   function() { # a new function whose parent env is new_counter's execution env
        # i <<- i + 1  # i will look up into its parent env 
        #  i
#     }

count_one()
# [1] 1
count_one()
# [1] 2

i <- 0
count_1 <- function() { # a new function whose parent env is new_counter's execution env
  i <<- i + 1  # i will look up into its parent env 
  i   # i will be changed, since these change is in local enclosing env
      # the changes to i will be preserved across all function calls. 
}
count_1()
# [1] 1
#> count_1()
#[1] 2
#> count_1()
#[1] 3
#> count_1()
#[1] 4

### the counters get around the "fresh start"
  # by not modifying varaibles in their local env

# since the changes in the i are made in the 
  # unchanging enclosing env where inner function is created
  # these local changes are preserved across function call



new_counter3 <- function() {
  i <- 0
  function() {
    i <- i + 1  # i just assign new value to the local and 
                # won't be able to assign up the change 
                # the the variable having the same name i
                # so every call of new_counter3, 
                # i start from 0, now changes from below
    i
  }
}

nc3_1 <- new_counter3()

nc3_1()


i <- 0
nc <- function() {
  i <- i + 1
  i
}
nc()



#========================
# 10.4 Lists of functions
#========================

# functions can be stored in lists
  # easier to work with groups of related functions
  # like df is easier to work with groups of related vectors


# example: comparing the performance of multiple ways of 
  # computing arithmetic mean
  # can do this by storing each approach (function) in a list

compute_mean <- list(
  base = function(x) mean(x),
  sum = function(x) sum(x) / length(x),
  manual = function(x) {
    total <- 0
    n <- length(x)
    for (i in seq_along(x)) {
      total <- total + x[i] / n
    }
    total
  }
)

x <- runif(1e5)
system.time(compute_mean[[1]](x))
system.time(compute_mean[[2]](x))
system.time(compute_mean[[3]](x))

# to call each of the function
lapply(compute_mean, function(f) f(x))
# $base
#[1] 0.5013672

#$sum
#[1] 0.5013672

#$manual
#[1] 0.5013672


lapply(compute_mean, function(f) system.time(f(x)))


## Another use of list of function:
  # to summarise an obj in mulitple ways
  # can store each summary function in a list
  # then run them all with lapply()

x <- 1:10
funs <- list(
  sum = sum,
  mean = mean,
  median = median
)
lapply(funs, function(f) f(x))
# $sum
#[1] 55

#$mean
#[1] 5.5

#$median
#[1] 5.5

# want to remove the na at the same time
lapply(funs, function(f) f(x, na.rm = T))






























































