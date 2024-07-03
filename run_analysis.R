# Coursera: Data Science Foundations - Getting and Cleaning Data Assignment

# Author: William Landers

# Requirements:  
# - Merge the training and test data sets to create one data set.  
# - Extract only the measurements on the mean and standard deviation for each measurement.   
# - Use descriptive activity names to name the activities in the data set.  
# - Appropriately label the data set with descriptive variable names.  
# - From the data set in step 4, create a second, independent tidy data set 
#   with the average of each variable for each activity and each subject.  

# Load packages 
pkgs <- c('data.table', 'reshape2')
sapply(pkgs, require, character.only=TRUE, quietly=TRUE)

# Retrieve data
path <- getwd()
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(url, file.path(path, "data.zip"))
unzip(zipfile = "data.zip")



# -------------

# Load activity labels + features
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)
