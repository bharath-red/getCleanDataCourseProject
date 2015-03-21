---
title: "Getting and Cleaning Data - Course Project"
output: html_document
---

##Description of the data set and its variables
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

- tBodyAcc-XYZ
- tGravityAcc-XYZ
- tBodyAccJerk-XYZ
- tBodyGyro-XYZ
- tBodyGyroJerk-XYZ
- tBodyAccMag
- tGravityAccMag
- tBodyAccJerkMag
- tBodyGyroMag
- tBodyGyroJerkMag
- fBodyAcc-XYZ
- fBodyAccJerk-XYZ
- fBodyGyro-XYZ
- fBodyAccMag
- fBodyAccJerkMag
- fBodyGyroMag
- fBodyGyroJerkMag

The set of variables that were estimated from these signals are: 

- mean(): Mean value
- std(): Standard deviation

The above measurements were conducted on 30 subjects during various activity phases such as  


- WALKING
- WALKING_UPSTAIRS
- WALKING_DOWNSTAIRS
- SITTING
- STANDING
- LAYING

The tidy data set which is the final output of the analysis tabulates the mean of the different measurement variables for each user and each activity type.

The step by step description of the analysis with code is present below.


###Download the dataset
The dataset is downloaded and unzipped if not already present.

```r
#Download the dataset
if (!file.exists("UCI HAR Dataset"))
{
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    setInternet2(use = TRUE)
    download.file(url, destfile = "./UCI HAR Dataset.zip", method = "auto")
    unzip("./UCI HAR Dataset.zip")
}
```


###Read the test and training datasets
The test and training datasets are read into seperate data frames.

```r
#Read the test and training datasets
trainActData <- read.table("./UCI HAR Dataset/train/X_train.txt", colClasses="numeric")
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainActLabel <- read.table("./UCI HAR Dataset/train/y_train.txt")

testActData <- read.table("./UCI HAR Dataset/test/X_test.txt", colClasses="numeric")
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testActLabel <- read.table("./UCI HAR Dataset/test/y_test.txt")
```


###Appropriately label the data set with descriptive variable names
The names of the variables are read from the features.txt file. These variables names are assigned as column names of the data frame.

```r
#Read the names of the measurement variables from the features.txt file
colLabels <- read.table("./UCI HAR Dataset/features.txt", colClasses = "character")

#Appropriately label the data set with descriptive variable names
names(trainActData) <- colLabels[,2]
names(testActData) <- colLabels[,2]
names(trainSubject) <- "subjectId"
names(testSubject) <- "subjectId"
names(trainActLabel) <- "activityLabel"
names(testActLabel) <- "activityLabel"
```


###Merge the training and the test sets to create one data set  
The training and test datasets are merged into a single dataset with all the variables and all measurements. This is done using the rbind and cbind functions.  

```r
#Merge the training and the test sets to create one data set
actDataTotal <- rbind(cbind(trainSubject, trainActLabel, trainActData), 
      cbind(testSubject, testActLabel, testActData))
```


###Extract only the measurements on the mean and standard deviation for each measurement
The mean and standard deviation values alone are subset and stored in a new dataset.

```r
#Extract only the measurements on the mean and standard deviation for each 
#measurement
filterIndices <- sort(c(grep("subjectId", names(actDataTotal), fixed = TRUE), 
                   grep("activityLabel", names(actDataTotal), fixed = TRUE), 
                   grep("mean()", names(actDataTotal), fixed = TRUE), 
                   grep("std()", names(actDataTotal), fixed = TRUE)))
actDataFilt <- actDataTotal[, filterIndices]
```


###Use descriptive activity names to name the activities in the data set
The activity names are assigned descriptive values instead of the enumerated values to improve readability.

```r
#Use descriptive activity names to name the activities in the data set
actDataFilt$activityLabel <- factor(actDataFilt$activityLabel, 
                                    labels = c("WALKING", "WALKING_UPSTAIRS", 
                                               "WALKING_DOWNSTAIRS", "SITTING", 
                                               "STANDING", "LAYING"))
```


###Create a independent tidy data set with the average of each variable for each activity and each subject
A final dataset with the average values of each variable for each activity and each subject is created and written to a file. Here the final tidy data set has the means of different variables in each column(tBodyAcc-mean()-X, tBodyAcc-mean()-Y, ...), and the user name + activty for which mean is measured in the rows (1_WALKING, 1_WALKING_UPSTAIRS, 1_WALKING_DOWNSTAIRS, 1_SITTING, 1_STANDING, 1_LAYING, 2_WALKING, 2_WALKING_UPSTAIRS, ...)

```r
#Create a independent tidy data set with the average of each variable for each 
#activity and each subject
library(reshape2)
actDataMelt <- melt(actDataFilt, id = c("subjectId", "activityLabel"))
actDataSummary <- as.data.frame(acast(actDataMelt, subjectId + activityLabel ~ 
                                          variable, mean))
write.table(actDataSummary, file = "./actDataSummary.txt", row.names=FALSE)
```
