#====================
# Chp 7 oo field guide
#====================

install.packages("pryr")
library(pryr)

# R has 3 object-oriented systems + base types
# center to any object-oriented system are the 
  # concepts of "class" and "method"

# A "class" defines the behavior of objects by 
  # describing their attributes and their relationship
  # to other classes.

# The class is also used when selecting methods, functions
  # that behave differently depending on the class of 
  # their input;

# Classes are organized in a hierarchy:
  # for a child, if a method does not exist
  # then parents method is used instead;
  # the child also inherits parents' behavior.


# Three OO systems differ in how "classes" and "methods" 
  # are defined:

  # S3: 
    # implements generic-function OO
    # different from other language, i.e. JAVA, C++
      # which implement message-passing OO:
      # which sends messages (methods) to objects
      # and the objects decide which function to call. 

    # S3 is different, 
      # generic function decides which method to call
      # then computations are carried out via methods. 

    # S3 has no formal definition of class, very casual. 
    # e.g. canvas.drawRect("blue")    


  # S4:
    # more formal.
    # has a formal class defining representations and inheritance for each class
    # has special helper functions to define generics and methods
    # has multiple dispatch, so generic functions can
      # pick methods based on the class of any number of args, not just 1.
    # e.g. drawRect(canvas, "blue")


  # Reference classes (RC):
    # different from S3 and S4
    # implements message-passing OO, so methods belong to class
    # NOT functions. 
    # e.g. canvas$drawRect("blue"), $ seperates obj and methods
    


#=============
# Base types
#=============
# Every R object is a C structure that describes
  # how that object is stored in memory. 
  # The structure includes: 
     # contents of the obj
     # info needed for memory management
     # a type


# Base types:
  # only R core team can create new types
  # most common base types:
    # atomic vectors
    # lists
  # also encompass functions, environments, names, calls, promises
# typeof()

f <- function() {}
typeof(f)  
# [1] "closure"
is.function(f) # [1] TRUE

# S3 can build on top of any base type
# S4 use a special base type. 


#====
# S3 
#====

# most obj encountered are S3 obj

install.packages("pryr")
library(pryr)

df <- data.frame(x = 1:10, y = letters[1:10])
otype(df)
# [1] "S3" so data frame is an S3 obj

otype(df$x)
# [1] "base" so atomic vector is a base type; so is list

otype(df$y)
#[1] "base"


# In S3, methods belong to generic functions. 
# S3 methods don't belong to objects or functions

# To determine if a function is an S3 generic function, 
  # UseMethod() to inspect its source code
  # that's the function figure out the correct method to call
  # the process of method dispatch


# Functions do method dispatch in C are called internal generics

# S3 generic functions is to call the right S3 method
# Recognise S3 method by their names:
  # the mean() generic function has Date() method
    # so mean.Date()
  # the print() generic function has factor() method
    # so print.factor()



# Visualise all the methods belong to gerneric funcions 
  # with methods()
methods("mean")
# [1] mean.Date     mean.default  mean.difftime
# [4] mean.POSIXct  mean.POSIXlt

methods("t.test")
#[1] t.test.default* t.test.formula*

# most S3 methods wion't be visable
  # use getS3method() to read their source code


# can see all the generics functions have a method for a given class
methods(class = "ts")
#  [1] [             [<-           aggregate    
#[4] as.data.frame cbind         coerce       
#[7] cycle         diff          diffinv      
#[10] initialize    kernapply     lines        
#[13] Math          Math2         monthplot    
#[16] na.omit       Ops           plot         
#[19] print         show          slotsFromS3  
#[22] t             time          window       
#[25] window<-



#======================================
# Defining classes and creating objects
#======================================

# S3 has no formal def of a class, ad hoc system
# To make an obj an instance of a class, 
   # just need to take an existing base obj
    # and set the class attribute
# use structure(), or with class<-()

# create and assign class in one step
foo <- structure(list(), class = "foo")

# alternatively
  # 1st create a list
foo <- list()
  # set the class 
class(foo) <- "foo"

# S3 objs are usually build on top of lists, atomic vectors
  # with attributes

# can also turn functions into S3 objs.

class(foo) # [1] "foo"

# to see if an obj inherits from a specfic class 
inherits(x, "classname")
inherits(foo, "foo")
# [1] TRUE


# The class of an S3 obj can be a vector, 
  # which describes behavior from most specific to least specific

# the calss of the glm() obj is c("glm", "lm")
# indicating the glm inherits behavior from lm


# class names are usually lower case, and avoid "."

# most S3 classes provide a consturtor function:
foo <- function(x) {
  if(!is.numeric(x)) stop("X must be numeric")
  structure(list(x), class = "foo")
}
# constructor functions usually have the same name as the class.


# Can change the class of existing obj
install.packages("ggplot2")
library(ggplot2)

mod <- lm(log(mpg) ~ log(disp), data = mtcars) 
class(mod)
# [1] "lm"

print(mod)

# change the class of mod
class(mod) <- "data.frame"
print(mod) # not good
# but the data is still there
mod$coefficients
# (Intercept)   log(disp) 
#-0.1144486  -0.4585683 

mod$residuals


# Note:
# While you can change the type of an obj, you never should
# 


#==================================
# Creating new methods and generics
#==================================

# To add a new generic, create a function that calls UseMethod()
# UseMethod() takes two arguments:
  # the name of the generic function
  # the arg to use for method dispatch
  # if the 2nd is omitted, it will dispatch on the 1st arg to the function

f <- function(x) UseMethod("f")

# but a generic function isn't useful w/o some methods
# To add a method, just create a regular function with 
  # the right name generic.name
f.a <- function(x) "Class a"
# generic.name <- a regular function


# create a list and assign class in one go
a <- structure(list(), class = "a")
class(a) # "a"
f(a)
# [1] "Class a"


# Adding a method o an existing generic works 
mean.a <- function(x) "a"
mean(a)
#[1] "a"



















