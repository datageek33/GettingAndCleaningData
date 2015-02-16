---
title: "Course Project Codebook"
author: "Justin"
date: "Sunday, February 15, 2015"
output: html_document
class: Getting and Cleaning Data
assignment: Course Project
---
This codebook describes the variables, data, and transformations and other work done to clean up the data for this course project.

Experiments were  carried out with a group of 30 volunteers within an age bracket of 19-48 years. 

Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist.

Observations from the sensors were stored in columns in the test files.

##Assumptions
-This script starts with the assumption that the Samsung data is available in the working directory in an unzipped UCI HAR Dataset folder.

-The data in the "Intertial Signals" folder was not used because it does not contain the necessary   

##Variables  
features: data frame containing the "features" which are column headings for the observed test results  
activityLabels: data frame containing the activity Labels for the observed test results  
    
subjectTest: contains the subject for the 2947 observations in the test folder  
subjectTestLabels: contains the activities for the 2947 observations in the test folder  
testSet: contains the 2947 observations from the test folder along with their subject and activity  

subjectTrain: contains the subject for the 7352 observations in the train folder  
subjectTrainLabels: contains the activities for the  observations in the train folder  
trainSet: contains the  observations from the train folder along with their subject and activity  

dataSet: contains the 10,299 combined observations form the test dataset and train dataset  

measurementSet: contains the mean and standard deviation observations form the test dataset and train dataset  
measurementVars: contains the variable names from the measurement set  

measurementMelt: melted data frame containing one row for each variable observed per subject and activity   

tidyData: contains the tidy data set with average of each variable group by subject and activity  

I intentionally chose to show the tidy data in a "long form" with one row per subject, activity, and average measurement.  

Another way to present it could have been with a "wide form" of a single row for each subject activity combination with a column per measurement.

#Data Processing Steps

##Read in the  data sets   

```
# each file was read in using read.table function like this
featureFile <- "./data/UCI HAR Dataset/features.txt"
features <- read.table(featureFile, header=FALSE, col.names=c("id", "desc"))

#set column names for the features/variables in the test set
features <- read.table(featureFile, header=FALSE, col.names=c("id", "desc"))
names(testSet) <- features$desc

```

##Merge the two data sets
```
#Merge the two data sets
dataSet <- rbind(trainSet,testSet)
```
##Name the activities in the data set with descriptive activity names
At the same time as reading the data sets in, I added descriptive activity names   
I did this by reading in the activity file
And by joining into each data set

```
#Name the activities in the data set with descriptive activity names
#merge the activity descriptions into the test labels
measurementSet <- merge(activityLabels, measurementSet, by.x="activity_id", by.y="activity_id", 
                  all.x=FALSE, all.y=FALSE)

`````

##Extract only the measurements on the mean and standard deviation for each measurement. 
I used the logic that only the columns with  "mean()" and "std()" should be used.  
I intentionally excluded columns like "gravityMean" or "meanFreq"

````
#Extract only the measurements on the mean and standard deviation for each measurement. 
measurementSet <- dataSet[1:3]
measurementSet <- cbind(measurementSet, dataSet[,grepl("std()", colnames(dataSet))])
measurementSet <- cbind(measurementSet, dataSet[,grepl("mean()", colnames(dataSet))])  

`````

##Create a second, independent tidy data set with the average of each variable for each activity  and each subject. 

I reshaped the data using melt to flatten it to one
row per observation per subject and activity

```
#melt the dataset down to one row per variable
measurementMelt <- melt(
  measurementSet,
  id=c("subject_id", "activity"),
  measure.vars = measurementVars)  
   
```

Then I summarized the data set to get the average for each variable grouped by subject and activity

```
#summarize the dataset to the mean of each variable per 
#subject_id/activity combination
tidyData <- measurementMelt %>% group_by(subject_id, activity, variable)  %>% summarize(average = mean(value))
tidyData <-arrange(tidyData, subject_id, activity, variable)

```

##Write out to a file
Finally I wrote the data set to a file
```
writeFile <- "./data/tidyData.txt"
write.table (tidyData, file=writeFile, row.names=FALSE)
````
