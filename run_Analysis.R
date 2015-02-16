#load libraries
library(dplyr)
library(reshape2)

#review the files we are working with and confirm that they exist
list.files("./data/UCI HAR Dataset")
list.files("./data/UCI HAR Dataset/train")
list.files("./data/UCI HAR Dataset/test")

#read in general files applicable to both testing and training datasets
#read in features, these will be the column names for the x_Test.csv file
featureFile <- "./data/UCI HAR Dataset/features.txt"
features <- read.table(featureFile, header=FALSE, col.names=c("id", "desc"))

#read in the activities
activityFile <- "./data/UCI HAR Dataset/activity_labels.txt"
activityLabels <- read.table(activityFile, header=FALSE, col.names=c("activity_id", "activity"))

#Read in the Test Data set  using read.table
#read in the test subjects
subjectTestFile <- "./data/UCI HAR Dataset/test/subject_test.txt"
subjectTest <- read.table(subjectTestFile, header=FALSE, col.names=c("subject_id"))

#read in the test labels
subjectTestLabelsFile <- "./data/UCI HAR Dataset/test/y_test.txt"
subjectTestLabels <- read.table(subjectTestLabelsFile, header=FALSE, col.names=c("activity_id"))

#read in the test set
testSetFile <- "./data/UCI HAR Dataset/test/x_Test.txt"
testSet <- read.table(testSetFile)

#set column names for the test set
names(testSet) <- features$desc

#add the observed activity column to the beginning of the test set
testSet <- cbind(subjectTestLabels, testSet)

#add the observed subject_id column to the beginning of the test set
testSet <- cbind(subjectTest, testSet)

#Read in the Training data set using read.table
#read in the train subjects
subjectTrainFile <- "./data/UCI HAR Dataset/train/subject_train.txt"
subjectTrain <- read.table(subjectTrainFile, header=FALSE, col.names=c("subject_id"))

#read in the train labels
subjectTrainLabelsFile <- "./data/UCI HAR Dataset/train/y_train.txt"
subjectTrainLabels <- read.table(subjectTrainLabelsFile, header=FALSE, col.names=c("activity_id"))

#read in the train set of observations
trainSetFile <- "./data/UCI HAR Dataset/train/x_train.txt"
trainSet <- read.table(trainSetFile)

#set column names for the test set
names(trainSet) <- features$desc

#add the observed activity column to the beginning of the test set
trainSet <- cbind(subjectTrainLabels, trainSet)

#add the observed subject_id column to the beginning of the test set
trainSet <- cbind(subjectTrain, trainSet)

#Merge the two data sets
dataSet <- rbind(trainSet,testSet)

#Extract only the measurements on the mean and standard deviation for each measurement. 
measurementSet <- dataSet[1:3]
measurementSet <- cbind(measurementSet, dataSet[,grepl("std()", colnames(dataSet))])
measurementSet <- cbind(measurementSet, dataSet[,grepl("mean()", colnames(dataSet))])

#Name the activities in the data set with descriptive activity names
#merge the activity descriptions into the test labels
measurementSet <- merge(activityLabels, measurementSet, by.x="activity_id", by.y="activity_id", 
                  all.x=FALSE, all.y=FALSE)

#3 2 lines for debugging purposes
#writeFile <- "./data/measurementSet.txt"
#write.table (measurementSet, file=writeFile, row.names=FALSE)

#Create a second, independent tidy data set
#with the average of each variable for each activity 
#and each subject.

#collect the names of the variables
measurementVars<-names(measurementSet[4:82])

#melt the dataset down to one row per variable
measurementMelt <- melt(
  measurementSet,
  id=c("subject_id", "activity"),
  measure.vars = measurementVars)

#summarize the dataset to the mean of each variable per 
#subject_id/activity combination
tidyData <- measurementMelt %>% group_by(subject_id, activity, variable)  %>% summarize(average = mean(value))
tidyData <-arrange(tidyData, subject_id, activity, variable)

#Write out to a file using  write.table() using row.name=FALSE
writeFile <- "./data/tidyData.txt"
write.table (tidyData, file=writeFile, row.names=FALSE)