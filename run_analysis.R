## download the file to a new directory
if(!file.exists("./data")){dir.create("./data")}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl, destfile="./data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")

## unzip the downloaded file to the given directory
zipF <- "./data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

outdir <-"./data"

unzip(zipF, exdir = outdir)

## import needed packages
library(dplyr); library(tidyr); library(readr); library(stringr)
library(data.table)
library(tidyverse)

## let's take a look at our downloaded file
list.files('./data/UCI HAR Dataset')
list.files('./data/UCI HAR Dataset/test')
list.files('./data/UCI HAR Dataset/test/Inertial Signals')

## open the activity_label file
activity <- read_csv('./data/UCI HAR Dataset/activity_labels.txt', col_names = FALSE)
#activity <- fread('./data/UCI HAR Dataset/activity_labels.txt')
#activity <- as_tibble(activity)
activity <- separate(activity, X1, into = c("index", "activity"), sep = " ")

## open the features text file
feature <- read_csv('./data/UCI HAR Dataset/features.txt', col_names = FALSE)
feature <- separate(feature, X1, into = c("index", "features"), sep = " ")

## open the subject_test text file in the test folder
#sub_test <- as_tibble(fread('./data/UCI HAR Dataset/test/subject_test.txt'))
sub_test <- read_csv('./data/UCI HAR Dataset/test/subject_test.txt', col_names = "id", 
                     col_types = cols(.default = col_factor()))

## open the X_test text file in the test folder
test_set <- read_delim('./data/UCI HAR Dataset/test/X_test.txt', 
                       col_names = feature$features, delim = " ", col_types = cols(.default = col_number())
)
test_set <- as_tibble(test_set, .name_repair = "universal")
## extract mean and sd of features in the test dataset
test_ms <- bind_cols(select(test_set, contains("mean")), select(test_set, contains("std")))


## open the y_test text file in the test folder
y_test <- read_csv('./data/UCI HAR Dataset/test/y_test.txt', 
                   col_names = "labels")

## create factor variables, test_labels
test_labels <- as_tibble(sapply(y_test, factor, levels = activity$index, labels = activity$activity))


## create dataset, df, by combining the columns of sub_test and test_set
df <- bind_cols(sub_test, test_labels, test_ms)


## -------------------------------------------------------------------
## train data
## let's take a look at our downloaded file
list.files('./data/UCI HAR Dataset/train')
list.files('./data/UCI HAR Dataset/train/Inertial Signals')

## open the subject_train text file in the train folder
sub_train <- read_csv('./data/UCI HAR Dataset/train/subject_train.txt', col_names = "id",
                      col_types = cols(.default = col_factor()))

## open the x_train text file in the train folder
train_set <- read_delim('./data/UCI HAR Dataset/train/X_train.txt',
                        col_names = feature$features, delim = " ", col_types = cols(.default = col_number())
)
train_set <- as_tibble(train_set, .name_repair = "universal")
## extract mean and sd of features in the train dataset
train_ms <- bind_cols(select(train_set, contains("mean")), select(train_set, contains("std")))


## open the y_train text file in the test folder
y_train <- read_csv('./data/UCI HAR Dataset/train/y_train.txt', col_names = "labels")

## create factor variables, train_labels
train_labels <- as_tibble(sapply(y_train, factor, levels = activity$index, labels = activity$activity))

## create dataset, dfl, by combining the columns of sub_train, train_labels and train_set
df1 <- bind_cols(sub_train, train_labels, train_ms)

data <- right_join(df, df1)


# -------------------------------------------------------------------#
# create a different dataset by using id and labels columns as factor variables.
factoredData <- group_by(data, id, labels)
tidydata <- summarize_each(factoredData, mean, (tBodyAcc.mean...X:fBodyBodyGyroJerkMag.std..))

# Export tidydata as text file
write_delim(tidydata, "tidy.txt")