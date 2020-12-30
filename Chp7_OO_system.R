#*************************#
# Chapter 7 OO field guid
#*************************#

## R has 3 obj oriented systems plus the base types
## central to any of the obj oriented system are the 
# concept of class and method
 
  ## class: defines the behavior of obj by describing their attributes 
          # and their relationship to other class

          ## also used when selecting methods, functions
          ## that behave differently depending on the class of their input


  ## Classes are usually organized in hierachy:
    # if there's not a method for child, then a parent's method is used
    # the child inherits behavior from the parent



#================#
# 7.1 Base Types 
#================#
# most common base types: atomic vectors, lists,
  # also encompass functions, envirnonments,
  # and other objs,e.g. names, calls, promises

# determine base tpye use typeof（）
f <- function(){}
typeof(f) # [1] "closure"

# S3 obj are built on top of base types
# S4 obj uses a special base type
# RC obj are combination of S4 and environment (another base type)


#=========#
# 7.2 S3 
#=========#

#-----------------------------------------#
# 7.2.1 Recogonising obj, generic funtion,
# and methods
#------------------------------------------#

pryr::otype() # determine obj type
library(pryr)

df <- data.frame(x = 1:10, y = letters[1:10])
otype(df) # [1] "S3"

otype(df$x) # [1] "base"

otype(df$y) # [1] "S3"


## In S3, methods belong to functions, called generic function
# or generic or short

# To determine if a function is an S3 generic, 
# can use UseMethod()

# ftype() describes the obj system asssociated with a function
mean
#function (x, ...) 
#UseMethod("mean")
#<bytecode: 0x7fc414e10a60>
#<environment: namespace:base>


ftype(mean)
# [1] "s3"      "generic"


# Given a class, the job of an S3 jeneric function
# is to call the right S3 method


## recognise S3 method by their names, looks like generic funtion.class()
# .e.g Data method for mean() is called mean.data()
# the factor method for print() is called print.factor()

# but still use ftype() to figure out S3 method or generic function

ftype(t.data.frame)
# [1] "s3"     "method"

ftype(t.test)
# [1] "s3"      "generic"

# all the methods that belong to a generic funtion using methods()
methods("mean")
# [1] mean.Date     mean.default 
# [3] mean.difftime mean.POSIXct 
# [5] mean.POSIXlt 

methods("t.test")
# [1] t.test.default* t.test.formula*


## Apart from the methods defined in the base package
# msot S3 methods will not be visable
# use getS3method() to read the source code

methods(class = "ts")
getS3method(cbind)


## 









































































is.object(x) # [1] FALSE

