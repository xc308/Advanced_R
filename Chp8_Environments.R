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































