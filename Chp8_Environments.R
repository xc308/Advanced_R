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





