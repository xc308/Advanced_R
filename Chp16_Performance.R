#====================
# Chp 16 Performance
#====================

# the following 4 chapters will give skills to speed up
  # the code

# chp17: how to systematically make your code faster
  # figure out what's slow, 
  # then apply general techniques to make the slow parts faster

# chp18: how R uses memory,
        # how garbage collection and copy-on-modify affect performance
        # and memory usage

# chp19: C++, Rccp package

# chp 20: understand performance of built-in base functions, 
        # a bit about R's C API. R's C internal. 


#-------------------------
# 16.2 Mircrobenchmarking
#-------------------------

# measurement of a very small piece of code
  # sth taking microseconds and nanoseconds

# best tool for benchmarking is microbenchmarking package
   # provides precise timing

# example: compare the speed of two ways of computing a square root

install.packages("microbenchmark")
library(microbenchmark)

x <- runif(100)
microbenchmark(
  sqrt(x),
  x^0.5
)

# by defalut, microbenchmark() runs each expression
# 100 times, also randomise the order of the expressions

# min, lower quantile (lq)

## useful to think how much times a function needs to run
# before it takes a second
# 1 ms, one thousand calls takes a second
# 1 Ats (microseconds), one million call takes a second
# 1 ns (nanoseconds), one billion call takes a second


#---------------------------
# 16.3 Language performance
#---------------------------
# 3 trade-offs that limit the performance of R
  # exetreme dynamism, 
  # name lookup with mutable environments
  # lazy evaluation of function args


# illustrate each trade-off by benchmarking 
  # showing how it slows down GNR-R

# trade-offs key to language design:
  # balance speed, flexibility, ease of implementation

# S3 and S4 method dispatch are expensive 
  # since R must search for the right method
  # every time the generic is called. 


#------------------------------------
# 16.3.2 Name loopup with mutable env
#------------------------------------

# it's difficult to find the value associated with a name
# in R
# due to combination of lexical scoping and 
  # extreme dynamism



#--------------------------------
# 16.4 Implementing performance
#--------------------------------

.subset2()
# Internal Objects in Package base
# from which to extract elements.
# are essentially equivalent to the [ and [[ operators, 
# except that methods dispatch does not take place.
# to avoid expensive unclassing when applying the default method to an object
# should not normally be invoked by end users.

microbenchmark(
  "[32, 11]" = mtcars[32, 11],
  ".subset2" = .subset2(mtcars, 11)[32]
)

#     expr  min   lq    mean median     uq   max
# [32, 11] 7334 7459 8296.50   7584 7729.5 66709
# .subset2   84  126  164.12    167  168.0  1126


#-------------------------------
# 16.4.2 ifelse(), pmin(), pmax()
#-------------------------------

# squish() a function ensures the 
  # smallest value in a vector is at least a
  # the largest value is at most b

squish_ife <- function(x, a, b) {
  ifelse(x <= a, a, ifelse(x >= b, b, x))
}
# slow as ifelse is slow
  # very general needs to evaluate all arg fully

squish_p <- function(x, a, b) {
  pmin(pmax(x, b), a)
}
# still slow because they take any number of elements 
# and need to do complicated checks and determine 
  # which method to use

squish_in_place <- function(x, a, b) {
  x[x <= a] <- a
  x[x >= b] <- b
  x
}

x <- runif(100, -1.5, 1.5)
microbenchmark(
  squish_ife = squish_ife(x, -1, 1), 
  squish_p = squish_p(x, -1, 1),
  squish_in_place = squish_in_place(x, -1, 1),
  unit = "us"
)
# Unit: microseconds
#   expr    min      lq     mean  median
#squish_ife 16.167 17.3545 36.71904 17.9180
#squish_p  9.168 10.5635 21.52105 11.3965
#squish_in_place  1.834  2.3965  2.90901  2.7505

## using subset is 10 times faster than pmin
# and 18 times faster than ifeles

# can even faster using C++


# include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector squish_cpp(NumericVector x, double a, double b) {
  int n = x.length();
  NumericVector out(n);
  
  for (int i = 0; i < n; ++i) {
    double xi = x[i];
    if (xi < a) {
      out[i] = a;
    } else if (xi > b) {
      out[i] = b;
    } else {
      out[i] = xi;
    }
  }
  
  return out;
}












































