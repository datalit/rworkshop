##'
##' Outline and concepts for workshop
##' =================================
##' 
##' This `<-` command basically takes anything on the right hand side
##' and puts it into the left hand side.  Like an equation.  This is
##' called variable assignment (?).
##' 
df <- read.csv('train.csv')

##' `head` checks only the first few rows of the dataset.
head(df)

##' `dim` checks the dimensions of the dataset (number of rows and
##' number of columns, in that order).
dim(df)

##' `str` checks the structure of the dataset, showing what the `df`
##' object is, what each item (or column) in the dataset is, such as
##' numeric, factor, etc.  This is pretty useful as it can give you a
##' quick overview of what the variables have been classified as and
##' if there are any problems.
str(df)

##' `class` checks only the type of object you are asking, not the
##' contents (unlike `str`).
class(df)

##' `summary` is an extremely useful command to check the basic
##' descriptive statistics (mean, median, range, count for factors).
##' I usually use this anytime I want to quickly look at my dataset,
##' to get a sense of it.
summary(df)

##' If you want to see specific columns or rows, you can use the `[`
##' command.  The first number is the row `[row, ]`, and the second
##' number is the column `[, column]`.  So together: `[row, column]`.
##'
df[1:2, 1:5]

##' Also, numbers can be put together like so:
1:10
-1:10
1:-10
-10:1

##' In dataframes, a negative number means remove:
df[1:2, ]
df[1:2, -2:-4]

##' You can use strings (real words) to select a specific column.
df[1:2, 'Age']

##' You can use the combine command `c()` to put two strings or
##' numbers together.
df[c(1, 4), c('Age', 'Sex')]

##' You can also subset the data using these commands:
head(df[df$Sex == 'male', ])
head(df[c(df$Sex == 'male', df$Age < 40), ])

##'
##' `dplyr` and `tidyr` approach
##' ----------------------------
##' 
##' However, these are a bit complicated, and hard to read!  There is
##' a better way.  Install and/or load these packages:
##+ dplyrInstall, eval = FALSE
install.packages('dplyr')
install.packages('tidyr')
##+ loadDplyr, eval = TRUE
library(dplyr)
library(tidyr)

##' To do the same as the above, use:
df %>%
  filter(Sex == 'male', Age < 40) %>%
  ## You can keep chaining
  tbl_df() %>%
  ## ... and chaining
  select(Sex, Age, Pclass, Parch) %>%
  ## ... and chaining
  summary()

##' The extremely useful `%>%` chain, or pipe command, is just like in
##' the shell/terminal. It takes the output of the previous command
##' and inputs it into the next command.  Otherwise, without the `%>%`
##' pipe, it looks like:
summary(select(tbl_df(filter(df, Sex == 'male', Age < 40)), Sex, Age, Pclass, Parch))

##' The pipe does this by basically making the output be named `.`, so
##' really, the pipe is doing this:
df %>% select(., Fare, Sex) %>% filter(., Sex == 'male') %>%
  select(., Fare) %>% round(., 3)

##' `tbl_df` makes the dataframe also a tbl object, so that the outout
##' can be printed easily.  The verbs for dplyr are:
##' 
##' * select
##' * filter
##' * mutate
##' * summarise
##' * arrange
##' * group_by
##'
##' For more explanation of dplyr, check the documentation:
##' https://github.com/hadley/dplyr or run this command
##' `vignette('introduction', package = 'dplyr')`
##' 
df <- tbl_df(df)
df %>% summary

df %>%
  ## subset the data by SibSp
  filter(SibSp >= 2) %>%
  ## select only the relevant columns
  select(Age, Sex, Survived, Cabin, Fare) %>%
  ## order the data (in descending) by Age
  arrange(Age) %>%
  ## create a new column
  mutate(d.Fare = cut(Fare, 3, labels = c('Low', 'Middle', 'High')))

##' To do even more interesting things, we can combine the dplyr
##' package with the tidyr package.  The tidyr has basically two main
##' verbs:
##'
##' * gather
##' * spread
##'
df %>%
  filter(SibSp >= 2) %>%
  select(Age, Sex, Survived, Cabin, Fare) %>%
  ## convert the data into a very long format
  gather(Measure, Value, -Sex) %>%
  ## make each summarise command run on the groups Sex and Measure
  group_by(Sex, Measure) %>%
  ## create summary statistics, in this cause the sample in each group
  ## (Sex and Measure)
  summarise(n = n()) %>%
  ## convert the data into a wide format
  spread(Sex, n)

##' Check the content again:
df %>% summary

##' Compare the means of continuous variables of those who survived
##' and those who didn't.
prep.table <- df %>%
  select(Survived, Age, Pclass, SibSp, Parch, Fare) %>%
  gather(Measure, Value, -Survived) %>%
  group_by(Survived, Measure) %>%
  ## remove missing values
  na.omit() %>%
  ## create a summary statistic (means)
  summarise(mean = mean(Value) %>% round(2)) %>%
  spread(Survived, mean)

##' This can be created into a markdown table, so that it can be
##' easily put into a manuscript or report.  A very useful package is
##' called `pander` which allows you to create markdown tables.
##+ panderInstall, eval = FALSE
install.packages('pander')
##+ table, results = 'asis'
library(pander)
prep.table %>% pander()

##' There is also join commands from dplyr:
##'
##' * left_join
##' * outer_join
##' * inner_join
##' * anti_join
##'
##' Code used in workshop
##' =====================
##' 
##' Exact code used in the workshop
ds %>% select(., Sex, Cabin, Fare) %>%
    filter(., Sex == 'female', Fare > 10)

filter(select(ds, Sex, Cabin, Fare),
       Sex == 'female')

ds %>%
    select(Sex, Cabin, Fare) %>%
    mutate(newcol = 10 * Fare) %>%
    arrange(Fare)

ds %>%
    select(Sex, Age, Fare) %>%
    group_by(Sex) %>%
    na.omit() %>%
    summarise(n = n(),
              mean = mean(Age))

##' Remove a column using the `-` sign.
ds %>% select(-Age)

prep.table2 <- ds %>%
    select(Sex, Fare, Age, Pclass, SibSp) %>%
    mutate(AgeDouble = Age * 2) %>%
    gather(Measure, Value, -Sex) %>%
    na.omit() %>%
    group_by(Sex, Measure) %>%
    ## create a column with the mean and standard deviation
    summarise(meanSD = paste0(mean(Value) %>% round(2),
                             ' (', sd(Value) %>% round(2),
                             ')')) %>%
    spread(Sex, meanSD)

##' Create a table, with a caption!
##+ tableTesting, results = 'asis'
pander(prep.table2, style = 'rmarkdown', caption = 'Testing')

##' To use the `grid.table` function instead of `pander`, load the
##' `gridExtra` package.  You may need to install first
##' (`install.packages('gridExtra')`).
library(gridExtra)
grid.table(prep.table2, rows = NULL)

##' A package that does a tutorial *within* R!  I've heard good things
##' from it.
install.packages('swirl')


##' To see help files, you can run the `vignette` command.
##+ vignHelp, eval = FALSE
vignette('introduction', package = 'dplyr')

##+ knit, eval = FALSE, echo = FALSE
library(knitr)
spin('practice.R')
