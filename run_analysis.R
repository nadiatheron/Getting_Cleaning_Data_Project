#You should create one R script called run_analysis.R that does the following. 

#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names. 
#5. From the data set in step 4, creates a second, independent tidy data set with the average
#   of each variable for each activity and each subject.

require(plyr)

## 1. Merges the training and the test sets to create one data set.
# Checks for data directory and creates one if it doesn't exist
if(!file.exists("./data")){
        dir.create("./data")
}
# Checks whether the source data has been downloaded and downloads it if it doesn't exist
if(!file.exists("./data/UCI HAR Dataset")){
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl,destfile="./data/Dataset.zip")
        unzip(zipfile="./data/Dataset.zip",exdir="./data")
        #create a list of files in the zip folder
        files_list <- list.files("./data/UCI HAR Dataset", full.names=TRUE, recursive=TRUE)   
}

# Read in the individual test and training dataset
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt", as.is= TRUE)
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# check dimensions and types of individual datasets prior to merging
str(X_test)
str(y_test)
str(X_train)
str(y_train)
str(subject_test)
str(subject_train)

dim(X_test)
dim(y_test)
dim(X_train)
dim(y_train)
dim(subject_test)
dim(subject_train)

# Merge & ## 4. label the datasets with descriptive variable names. 
feature.data <- rbind(X_train,X_test)
names(feature.data) <- feature.names
activity.data <- rbind(y_train,y_test)
names(activity.data) <- "activity.id"
subject.data <- rbind(subject_train,subject_test)
names(subject.data) <- "subject"

dim(feature.data)
dim(activity.data)
dim(subject.data)

##2. Extracts only the measurements on the mean and standard deviation for each measurement in the features dataset. 
# Read in the feature dataset that identifies the feature names
features <- read.table("./data/UCI HAR Dataset/features.txt")
feature.names <- c(as.character(features$V2))
# identify the columns that contain 'mean()' or 'std()'
indices_for_mean_std <- grepl("mean()",feature.names,fixed=TRUE)|grepl("std()",feature.names,fixed=TRUE)
# use the indices to extract the relevant data and column names
meanstdfeature.names <- feature.names[indices_for_mean_std]
meanstdfeature.data <- feature.data[,c(indices_for_mean_std)]
names(meanstdfeature.data) <- c(meanstdfeature.names)
dim(meanstdfeature.data)


##3. Uses descriptive activity names to name the activities in the actvity dataset
# labels names based on activity_labels.txt
# rename generic column names V1 & V2 with descriptive variable names
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt",col.names=c("activity.id","activity.label"))
# merge in the labels based on the activity id 
activity.data <- merge(activity.data,activity_labels,by.x="activity.id",by.y="activity.id")
# update the activity data so that the id's are replace by the labels
activitylabel.data <- subset(activity.data,select=c(activity.label))

# Merge the subject, activity and mean/std measures of the feature data into a single dataset
merged.data <- cbind(subject.data,activitylabel.data,meanstdfeature.data)
str(merged.data)
dim(merged.data)

##4. Appropriate labels added to the data set with descriptive variable names see row 54,56 & 71 above 

##5. From the data set in step 4, creates a second, independent tidy data set with the average
#   of each variable for each activity and each subject.
tidy.mean <- ddply(merged.data, .(subject, activity.label),colwise(mean),.drop=FALSE)
# Sanity check - not all combinations of subject & activity appears, however these combinations are retained in the dataset
table(merged.data$subject,merged.data$activity)
str(tidy.mean)
dim(tidy.mean)
View(tidy.mean)

#output final table
write.table(tidy.mean, file = "tidymean.txt",row.name=FALSE)
