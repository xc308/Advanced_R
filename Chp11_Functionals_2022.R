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























