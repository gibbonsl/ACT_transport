cd "G:\Laura\ACT transport"

*** by ACT or not
*** also included wts in BRFSS

use combined, clear
keep if visit==0 | visit==. // visit==. is BRFSS

* didn't work for race4, try race3 and hispanic separately
keep xmmsawt id act ageg5yr sex ed3 race3 hispanic marry work smoke bpcurr cholcurr mi heart_dis stroke asthma copd diabetes cancer osteoa ratehealth diffdres diffwalk 
order id, before(sex)
su 
save temp, replace

mi set wide // run mi update if drop vars (or people)
mi misstable summarize
mi misstable summarize if act==1
mi misstable summarize if act==0

* These are the variables with no missing data
mi register regular id act ageg5yr sex xmmsawt
	
* The variables with missing data 
mi register imputed ed3 race3 hispanic marry work smoke bpcurr cholcurr mi heart_dis stroke asthma copd diabetes cancer osteoa ratehealth diffdres diffwalk 
mi describe
save temp, replace

mi impute chained 	/// 
	(ologit, ) ed3 smoke ratehealth  ///
	(mlogit) race3 marry work  ///
	(logit) hispanic bpcurr cholcurr mi heart_dis stroke asthma copd diabetes cancer osteoa diffdres diffwalk  = ageg5yr sex  ///
	, add(40) rseed(2466755) force by(act) augment // augment finesses perfect prediction of something in BRFSS
mi describe 	
mi varying	

save impute40by, replace // to keep all this work!
	
