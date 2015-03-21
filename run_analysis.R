#Download the dataset
if (!file.exists("UCI HAR Dataset"))
{
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    setInternet2(use = TRUE)
    download.file(url, destfile = "./UCI HAR Dataset.zip", method = "auto")
    unzip("./UCI HAR Dataset.zip")
}


#Read the test and training datasets
trainActData <- read.table("./UCI HAR Dataset/train/X_train.txt", colClasses="numeric")
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainActLabel <- read.table("./UCI HAR Dataset/train/y_train.txt")

testActData <- read.table("./UCI HAR Dataset/test/X_test.txt", colClasses="numeric")
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testActLabel <- read.table("./UCI HAR Dataset/test/y_test.txt")


#Read the names of the measurement variables from the features.txt file
colLabels <- read.table("./UCI HAR Dataset/features.txt", colClasses = "character")


#Appropriately label the data set with descriptive variable names
names(trainActData) <- colLabels[,2]
names(testActData) <- colLabels[,2]
names(trainSubject) <- "subjectId"
names(testSubject) <- "subjectId"
names(trainActLabel) <- "activityLabel"
names(testActLabel) <- "activityLabel"


#Merge the training and the test sets to create one data set
actDataTotal <- rbind(cbind(trainSubject, trainActLabel, trainActData), 
                      cbind(testSubject, testActLabel, testActData))


#Extract only the measurements on the mean and standard deviation for each 
#measurement
filterIndices <- sort(c(grep("subjectId", names(actDataTotal), fixed = TRUE), 
                        grep("activityLabel", names(actDataTotal), fixed = TRUE), 
                        grep("mean()", names(actDataTotal), fixed = TRUE), 
                        grep("std()", names(actDataTotal), fixed = TRUE)))
actDataFilt <- actDataTotal[, filterIndices]


#Use descriptive activity names to name the activities in the data set
actDataFilt$activityLabel <- factor(actDataFilt$activityLabel, 
                                    labels = c("WALKING", "WALKING_UPSTAIRS", 
                                               "WALKING_DOWNSTAIRS", "SITTING", 
                                               "STANDING", "LAYING"))


#Create a independent tidy data set with the average of each variable for each 
#activity and each subject
library(reshape2)
actDataMelt <- melt(actDataFilt, id = c("subjectId", "activityLabel"))
actDataSummary <- as.data.frame(acast(actDataMelt, subjectId + activityLabel ~ 
                                          variable, mean))
write.table(actDataSummary, file = "./actDataSummary.txt", row.names = FALSE)
