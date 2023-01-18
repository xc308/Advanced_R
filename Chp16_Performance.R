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

























