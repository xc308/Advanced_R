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
attrib() # additional arbitrary metadata

# differ in: atomic vector has the same type of all elements
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
















