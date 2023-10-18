cd "G:\Laura\ACT transport"
* this is only for baseline weights. Weights over time are more involved. 

use impute40by, clear
*gen xx=round(xmmsawt) // for roc

mi svyset [pweight=xmmsawt] 
mi estimate, saving(temp3, replace): svy: logit act i.ageg5yr sex i.ed3 i.race3 hispanic i.marry i.work i.smoke bpcurr cholcurr mi heart_dis stroke asthma copd diabetes cancer osteoa ratehealth diffdres diffwalk sex##i.work sex##i.smoke sex##i.osteoa sex##i.diffwalk i.ed3#sex i.ed3##i.race3 i.marry##i.ageg i.marry##i.ed3 i.marry##i.race3 i.ed3#cholcurr c.ratehealth##i.ageg c.ratehealth##sex c.ratehealth##i.ed3 c.ratehealth##i.race3

* default is linear prediction, not probability of a positive outcome
mi predict xbbase using temp3, 
su xbbase // temp3.ster is tempi with prbase added
gen prbase=exp(xbbase)/(1+exp(xbbase))
su prbase
bys act:su prbase, de
 
* Figure
tw kdensity prbase if act==0, lpattern(dash)  lcolor(black) || kdensity prbase if act==1, lcolor(black) ///
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
* stabilized inverse odds weight is IOW * odds of being in act
gen practbase=5762/431701.1 // numerical probability of being in ACT. denominator is a fraction because it's survey weighted to represent the population >65 in the region. 

gen siowbase=iowbase*pract/(1-pract) //stabilized
bys act:su *base

******************************************
*## setting stabilized weights for HRS to 1 because they're the target (weighted to themselves)
replace siowbase=1 if act==0 & siowbase<.
su siowbase, de 
******************************************

* Winsorize. OK to do without survey wts?  Hayes-Larson did it this way.
recode siowbase (min/0.0015828 = 0.0015828) (6.691905/max=6.691905), gen(wsiowbase)
	// could have automated obtaining the first and 99th percentiles.
la var iowbase "Inverse Odds ACT, using baseline"
la var siowbase "Stabalized Inverse Odds ACT, baseline"
notes siowbase:set to 1 for BRFSS // *******************************************
la var wsiowbase "Winsorized, Stablized Inverse Odds ACT, using baseline"
notes wsiowbase: This is the weight for the primary analyses.

* These standardized weights are used in sensitivity analyses
egen zwsiowbase=std(wsiowbase) if act==1, mean(1) 	
replace zwsiowbase=wsiowbase if act==0
la var zwsiowbase "Std, Winsorized, Stablized Inverse Odds ACT, using baseline"
* this was the svyodds variable until 231009
gen zsvyodds=xmmsawt*zwsiowbase
la var zsvyodds "Combined BRFSS and std Wins, Stab IO ACT, using baseline"
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

