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



#-----------------------------------
# 19.1.5 Matrix input, vector output
#-----------------------------------

# each vector type has a matrix equivalent:
  # NumericMatrix
  # IntegerMatrix
  # CharacterMatrix 
  # LogicalMatrix


# Example: rowSums()

NumericVector rowSumsC(NumericMatrix x) {
  int nrow = x.nrow();
  int ncol = x.ncol();
  NumericVector out(nrow);
  
  for (int i = 0; i < nrow; ++i) {
    double total = 0;    // initialse a double scalar, allocate memory
    for (int j = 0; j < ncol; ++j) {
      total += x(i, j);
    }
    out[i] = total;
  }
  return out;
}


NumericVector rowSumsC(NumericMatrix x) {
  int nrow = x.nrow();
  int ncol = x.ncol();
  NumericVector out(nrow);
  
  for (int i = 0; i < nrow; ++i) {
    double total = 0;
    for (int j = 0; j < ncol; ++j) {
      total += x(i, j); //matrix indexing using ()
    }
    out[i] = total; // vector indexing using []
  }
  return out;
}


library(Rcpp)
cppFunction('NumericVector rowSumsC(NumericMatrix x) {
  int nrow = x.nrow();
  int ncol = x.ncol();
  NumericVector out(nrow);
  
  for (int i = 0; i < nrow; ++i) {
    double total = 0;    // initialse a double scalar, allocate memory
    for (int j = 0; j < ncol; ++j) {
      total += x(i, j);
    }
    out[i] = total;
  }
  return out;
}')


set.seed(14-02-2023)
smp <- sample(100)
head(smp)
str(smp)

M <- matrix(sample(100), nrow = 10)
rowSums(M)
rowSumsC(M)

microbenchmark::microbenchmark(
  rowSums(M),
  rowSumsC(M)
)

# Unit: microseconds
#expr    min     lq     mean
#rowSums(M) 11.792 11.959 12.33280
#rowSumsC(M)  1.459  1.667  9.97396
#median      uq     max neval
#12.167 12.3135  27.418   100
#1.834  1.9590 810.709   100

## Remarks:
  # use () to index a matrix in C++;
  # use .nrow(), .ncol() to get the dimension of a matrix;


# revise rowSums function
NumericVector rowSumsC(NumericMatrix x) {
  int nrow = x.nrow();
  int ncol = x.ncol();
  NumericVector out(nrow);
  
  for (int i = 0; i < nrow; ++i) {
    double total = 0;
    for (int j = 0; j < ncol; ++j) {
      total += x(i, j)
    }
    out[i] = total;
  }
  return out;
}

library(Rcpp)

cppFunction('NumericVector rowSumsC(NumericMatrix x) {
  int nrow = x.nrow();
  int ncol = x.ncol();
  NumericVector out(nrow);
  
  for (int i = 0; i < nrow; ++i) {
    double total = 0;
    for (int j = 0; j < ncol; ++j) {
      total += x(i, j)
    }
    out[i] = total;
  }
  return out;
}')



#------------------------
# 19.1.6 Using sourceCpp
#------------------------

# cppFunction in package "Rcpp" is inline C++;
# But real problems, 
  # simpler to use stand-alone C++ file, 
    # then source them into R using sourceCpp();

  # takes advantage of text editor for C++ files

# Stand-alone C++ file should 
  # have extension .cpp
  # needs to start with :
      #  #include <Rcpp.h>
      #  using namespace Rcpp;

# And for each function that you want available within R
  # need to prefix it with:
    #
    # //[[Rcpp::export]]

    # Note: the space above //[[Rcpp::export]] is mandatory;
    # Rcpp::export controls whether a function is 
      # export from C++ to R


# can embed R code in special C++ comment blocks
  # convenient to run test code

/*** R
# This is R code
*/

# the R code is run with source(echo = TRUE)
  # so don't need to print output explicitly
  
  
# To compile C++ code, 
  # use sourceCpp("path/to/file.cpp")
  
  # this will create the matching R functions
  # and add them to your current session. 
  
# These functions can NOT be saved in a .Rdata file
  # and re-loaded later session; 

# they must be recreated each time you restart R

# e.g., running sourceCpp() on the following file
  # implements mean function in C++
    # then compares it to the built-in mean(); 


sourceCpp(file = "Fun_mean.cpp")



#--------------
# 19.2 Attributes and other classes
#--------------

# all R objs have attributes
  # queried and modified with .attr()

# Rcpp provides .names() as an alias for the name attribute

# The use of ::create(), is a class method
  # allows you to create an R vector from C++ scalar values

library(Rcpp)
sourceCpp(file = "Fun_attribs.cpp")


#------------------------------
# 19.2.1 Lists and data frames
#------------------------------

# Rcpp also provides classes List and DataFrame
# more useful for output than input
  # as List and DataFrame can contain arbitrary classes 
    # but C++ needs to know their classes in advance

# if the list has known structure e.g., S3 obj
  # can extract the components and manually convert them 
     # to their C++ equivalents with as()


# Example: 
  # object created by S3 lm(), 
  # show C++ work with S3 obj 
    # to extract the mean percentage error (mpe()) of a linear model
  # .inherits() and stop() to check the obj is really a linear model


library(Rcpp)
sourceCpp("Extract_S3_convert_to_C++.cpp")
# mod <- lm(mpg ~ wt, data = mtcars)
#> mpe(mod)
#[1] -0.01541615


#--------------------
# 19.3 Missing Values
#--------------------

# working with missing values
  # two things:
  # how R's missing values behave in C++'s scalars (double)
  # how to get and set missing values in vectors (NumericVector)

## Scalars
# take one of R's missing values, 
  # coerce it into a scalar in C++, 
    # then coerce back to an R vector

library(Rcpp)
sourceCpp("R_Missing_C++.cpp")
# > str(scalar_missings())
# List of 4
# $ : int NA
# $ : chr NA
# $ : logi TRUE
# $ : num NA

# most of missing values in C++ has been preserved after
  # coercing into R.


#--------------------
# 19.3.1.1 Integers
#--------------------

# with integers, missing values are stored as the smallest integer
# they will be preserved if you don't do anything to them
# Since C++  doesn't know the smallest integer will be preserved
# you will likely to get an incorrect value if you do anything to it

# So if you want to work with missing values in integers
  # either use a length one IntegerVector
  # or be very careful


library(Rcpp)
evalCpp('NA_INTEGER + 1')
# evaluate a C++ expression
# [1] -2147483647


#----------------
# 19.3.1.2 Doubles
#----------------

# With Doubles, 
  # may get away with ignoring missing values
  # and working with NaNs (not a number)

  # any logical expression that involves a NaN or NAN(in C++)
    # always evaluates as FALSE

evalCpp('NAN == 1')
# [1] FALSE

evalCpp('NAN < 1')
# [1] FALSE

evalCpp('NAN > 1')
# [1] FALSE

evalCpp('NAN == NAN')
# [1] FALSE


## but when combining with booling values
evalCpp("NAN && TRUE")
# [1] TRUE

evalCpp("NAN || FALSE")
# [1] TRUE


## But in numeric contexts, NANs will propagate NAs
evalCpp("NAN + 2")
# [1] NaN

evalCpp("NAN - 2")
# [1] NaN

evalCpp("NAN * 2")
# [1] NaN

evalCpp("NAN / 2")
# [1] NaN


#--------------
# 19.3.2 Strings
#--------------

# String is a scalar string class introduced by Rcpp
  # it knows how to deal with missing values


#---------------
# 19.3.3 Boolean
#---------------

# C++ 's bool scalar has two possible values T or F
# a logical vector in R has TRUE, FALSE, NA

# if coerce a length 1 logical vector to R  
  # make sure it doesn't contain any missing values 
  # otherwise they will be converted to TRUE



#==============
# 19.3.4 Vectors
#==============

# With vectors, need to use a missing value specific to the 
  # type of vector, 
  # NA_REAL, NA_INTEGER, NA_LOGICAL, NA_STRING

library(Rcpp)
sourceCpp("Vector_C++_to_R.cpp")
# str(missing_sampler())
#List of 4
#$ : num NA
#$ : int NA
#$ : logi NA
#$ : chr NA



## To check if a value in vector is missing, 
  # use the class method ::is_na()

library(Rcpp)
sourceCpp("Check_NA_in_Vector.cpp")


#================
# 19.4 Rcpp Sugar
#================

# sugar to ensure C++ functions works very similarly 
  # to their R equivalents


# sugar functions:
  # arithmetic and logical operators
  # logical summary functions
  # vector views
  # other useful functions


#--------
# 19.4.1 Arithmetic and logical operators
#--------

# arithmetic and logical operators are vectorised:
  # + * - / pow 
  # < <= > >= == != !


# use sugar to considerably simplify the implementation 
  # of pdistC()

pdistR <- function(x, ys) {
  sqrt((s - ys)^2)
}

library(Rcpp)
sourceCpp("Sugar_pow.cpp")
x <- 3
y <- rnorm(10)
pdistC(x, ys = y)
# [1] 1.224793 3.177128 3.949213 2.494650
# [5] 1.220628 3.424891 2.552759 1.616188
# [9] 1.891071 2.762183



#-----------------------------------
# 19.4.2 Logical summary functions
#-----------------------------------

# any() all()
  # any(x == 0) one evaluate one element of a vector
  # return a special type can convert into a bool 
  # using .is_ture(), .is_false(), .is_na()

# can use this sugar to write an efficient function
  # to determine whether or not a numeric vector contains
  # any missing values

# in R: 
any_naR <- function(x) {
  any(is.na(x))
}

library(Rcpp)
sourceCpp("Logical_summary.cpp")

# microbenchmark::microbenchmark(
+   any_naR(x0), any_naC(x0),
+   any_naR(x1), any_naC(x1),
+   any_naR(x2), any_naC(x2)
+ )
#Unit: microseconds
#expr     min       lq      mean
#any_naR(x0) 168.626 246.1255 264.49403
#any_naC(x0) 218.001 218.7500 225.05065
#any_naR(x1) 168.751 250.3340 293.17022
#any_naC(x1) 218.043 218.7090 227.03070
#any_naR(x2)  75.709 154.8965 201.56982
#any_naC(x2)   1.001   1.2920   8.40196
#median       uq      max neval
#257.6880 275.0840 1358.792   100
#222.5210 228.6465  248.084   100
#263.4175 281.2930 3661.584   100
#222.6460 229.8755  325.793   100
#165.1255 194.8550 3496.793   100
#1.5430   2.0420  618.042   100




#--------------------
# 19.4.3 Vector Views
#--------------------

# helpful functions provide a "view" of a vector:
  # head(), tail(), rep_each(), rep_len(), rev(), 
  # seq_along(), seq_len()


# In R, these would all produce copies of vector
# In Rcpp, they simply point to the existing vector 
  # and override the subsetting operator ([])
  # to implement special behaviour

# so much efficient 
  # e.g. rep_len(x, 1e6) do not make millions of copies of x

rep_len() 
# replicate the values with given length.out


#------------------------
# other useful functions
#------------------------

# p416

# noNA(x) asserts the vector x does not contain any missing
  # values and allows optimisation of some math operations. 



#=================
# 19.5 The STL
#=================

# real strength of C++ when need to implement more complex algo

# The standard templete library (STL)
  # provides a set of extremely useful data structure and algo

# explain the most important algo and data structure

# if the algo or data structure not implemented in STL
  # a good place to start is boost

# install boost, then
  # can include boost data structures and algo 
  # by including appropriate header file with 
  # #include <boost/array.hpp>


#-----------------------
# 19.5.1 Using iterations
#-----------------------

# iterators are used extensively in the STL
  # many functions either accept or return iterators
  
# iterators have 3 main operators:
  # advance with ++
  # get the value they refer to *
  # compare with ==


# rewrite the sum function using iterations
library(Rcpp)
sourceCpp("Iterator.cpp")
# sum3(x)
# [1] -16.44646


sourceCpp("accumulate_in_numeric.cpp")
#  sum(x)
# [1] 95.71833



#==================
# 19.5.2 Algorithms
#==================

# <algorithm> header provides a larger number of algo 
  # that work with iterations

# 


#=======================
# 19.5.3 Data structures
#=======================

# most important data structure:
  # vector, unordered_set, unordered_map

# Rcpp knows how to convert from many STL data structures 
  # to R equivalents, 


#--------------------
# 19.5.4 Vectors STL
#--------------------

# STL vectors very similar to R vector
  # except it grows efficiently
  # makes vectors appropriate to use when you don't know
    # how big the output will be

# Vectors are templatd
  # you need to specify the type of obj the vector
    # will contain when you create it:
      # vector<int>, vector<bool>, vector<double>, vector<String>

# access the elements of a vector using []
# add a new element at the end of the vector 
    # using .push_back()

# if have idea how big the vector will be, 
  # use .reserve() to allocate sufficient storage



# -----------
# 19.5.5 Sets
# -----------

# Sets maintain a unique set of values, 
  # can efficiently tell if the value has been seen before

# useful for problem involving:
  # duplicates or unique values
  # like unique, duplicated, in

# C++ provides both 
  # ordered set (std::set)
  # unordered set (std::unordered set)

# Unordered set: faster, 
  # use a hash table internally (key-value pair dictionary)
  # rather than tree

  # so should use unordered set then sorting the output


# Sets are temperlated (same as vector)
  # need to request the appropriate type of set
  # unordered_set<int>, unordered_set<bool>, 


# Example:
  # uses unordered set to implement an equivalent to 
    # duplicate() for integer vecotors. 

  # the use of see.insert(x[i]).second. insert() returns a pair
  # the .first value is an iterator that points to element 
  # the .second value is a boolean that's ture if the value
    # was a new addition to the set

library(Rcpp)
sourceCpp("Unordered_set.cpp")  
# > x <- c(4, 2, 4, 8, 0)
#> duplicatedC(x)
#[1] FALSE FALSE  TRUE FALSE FALSE


#-----------------
# 19.5.6 Map
#-----------------

# A map:
  # similar to a set
  # but instead of sorting presence or absence
    # it can store additional data

  # useful for functions like table() or match() that need
  # to look up a value

  # there are 
    # ordered_map std::map
    # unordered_map std::unordered_map

  # maps have a value and a key
    # need to specify both types when initialising a map
      # map<double, int>
      # unordered_map<double, double> etc.

# examples:
  # shows using a map to implement table() for numeric vectors



x <- c(4, 3, 8, 9, 9, 2, 4)
table(x)
# x
#2 3 4 8 9 
#1 1 2 1 2

sourceCpp("Map.cpp")
# > x <- c(4, 3, 8, 9, 9, 2, 4)

#> tableC(x)
#2 3 4 8 9 
#1 1 2 1 2 


#===================
# 19.6 Case Studies
#===================

# Use C++ to replace slow R

#--------------
# Gibbs Sampler
#--------------

gibbs_r <- function(N, thin) {
  mat <- matrix(NA, nrow = N, ncol = 2)
  x <- y <- 0
  
  for (i in 1:N) {
    for (j in 1:thin) {
      x <- rgamma(1, shape = 3, rate = y*y + 4)
      y <- rnorm(1, mean = 1/(x+1), sd = 1/sqrt(2*(x+1)))
    }
    mat[i, ] <- c(x, y)
  }
}


library(Rcpp)
sourceCpp("Gibbs_C.cpp")

microbenchmark::microbenchmark(
  gibbs_r(N = 100, thin = 10),
  gibbs_C(N = 100, thin = 10)
)

# Unit: microseconds
#Unit: microseconds
#                       expr      min       lq      mean   median
#gibbs_r(N = 100, thin = 10) 3237.376 3266.979 4064.2569 3306.168
#gibbs_C(N = 100, thin = 10)  311.043  318.146  324.2461  322.355

# 10 times faster






















  












































































































  




























