cd "G:\Laura\ACT transport"

use impute40by, clear	// want zswiowbase
rename id subject
mi unregister mi // confusing because the variable is "mi"
drop *mi // not used, problematic
qui forvalues i=1/40 {
	preserve
	tempfile t`i'
	gen i=`i'
	foreach x in ed3 race3 hispanic marry work smoke bpcurr cholcurr heart_dis stroke asthma copd diabetes cancer osteoa ratehealth diffdres diffwalk  {
		drop `x'
		rename _`i'_`x' `x'
		mi unregister `x'
	}
	save `t`i'', replace
	su _*
	restore
}

use `t1', clear
qui forvalues i=2/40 {
append using `t`i''
}

mi unset
drop mi_miss
save all40, replace 

use "G:\Paul\Cecilia\eyedxpx220707", clear
keep if visit==0
keep subject age visit gltodate amdtodate drtodate cataracttodate
merge 1:m subject using all40, nogen keep(2 3)
save prev40, replace

qui forvalues i=1/40 {
use all40, clear
	keep if i==`i'
	merge 1:m subject using G:\Paul\Cecilia\eyedxpx220707, keep(1 3) nogen keepusing(subject surv_age age age_bl anydem educ white smoke apoe gender visit glyrcat amdyrcat dryrcat cataractyrcat gltodate amdtodate drtodate cataracttodate)
save "G:\Laura\ACT transport\for_boot\long`i'", replace 
} 

*** make sure to run this ********************
	capture program drop cleareclass
	program cleareclass, eclass // needed for some reason
		ereturn clear
	end

*** guts of the program
	capture program drop wp
	program define wp, rclass
	syntax [if], // this [if] is needed for the jackknife for bca

	preserve
	svyset [pweight=xmmsawt] 
	svy: logit act i.ageg5yr sex i.ed3 i.race3 hispanic i.marry i.work i.smoke bpcurr cholcurr  heart_dis stroke asthma copd diabetes cancer osteoa ratehealth diffdres diffwalk sex##i.work sex##i.smoke sex##i.osteoa sex##i.diffwalk i.ed3#sex i.ed3##i.race3 i.marry##i.ageg i.marry##i.ed3 i.marry##i.race3 i.ed3#cholcurr c.ratehealth##i.ageg c.ratehealth##sex c.ratehealth##i.ed3 c.ratehealth##i.race3 if visit==0 | act==0
	* now default is probability of a positive outcome since not mi
	predict prbase if e(sample)
	gen iowbase=(1-prbase)/prbase 
	*## stabilized inverse odds weight is IOW * odds of being in act
	gen siowbase=iowbase*0.0133472/(1-0.0133472) //stabilized. 0.0133472 is the probability of being in ACT
	*## setting stabilized weights for HRS to 1 because they're the target (weighted to themselves)
	replace siowbase=1 if act==0 & siowbase<.
	su siowbase, de 
	local p1=r(p1) 
	local p99=r(p99)
	recode siowbase (min/`p1' = `p1') (`p99'/max=`p99'), gen(wsiowbase)
	la var wsiowbase "Winsorized, Stablized Inverse Odds ACT, using baseline"
	bys subj (visit): replace wsiowbase=wsiowbase[_n-1] if wsiowbase==.
	
	* dementia
	stset surv_age [pweight=wsiowbase] 	if act==1, failure(anydem) origin(time 0) enter(age_bl) id(subj)
	stcox i.dryrcat age_bl educ white i.smoke if act==1, nolog strata(apoe gender) nohr
		return scalar bdr11=_b[1.dryrcat] 
		return scalar bdr12=_b[2.dryrcat]
	
	stcox i.amdyrcat age_bl educ white i.smoke if act==1, nolog strata(apoe gender) nohr
		return scalar bamd11=_b[1.amdyrcat]
		return scalar bamd12=_b[2.amdyrcat] 
	
	* prevalence	
	svyset [pweight=wsiowbase]
	foreach e in gl amd dr cataract {
		svy: tab `e'todate ageg5yr if act==1 & visit==0, col 
		return scalar `e'11=e(b)[1,1]
		return scalar `e'12=e(b)[1,2]
		return scalar `e'13=e(b)[1,3]
		return scalar `e'14=e(b)[1,4]
		return scalar `e'21=e(b)[1,5]
		return scalar `e'22=e(b)[1,6]
		return scalar `e'23=e(b)[1,7]
		return scalar `e'24=e(b)[1,8]
	}

	cleareclass
	end
	
display "$S_TIME  $S_DATE"

* first 5 imputed datasets were run in separate files. 
* set seed 13109874 for first file 
* set seed 12938471 for 2 and 3
* set seed 1572893 for 4 and 5
* set seed 12309487 // for j=6
* set seed 23409875 // for j=7-17
set seed 19874 // 18 to 40

forvalues j=18/40 {	
	// done similarly for the first 17 datasets, but with the starred out seeds
use "G:\Laura\ACT transport\for_boot\long`j'", clear 
bootstrap  ///
		gl11=r(gl11) gl12=r(gl12) gl13=r(gl13) gl14=r(gl14)	gl21=r(gl21) gl22=r(gl22) gl23=r(gl23) gl24=r(gl24) ///
		amd11=r(amd11) amd12=r(amd12) amd13=r(amd13) amd14=r(amd14)	///
		amd21=r(amd21) amd22=r(amd22) amd23=r(amd23) amd24=r(amd24) ///
		dr11=r(dr11) dr12=r(dr12) dr13=r(dr13) dr14=r(dr14)	dr21=r(dr21) dr22=r(dr22) dr23=r(dr23) dr24=r(dr24) ///
		cataract11=r(cataract11) cataract12=r(cataract12) cataract13=r(cataract13) cataract14=r(cataract14) ///
		cataract21=r(cataract21) cataract22=r(cataract22) cataract23=r(cataract23) cataract24=r(cataract24)  ///
		bamd11=r(bamd11) bamd12=r(bamd12) bdr11=r(bdr11) bdr12=r(bdr12) 	 ///
		, reps(500) saving("combboot`j'",replace) nowarn:wp
}

display "$S_TIME  $S_DATE"

forvalues j=1/40 {	
	use "G:\Laura\ACT transport\for_boot\combboot`j'", clear
	gen i=`j'
	save "G:\Laura\ACT transport\for_boot\combboot`j'", replace
	}

use "G:\Laura\ACT transport\for_boot\combboot1", clear
forvalues j=2/40 {	
	append using "G:\Laura\ACT transport\for_boot\combboot`j'"
	}

* then convert to the numbers I actually want and take percentiles.
foreach e in gl amd dr cataract {
	gen `e'65=`e'21/(`e'11+`e'21)
	gen `e'70=`e'22/(`e'12+`e'22)
	gen `e'75=`e'23/(`e'13+`e'23)
	gen `e'80=`e'24/(`e'14+`e'24)
	gen `e't=(`e'21+`e'22+`e'23+`e'24)
}

save "G:\Laura\ACT transport\for_boot\combboot_all", replace

* these list out the bootstrapped CI for Tables 3 and 4 
foreach e in gl amd dr cataract {
	foreach x in 65 70 75 80 t {
		_pctile `e'`x', percentiles(2.5,97.5)
		di ""
		di ""
		di in red "`e'`x'" 
		return list // r1 is 2.5%, r2 is 97.5%
		}
	}

foreach e in bdr11 bdr12 bamd11 bamd12 {
		_pctile `e', percentiles(2.5,97.5)
		di ""
		di ""
		di in red "`e'" 
		qui return list // r1 is 2.5%, r2 is 97.5%
		di exp(r(r1)) "    " exp(r(r2))
	}

