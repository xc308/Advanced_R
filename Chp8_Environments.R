## ********
# Chp8_Enviornments
## *******************
# Environment is the data structure that powers scoping
  # 4 scoping rules


#==================
# 8.1 Env basics
#==================

# job of an env: 
  # to associate, bind, a set of names to a set of values
  # think an env as a bag of names

# Each name points to an obj stored elsewhere in memory;

e <- new.env() # get,set, test, create a new env
e$a <- F
e$b <- "a"
e$c <- 2.4
e$d <- 1:3

# NOte: 
  # 1. these objs don't live in the env 
  # so multiple names can point to the same obj
e$a <- e$d # assign the ojb under name d to the obj under name a too
e$a # [1] 1 2 3

# 2. name can point to different objs that have the same value
e$a <- 1:3
e$a # [1] 1 2 3

# 3. if an obj has no name pointing to it,
  # it gets automatically deleted by the garbage collector


## Every env has a parent, another env
  # in diag, represents the parent pointer with black circle

# the parent is used to implement lexical scoping:
  # if a name is not found in an env, 
    # then R looks in its parent

# only one env doesn't have parent: the empty env


# Grandparent of env: parent's parent
# ancestors: all parents up to empty env

# rare to talk about the children of an env as no back links:
  # given an env, no way to find its children

# Generally, an env is similar to a list, with 4 important exceptions:
  # Every obj has a unique name
  # Obts in an evn are not ordered, no first obj or last
  # An env has a parent
  # envs have reference semantics


# technically, an env is made up of two components:
  # the frame: contains the name-obj bindings (a named list)
  # the parent env

# 4 special envs:
  # globalenv(): the interactive workspace; 
                # where you normally work;
                # the parent of the globalenv() is the last package you attached with library()

  # baseevn(): the env of the base package. 
              # its parent is the empty env

  # emptyenv(): the ultimate ancestor of all envs
              # the only env w/o parents

  # environment(): the current env


# search() lists all parents of the global env. 
  # is called the search path 
    # as objs in these envs can be found 
    # from the top-level interactive workspace
  # it contains one env for each attached package 
    # and any other objs that you've attach()ed.
  # it also contains a special env called Autoloads which 
    # is used to save memory by only loading package objs when needed

# can access any env on the search list using as.environment()
search()

as.environment("package:stats4")

# Everytime load a new package with library()
  # it's inserted between the global env and the package that was previously loaded


## to create an evn mannually, use new.env()
  # can list the bindings in the env's frame with ls()
  # see its parent with parent.env()

e <- new.env()
parent.env(e)
# <environment: R_GlobalEnv>
# the default parent for new.env() is the env from which it is called
ls(e)
# character(0)

## the easiest way to modify the bindings in an env is to 
  #  treat it like a list
e$a <- 1
e$b <- 2
ls(e)
# [1] "a" "b"
# by default, ls() only shows name don't begin with .
# use all.names = TRUE show all bindings in the env

e$a # [1] 1

e$.a <- 4 
ls(e)
# [1] "a" "b"
ls(e, all.names = T)
# [1] ".a" "a"  "b" 

## Another useful way to view an env is ls.str()
  # more useful than str()
    # since it shows each obj in the env

str(e) # <environment: 0x7fd9e7a39628>
ls.str(e)
# a :  num 1
# b :  num 2
ls.str(e, all.names = T)
# .a :  num 4
# a :  num 1
# b :  num 2


## Given a name, can extract the value to which it's bound with 
  # $, [[]], get()
  # $, [[]] only look in one env and return NULL if there's no binding with the name
  # get() uses regular scoping rules, throws an error if the binding not find

e$c <- 3
e$c 
# [1] 3
e[["c"]] 
# [1] 3
get("c", envir = e) 
# [1] 3


## Deleting objs from environments a bit different from list
  #  list: set it to NULL
  # environment: such action will create a new binding to NULL;
      # use rm() to remove the binding
e <- new.env()
e$a <- 1
e$a <- NULL
ls(e)
# [1] "a"
ls.str(e)
# a :  NULL

rm("a", envir = e)
ls(e)
# character(0)
ls.str(e)
# nothing returned!!


## Determine if a binding exists in an env with exists()
  # it follows regular scoping rules and look in parent env
  # if don't want it look up, then inherits = F

x <- 10
exists("x", envir = e)
# by look up e's parent env which is global env 
# [1] TRUE

exists("x", envir = e, inherits = F)
# [1] FALSE
# doesn't exist x string in the env e
ls.str(e)
# still nothing 



## To compare envs, must use identical(), not ==

identical(globalenv(), environment())
# [1] TRUE

globalenv() == environment()

# Error in globalenv() == environment() : 
# comparison (1) is possible only for atomic and list types


#================================
# 8.2 Recursing over environments
#================================

# environments form a tree, 
  # so it's convenient to write a recursive function

# this section to understand the helpful pryr::where()
# Given a name, where() finds the env where that name is defined
  # using R's regular scoping rules

library(pryr)
x <- 5
where("x")
# <environment: R_GlobalEnv>

where("mean")
# <environment: base>

# def of where() has two args:
  # name: a string to look for
  # an env: in which to start the search
    # parent.frame() is a good deafult start

where <- function(name, env = parent.frame()) {
  if (identical(env, emptyenv())) {
    # base case
    # no binding, can not go any further up
    stop("Can't find", name, call. = T)
  } else if (exists(name, envir = env, inherits = F)) {
    # success case
    env
  } else {
    # recursive case, 
    # name is not find in this env, try the parent
    where(name, env = parent.frame(env))
  }
}


#==================
# 8.3 Function env
#==================

# most env are not created by you with new.env()
# but are created as a consequence of using functions

# 4 types of envs associated with a function: 
  # enclosing: where a function is created
  # binding: mean <- function(x)
  # calling : create an short-lived execution env
  # execution : stores variables created during execution
  

## The enclosing environment is the env
  # where function was created
  
  # every function has one and only one enclosing env

# For the other three types, 
  # there may be 0, 1, or many envs associated with each function

## binding a function to a name with <- defines a binding env

## Calling a function creates an ephemeral(short-lived) 
   # execution env
   # that stores variables created during execution 



#------------------------
# 8.3.1 The enclosing env
#------------------------

# when a function is created, it gets a ref to the env where it was made
  # this ref is the enclosing env
  # is used for lexical scoping

# can determine an enclosing env of a funtion by environment()
   # with the name of the function as its 1st arg

environment(fun = mean)
# <environment: namespace:base>

y <- 1
f <- function(x) x + y
environment(f)
# <environment: R_GlobalEnv>


# diagram:
  # round rectangle: function
  # small black circle: enclosing envirnment
    # with an arrow pointing to its parent env, i.e.,R_GlobalEnv


#------------------
# 8.3.2 Binding env
#------------------

# the name of a function is defined by a binding
# the binding envs are all envs that have a binding to the function

# the above example: 
  # the enclosing env is where the function(x) x+y is created
    # which is the working interface: globalevn
  # the binding env is where the function(x) is assiged to a name f
    # which is also in the working interface: globalevn

  # so the binding env is identical to enclosing env


# can assign the function to a name in another env
e <- new.env()
e$g <- function() 1

# enclosing env: where the function() 1 is created 
  # globalenv
# binding env: where the function() 1 's name is 
  # in new env: e

# enclosing env is where the function finds its values
# binding env is where we can find the function


## The difference between enclosing and binding env is important
  # for pacakge namespaces

# Package namespaces keep packages independent.
  # Package A uses base mean() function 
  # package B creates its own mean() function
# namespaces ensure the package A continues to use the base mean
# and it's not affected by package B


# namespaces are implemented using environments
  # taking advantage of the fact that functions don't 
    # need to live in their enclosing env

# the base function sd(). 
# its binding and enclosing environments are different

# calling environment() to find enclosing env
environment(sd)
# <environment: namespace:stats> # defined in a package namespace

# calling where() to find where the function name is defined
where("sd")
# <environment: package:stats>
#attr(,"name")
#[1] "package:stats"
#attr(,"path")
#[1] "/Library/Frameworks/R.framework/Versions/4.2/Resources/library/stats"

## Notice the name of the function is in a different place
   # than the place where the function is created. 


## the definition of the sd() uses var()
  # but if we use our own version of var(), 
    # it doesn't affect sd(), because sd only uses the var() in base package
  # our version of var() in the global env, indepent of base

x <- 1:10
sd(x) # [1] 3.02765

var <- function(x, na.rm = T) 100 
sd(x)
# [1] 3.02765
rm(var)
sd(x)
# [1] 3.02765


## This works because every package has two envs associated with it
  # the package env:
      # contains all publicly accessible function
      # is placed on the search path
  # the namespace env:
      # contains all functions including internal functions
      # its parent env is a special imports env that 
        # contains bindings to all the functions that 
          # the package needs

    # every exported function in a package is 
      # bound into the package env

      #where("sd")
      #<environment: package:stats>
    
    # but is enclosed in the namespace env:

      # environment(sd)
      # <environment: namespace:stats>









































































