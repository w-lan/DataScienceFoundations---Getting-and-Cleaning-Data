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

# Activity Labels / Features
activity_labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        ,col.names = c('activity_id', 'label'))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  ,col.names = c('index', 'feature'))

# Retain mean and standard deviation measurements for each feature
idx_retain_features <- grep("(mean|std)\\(\\)", features[, feature])
measurements <- features[idx_retain_features, feature]
measurements <- gsub('[()]', '', measurements)

# Bind training and test data with subject and activity ID
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, idx_retain_features, with = FALSE]
data.table::setnames(train, colnames(train), measurements)

train_activities <- fread(file.path(path, "UCI HAR Dataset/train/y_train.txt"), col.names=c('activity_id'))
train_subject <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names=c('subject_id'))
train <- cbind(train_subject, train_activities, train)

test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, idx_retain_features, with = FALSE]
data.table::setnames(test, colnames(test), measurements)

test_activities <- fread(file.path(path, "UCI HAR Dataset/test/y_test.txt"), col.names=c('activity_id'))
test_subject <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names=c('subject_id'))
test <- cbind(test_subject, test_activities, test)

combined <- rbind(train, test)

# Convert activity_id to activity label
combined[["activity_id"]] <- factor(combined[, activity_id]
                                    ,levels = activity_labels[["activity_id"]]
                                    ,labels = activity_labels[["label"]])
setnames(combined, old = "activity_id", new = "activity")
combined[["subject_id"]] <- as.factor(combined[,subject_id])

# wide > long
combined <- reshape2::melt(data = combined, id = c("subject_id", "activity_id"))

# Average of each variable for (subject, activity) pairs. 
combined <- reshape2::dcast(data = combined, subject_id + activity ~ variable, fun.aggregate = mean)

# export results
data.table::fwrite(x = combined, file = "tidy_data.txt", row.name=FALSE, quote = FALSE)