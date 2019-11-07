#!/usr/local/bin/Rscript

# load libraries

library(readr)
library(stringr)
library(dplyr)
library(pryr)
library(tidyr)
library(tibble)

# list of data files relevant for the assignment on UCI HAR data
#
#################### NOTE #####################
#
# change the paths below to the actual paths where these are available
# Must keep the sequence the same - this is critical
# The 3 output csv files will be produced in path thay you indicate below

x_train_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/train/X_train.txt"
x_test_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/test/X_test.txt"
act_label_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/activity_labels.txt"
y_train_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/train/y_train.txt"
y_test_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/test/y_test.txt"
feat_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/features.txt"
sub_train_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/train/subject_train.txt"
sub_test_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/test/subject_test.txt"

# the output of the pre-analysis program below - the perl script is received
# in the following 2 csv files - one for the training data and one for test data

combo_train_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/train/subject_train.csv"
combo_test_f <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/test/subject_test.csv"

# these are the 3 final tidy datasets in 3 csv files. Change the path as you wish to
combo_tidy_dset <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/uci_har_combo_tidy_dset.csv"
train_tidy_dset <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/uci_har_train_tidy_dset.csv"
test_tidy_dset <- "/Users/lil.haifa83/DS/UCI_HAR_Dataset/uci_har_test_tidy_dset.csv"

# path to the pre-analysis perl script
pre_anlys_pgm <- "/Users/lil.haifa83/EC_PC_flow/bin/pre_analysis.pl"

sys_cmd <- paste(pre_anlys_pgm,x_train_f,x_test_f,act_label_f,y_train_f,y_test_f,feat_f,sub_train_f,sub_test_f)
print(sys_cmd)

# run the system command now to obtain the output of the pre-analysis in the above mentioned 2 csv files
 system(sys_cmd)

# now begins the analysis part in R 

# read the test data csv file prepared by the perl script
uci_har_test_dset <- read.csv(combo_test_f)
# select the summary variables - mean and std
uci_har_test_sum_dset <- select(uci_har_test_dset,subject_id,activity_label,matches("Mean|std"))
# add the column tidy_data and set the value to test - for test data
uci_har_test_sum_dset <- add_column(uci_har_test_sum_dset,data_type = "test")
# create the summary tidy set for test data
uci_har_test_sumtidy_dset <- uci_har_test_sum_dset %>% select(-data_type) %>% group_by(subject_id,activity_label) %>% summarize_all(mean) %>% ungroup()

# read the train data csv file prepared by the perl script
uci_har_train_dset <- read.csv(combo_train_f)
# select the summary variables - mean and std
uci_har_train_sum_dset <- select(uci_har_train_dset,subject_id,activity_label,matches("Mean|std"))
# add the column tidy_data and set the value to train - for train data
uci_har_train_sum_dset <- add_column(uci_har_train_sum_dset,data_type = "train")
# create the summary tidy set for test data
uci_har_train_sumtidy_dset <- uci_har_train_sum_dset %>% select(-data_type) %>% group_by(subject_id,activity_label) %>% summarize_all(mean) %>% ungroup()

# combine the test and train data into a combo by using rbind()
uci_har_combo_sum_dset <- rbind(uci_har_train_sum_dset,uci_har_test_sum_dset)
# create the summary tidy set for combo data
uci_har_combo_sumtidy_dset <- uci_har_combo_sum_dset %>% select(-data_type) %>% group_by(subject_id,activity_label) %>% summarize_all(mean) %>% ungroup()
# write the summary tidy data to csv files for test, train and combo datasets
write.csv(uci_har_combo_sumtidy_dset,combo_tidy_dset,row.names = FALSE)
write.csv(uci_har_train_sumtidy_dset,train_tidy_dset,row.names = FALSE)
write.csv(uci_har_test_sumtidy_dset,test_tidy_dset,row.names = FALSE)

quit(status=0)

