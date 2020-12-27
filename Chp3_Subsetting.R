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



#--------------#
# 3.1.2 Lists
#--------------#

# Subsetting a list works the same as subsetting an atomic vector
# use [ ] will return a list
# use [[ ]] or $ will pull out the component of a list

L <- list(1:3, c(T, F), c("a", "b"))
str(L)
L[1]
# return the 1st list
# [[1]]
# [1] 1 2 3
L[2]
# [[1]]
# [1]  TRUE FALSE


# to pull out the component of the 2nd list
L[[2]]
# [1]  TRUE FALSE


#--------------------------#
# 3.1.3 Matrices and Arrays
#--------------------------#

# 3 ways to subset high-dim structures
  # multiple vectors
  # a single vectors
  # a matrix


## subset with a multiple vector
a <- matrix(1:9, nrow = 3)
colnames(a) <- c("A", "B", "C")
a
a[1:2, ]

a[c(T, F, T), c("B", "A")]

a[0, -2]
#  A C


## subset with a single vector
# because matrix / arrays are implemented as vectors
# so, it's possilbe to subset them with a single vector
# In this case, matrix / arrays behave like vectors

# arrays in R are stored in column-major order

vals <- outer(1:5, 1:5, FUN = "paste", sep = "*.*")
vals
# in column-major order
# matrix behave like a vector
vals[c(4, 15)] # subset with a single vector
# pull out the element of the matrix (like vector)
# at the postion of 4th and 15th

# "4*.*1" "5*.*3"


## Subset using a matrix
sel <- matrix(ncol = 2, byrow = TRUE, 
              c(1, 1,
                3, 1,
                2, 4))

# each row of the matrix specified the location
# of the value, e.g (1, 1) the 1st row, the 1st col,
# the number of cols of matrix corresponds to the dimension of arry being subsetted

sel
vals[sel]
# [1] "1*.*1" "3*.*1" "2*.*4"
# the result is a vector

# the n# of cols of the selcting matrix corresponds to the dim of the array being subsetted
# so if it's 2, then subset a matrix, 
# if it's 3, then subset a 3-d array




