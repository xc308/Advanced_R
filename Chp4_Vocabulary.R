#**********************#
# Chapter 4 Vocabulary 
#**********************#

#===========
# 4.1 Basics
#===========

get()
#get(x, pos = -1, envir = as.environment(pos), mode = "any",
#    inherits = TRUE)
# Search by name for an object (get) or zero or more objects (mget).
# x: 
  # For get, an object name (given as a character string).
  # For mget, a character vector of object names
# pos: 
  # default of -1 indicates the current environment of the call to get

get("%o%")



#------------
## Basic Math
#------------
##
sign # return a vector of signs of the elements of targeting vector 

x <- c(1, -1, 3, -5, -9)
sign(x) # [1]  1 -1  1 -1 -1
 
##
ceiling(4) 
  # [1] 4 ceiling of 4 is the number no less than 4
  # returns the smallest value that's no less than x
  # ceiling of x ~ >= x

## 
floor() 
  # floor of x ~ <= x
  # largest value no greater than x


## 
trunc()
  # takes: a single numeric argument x
  # returns: a numeric vector containing the 
    # integers formed by truncating the values in x toward 0

trunc(4.28) #[1] 4
trunc(-0.45) # [1] 0


## 
signif(4.56, 2)
  # rounds the values in its first argument to the specified number of significant digits
  # [1] 4.6
  # > signif(4.569, 3)
  # [1] 4.57


## 
cummax(1:10)
# [1]  1  2  3  4  5  6  7  8  9 10
cummin(1:10)
# [1]  1  2  3  4  5  6  7  8  9 10
cumprod(1:10)
# [1]       1       2       6
# [4]      24     120     720
# [7]    5040   40320  362880
# [10] 3628800

cumsum(1:10)
# [1]  1  3  6 10 15 21 28 36 45 55


## pmin()

min(5:1, pi) #-> one number  1
pmin(5:1, pi) #->  5  numbers
# [1] 3.141593 3.141593 3.000000 2.000000 1.000000

## rle
rle() 
  # Compute the lengths and values of runs of equal values in a vector 

x <- rev(rep(6:10, 1:5))
# [1] 10 10 10 10 10  9  9  9  9  8  8  8  7  7  6

rle(x)
# Run Length Encoding
#lengths: int [1:5] 5 4 3 2 1
#values : int [1:5] 10 9 8 7 6


#================================
# Functions relating to functions
#================================

missing()
  # sed to test whether a value was specified as an argument to a function.

myplt <- function(x, y) {
  if (missing(y)) {
    y <- x
    x <- 1:length(y)
  }
  
  plot(x, y)
}

x <- seq(1:100)
myplt(x)


##=====================
# Vectors and matrices
##=====================

sweep()
  # Sweep out Array Summaries
  # sweep(x, MARGIN, STATS, FUN = "-", check.margin = TRUE, ...)
    # x	an array, including a matrix.
    # MARGIN	a vector of indices giving the extent(s) of x which correspond to STATS. 
      # Where x has named dimnames, it can be a character vector selecting dimension names.

  # STATS	the summary statistic which is to be swept out.
  # FUN	the function to be used to carry out the sweep.
  # 

A <- array(1:24, dim = 4:2)
A
A.fun <- apply(A, 1, min)
sweep(A, 1, min)


require(stats)
med.att <- apply(attitude, 2, median)

sweep(data.matrix(attitude), 2, med.att)
Matr_att <- data.matrix(attitude)

head(attitude)
str(Matr_att)
head(Matr_att)





