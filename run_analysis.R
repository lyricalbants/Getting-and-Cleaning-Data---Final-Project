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
activity <- separate(activity, X1, into = c("index", "activity"), sep = " ")

## open the features text file
#feature <- read_csv('./data/UCI HAR Dataset/features.txt', col_names = FALSE)
#feature <- separate(feature, X1, into = c("index", "features"), sep = " ")
feature <- fread('./data/UCI HAR Dataset/features.txt')
names(feature) <- c("index", "features")

# Make features a bit descriptive
feature$features <- gsub("BodyBody", "Body", feature$features, fixed = T)
feature$features <- gsub("tBody", "TimeBody", feature$features, fixed = T)
feature$features <- gsub("Acc", "Acceleration", feature$features, fixed = T)
feature$features <- gsub("tGravity", "TimeGravity", feature$features, fixed = T)
feature$features <- gsub("Mag", "Magnetic", feature$features, fixed = T)
feature$features <- gsub("Freq", "Frequency", feature$features, fixed = T)
feature$features <- gsub("fBody", "FrequencyBody", feature$features, fixed = T)
feature$features <- gsub("()", "", feature$features, fixed = T)
feature$features <- gsub("-", ".", feature$features, fixed = T)


## open the subject_test text file in the test folder
sub_test <- read_csv('./data/UCI HAR Dataset/test/subject_test.txt', col_names = "subject", 
                     col_types = cols(.default = col_factor()))

## open the X_test text file in the test folder
test_set <- read_delim('./data/UCI HAR Dataset/test/X_test.txt', 
                       col_names = feature$features, delim = " ", col_types = cols(.default = col_number())
)
test_set <- as_tibble(test_set, .name_repair = "universal")
names(test_set) <- tolower(names(test_set))

## extract mean and sd of features in the test dataset
test_ms <- bind_cols(select(test_set, contains("mean")), select(test_set, contains("std")))


## open the y_test text file in the test folder
y_test <- read_csv('./data/UCI HAR Dataset/test/y_test.txt', 
                   col_names = "activity")

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
sub_train <- read_csv('./data/UCI HAR Dataset/train/subject_train.txt', col_names = "subject",
                      col_types = cols(.default = col_factor()))

## open the x_train text file in the train folder
train_set <- read_delim('./data/UCI HAR Dataset/train/X_train.txt',
                        col_names = feature$features, delim = " ", col_types = cols(.default = col_number())
)
train_set <- as_tibble(train_set, .name_repair = "universal")
names(train_set) <- tolower(names(train_set))

## extract mean and sd of features in the train dataset
train_ms <- bind_cols(select(train_set, contains("mean")), select(train_set, contains("std")))


## open the y_train text file in the test folder
y_train <- read_csv('./data/UCI HAR Dataset/train/y_train.txt', col_names = "activity")

## create factor variables, train_labels
train_labels <- as_tibble(sapply(y_train, factor, levels = activity$index, labels = activity$activity))

## create dataset, dfl, by combining the columns of sub_train, train_labels and train_set
df1 <- bind_cols(sub_train, train_labels, train_ms)

data <- right_join(df, df1)


# -------------------------------------------------------------------#
# create a different dataset by using id and labels columns as factor variables.
factoredData <- group_by(data, subject, activity)
tidydata <- summarize_each(factoredData, mean, (timebodyacceleration.mean.x:frequencybodygyrojerkmagnetic.std))

# Export tidydata as text file
write_delim(tidydata, "tidy.txt")
