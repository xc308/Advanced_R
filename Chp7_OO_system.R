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


#-----------------------------------------#
# 7.2.2 Defining classes and creating objs
#-----------------------------------------#


# S3 is a simple and ad hoc system
# it has no formal definition of a class
# To make an obj an instance of a class
# you just take an existing base obj and set the class attributes

# can do this during creation with structure()
# or after with calss<-()

# creat and assign class in one step
foo <- structure(list(), class = "foo")
str(foo)
#  list()
# - attr(*, "class")= chr "foo"

# create 1st, then assign class
foo <- list()
class(foo) <- "foo"
str(foo)
#  list()
# - attr(*, "class")= chr "foo"


## S3 objs are usually built on top of lists, 
# atomic vectors with attributes

# can also turn functions into S3 objs

# can determine the class of any obj using class(x)
# and see if an obj inherites from a specific class
# using inherits(x, "classname")

class(foo) # [1] "foo"
inherits(foo, "foo") # [1] TRUE


# the class of an S3 obj can be a vector, 
# which describes behavior from most to least specific

class(glm)

# class names lower case and avoid . 


## most S3 classes provide a constructor function
function(x) {
  if(!is.numeric(x)) stop("x must be numeric!")
  
  structure(list(x), class = "foo")
}

# S3 has no check for correctness
# so can change the class of existing obj
head(mtcars, 2)

# create a lm model
model1 <- lm(log(mpg) ~ log(disp), data = mtcars)
class(model1) # [1] "lm"

print(model1)
# Call:
#lm(formula = log(mpg) ~ log(disp), data = mtcars)

#Coefficients:
#  (Intercept)    log(disp)  
#5.3967      -0.4658  

# while you can change the class of a sub
# but you never should


hist(mtcars$mpg) # skewed so log to normality
hist(log(mtcars$mpg)) 
hist(mtcars$disp)
hist(log(mtcars$disp), breaks = 25)


#----------------------------------------#
# 7.2.3 Creating new methods and generics
#-----------------------------------------#
# Relationship between generic functions and methods:
  # For S3 obj
  # generic function decides which Method to call
  # and the Method carry out computation


# To create a new generic, need to create a function that calls UseMethod()
# which takes two arg: the name of the generic function
# and another argement to use for method dispatch
# if the 2nd arg is omitted, then will dispatch the 1st to the fun

# no need to pass any arg of generic function to UseMethod()
# 1st add a new generic, create a function that calls UseMethod()
f <- function(x) UseMethod("f")

# a generic isn't useful without some methods. 
# To add a method, just create a regular function
# with the correct (generic.class) name:
f.a <- function(x) "Classs a"


# defining a new class
a <- structure(list(), class = "a")
class(a) # [1] "a"

f(a) # [1] "Classs a"


# adding a method to an existing generic works
mean.a <- function(x) "a"
mean(a) # [1] "a"


#-----------------------#
# 7.2.4 Method Dispatch
#-----------------------#
# S3 method dispatch is simle: 
# UseMethod() creates a vector of function names
# like paste0("generic", ".", "c(class(x), "default"))
# and looks for each in turn. 

# create a generic function
f <- function(x) UseMethod("f")

# add a method (class)
f.a <- function(x) "Class a"

# add a default method
f.default <- function(x) "Unknonwn class"


f(structure(list(), class = "a"))
# [1] "Class a"

f(structure(list(), class = c("b", "a")))
#[1] "Class a"
# no method for class b, so dispatch method for class a

f(structure(list(), class = "c"))
# [1] "Unknonwn class"



#========#
# 7.3 S4 #
#========#

# S4 works in a similar way to S3, but adds formality and rigour
# Methods still belong to function not classes
# but:
  # classes have formal definition which describes their fields and hinheritance structures(parent classes)
  # method dispatch can be based on mulitple arg to a generic function, not just one. 
  # a special operator, @, for extracting slots(fields) from an S4 obj



#---------------------------#
# 7.3.1 Recognising objects, 
# generic functions, methods
#----------------------------#
# identify S4 obj, str() decribes it as a "formal" class
# isS4() returns TRUE
# pryr::otype()


# identigy S4 generics and methods are easy as they are S4 obj with well defined classes

# There aren't any S4 classes in the commonly used base package
# (stats, grpahics, utils, datasets, base)

# we start by creating an S4 classes and methods associated with mle

install.packages("stats4")
library(stats4)

y <- c(26, 17, 13, 12, 20, 5, 9, 8, 5, 4, 8)
nLL <- function(lambda) -sum(dpois(y, lambda, log = TRUE))
fit <- mle(nLL, start = list(lambda = 5), nobs = length(y))

# An S4 obj
isS4(fit) # [1] TRUE
otype(fit) # [1] "S4"

# An S4 generic
isS4(nobs) # [1] TRUE
ftype(nobs) # [1] "s4"      "generic"

# a list of all S4 generics with
getGenerics()

# get a list of all S4 classes
getClasses()

# get a list of all S4 methods
showMethods()



#----------------------------------------#
# 7.3.2 defining classes and creating obj
#-----------------------------------------#

# to define the class using setClass()
# to create a new obj with new()

## An S4 class has 3 key properties:
  # A name: Use UpperCamelCase
  # A named list of slots (fields), which defines slot names and permitted classes
  # A string giving the class it inherits from or contains



# set class Person with slot(fields) "names" and "age"
setClass("Person", slots = list(name = "character", 
                                age = "numeric"))

setClass("Employee", slots = list(boss = "Person"),
         contains = "Person")

alice <- new("Person", name = "Alice", age = 20)
john <- new("Employee", name = "John", age = 32)


# to access slots of S4 obj, use @
alice@age # [1] 20

john@boss
# An object of class "Person"
#Slot "name":
#  character(0)

#Slot "age":
#  numeric(0)


## if a S4 obj contains (inherits from) an S3 obj class
# or a base type, it will have a special .Data slot
# which contains the underlying base type or S3 obj:

setClass("RangedNumeric", contains = "numeric",
         slots = list(min = "numeric", max = "numeric"))

rn <- new("RangedNumeric", 1:10, min = 1, max = 10)

rn@min
rn@max
rn@.Data # has a 1:10 coming from base type


#----------------------------------------#
# 7.3.3 Creating new methods and generics
#----------------------------------------#

























































































































































































is.object(x) # [1] FALSE

