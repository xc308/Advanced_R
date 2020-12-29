#**********************#
# Chapter 6 Function 
#**********************#

#========================#
# 6.1 Function Components 
#========================#

# All function has 3 parts:
  # the body(), the code inside the function
  # the formals(), the list of arguments which controls how you call the function
  # the envirnoment(), the "map"of the locations of the function's variables


f <- function(x) x^2
f
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


























