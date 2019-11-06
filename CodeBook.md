R Objects created:
(i) uci_har_test_dset :  from the test data file prepared by the perl script. This includes - subject_id, activity_label and the feature names as variable names of the complete set of 561 measurements for test data
(ii) uci_har_test_sum_dset : selected columns - mean and std from the above data set
(iii) The column data_type with value = "test" is added to the above data set - as part of tidying up. 
(iv) uci_har_test_sumtidy_dset : The mean of the above dset grouped by subject_id and activity_label
(v) uci_har_train_dset :  from the train data file prepared by the perl script. This includes - subject_id, activity_label and the feature names as variable names of the complete set of 561 measurements for train data
(vi) uci_har_train_sum_dset : selected columns - mean and std from the above data set
(vii) The column data_type with value = "train" is added to the above data set - as part of tidying up. 
(viii) uci_har_train_sumtidy_dset : The mean of the above dset grouped by subject_id and activity_label
(ix) uci_har_combo_sum_dset : vertically combined data set from data sets in (iii) and (viii) above
(x) uci_har_combo_sumtidy_dset : The mean of the above dset grouped by subject_id and activity_label

Files created by perl script and used by R script as inputs:

(i) subject_train.csv and subject_test.csv
(ii) Output files created for the tidy summary data sets : uci_har_combo_tidy_dset.csv, uci_har_train_tidy_dset.csv, uci_har_test_tidy_dset.csv
