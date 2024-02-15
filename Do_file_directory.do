*** Data preparation ***
*----------------------*

* To make the ACT dataset, actdata2020.dta, from the ACT 2020 freeze data:
act_data_2020_freeze.do

* To make the BRFSS dataset, seabrfss2019.dta, from the BRFSS source data 
seabrfss2019.do   

* To combine the actdata2020 and seabrfss2019 and align the variables, making combined.dta
align_act_brfss.do

* Missing data imputation. Makes "impute40by.dta" from "combined.dta" 
impute_missing_data_by_group.do


*** Primary analyses ***
*----------------------*

* Computing the weights. 
* Uses "impute40by.dta" to make "baseallby.dta" and also "wtbaseby.dta", which only has ACT people. 
weights_with_imputed_data.do

* Check how well the weights balance the data.
develop_difference_plots.do // makes the usual figure. The y labels were edited in Indesign. 

* Eye disease examples, not bootstrapped. 
* These use wtbaseby.dta merged with a file with eye disease data (eyedxpx220707.dta)
eye_disease_prev.do // baseline prevalence estimates
longitudinal_eye_example.do // dementia risk

* Bootstrapping the CI for both the prevalence and dementia weighted analyses 
bootstrap_CI.do

/*** Sensitivity analyses - similar do files were made for each set but not uploaded here.
1) Remove ACT people born before 1920. 
2) Take ADL's out of weights
3) Standardized weights (Using zwsiowbase as the weighting variable)

Please contact gibbonsl@uw.edu with any questions.