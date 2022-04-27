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


#================
# making vectors
#================

##
rev()
  # provides a reversed version of its argument.
x <- c(1:5, 5:3)
rev(x)


##
combn()
  # Generate all combinations of the elements of x taken m at a time
  # If argument FUN is not NULL, applies a function given by the argument to each point
  # If x is a positive integer, returns all combinations of the elements of seq(x) taken m at a time.
combn(letters[1:4], 2)
combn(seq(5), 2, min)
# = combn(5, 2)
# [1] 1 1 1 1 2 2 2 3 3 4
# seq(5) = 1,2,3,4,5
# combination: 
  # 12, 13, 14, 15, min = 1
  # 23, 24, 25, min = 2
  # 34, 35, min = 3
  # 45,  min = 4


## 
as.numeric()
  # for double precision 


#====================
#lists & data.frames
#==================== 

split()
  # split(x, f, drop = FALSE, ...)
  # divides the data in the vector x into the groups defined by f
  # x: vector or data frame containing values to be divided into groups.
  # f: a ‘factor’ in the sense that as.factor(f) defines the grouping, or a list of such facto
  # drop: ogical indicating if levels that do not occur should be dropped

split(x, f, drop = FALSE, ...) <- value
  # value: a list of vectors or data frames compatible with a splitting of x. 


split(1:10, 1:2)
# $`1`
#[1] 1 3 5 7 9

#$`2`
#[1]  2  4  6  8 10


require(stats); require(graphics)
n <- 10; nn <- 100
g <- factor(round(n * runif(n * nn)))
str(g)
#[1] 5  10 6  9  10 8 
#Levels: 0 1 2 3 4 5 6 7 8 9 10


x <- rnorm(n * nn) + sqrt(as.numeric(g))
xg <- split(x, g)
str(xg)
#List of 11
#$ 0 : num [1:50] 2.3937 1.6635 1.318 0.3456 -0.0188 ...
#$ 1 : num [1:105] 2.13 1.97 0.51 1.98 1.06 ...
#$ 2 : num [1:91] 0.282 2.186 2.911 2.691 1.613 ...
#$ 3 : num [1:108] 3.19 3.15 3.1 2.14 2.02 ...
#$ 4 : num [1:105] 1.75 1.77 2.59 1.73 3.55 ...

# those with 0 labled elements in x is catorgorized into the 1st row
  # those with 1 labled elements in x in catorgoized into the 2nd row

boxplot(xg, col = "lavender", notch = TRUE, varwidth = TRUE)

# the boxes are drawn with widths proportional to the square-roots of the number of observations in the groups
# if notch is TRUE, a notch is drawn in each side of the boxes. 
  #  If the notches of two plots do not overlap this is ‘strong evidence’ that the two medians differ 







