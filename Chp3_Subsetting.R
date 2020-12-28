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


#-------------------#
# 3.1.4 Data Frames
#-------------------#

# As data frames possess the characteriscs of 
# both lists and matrices
# so:
  # if subset wiht a single vector, 
    # df acts like a list

  # if subset with two vectors
    # df acts like a matrices

df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df

## selecting rows of a df
df[df$x == 2, ]
df[c(1, 3), ]

## selecting cols from a df, two ways
  ## selecting like a list
df[c("x", "z")]
#   x z
# 1 1 a
# 2 2 b
# 3 3 c

  ## selecting like matrix
df[, c("x", "z")]
#   x z
# 1 1 a
# 2 2 b
# 3 3 c

## NOTE: when selecting a single column
# there's an important difference:
  # selecting like a matrix, 
    # the result is simplified to a vector by defalut
  # selecting like a list,
    # the result keeps the df structure

# like a list
str(df["x"])
# 'data.frame':	3 obs. of  1 variable:
# $ x: int  1 2 3


# like a matrix
str(df[, "x"])
#  int [1:3] 1 2 3


#-=========================#
# 3.2 Subsetting operators
#==========================#
# x is a list
# x[3:5]: only returns a sub list of x
# x[[2]]: returns the value in the 2nd list of x

L <- list(a = 1, b = 2)
L[1]
# $a
#[1] 1

L[[1]]
# [1] 1

L[["b"]] # [1] 2


LR <- list(a = list(b = list(c = list(d = 1))))

# supply with a vector, it indexes recursively
LR[[c("a", "b", "c", "d")]]
# the same as
LR[["a"]][["b"]][["c"]][["d"]]
# [1] 1


# as df are lists of columns, can use [[ ]] to 
# extract a column from df
mtcars[[1]]
head(mtcars, 2)
mtcars[["mpg"]]


#-----------#
# 3.2.2 $
#-----------#

# $ is shorthand operator for [[ ]]combined wiht character subset
# x$y is equivalent to x[["y", exact = FALSE]]
# means $ does partial matching

x <- list(abc = 1)
x$a # [1] 1
x[["a"]] # NULL



#-----------------------------#
# 3.2.3 Out of bounds indices
#-----------------------------#
# OOB


#-------------------------------#
# 3.3 Subsetting and assignment
#-------------------------------#
# subsetting combined with assignment to modify
# selected values of the input vector

x <- 1:5
x[c(1, 3)] <- 100:101
x

# length of both sides shall match
x[-1] <- 4:1
x

# cannot combine integer indices with NA
x[c(1, NA)] <- c(1, 2)
# NAs are not allowed in subscripted assignments


# but can combine with logi indices with NA
# where they are treated as FALSE
x[c(T, F, NA)] <- 1000 # recycled



# most useful when conditionally modifying vectors
df <- data.frame(a = c(1, 10, NA))
df$a[df$a < 5] <- 0
df$a # [1]  0 10 NA simplify to vector
df["a"]
#    a
# 1  0
# 2 10
# 3 NA
# preserving the data frame structure


## Subseting nothig + assignment preserve the original object class

# length(mtcars) # [1] 11
mtcars[] <- lapply(mtcars, as.integer)
# preserve str of mtcars
str(mtcars) 
# 'data.frame':	32 obs. of  11 variables:

mtcars2 <- lapply(mtcars, as.integer)
str(mtcars2) 
# List of 11


## To remove a component of a list
# use [[]] + assignment + NULL
L <- list(a = 1, b = 2)
L[["b"]] <- NULL
L
# $ $a
# [1] 1

## to add a NULL sublist to a list
# use [] + assignment + list(NULL)
L["c"] <- list(NULL)
str(L)
# List of 2
# $ a: num 1
# $ c: NULL



