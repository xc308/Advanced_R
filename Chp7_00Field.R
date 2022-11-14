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


#======================
# 7.2.4 Method dispatch
#======================

# S3 method dispatch is simple
  # UseMethod() creates a vector of function names, e.g., 
    # paste0("generic", ".", c(class(x), "default")

f <- function(x) UseMethod("f")
f.a <- function() "Class a"
f.default <- function() "Unknown class"
f(structure(list(), class = "a"))
f(structure(list(), class = c("b", "a")))


#----
# call an S3 generic with a non-S3 obj
#----
# non-internal s3 GENERICS will dispatch on the implicit class
# of base types

# the rules determine the implicit class of a base type are shown below
iclass <- function(x) {
  if(is.object(x)) {
    stop("x in not a primitive type", call. = FALSE)
  }
  
  c(
    if(is.matrix(x)) "matrix",
    if(is.array(x) && !is.matrix(x)) "array",
    if(is.double(x)) "double",
    if(is.integer(x)) "integer",
    mode(x)
  )
} 

iclass(matrix(1:5))
# [1] "matrix"  "integer" "numeric"

iclass(array(1.5))
# [1] "array"   "double"  "numeric"



#==========
# 7.3 S4
#==========

# formal and rigour
# Methods belong to functions, not classes
  # classes have formal definitions which describe their fields and parent classes
  # method dispatch can be based on mulitple arguments to a generic
  # a special operator @ to extract slots aka fields from S4 objects

# all S4 related code is stored in methods package
# this package is always available when running R iteratively
  # good to include library(methods) when using S4



#------------------------------------------------------
# 7.3.1 Recognising objects, generic functions, methods
#------------------------------------------------------

## Recognise
  # str() : "formal class"
  # isS4(): true
  # pryr::otype(): "S4"

# aren't any S4 classes in the base packages 
  #(stats, graphics, utils, datasets, base)

# create an S4 obj first from the built-in stats4 package
  # provides S4 classes and methods associated with mle

library(stats4)

y <- c(26, 17, 13, 12, 20, 5, 9, 8, 5, 4, 8)
nLL <- function(lambda) {
  -sum(dpois(y, lambda = lambda, log = TRUE))
}
fit <- mle(nLL, start = list(lambda = 5), nobs = length(y))

isS4(fit) # [1] TRUE

#otype(fit)

isS4(nobs) # [1] TRUE


# retrieve an S4 method and describe later
mle_nobs <- method_from_call(nobs(fit))


## Use is() with one arg to list all classes that 
  # an obj inherits from
is(fit) # [1] "mle"

# Use is() with two arg to test if an obj inherits from a specific class
is(fit, "mle")
# [1] TRUE


# can get a list of all S4 generics with getGenerics()
  # list all S4 classes with getClasses(). 
  # list all S4 methods with showMethods()



#========================================
# 7.3.2 Defining classes and creating obj
#========================================
# define the representation of a class with setClass()
# create a new obj with new()
# class - obj

# An S3 obj has three key properties:
  # A name: convention use UpperCamelCase ThisIsAnExample
  # A named list of slots (fields)
      # defines slot names and permited classes
      # a person class is represented by a char name and a
        # a numeric age
        # list(name  = "character", age = "numeric")

  # a string giving the class it inherits from, or it contains
  # 

# S4 class has other optional properties like 
  # a validity method
  # that tests if an obj is valid
  # a prototype obj
    # that defines default slot values

# ?setClass for more detail

# Example:
# creating a Person class with fields name and age
# Employee class ther inherits from Person
# add an additional slot, boss
# To create objs, call new() with the name of class and
  # name-value pair of slot values


setClass('Person',
         slots = list(name = "character", age = "numeric"))

setClass('Employee',
         slots = list(boss = 'Person'),
         contains = 'Person')

alison <- new('Person', name = 'Alison', age = 35)
mark <- new('Employee', name = 'Mark', age = 42, boss = alison)


# To access slots of an S4 obj, use @ or slot
alison@age
slot(mark, "boss")
mark@boss

# if the S4 obj contains (inherits from) an S3 class or a base type
  # it wil have special .Data slot which contains the underlying base type
setClass("RangedNumeric",
         contains = 'numeric',
         slots = list(min = 'numeric', max = 'numeric'))
rn <- new('RangedNumeric', 1:10, min = 1, max = 10) # new(class, obj content...)

rn@min # [1] 1
rn@max # [1] 10
rn@.Data # [1]  1  2  3  4  5  6  7  8  9 10
  # contains underlying base type or S3 obj

# Note:
  # if modified the class, must recreate any objects of that class.


#=========
# 7.3.3 Creating new methods and generics
#=========

# S4 provides special functions for creating new generics
  # and methods
# setGeneric() creats new generic or converts an existing function into generic
# setMethod() takes 
  # the name of generic, 
  # the classes the method should be associated with
  # a function that implements the method

# Example:
  # - take union() function as new generic, which usually only works for vector
  # - now want it associated with data frame class
  # - define a function that implements the union method
setGeneric("union")
# create a genric verision of the named function s.t. methods maybe defined later
setMethod("union",
          c(x = "data.frame", y = "date.frame"),
          function(x, y) {
            unique(rbind(x, y))
          }
        )
# create a method for generic function


# if you create a new generic from scratch, you need to supply
# a function that calls standardGeneric():
setGeneric("myGeneric", function(x) {
  standardGeneric("myGeneric")
})
# Note: standardGeneric is equivalent to UseMethod()


#======================
# 7.3.4 Method dispatch
#======================

# if an S4 generic dispatches on a single class with a single parent
  # S4 method dispatch is the same as S3 dispatch

  # main difference: how the defalut values are set up
  # S4 uses special class ANY to match any class 
    # and "missing" to match a missing arg
  
# S4 like S3 also has group generics
  # ?S4groupGeneric

# a way to call the "parent method"
  # callNextMethod()



# Dispatch multiple classes and/or multiple inheritence,
  # as it will be difficult to know which method has be dispatch to which class


##=======
# RC
##=======

# RC obj behave more like objs do in Python, C++
# Reference classes are a special S4 class that wraps around an environment

#---------
# Defining Classes and creating obj
#---------
# setRefClass()
# only required arg is an alphanumeric name
# can use new() to create a new RC obj
  # but good to use the obj returned by setRefClass()

Account <- setRefClass("Account")
Account$new()
# Reference class object of class "Account"

#  setRefClass() also accepts 
  # a list of name-class pairs that defined  FIELDS (= S4 slots)
  # Additional named arg passed to new() will set initial values of the fields

  # can get and set field values with $

Account <- setRefClass("Account",
            fields = list(balance = "numeric")) # name-class pair to define class fields

a <- Account$new(balance = 100)
a
# Reference class object of class "Account"
#Field "balance":
#  [1] 100
a$balance
a$balance <- 200
a$balance # [1] 200

# instead of supplying a class name for the field
  # can provide a single argument function act as an accessor method
  # allows you to add custom behavior when getting or setting a field
# see ?setRefClass


## An obj is not very useful w/o some behavior defined by methods
# RC methods are associated with a class 
  # and can modify its fields in place

# In below expample 
  # access the value of fields with their name,
  # modify them with <<-

setRefClass("Account",
            fields = list(balance = "numeric"),
            methods = list(
              withdraw = function(x) {
                balance <<- balance - x  # access field's value with their name
                                        # modify them with <<-
              },
              
              deposit = function(x) {
                balance <<- balance + x
              }
            )
          )


# can call an RC method in the same way as access a field
a <- Account$new(balance = 100)
a
# Reference class object of class "Account"
# Field "balance":
#  [1] 100

a_0 <- Account$new(balance = 100)
a_0$deposit(150)
a_0$balance
a_0$withdraw(150)
a_0$balance
a_0$withdraw(50)
a_0$balance


# the final important arg to setRefClass() is contains
  # this is the name of the parent RC class to inherit behavior from   

# following example creates a new type of bank account,
  # returns an error if balance go below zero

NoOverDraft <- setRefClass("NoOverDraft",
                           contains = "Account",
                           methods = list(
                             withdraw = function(x) {
                               if(balance < x) stop ("No enough money!")
                               balance <<- balance - x
                             }
                           )
                        )


accountJon <- NoOverDraft$new(balance = 100)
accountJon$balance # [1] 100
accountJon$deposit(50)  # method inherit from class "Account"
accountJon$balance # [1] 150  # fields inherit from class "Account"
accountJon$withdraw(2000)
# Error in accountJon$withdraw(2000) : No enough money!


## Note:
  # all reference classes eventually inheirt from envRefClass. 
  # it provides useful methods 
    # e.g., copy(), callsuper() to call parent field
        # field() to get the value of a field given its name
        # export() equivalent to as()
        # show() overriden to control printing



#==================================
# 7.4.2 Recognising objs and methods
#==================================

# Can recognise RC objs because they are S4 obj (isS4(x))
  # that inherit from "refClass" (is(x, "refClass"))
    # pryr::otype() will return "RC"



#==================================
# 7.4.3 Method dispatch
#==================================

# simple in RC as methods are associated with classes, not functions
# when call x$f, R will look for a method in class x, then in its parent, then its great parent
# from within a method, can call the parent method directly with callSuper()

























