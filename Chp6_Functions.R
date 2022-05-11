#**********************#
# Chapter 6 Function 
#**********************#

install.packages("pryr")  # explore what happens when modifying vectors in place.
library(pryr)


#========================#
# 6.1 Function Components 
#========================#

# All function has 3 parts:
  # the body(), the code inside the function
  # the formals(), the list of arguments which controls how you call the function
  # the envirnoment(), the "map" of the locations of the function's variables


f <- function(x) x^2
f
body(f)
formals(f) #  $x
environment(f) # <environment: R_GlobalEnv>


# functions like all objects in R, can also pocesses 
# any number of additional attibutes. 
# One attributes used by base R is "srcref": scource reference
# which points to the source code used to create the funtion
# Can also set class() to a function


#--------------------------#
# 6.1.1 Primitive Functions
#--------------------------#
# there's one exception to the rules that functions have
# 3 components. 
# Primitive functions, like sum(), call C code directly 
# with .Primitive() and contains no R code
# therefore, their formals(), body(), envirnment() are all NULL
sum
# function (..., na.rm = FALSE)  .Primitive("sum")


View(sapply)

# only found in base package
  # they operate at low level, more efficient


#=====================
# 6.2 Lexical scoping
#=====================

#--------------------
# 6.2.1 Name masking
#--------------------

x <- 1
h <- function() {
  y <- 2
  i <- function() {
    z <- 3
    c(x, y, z)
  }
  i()
}
h()
rm(x, h)


#-------------------
# 6.2.3 fresh start
#-------------------

# exist() 
  # T if a varaible of that name has in existence

j <- function() {
  if (!exists("a")) {
    a <- 1
  } else {
    a <- a + 1
  }
  print(a)
}

j() # [1] 1
# but no matter how many times run, it always return same 1

# each time a function called, a new environment is created to host execution
# function does not remember what happened last time

# each invocation is independent.
rm(j)



##-----------------
# Dynamic lookup
##-----------------

# lexical scoping: where to look for values
                  # not when

# R look for values only when the function is run
# so output of a function can be different depending on 
  # objects outside its environment

f <- function() {x}
#rm(x)
x <- 12
f() # [1] 12

x <- 16
f() # [1] 16

## Note: 
  # want to avoid this behavior as this means
  # the function is not self-contained

  # common error: when there's a spelling error in function 
      # don't get an instant error
      # To avoid this, use findGlobals() from codetools
          # lists all the external dependencies of a function

f <- function() {x + 1}
codetools::findGlobals(f)
# [1] "{" "+" "x"

# NOT possible to make a function completely self-contained
  # as always rely on functions defined in base R



#=======================================#
# 6.3 Every operation is a function call
#=======================================#
# every operation in R is a function call
# this includes: infix operators e.g. +
# control flow operators e.g. for, if, while
# subsetting e.g. [ ], $, even { }

# the backtick ' lets you refer to functions or var
# that have otherwise resrved or illegal names
# `name` is the same as get(name, envir = baseenv())

x <- 10; y <-  5
x + y # [1] 15
'+' (x, y) # [1] 15

for (i in 1:2) print(i)
# [1] 1
# [1] 2

'for' (i, 1:2, print(i))
# [1] 1
# [1] 2

if (i == 1) print("y") else print("n")
'if' (i == 1, print('y'), print("n"))

x[3] # NA
'[' (x, 3) # NA


{ print(1); print(2); print(3)}
?{}
'{' (print(1), print(2), print(3))

# it's more often to treat these special base fuction
# as ordinary functions. 

sapply(1:5, '+', 3) # use the value of an obj called +
# [1] 4 5 6 7 8
sapply(1:5, "+", 3) # use the name of a function instead of a function
# [1] 4 5 6 7 8
# possible because the 1st line of sapply is match.fun()
# which match a function with the given names

# a more useful application is to combine the sapply
# or lapply with subsetting
x <- list(1:3, 4:9, 10:12)
sapply(x, "[", 2) # [1]  2  5 11


#=======================#
# 6.4 Function arguments
#=======================#

#------------------------#
# 6.4.1 Calling functions
#------------------------#
# when calling a function, can specify arguments
# by postion, by complete names, by partial names
# arg are matched first by exact names (perfect matching)
# then by prefix matching, and last by postion

f <- function(abcdef, bcde1, bcde2){
  list(a = abcdef, b1 = bcde1, b2 = bcde2)
}


# by postion
f(1, 2, 3)
# $a
# [1] 1

# $b1
# [1] 2

# $b2
# [1] 3


# by perfect match then by postion
f(2, 3, abcdef = 1)
# $a
# [1] 1

# $b1
# [1] 2

# $b2
# [1] 3


# by partial match and then by position
f(2, 3, a = 1)
# $a
# [1] 1

# $b1
# [1] 2

# $b2
# [1] 3

## good calls
mean(1:10) # argument is a vector

## bad calls
mean(x = 1:10)
View(mean)

(mean)



#--------------------------------------------------#
# 6.4.2 Calling a function given a list of argments
#--------------------------------------------------#

# had a list of arguments
arguments <- list(1:10, na.rm = TRUE)

# how to pass a list of arg into mean fuction?
# need do.call
do.call(mean, arguments) # [1] 5.5



#------------------------------------#
# 6.4.3 Defalut and missing arguments
#------------------------------------#

# default
f <- function(a = 1, b = 2){
  c(a, b)
}
f()
# [1] 1 2
str(f)


## the default values can be defined in terms of 
# other arg
g <- function(a = 1, b = a * 2){
  c(a, b)
}
g(10, 20)



#-----------------------#
# 6.4.4 Lazy Evaluation
#-----------------------#

# function arg are lazy - they're only evaluated
# if they are acturally used. 

add_fun <- function(x){
  function(y) x + y
}
adders <- lapply(1:10, add_fun)
adders[[1]](10) # [1] 11 # x = 1, y = 10
adders[[10]](10) # [1] 20 # x = 10, y = 10


## Laziness is useful in if statement
# the 2nd statement will be evaluated only if the 1st is true
# if the 1st is not true, the statement would return an error
# NULL > 0 is a logical vector of length 0 so not a valid input of if 


## if (condition)
# condition: a length-one logical vecotr that is not NA

a <- NULL
if(is.null(a)) stop("a is null")


View(plot.default)


#===================#
# 6.5 Special Calls #
#===================#

# two additional syntaxes for calling special 
# types of functions:
  # infix function
  # replacement function


#----------------------#
# 6.5.1 infix functions
#----------------------#

# most functions are prefix operators:
  # the name of the function goes ahead of the arg

# infix functions can be created
  # the function names come in between the agrs
  # e.g. +, -, 

# if self-create the infix function
  # must start and end with %

# predefined infix functions:
  # %% indicates x mod y (“x modulo y”)
  # %/% indicates integer division
  # %*% matrix product
  # %in% logical match
  # %o% outer product of arrays
  # %x% kronecker products on arrays


# create a new infix function that paste strings together
'%+%' <- function(a, b){
  #if(!is.character(a)) return("a must be a string!")
  #if(!is.character(b)) return("b musth be a string!")
  if(!is.character(a) & !is.character(b)) 
    return("a and b must be string!")
  paste0(a, b)
} 
  
3 %+% 4
"Gav" %+% "in"

'%+%' ('gav', 'in')


'%_%' <- function(a, b){
  if(!is.character(a) & !is.character(b))
    return("a and b must all be strings!")
  
  paste0("(", a, "_", b, ")")
}

3 %_% 5 # [1] "a and b must all be strings!"
"a" %_% "b" # [1] "(a_b)"
"29" %_% "12" %_% "2020" # [1] "((29_12)_2020)"


# a useful infix function that
# when an input is NULL, then use a default vallue
'%||%' <- function(a, b = 0){
  if (!is.null(a)) a else b
}

NULL %||% 0


#----------------------------#
# 6.5.2 Replacement function
#----------------------------#
#replacement function acts like they modify 
# their arguments in place, 
# and have special names **<- 
# they typically have two arguments:
  # x: a vector or array 
  # value
# they must return the modified obj

'replace_second<-' <- function(x, value){
  x[2] <- value
  x
}

x <- 1:10
replace_second(x) <- 5L 
x


'replace_main_diag<-' <- function(x, value){
  x[1, 1] <- value
  x[2, 2] <- value
  x
}
x <- matrix(runif(4), nrow = 2 )
replace_main_diag(x) <- 100L
x
#             [,1]        [,2]
# [1,] 100.0000000   0.7532425
# [2,]   0.7061591 100.0000000


## can use pryr::address() to find the memory address
# of the underlying obj

install.packages("pryr")
library(pryr)

x <- 1:10
address(x) # [1] "0x7fc417bf5460"

replace_second(x) <- 5L
address(x) # "0x7fc41acfad68"

# so the replacement act like modify in place
# but actually they create a modified copy


# But build-in functions that are implemented using
# premitive() will just modify directly in place

x <- 1:10 
address(x) # [1] "0x7fc415051c08"

x[2] <- 6L
address(x)


## supply additional arg
'modify<-' <- function(x, position, value){
  x[position] <- value
  x
}
x <- 1:10
modify(x, 10) <- 100L
x
# [1]   1   2   3   4   5   6   7
# [8]   8   9 100


## useful to combine replacement and subsetting
x <- c(a = 1, b = 2, c = 3)
names(x)
names(x)[2] <- "Two"
names(x) # [1] "a"   "Two" "c" 

# this works is because
'*temp*' <- names(x)
'*temp*'[2] <- 'Two'
names(x) <- '*temp*'

# it creates a local variable named '*temp*'
# and is removed afterwards

# to find a list of replacement function is base package
library(help = "base")


# is.function Is an Object of Type (Primitive) Function?

is.function(names)
# [1] TRUE



#==================# 
# 6.6 Return Values
# =================#

# The last expression evaluated in a function
# is the return value, the result of invoking the function

# funtions can return only a single obj, 
# but can use list to contain any number of objs


#----------#
# On exit 
#----------#
in_dir <- function(dir, code){
  old <- setwd(dir)
  on.exit(setwd(old))
  
  force(code)
}
getwd()
# [1] "/Users/chenxiaoqing/Dropbox/Learn/Advanced_R"

in_dir("~", getwd())
#  [1] "/Users/chenxiaoqing"

setwd("/Users/chenxiaoqing/Dropbox/Learn/Advanced_R")













































































