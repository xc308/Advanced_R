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





















