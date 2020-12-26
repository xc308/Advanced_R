################
# Advanced R #
##############

##---------------------------##
# Chapter 2 Data Structures #
##--------------------------##

#------------#
# 2.1 Vectors 
#------------#
# the basic data str
# two flavors: atomic vector, list
# have 3 common properties
typeof() # type
length() # how many elements it contains
attri() # additional arbitrary metadata

# differ in:atomic vector has the same type of all elements
# list can have different types of elements

# to test if an obj is an atomic vector or a list
is.atomic()
is.list()



## 2.1.1 Atomic Vectors ##

# 4 different types of atomic vectors
# logical, integer, double (numeric), character

# atomic vector are usually created with c(), combine

# double
dbl_var <- c(1, 3.3, 4.5)

# with L, get integer
int_var <- c(1L, 2L, 5L)

# use TRUE, FALSE, T, F to create logical vector
log_var <- c(TRUE, FALSE, T, F)

# use "abc" strings to create character vector
chr_var <- c("these are", "some strings")

# atomic vectors are always flat
c(1, c(2, c(3, 4)))
# [1] 1 2 3 4

# the same as 
c(1, 2, 3, 4)
# [1] 1 2 3 4


# missing value NA is a logical vector of length 1
length(NA) # [1] 1


## 2.1.1.1 Types and tests ##
typeof(int_var) # "integer"
is.integer()
is.atomic()

## 2.1.1.2 Coercion ##
# all elements of atomic vector must be same type
# so when combine different type, 
# they will be coerced to the most flexible type
# types from least to most flexible are:
# logical, integer, double, character

c("hi", 3L) # will return a chr
# [1] "hi" "3" 


# when a logical vector is coerced to an int
# or a double, TRUE becomes 1, FALSE be 0. 
# this is useful when conjunction with sum(), mean()

X <- c(F, F, F, T)
sum(X) # [1] 1
mean(X) # [1] 0.25
as.numeric(X) # [1] 0 0 0 1


## 2.1.2 Lists ##
# lists are different types of elements, including lists
# construct lists using list()

x <- list(1:3, "a", c(T, F), c(2.3, 4.6))
str(x)

# a list can contain other lists
x <- list(list(list(list())))
str(x)

# called recursive vector
is.recursive(x) #[1] TRUE

# if given a combination of vectors and lists
# c() will coerce the vector to list before combining them 
x <- list(list(1, 2), c(3, 4))
str(x)

y <- c(list(1, 2), c(3, 4)) # first coerce c(3, 4) into a vector
str(y)


# test a list
is.list()

# coerce to a list
as.list()

# lists are used to build up many complicated data structures
# include data frame, linear model objects
is.list(mtcars) # [1] TRUE

mod <- lm(mpg ~ wt, data = mtcars)
is.list(mod) # [1] TRUE


#---------------#
# 2.2 Attributes 
#---------------#
# attributes can be thought of as a named list (unique names)
# can be accessed individually with attr()
# or all at once (as one list) with attributes()

y <- 1:10
attr(y, "attribute 1") <- "y is a vector"
attr(y, "attribute 2") <- "its length is 10"
attr(y, "attribute 3") <- "it has 10 elements"
attr(y, "attribute 4") <- "each of its element is integer"


attributes(y)
# $`attribute 1`
# [1] "y is a vector"

# $`attribute 2`
# [1] "its length is 10"

# get a single attribute of y
attr(y, "attribute 2") # "its length is 10"

str(attributes(y))
# List of 4
# $ attribute 1: chr "y is a vector"
# $ attribute 2: chr "its length is 10"
# $ attribute 3: chr "it has 10 elements"
# $ attribute 4: chr "each of its element is integer"

y # has both a vector of values and a list of 4 named lists
#  [1]  1  2  3  4  5  6  7  8  9 10
# attr(,"attribute 1")
# [1] "y is a vector"
# attr(,"attribute 2")
# [1] "its length is 10"
# attr(,"attribute 3")
# [1] "it has 10 elements"
# attr(,"attribute 4")
# [1] "each of its element is integer"


# By default, most attributes lost when modifying a vector
attributes(sum(y)) # NULL
attributes(y[1]) # NULL


# only 3 most important attributes won't lost
# Names: a chr vector giving each element a name
# Dimensions: used to turn vectors into matrices and arrays
# Class: to implement the S3 object system

# each of above attributes has their own 
# accessor function to get and set values
# names()
# dim()
# class()



## 2.2.0.1 Names ##
# 3 ways to create names:

# when 1st creating it
x <- c(a = 1, b = 2, c = 3)

# modify an existing vector in place:
x <- 1:3
names(x) <- c("a", "b", "c")
x


# creating a modified copy of a vector
x <-setNames(object = 1:3, c("a", "b", "c"))
x


# not all elements of a vector need ot have names
# if some names are missing, 
# names() will return an empty string for these elements
# if all names are missing, then return NULL

y <- c(a = 0, 1, 2)
names(y) # [1] "a" ""  "" 

z <- c(0, 1, 2)
names(z)  #NULL

# to remove names in place
names(x) <- NULL
names(x) # NULL



#---------------#
# 2.2.1 Factors 
#---------------#
# one important use of attributes is to define vectors
# A factor is a vector that can contain only predefined values
# and is used to store categoriacal data

# factors are built on top of integer vectors
# usign two attributes: 
# class(), "factor", which makes them behave differently from regular integer vectors
# levels(), which define the set of values allowed. 

x <- factor(c("a", "b", "c"))
x
class(x) # "factor"
levels(x) # [1] "a" "b" "c"

# cannot assign values that are not in the levels
x[2] <- "c"
x[2] <- "d"
# Warning message:
#In `[<-.factor`(`*tmp*`, 2, value = "d") :
#  invalid factor level, NA generated

#  Nor can we combine factors
c(factor("a"), factor("b")) # [1] 1 1

# use a factor instead of a character vector 
# makes it obvious when some groups contains no obs

sex_chr <- c("m", "m", "m")
sex_factor <- factor(sex_chr, levels = c("m", "f"))

table(sex_chr)
# sex_chr
# m 
# 3 

table(sex_factor)
# sex_factor
# m f 
# 3 0 

# while factors look like charactor vectors
# they are actually integers. 
# so coerce the factor to charactor vectors
# if need string - like behavior


#------------------------#
# 2.3 Matrices and Arrays
#------------------------#

# Adding a dim() to an atomic vector allows
# it to behave like a multi - dimensional array
# A special case of the array is the matrix
# which has two dim

# matrix 
a <- matrix(1:6, nrow= 2, ncol = 3)

# array
# use one vector argument to describe all dimensions
b <- array(1:12, c(2, 3, 2))

# can also modify an obj already in place by setting dim()
c <- 1:6
dim(c) <- c(3, 2)
c

dim(c) <- c(2, 3)

rownames(a) <- c("A", "B")
colnames(a) <- c('c', "d", "e")
a

length(b)
dim(b)
dimnames(b) <- list(c("One", "Two"),
                    c("C1", "C2", "C3"),
                    c("Layer1", "Layer2"))
b

# Note:
# Vectors are not the only 1-d data structure
# matrix can have single row/col, 
# arrays can just have one single dimension
# they print out quite similar
# but they are structurly different
# always use str()

str(c(1:3))  # 1-d vector
# int [1:3] 1 2 3

str(matrix(1:3, ncol = 1)) # column vector
# int [1:3, 1] 1 2 3

str(matrix(1:3, nrow = 1)) # row vector
# int [1, 1:3] 1 2 3

str(array(1:3, 3)) # 1-d array
# int [1:3(1d)] 1 2 3







