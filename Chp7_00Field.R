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





