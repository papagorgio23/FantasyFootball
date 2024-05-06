---
title: "Lineup Optimizer"
author: "Jason Lee"
date: "6/2/2018"
output: html_document
---



## Daily Fantasy Football


If you are like me and love fantasy football but aren't always positive which lineup is the opitmal lineup to use in a given week - Then this optimizer is for you!

## Updated Python Version included with Notebook [here](https://github.com/papagorgio23/Python101/blob/master/DFS_Football_Lineup_Optimizer.ipynb)

A better version will be included in my upcoming Applied Sports Analytics book. Chapter 8 - Lineup Optimization Using Linear Programming


(add versions to R packages)

*** 
#### Math
***

We are going to solve:
maximize f'x subject to A*x with constraints equal to b where:

* **x:** is the variable to solve for: a vector of 0 or 1:
    + 1 when the player is selected, 0 otherwise
* **f:** is your objective vector
* **A:** is a matrix
* **dir:** a vector of "<=", "==", or ">="
* **b:** a vector defining your linear constraints.

***


```r
# load library
library(Rglpk)
```

## Load Data

We need to get the weekly fantasy football prices and projected scores. 

Here we have data from Yahoo's Daily fantasy tournments.


```r
QB <- read.csv("Data/QBs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
RB <- read.csv("Data/RBs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
WR <- read.csv("Data/WRs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
TE <- read.csv("Data/TEs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
DEF <- read.csv("Data/DEFS-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
```



## Append and Combine Data

We need to tag each of the players with their position.

We also need to combine all the players into a single dataset.


```r
QB$pos <- rep("QB")
RB$pos <- rep("RB")
WR$pos <- rep("WR")
TE$pos <- rep("TE")
DEF$pos <- rep("DEF")

ALL <- rbind(QB, RB, WR, TE, DEF) # combind into one data.frame
```

#### View the data

To give you an idea of what data set you would need to input when you are customizing and updating the equation for your current week.  

Here's what my dataset looks like to start


```r
head(ALL)
```

```
##                 name cost projPts pos
## 1      Aaron Rodgers   42 20.5550  QB
## 2        Andrew Luck   42 23.9883  QB
## 3        Andy Dalton   31 17.9616  QB
## 4 Ben Roethlisberger   43 19.5577  QB
## 5      Blake Bortles   23 16.5012  QB
## 6         Cam Newton   34 19.7308  QB
```


As you can see it is very simple. We only need 4 key elements to run the algorithm:

* **Player Name** - this could be a player name or playerID
* **Position** - Needs to be either QB, RB, WR, TE, or DEF
* **Cost** - how much the player costs for the given week
* **Projected Points** - you can choose whatever site or projections you want  
    + I will have another project posted showing you how to create your own projections


## Set contraints


```r
# count of all the players
num.players <- length(ALL)

# objective:
f <- ALL$projPts

# the variables are all booleans
var.types <- rep("B", num.players)

# the constraints
A <- rbind(as.numeric(ALL$pos == "QB"), # num QB
           as.numeric(ALL$pos == "RB"), # num RB
           as.numeric(ALL$pos == "WR"), # num WR
           as.numeric(ALL$pos == "TE"), # num TE
           as.numeric(ALL$pos == "DEF"), # num DEF
           ALL$cost)                    # total cost

dir <- c("==",
         "==",
         "==",
         "==",
         "==",
         "<=") # this is for the total team salary, which is why it is less than or equal
```


## Customize Constraints

Here is the part that needs to be adjusted depending on how you want your lineup to be and what the total salary limit is for the team.

* **QB:** It's normal to have only one QB but hey if there's a daily league with more you can change this.
* **RB:** There is usually 2 required plus a possible flex position.  
    + If you want that flex position to be a RB then this needs to be at 3.  
    + If not then set it to 2.
* **WR:** There is usually 3 required plus a possible flex position.  
    + If you want that flex position to be a RB then this needs to be at 4.  
    + If not then set it to 3.
* **TE:** There is usually 1 required plus a possible flex position.  
    + If you want that flex position to be a RB then this needs to be at 2.  
    + If not then set it to 1.
* **DEF:** There is usually one 1 defense required.
* **Salary:** The salary limit could be very different depending on the league.
    + Yahoo is $200
    + Draft Kings is $60,000
    + Fan Duel is $50,000
    
*** 

## 3 Examples

I will run the algorithm 3 different ways.

    1. The flex position be an extra RB

    2. The flex position be an extra WR

    3. The flex position be an extra TE

***

## 3 Running Back Lineup


```r
b <- c(1, # QB
       3, # RB
       3, # WR
       1, # TE
       1, # DEF
       200) # cost
```

#### Results

The first thing to check is that the status = 0.  If it does not then it did not find an optimal solution.


```r
# Solve the math problem
sol.3rb <- Rglpk_solve_LP(obj = f, mat = A, dir = dir, rhs = b,
                      types = var.types, max = TRUE)

# Check that Status = 0 and that there is an optimum value
sol.3rb
```

```
## $optimum
## [1] 130.6174
## 
## $solution
##   [1] 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0
##  [36] 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
##  [71] 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0
## [106] 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0
## [141] 0 0 0 0 0 0 0 0 0 0 0
## 
## $status
## [1] 0
## 
## $solution_dual
## [1] NA
## 
## $auxiliary
## $auxiliary$primal
## [1]   1   3   3   1   1 200
## 
## $auxiliary$dual
## [1] NA
```

```r
# View the selected players
ALL$name[sol.3rb$solution == 1]
```

```
## [1] "Andrew Luck"       "Ameer Abdullah"    "Carlos Hyde"      
## [4] "Doug Martin"       "Brandin Cooks"     "Larry Fitzgerald" 
## [7] "Terrance Williams" "Tyler Eifert"      "Rams"
```

##### These guys are your best possible lineup with 3 Running Backs

***

## 4 Wide Receivers Lineup


```r
b1 <- c(1, # QB
       2,  # RB
       4,  # WR
       1,  # TE
       1,  # DEF
       200) # cost
```


#### Results


```r
# Solve the math problem
sol.4wr <- Rglpk_solve_LP(obj = f, mat = A, dir = dir, rhs = b1,
                      types = var.types, max = TRUE)

# Check that Status = 0 and that there is an optimum value
sol.4wr
```

```
## $optimum
## [1] 130.1095
## 
## $solution
##   [1] 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
##  [36] 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
##  [71] 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0
## [106] 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0
## [141] 0 0 0 0 0 0 0 0 0 0 0
## 
## $status
## [1] 0
## 
## $solution_dual
## [1] NA
## 
## $auxiliary
## $auxiliary$primal
## [1]   1   2   4   1   1 200
## 
## $auxiliary$dual
## [1] NA
```

```r
# View the selected players
ALL$name[sol.4wr$solution == 1]
```

```
## [1] "Andrew Luck"       "Chris Johnson"     "DeMarco Murray"   
## [4] "Brandin Cooks"     "Larry Fitzgerald"  "Mike Wallace"     
## [7] "Terrance Williams" "Tyler Eifert"      "Rams"
```


##### These guys are your best possible lineup with 4 Wide Receivers.

***


## 2 Tight Ends Lineup


```r
b2 <- c(1, # QB
       2,  # RB
       3,  # WR
       2,  # TE
       1,  # DEF
       200) # cost
```

#### Results


```r
# Solve the math problem
sol.2te <- Rglpk_solve_LP(obj = f, mat = A, dir = dir, rhs = b2,
                      types = var.types, max = TRUE)

# Check that Status = 0 and that there is an optimum value
sol.2te
```

```
## $optimum
## [1] 130.3089
## 
## $solution
##   [1] 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
##  [36] 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
##  [71] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0
## [106] 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 1 0
## [141] 0 0 0 0 0 0 0 0 0 0 0
## 
## $status
## [1] 0
## 
## $solution_dual
## [1] NA
## 
## $auxiliary
## $auxiliary$primal
## [1]   1   2   3   2   1 200
## 
## $auxiliary$dual
## [1] NA
```

```r
# View the selected players
ALL$name[sol.2te$solution == 1]
```

```
## [1] "Andrew Luck"       "DeMarco Murray"    "Doug Martin"      
## [4] "Larry Fitzgerald"  "Mike Wallace"      "Terrance Williams"
## [7] "Jordan Cameron"    "Tyler Eifert"      "Rams"
```

##### These guys are your best possible lineup with 2 Tight Ends.

***

## Best Lineups


```r
# 3 RB lineup
sol.3rb$optimum
```

```
## [1] 130.6174
```

```r
ALL$name[sol.3rb$solution == 1]
```

```
## [1] "Andrew Luck"       "Ameer Abdullah"    "Carlos Hyde"      
## [4] "Doug Martin"       "Brandin Cooks"     "Larry Fitzgerald" 
## [7] "Terrance Williams" "Tyler Eifert"      "Rams"
```

```r
# 4 WR lineup
sol.4wr$optimum
```

```
## [1] 130.1095
```

```r
ALL$name[sol.4wr$solution == 1]
```

```
## [1] "Andrew Luck"       "Chris Johnson"     "DeMarco Murray"   
## [4] "Brandin Cooks"     "Larry Fitzgerald"  "Mike Wallace"     
## [7] "Terrance Williams" "Tyler Eifert"      "Rams"
```

```r
# 2 TE lineup
sol.2te$optimum
```

```
## [1] 130.3089
```

```r
ALL$name[sol.2te$solution == 1]
```

```
## [1] "Andrew Luck"       "DeMarco Murray"    "Doug Martin"      
## [4] "Larry Fitzgerald"  "Mike Wallace"      "Terrance Williams"
## [7] "Jordan Cameron"    "Tyler Eifert"      "Rams"
```



***

Obviously these lineups are from a few years ago but you can change the inputs and try to compete against me next season!

***

## Good Luck

***
