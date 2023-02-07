#===========================================
# Chp 19 High Performance functions with Rcpp
#===========================================

# improve perfomance by rewritting key functions in C++
# by Rcpp package

  # make it simple to connect C++ to R

# C++ can address:
  # loops can be easily vectorised since subsequent iterations
    # depend on previous ones

  # Recursive functions or problems calling functions 
    # millions of times

  # problems that require advanced data strucutures 
    # and algo that R does not provide
      # via std. template library (STL), 
      # C++ has efficient implementations of many important
      # data structures, e.g., ordered maps, double-ended queues


#-------------
# pre-requisit
#-------------
# install the lastest version of Rcpp
install.packages("Rcpp")
library(Rcpp)

# a working C++ compiler
  # Xcode


#-----------------------------
# 19.1 Getting started with C++
#-----------------------------

# cppFunction() allows you to write C++ functions in R

cppFunction(
  'int add(int x, int y, int z){
  int sum = x + y + z;
  return sum;
  }'
)

add
# function (x, y, z) 
# .Call(<pointer: 0x113856120>, x, y, z)

# can work like a regular R function
add(1, 2, 3)
# [1] 6

# when run this add() function
  # Rcpp will compile the C++ code 
    # and construct an R function that connects to 
      # to the compiled C++ function


## Following translate simple R functions to their C++ equivalents
  # start with a function with 
    # no inputs, scalar output, then
    # scalar input, scalar output
    # Vector input, scalar output
    # Vector input, vector output
    # Matrix input, vector output


#-------------------------------
# 19.1.1 No input, scalar output
#-------------------------------

# simple start: no arg. always return integer 1
one <- function() 1L

# equivalent C++
int one() {
  return 1;
}

# compile this C++ from R
cppFunction('int one() {
            return 1;
}')


## difference in C++ compared with R:
  # must declear the type of output the function returns (one)
  # must use an explicit return statement to return a value from a function
  # must end every statement with ';'

# scaler and vector type correspondence:
  # scaler: 
    # double, int, string, bool

  # vector:
    # NumericVector, IntegerVector, CharacterVector, LogicalVector

































