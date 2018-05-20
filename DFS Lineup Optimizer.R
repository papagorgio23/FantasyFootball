###########  DAILY FANTASY FOOTBALL  #########

# We are going to solve:
# maximize f'x subject to A*x <dir> b
# where:
#   x is the variable to solve for: a vector of 0 or 1:
#     1 when the player is selected, 0 otherwise,
#   f is your objective vector,
#   A is a matrix, b a vector, and <dir> a vector of "<=", "==", or ">=",
#   defining your linear constraints.



## 3 RB

library(Rglpk)

QB <- read.csv("Data/QBs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
RB <- read.csv("Data/RBs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
WR <- read.csv("Data/WRs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
TE <- read.csv("Data/TEs-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)
DEF <- read.csv("Data/DEFS-Table 1.csv",header=TRUE,stringsAsFactors=FALSE)

QB$pos <- rep("QB")
RB$pos <- rep("RB")
WR$pos <- rep("WR")
TE$pos <- rep("TE")
DEF$pos <- rep("DEF")

ALL <- rbind(QB, RB, WR, TE, DEF) # combind into one data.frame



# number of variables
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
         "<=")

b <- c(1, # QB
       3, # RB
       3, # WR
       1, # TE
       1, # DEF
       200) # cost


sol.3rb <- Rglpk_solve_LP(obj = f, mat = A, dir = dir, rhs = b,
                      types = var.types, max = TRUE)
sol.3rb

ALL$name[sol.3rb$solution == 1]

### 4 WR


b1 <- c(1, # QB
       2,  # RB
       4,  # WR
       1,  # TE
       1,  # DEF
       200) # cost


sol.4wr <- Rglpk_solve_LP(obj = f, mat = A, dir = dir, rhs = b1,
                      types = var.types, max = TRUE)
sol.4wr

ALL$name[sol.4wr$solution == 1]


### 2 TE


b2 <- c(1, # QB
       2,  # RB
       3,  # WR
       2,  # TE
       1,  # DEF
       200) # cost

?Rglpk_solve_LP
sol.2te <- Rglpk_solve_LP(obj = f, mat = A, dir = dir, rhs = b2,
                      types = var.types, max = TRUE)
sol.2te

ALL$name[sol.2te$solution == 1]



####  BEST LINEUPS  ####

# 3 RB
sol.3rb$optimum
ALL$name[sol.3rb$solution == 1]
# 4 WR
sol.4wr$optimum
ALL$name[sol.4wr$solution == 1]
# 2 TE
sol.2te$optimum
ALL$name[sol.2te$solution == 1]
