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



# ===============#
# 3.4 Application
#================# 

#--------------------#
# 3.4.1 lookup tables
#---------------------#
# or character matching or subsetting
x <- c("m", "f", "u", "f", 'm')
lookup <- c(m = "Male", f = "Female", u = "Unkown")
lookup[x]

unname(lookup[x])

#----------------------------------#
# 3.4.2 Matching and merging by hand
#----------------------------------#
grades <- c(1, 2, 3, 2, 1)
info <- data.frame(
  grades = 3:1,
  descrp = c("Excellent", "Good", "Poor"),
  fail = c(F, F, T)
)
head(info, 2)

# want to corresponding infor for each value of grades
# two ways to do this:
  # match() and integer subsetting
  # rownames() and character subseeting


# match()
id <- match(grades, info$grades)
# returns a vector of postition the 1st argument match the 2nd argument table
info[id, ]

# rownames()
head(info, 2)

rownames(info) <- info$grades
head(info, 2)
info[as.character(grades), ]


#--------------------------------#
# 3.4.3 Random Smaples/bootstrap 
# (integer subsetting)
#--------------------------------#
rep(1:3, each = 2)
# [1] 1 1 2 2 3 3

df <- data.frame(x = rep(1:3, each = 2),
           y = 6:1, z = letters[1:6])

df


sample(nrow(df)) # get a vector of indices

# subset the indices to access the values
set.seed(28-12-2020)
df[sample(nrow(df)), ]

# select 3 row randomly
df[sample(nrow(df), 3), ]


# select 6 bootstrap relicates (equivalent to with replacement sampling)
df[sample(nrow(df), 6, replace = TRUE), ]
#     x y z
# 5   3 2 e
# 3   2 4 c
# 6   3 1 f
# 6.1 3 1 f
# 5.1 3 2 e
# 1   1 6 a
# sample() what, how many, and with/without replacement


#----------------------#
# 3.4.4 Ordering 
# (interger subsetting)
#----------------------#
# order()takes a vector as input, 
# returns an integer vector indicating how the input should be ordered
P <- c("c", "x", "l", "a")
order(P) # [1] 4 1 3 2
P[order(P)]
# [1] "a" "c" "l" "x"

# additional variable to order()
  # ascending / descending = TRUE

# any missing value will be put at the end
# can remove them by na.last = NA or 
# PUT the NA AT THE FIRST na.last = FALSE

order(c(NA, "c", "x", "l", "a"))
# [1] 5 2 4 3 1

# remove NA
order(c(NA, "c", "x", "l", "a"), na.last = NA)
#[1] 5 2 4 3

# NA put at the first
order(c(NA, "c", "x", "l", "a"), na.last = FALSE)
# [1] 1 5 2 4 3


## For two or more dimensio, 
# order() and integer subsetting makes it easy
# to subset either the rows/columns of an object

# reorder rows by sample & reoder colum
df2 <- df[sample(nrow(df)), 3:1]
df2
#   z y x
# 5 e 2 3
# 2 b 5 1
# 1 a 6 1
# 3 c 4 2
# 4 d 3 2
# 6 f 1 3

# reorder rows
df2[order(df2$x), ]

# reorder cols
df2[, order(colnames(df2))]


#----------------------------#
# Expanding aggregated counts
# (integer subsetting)
#----------------------------#
# sometimes data frame's duplicated rows 
# have been collapsed into one
# and a count column has been added

# use rep() to uncollapse and integer repeated subsetting


df <- data.frame(x = c(2, 4, 1), y = 3:1, n = c(3, 5, 2))
df
rep(1:nrow(df), df$n)
df[rep(1:nrow(df), df$n), ]


#---------------------------------------#
# 3.4.6 Removing columns from data frame
# (chr subsetting)
#---------------------------------------#
# Two ways:
  # set individual col to be NULL
  # only subset the ones you want

df <- data.frame(x = 1:3, y = 2:4, z = LETTERS[1:3])
df
df$z <- NULL
df

df[c("x", "y")]

# if know the name of col don't want 
# jsut use the setdiff to work out which column to keep
setdiff(colnames(df), "z")
# [1] "x" "y"

# col subset is chr subset
df[setdiff(colnames(df), "z")]


#------------------------------------------#
# 3.4.7 Selceting rows based on a condition
# (logical subsetting)
#-------------------------------------------# 
head(mtcars, 2)
range(mtcars$mpg)

mtcars[mtcars$mpg > 20 & mtcars$gear > 5, ]

# subset() a shorthand for subsetting df
subset(mtcars, gear == 5)



#-----------------------------------------#
# 3.4.8 Boolean algebra vs sets operations
#-----------------------------------------#
x <- sample(10) < 4
x
# [1] FALSE FALSE FALSE  TRUE FALSE
# [6] FALSE  TRUE FALSE FALSE  TRUE
which(x) 
# convert logi to integer
# return true
# return the integer postion of boolean true
# [1]  4  7 10 these postion are true

# unwhich
unwhich <- function(x, n){
  out <- rep_len(FALSE, n)
  out[x] <- TRUE
  out
}


# rep_len(FALSE, 10)[x] # x is logi 0000100001
# got [1] FALSE FALSE FALSE


unwhich(which(x), 10)
#  [1] FALSE FALSE FALSE  TRUE FALSE
#  [6] FALSE  TRUE FALSE FALSE  TRUE



## create two logi vectors and their integer equivalents

# Logi
(x1 <- 1:10 %% 2 == 0)
# [1] FALSE  TRUE FALSE  TRUE FALSE
# [6]  TRUE FALSE  TRUE FALSE  TRUE

# integer equvalents
(x2 <- which(x1))
# [1]  2  4  6  8 10

# logi
(y1 <- 1:10 %% 5 == 0)
#  [1] FALSE FALSE FALSE FALSE  TRUE
#  [6] FALSE FALSE FALSE FALSE  TRUE

# integer equvalents
(y2 <- which(y1))
# [1]  5 10


## Relationship betw logi and integer equivalents

# x & y  is the same as intersect(x, y)
x1 & y1
# [1] FALSE FALSE FALSE FALSE FALSE
# [6] FALSE FALSE FALSE FALSE  TRUE
intersect(x2, y2)
# [1] 10


# x | y is the same as union(x, y)
x1 | y1
# [1] FALSE  TRUE FALSE  TRUE  TRUE
# [6]  TRUE FALSE  TRUE FALSE  TRUE

union(x2, y2)
# [1]  2  4  6  8 10  5


# x & !y is the same as setdiff(x, y)
x1 & !y1
# [1] FALSE  TRUE FALSE  TRUE FALSE
# [6]  TRUE FALSE  TRUE FALSE FALSE

setdiff(x2, y2)
# [1] 2 4 6 8


# xor(x, y) is the same as setdiff(union(x, y), intersect(x, y))
xor(x1, y1)
# [1] FALSE  TRUE FALSE  TRUE  TRUE
# [6]  TRUE FALSE  TRUE FALSE FALSE

setdiff(union(x2, y2), intersect(x2, y2))
# [1] 2 4 6 8 5















