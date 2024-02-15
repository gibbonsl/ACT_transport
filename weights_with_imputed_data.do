cd "G:\Laura\ACT transport"
* this is only valid for baseline weights. 

use impute40by, clear

mi svyset [pweight=xmmsawt] 

mi estimate, saving(temp3, replace): svy: logit act i.ageg5yr sex i.ed3 i.race3 hispanic i.marry i.work i.smoke bpcurr cholcurr  heart_dis stroke asthma copd diabetes osteoa ratehealth diffdres diffwalk 

* default is linear prediction, not probability of a positive outcome
mi predict xbbase using temp3, 
su xbbase // temp3.ster is tempi with prbase added
gen prbase=exp(xbbase)/(1+exp(xbbase))
su prbase
bys act:su prbase, de

*mi estimate:svy:tab prbase if act==0
 
*tw kdensity prbase if act==0, lpattern(dash)  lcolor(black) || kdensity prbase if act==1, lcolor(black) ///
	scheme(s1mono) ///
	ytitle("Density") xtitle("Propensity score") ///
	ylabel(,angle(0)) legend(label(1 "BRFSS") label(2 "ACT"))
	
* no longer using mi - only wanted prbase
mi unset
svyset  [pweight=xmmsawt] 
* to check, to get n's
svy: tab ageg5yr act, count format(%9.1f) 
* Odds of being in ACT
gen iowbase=(1-prbase)/prbase 
*## stabilized inverse odds weight is IOW * odds of being in act
gen practbase=5762/431701.1 // numerical probability of being in ACT. denominator is a fraction because it's survey weighted to represent the population >65 in the region. This will be trickier to think about in Rush because I don't think ROS is a subset of MAP.

gen siowbase=iowbase*pract/(1-pract) //stabilized
bys act:su *base

******************************************
*## setting stabilized weights for BRFSS to 1 because they're the target (weighted to themselves)
replace siowbase=1 if act==0 & siowbase<.
su siowbase, de 
******************************************

* winsorize. OK to do without survey wts? Hayes-Larson et al did.
local p1=r(p1) 
local p99=r(p99)
recode siowbase (min/`p1' = `p1') (`p99'/max=`p99'), gen(wsiowbase)
la var iowbase "Inverse Odds ACT, using baseline"
la var siowbase "Stabalized Inverse Odds ACT, baseline"
notes siowbase:set to 1 for BRFSS // *******************************************
la var wsiowbase "Winsorized, Stablized Inverse Odds ACT, using baseline"
egen zwsiowbase=std(wsiowbase) if act==1, mean(1) 	
replace zwsiowbase=wsiowbase if act==0
la var zwsiowbase "Std, Winsorized, Stablized Inverse Odds ACT, using baseline"
* this was the svyodds variable until 231009
gen zsvyodds=xmmsawt*zwsiowbase
la var zsvyodds "Combined BRFSS and std Wins, Stab IO ACT, using baseline"
* they say don't std
notes zsvyodds:xmmsawt*wsiowbase
gen svyodds=xmmsawt*wsiowbase
bys act:su *wsiowbase, de
la var svyodds "Combined BRFSS and Wins, Stab IO ACT, using baseline"
notes svyodds:xmmsawt*wsiowbase
save baseallby, replace

/*## check distributions. the weights represent how similar the rush person is to the US census. so some people are very 
## unlike the population so their weights are close to 0. other people are very similar to lots of US census people so 
## maybe they represent 100 people */

svy, subpop(if act==1):mean *iow* xmmsawt prbase
* just in ACT, no survey wts, to see range
su *iow* prbase, de, if act==1

keep if act==1
keep id *base
save wtbaseby, replace

