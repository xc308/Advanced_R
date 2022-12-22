#^^^^^^^^^^^^^^^^^^^^^^^^
# Chapter 11 Functionals
#^^^^^^^^^^^^^^^^^^^^^^^^

=^.^=
  
# A higher-order function is a function that takes
    # a function as an input or returns a function as output
  
# one type of higher-order function: closer
    # functions returned by another function
  
  # complement to a closer is functional
    # a function that takes a function as an input and 
    # returns a vector as output
  
randomise <- function(f) f(runif(1e3))
# input is a function f
# then call the function with 1000 rd uniform numbers
randomise(mean)
# [1] 0.5029821
randomise(sum)
# [1] 509.8326


## common use of functional is an alternative for loop
  # downside of loop:
    # slow
    # not very expressive

## pros of loop:
# instead of using for loop
  # better to use functionals

# also useful for encapsulating common data manipulation task
  # e.g., split-apply-combine

# reduce bug

# communicate clearly 

# build tools for a wide range of problems

# once have a clear, correct code, then can speed up using Chp17 RCpp



#==============
# 11.1 lapply()
#==============

# apply a function onto each element of a list
  # returns a list

# essense of the lapply()
lapply2 <- function(x, f, ...) {
  x <- vector("list", length(x))
  for(i in seq_along(x)){
    out[[i]] <- f(x[[i]],...)
  }
  out
}

## other functionals are just variations of this theme:
  # they just use different types of input and output

l <- replicate(20, runif(sample(1:10, 1)), simplify = F)
str(l)
# List of 20

# with a for loop
out <- vector("list", length(l))
for(i in seq_along(l)) {
  out[[i]] <- length(l[[i]])
}
unlist(out)


# with lapply
unlist(lapply(l, length)) 
# from list output to a vector to make it more compact

# since dfs are also list
# lapply is useful when want to do something to each col of df


# what class is each col of mtcars
unlist(lapply(mtcars, class))

# divide each col by mean
mtcars[] <- lapply(mtcars, function(x) x / mean(x))
str(mtcars)


## Note that in lapply(x, f, ...) 
  # each picecs of x are always supplied as the 1st arg of f

# example: vary the amount of trim when computing mean(x)
trims <- c(0, 0.1, 0.2, 0.5)
x <- rcauchy(1000)
unlist(lapply(trims, function(trim) mean(x, trim = trim)))
# each piece of x is the first arg of function()



#========================
# 11.1.1 looping patterns
#========================

# 3 ways to loop over a vector:
  #1. loop over the elements: for (x in xs)
  #2. loop over the numeric indices: for (i in seq_along(xs))
  #3. loop over the names: for (nm in names(xs))

# 1. not good: inefficient ways of saving output
  #  as has to copy all of the existing elements of the vector
    # then expand it with new element

# more efficient way is to create a space for the desired output
  # then fill it in. 
# so the 2nd form is the easier way
xs <- runif(1e3)
res <- numeric(length(xs))  # create a double-precision vector
for (i in seq_along(xs)) {
  res[i] <- sqrt(xs[i])
  }


## 3 basic ways for lapply()
# 1. lapply(xs, function(x) {})
# 2. lapply(seq_along(xs), function(i) {})
# 3. lapply(names(xs), function(nm) {})

# normally use the 1st one, 
  # but when what to know the position or name of the element
  # work with the 2nd and 3rd



##============================================
# 11.2 For loop functional: friends of lapply()
##============================================

# sapply() vapply(): 
  # variants of lapply() that produces
  # vectors, matrices, arrays as output, instead of list

# Map() and mapply():
  # iterates over multiple input data structures in parallel

# mclapply() and mcMap() :
  # multi-core
  # so parallel version of lapply() and Map()

# rollapply():
  # write a new function to solve a new problem


#----------------------------------------
# 11.2.1 Vector output:sapply and vapply
#----------------------------------------

# simplify output of lapply to atomic vector

# sapply():
  # good for interactive use as saving typing
  # not good for inside of a function 
    # will get errors if the supply the wrong input 

# vapply():
  # need an arg to specify the output type
  # gives more information on error
  # never silent failure
  # better suited for inside other functions

# when given a data frame, 
  # sapply() and vapply() gives the same result

# when given an empty list
  # sapply() returns an empty list 
    # not the more correct one a zero length logical vector

sapply(mtcars, is.numeric)
# mpg  cyl disp   hp drat   wt qsec   vs 
#TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE 
#am gear carb 
#TRUE TRUE TRUE

length(logical(1)) 
# [1] 1
# If length(FUN.VALUE) == 1 a vector of the same length as X is returned, 
# otherwise an array. 

#vapply(X, FUN, FUN.VALUE)
vapply(mtcars, is.numeric, 1)
vapply(mtcars, is.numeric, logical(1))

length(mtcars) # 11
str(mtcars)
# 'data.frame':	32 obs. of  11 variables:

logical(0) # logical(0)
logical(1) # [1] FALSE
logical(2) # [1] FALSE FALSE
logical(3) # [1] FALSE FALSE FALSE


sapply(list(), is.numeric)
# list()
vapply(list(), is.numeric, logical(1))
# logical(0)


## if a function returns results of different types or lenths
  # sapply() silently return a list
  # vapply() throw an error


# Example: extracting the class of col in a data frame
  # if falsely assume that class only has one value
  # and thus use sapply()
  # won't find out the problem until some future function 
    # is given a list instead of a character vector

df <- data.frame(x = 1:10, y = letters[1:10])
# two variables one is x the other is y

sapply(df, class)
#         x           y 
#   "integer" "character" 
vapply(df, class, character(1))
#         x           y 
#   "integer" "character" 

df2 <- data.frame(x = 1:10, y = Sys.time() + 1:10)

sapply(df2, class)
# $x
#[1] "integer"

#$y
#[1] "POSIXct" "POSIXt"

vapply(df2, class, character(1))
# Error in vapply(df2, class, character(1)) : values must be length 1,
# but FUN(X[[2]]) result is length 2

# > character(1)
#[1] ""
#> character(2)
#[1] "" ""


## sapply():
  # a thin wrapper around lapply() that transform the
    # list output into a vector

## vapply():
  # an implementation of lapply() that assigns results
    # to a vector or a matrix of appropriate type instead of a list


function(x, f, f.value, ...) {
  out <- matrix(rep(f.value, length(x)), nrow = length(x))
  for (i in seq_along(x)) {
  res <- f(x[i], ...)
  stopifnot(
    length(res) == length(f.value),
    typeof(res) == typeof(f.value)
  )
  out[i, ] <- res
  }
  out
}





































