#**********************#
# Chapter 3 Subsetting 
#**********************#

# Concepts:
# 3 subsetting operators
# 6 types of subsetting
# important differences in behavior for different
    # objects (vectors, lists, factors, matrices, data frames)
# the use of subsetting in conjunction with assignment


#================#
# 3.1 Data types 
#================#

#---------------------#
# 3.1.1 Atomic Vectors 
#---------------------#

x <- c(2.1, 4.2, 3.3, 5.4)

## positive integers 
x[3] # [1] 3.3

x[c(3, 1)] # [1] 3.3 2.1

x[c(1, 1)] # [1] 2.1 2.1

x[c(2.1, 2.9)] # real value postion truncate to integer
# [1] 4.2 4.2

order(x) # [1] 1 3 2 4
x[order(x)]


## Negative integers
x[-c(3, 1)]  # remove 
# 4.2 5.4

## logical vectors: select TRUE postion
x[c(T, T, F, F)] # [1] 2.1 4.2

x[c(T, F)] # recycled to the same length
# [1] 2.1 3.3
# equivalent to x[c(T, F, T, F)]

x[c(T, T, NA, T)]
# [1] 2.1 4.2  NA 5.4

## Nothing: return the vector itself
x[] # [1] 2.1 4.2 3.3 5.4

## zero: return a length-zero vector
x[0] # numeric(0)


## Chr vectors
y <- setNames(1:3, c("a", "b", "c"))
y[c("a", "c")]

y <- setNames(x, letters[1:4])
y[c("a", "d")]
#   a   d 
# 2.1 5.4 





