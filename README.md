# coursera_data_tidying_cleaning
Coursera Data Tidying and Cleaning Assignment
REQUIREMENTS: 
You should create one R script called run_analysis.R that does the following.
1.	Merges the training and the test sets to create one data set.
2.	Extracts only the measurements on the mean and standard deviation for each measurement.
3.	Uses descriptive activity names to name the activities in the data set
4.	Appropriately labels the data set with descriptive variable names.
5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

SOLUTION:
The submission includes two scripts:
a) an "R" script : run_analysis.R
b) A perl script : pre-analysis.pl

Overview:
The perl script is called first by the "R" script and performs the following tasks:
(i) converts the white-space delimited input files "X_train.txt" and "X_test.txt" to csv files.
(ii) extracts the activity label strings and maps them against the label integer codes - from "activity_labels.txt"
(iii) replaces the activity codes by their respective labels in the input files "y_train.txt" and "y_test.txt"
(iv) It ensures that the order of the labels is retained - identical to the order of the codes.
(v) Extracts the features list from "features.txt", cleans up the feature name strings ( removes probematic characters like '(', ')', ',' or replaces them with underscore) - so that these can be used as descriptive names for the measurments extracted.
(vi) It then transforms the feature list into CSV format, i.e., names separated by ',' into one single string - to serve as the variable names for the respective train and test data sets
(vii) Finally, the script merges the subject IDs, the Activity Labels and the measurement csv files into a single csv file - one for train and one for test - called "subject_train.csv" and "subject_test.csv". It also adds the header string from (vi) above to the 2 csv files. 

These combined csv files then are used by the R script to further tidy up the data, select the required columns and summarize them. 
In summary, requirements 3 and 4 are fulfilled by the perl script and requirements 1,4 and 5 are fulfilled by the R script. 

DESCRIPTION : R Scipt
(i) read the test data csv file prepared by the perl script
(ii) select the summary variables - mean and std
(iii) add the column tidy_data and set the value to test - for test data
(iv) create the summary tidy set for test data
(v) read the train data csv file prepared by the perl script
(vi) select the summary variables - mean and std
(vii) add the column tidy_data and set the value to train - for train data
(viii) create the summary tidy set for test data
(ix) combine the test and train data into a combo by using rbind()
(x) create the summary tidy set for combo data
(xi) write the summary tidy data to csv files for test, train and combo datasets

DESCRIPTION : perl Script
Takes 8 arguments - path names to the input txt files in a specific order. The order is critical. 
subroutine txtocsv_a : converts the measurement data into csv format. This is called once each for train and test data.
subroutine txtolabel : reads the activity label file and maps the labels agains the codes
subroutine replace_a : replaces the activity codes in y_train and y_test files by the labels
subroutine txtocsv_b : reads the features list and converts the feature description strings into a single csv record - as header to the measurement data. 
subroutine merge_dset : merges the subject ID, activity labels and measurement data (561 data points) into a single csv - one each for test and train data. 

NOTE:  The perl script can be run independently from the system command line, not necessarily from within the R script
       Read the commented description in the scripts.

PORTABILITY:  Both scripts are portable on linux and macos. Not tested over windows. 
