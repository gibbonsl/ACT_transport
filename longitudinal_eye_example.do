cd "G:\Laura\ACT transport"

use wtbaseby, clear
*use noadlwtbaseby, clear // for sensitivity analyses
rename id subject

merge 1:m subject using "G:\Paul\Cecilia\eyedxpx220707", keep(3) nogen // 5 people don't have weights.

*stset surv_age, failure(anyad) origin(time 0) enter(age_bl) id(subj) // unweighted
stset surv_age [pweight=wsiowbase], failure(anyad) origin(time 0) enter(age_bl) id(subj) // weighted

stcox i.dryrcat age0 educ white i.smoke, nolog strata(apoe gender)
estat phtest, de // fine unweighted, white is a problem weighted

stcox i.amdyrcat age0 educ white i.smoke, nolog strata(apoe gender)
estat phtest, de // ditto

	 
