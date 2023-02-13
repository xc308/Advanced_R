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

cppFunction('int one() {
  return 1;
}')


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


#----------------------------------
# 19.1.2 Scalar input, scalar output
#----------------------------------

# a scarlar version of sign() function
  # that returns 1 if input is postive
    # and -1 if input is negative

signR <- function(x) {
  if (x > 0) {
    1
  } else if (x == 0) {
    0
  } else {
    -1
  }
}



signR <- function(x) {
  if (x > 0) {
    1
  } else if (x == 0) {
    0
  } else {
    -1
  }
}


cppFunction('int signC(double x) {
  if (x > 0) {
    return 1;
  } else if (x == 0) {
    return 0;
  } else (x < 0) {
    return -1;
  }
}')





cppFunction('int signC(double x) {
  if (x > 0) {
    return 1;
  } else if (x == 0) {
    return 0;
  } else {
    return -1;
  }
}')


cppFunction('int signC(double x) {
  if (x > 0) {
    return 1;
  } else if (x == 0) {
    return 0;
  } else {
    return -1;
  }
}')


## declare each type of input as well as output type
## as in R, can use break to exit the loop
  ## but to skip one iteration, 
    ## need to use continue instead of next in C



#----------------------------
# Vector input, scalar output
#----------------------------

# the cost of loop is much smaller in C++

sumR <- function(x) {
  total <- 0
  for (i in seq_along(x)) {
    total <- total + x[i]
  }
  total
}

## in C++, loops has little cost
# in 19.5, see alternatives to for loop that more clearly 
  # express your intent
  # not faster, but more clearer


double sumC(NumericVector x) {
  int n = x.size();
  double total = 0;
  
  for (int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total;
}


cppFunction('double sumC(NumericVector x) {
  int n = x.size();
  double total = 0;
  
  for (int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total;
}')


sumR <- function(x) {
  total <- 0
  for (i in seq_along(x)) {
    total <- total + x[i]
  }
  total  # a scalar
}

double sumC(NumericVector x) {
  int n = x.size(); # method .size(), returns an integer
  double total = 0;
  
  for (int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total;
}

cppFunction('double sumC(NumericVector x) {
  int n = x.size(); // method .size() return integer
  double total = 0;
  
  for (int i = 0; i < n; ++i) {
    total += x[i];
  }
  return total;
}')


sumR <- function(x) {
  total <- 0
  
  for (i in seq_along(x)) {
    total <- total + x[i]
  }
  total
}


double sumC(NumericVector x) {
  int n = x.size();
  double total = 0;
  
  for (int i; i < n; ++i) {
    total += x[i];
  }
  return total;
}


cppFunction('double sumC(NumericVector x) {
  int n = x.size();
  double total = 0;
  
  for (int i; i < n; ++i) {
    total += x[i];
  }
  return total;
}')


## Remarks
  # .size() is a C++ method, use . to call method in C++;
  # syntax for for loop is for (init; check; increment):
    # 1. initialised by creating a new variable i with value 0;
    # 2. before each iteration, we check i < n
       # terminate the loop if not
    # 3. after each iteration, we increament the value of i by 1
      # using prefix operator ++ which increase the value of i by 1

  # In C++, Vector indices start at 0! so above 0, 1, 2, 3, 4, 
  # In C++, Vector indices start at 0!
  # In C++, Vector indices start at 0!
  # common source of error when converting R to C++

  # use = assign not <-

  # += in place operators, -=, *=, /=

x <- runif(1e3)
microbenchmark::microbenchmark(
  sum(x), # built-in so highly optimised
  sumC(x),
  sumR(x)
)

# Unit: microseconds
#expr     min       lq      mean   median       uq     max
#sum(x) 109.375 109.5430 109.99936 109.6465 109.8755 117.292
#sumC(x)   1.917   2.0425   2.29686   2.1260   2.2090  10.750
#sumR(x)  38.875  38.9590  39.15147  39.0005  39.0840  44.043


#-----------------------------------
# 19.1.4 Vector input, vector output
#-----------------------------------

# compute Euclidean distance between a value and a vector of values
# 
pdistR <- function(x, ys) {
  sqrt((x - ys)^2)
}

# x is a scalar and ys is a vector

NumericVector pdistC(double x, NumericVector ys){
  int n = ys.size();
  NumericVector out(n);
  
  for (int i = 0; i < n; ++i) {
    out[i] = sqrt(pow(ys[i] - x, 2.0));
  }
  return out;
}


NumericVector pdistC(double x, NumericVector ys) {
  int n = ys.size();
  NumericVector out(n); // a new numeric vector of length n
  
  for (int i = 0; i < n; ++i) {
    out[i] = sqrt(pow(ys[i] - x, 2.0)); //pow() for exponentiation
  }
  return out;
}

cppFunction('NumericVector pdistC(double x, NumericVector ys) {
  int n = ys.size();
  NumericVector out(n);
  
  for (int i = 0; i < n; ++i) {
    out[i] = sqrt(pow(ys[i] - x, 2.0));
  }
  return out;
}')


x <- 1
ys <- runif(1e4)
microbenchmark::microbenchmark(
  pdistR(x, ys),
  pdistC(x, ys)
)

# Unit: microseconds
# expr    min      lq     mean median
# pdistR(x, ys) 26.793 42.2925 59.80900 42.688
# pdistC(x, ys)  7.459 23.4590 30.68529 23.959
# uq      max neval
# 43.605 1720.834   100
# 24.605  571.543   100


## Remark:
  # R is already vectorized version, so is fast
  # but C++ is faster 
  # due to memory allocation 
  # R needs to create an intermidiate vector the same
    # length as y, and allocating memory is expensive.




















