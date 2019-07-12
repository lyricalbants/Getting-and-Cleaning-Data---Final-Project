# Getting-and-Cleaning-Data---Final-Project
**Synopsis** 
Merged two datasets, training and test data. Extracted only the measurements on the mean and standard deviation for each measurement. Used descriptive activity names to name the activities in the data set. Labeled the dataset with descriptive variable names. Finally, created a new dataset , with the average of each variable for each activity and each subject in the first dataset.

The r script, run_analysis.R, conveys everything I have been able to learn on Getting and Cleaning data thus far. 
The very first section of the script denotes getting the required files from the web, unzipping and putting the zipped files in a new directory if such directory doesn't exist.
import packages needed to clean and tidy the datasets.
Have a notion of the task at hand using list.files() to view the downloaded files.
First, open and read the files in the test folder, leaving out those in the subdirectory, Inertial Signal.
Rename the column names of the X_test dataset with each row element in the features dataset.
Extract only the X_test columns with mean or std in their column names and then column-bind them to the subject_test and y_test.
Do the same for the train folder
Join both datasets derived from the test and train folders to create a train-test dataset.
To create a new categorical dataset, group the merged test-train dataset by columns id and labels and summarize for each subject and each activity, the mean of each variable. 
print
