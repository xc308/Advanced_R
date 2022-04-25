#**********************#
# Chapter 4 Vocabulary 
#**********************#

#===========
# 4.1 Basics
#===========

get()
#get(x, pos = -1, envir = as.environment(pos), mode = "any",
#    inherits = TRUE)
# Search by name for an object (get) or zero or more objects (mget).
# x: 
  # For get, an object name (given as a character string).
  # For mget, a character vector of object names
# pos: 
  # default of -1 indicates the current environment of the call to get

get("%o%")



#------------
## Basic Math
#------------
##
sign # return a vector of signs of the elements of targeting vector 

x <- c(1, -1, 3, -5, -9)
sign(x) # [1]  1 -1  1 -1 -1
 
##
ceiling(4) 
  # [1] 4 ceiling of 4 is the number no less than 4
  # returns the smallest value that's no less than x
  # ceiling of x ~ >= x

## 
floor() 
  # floor of x ~ <= x
  # largest value no greater than x






