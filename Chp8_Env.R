#********************#
# chp 8 Environments
#********************#

# The environment is the data structure that power scoping
# Environment can also be useful data structure in their own right
  # as they have reference semantics

#===============#
# 8.1 Env Basics
#===============#
# The job of an env is to associate, or bind a set of names 
# to a set of values

# can be thought as a bag of names
# and each name points to an obj stored elsewhere in memory

e <- new.env()
e$a <- FALSE
e$b <- "a"
e$c <- 2.3
e$d <- 1:3

# objs don't live in the env so multiple names can point to the same obj
e$a <- e$d
e$a

# they could also point to different obj has the same value
e$a <- 1:3


# if an obj has no name pointing to it, it's delected


## every env has a parent env (another env)
# in diagram, represented by a small black circle

# The parent is used for lexical scoping. 
# so if a name is not found in an env, it will look in its parent

# only one env doesn't have a parent: empty env


## Generally, an env is similar to a list, 
# with 4 important exceptions:
  # Every obj in an env has a unique name
  # The objs in an env are not ordered
  # An env has a parent
  # Envs have reference semantics

## Technically, an env is made up of two components
  # the frame: contains the name-obj bindings (behave like a name list)
  # the parent env

# 4 special envs:
  # The globalenv(): the interactive workspace, where normally work
    # the parent of the globalenv is the last package that you attached with library() or require()

  # The baseenv(): the env of the base package. 
    # the parent of the baseenv() is the empty env

  # The emptyenv(): is the ultimate ancestor of all envs and the only env without a parent

  # The environment() is the current env. 


# search lists all parents of the global env
search()
# [1] ".GlobalEnv"       
# [2] "package:stats4"   
# [3] "package:pryr"     
# [4] "tools:rstudio"    
# [5] "package:stats"    
# [6] "package:graphics" 
# [7] "package:grDevices"
# [8] "package:utils"    
# [9] "package:datasets" 
# [10] "package:methods"  
# [11] "Autoloads"        
# [12] "package:base"    

# this is called search path, as objs in these env
# can be found from the top-level interactive workspace

# It contains one env for each attached package and other objs attach()ed

# The special env "Autoloads" is used to save memory by only loading package objs wehn needed

# Access any env on the search list using as.envirnment()
as.environment("package:stats")

# Each time you load a new package with library()
# it is inserted right below the globalenv and on top of the package 
# that was previously at the top search path


# To create a new env manually, use new.env()
# can list the binding in the env's frame wiht ls()
# and see its parent with parent.env()


e <- new.env()
# the default parent provided by new.env is the env from which it is called

parent.env(e) # <environment: R_GlobalEnv>

ls(e)


## Modify a binding: the easiest way is to treated it as a list
e$a <- 1
e$b <- 2
e$.a <- 3
ls(e) # show all the names don't begin with . 

# to see all names 
ls(e, all.names = TRUE)

# another useful way is 
ls.str(e)
ls.str(e, all.names = TRUE)
# .a :  num 3
# a :  num 1
# b :  num 2


## Given a name, can extract the value to which it is bound with 
# using $, [[ ]] or get

# $ and [[ ]] look only in one env and return NULL
  # if there's no binding asscociated with the name

# get() uses the regular scoping rules and throws an error if binding not found


## delete objs from env is a bit differnt from lists
  # with a list: jsut setting an entry to NULL
  # in env, will create a new binding to NULL, 
  # use rm() to remove the binding
e <- new.env()

e$a <- 1

# to remove a
e$a <- NULL
ls(e) # [1] "a"     #bindig is still there

# so remove in the env
rm("a", envir = e)
ls.str(e) # no result
ls(e) # character(0)


## Can determine if a binding exists in an env with exists()
  # it's default behavior is to follow the regular scoping rules 
  # and look in parent envirments 
  # can use inherits = FALSE to stop this


x <- 10
exists("x", envir = e)
ls(e) # character(0)
exists('x', envir = e, inherits = FALSE) # [1] FALSE
# so verify there's no x in e


## To compare environments, use identical()
identical(globalenv(), environment())
# [1] TRUE
# so we are currently working in the globalenv








































































































