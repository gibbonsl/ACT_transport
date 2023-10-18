cd "G:\Laura\ACT transport"

use baseallby, clear 
* only survey wts
svyset  [pweight=xmmsawt] 

* to check, to get n's
svy: tab ageg5yr act, count format(%9.1f) 

* format for table
rename ageg5yr Age
rename sex Sex
rename ed3 Education
rename race3 Race
replace Ed=9 if Ed==.
la def Ed 1 "Less than HS" 2 "HS degree" 3 "College or higher" 9 "Unknown"
la val Ed Ed
recode Race (.=9)
la def Race 1 "White" 2 "Black" 3 "Other" 9 Unknown
la val Race Race 

recode marry (.=2)
tab1 Age Sex Ed Race marry, mi
la var Age "Age"
la var Sex "Sex"
la var Ed "Education"
la var Race "Race"
la var hispanic "Hispanic"

* health etc
recode ratehealth (1/3=1 "Good - Excellent") (4/5=0 "Fair - Poor") (.=9 Unknown),gen(rate2)
la var rate2 "Self-perceived general health"
la var bpcurr "Current hypertension medication"
la var cholcurr "Current cholesterol medication"
la var smoke "Smoker"
la var mi "Myocardial infarction" // dropped because heart_dis. Could keep instead of MI.
la var heart_dis "Any heart disease"
la var stroke "Stroke"
la var asthma "Asthma"
la var cancer "Non-melanoma cancer"
la var copd "COPD or emphysema"
*la var kidneydis "Kidney Disease"
la var diabetes "Diabetes"
la var osteoa "Osteoarthritis"
la var diffdres "Any difficulty dressing or bathing"
la var diffwalk "Any difficulty walking or climbing stairs"

foreach x in work smoke {
	replace `x'=9 if `x'>=.
}
la def w 1 Employed 2 Other 0 Retired 9 Unknown
la val work w
la def sm 0 Never 1 Past 2 Current 9 Unknown
la val smoke sm

la def miss9 0 No 1 Yes 9 Unknown
foreach x in hispanic bpcurr cholcurr heart_dis stroke asthma copd /*kidneydis*/ diabetes cancer osteoa diffdres diffwalk {
	replace `x'=9 if `x'>=.
	la val `x' miss9
}
* could have used "la def, add (or modify)
*. label copy yesno yesnomaybe
*. label define yesnomaybe 3 "Maybe", add

**# Put to excel

/* Use this section of code instead of lines 81-88 for survey wts only tab

svyset  [pweight=xmmsawt] 
svy: tab Sex act, count format(%9.1f) // to get ACT n with these wts.

global act=5762 
global brfss=431701.1
global tot=$act+$brfss
putexcel set "G:\Laura\ACT transport\Output\develop weights by 230208.xlsx", sheet(survey weights only) modify
putexcel A1="Survey Weights only"
*/

* combined

svyset  [pweight=svyodds] 
svy: tab Sex act, count format(%9.1f) // to get ACT n with these wts.
global act=6134.6 // with unstandardized weights. See check weights by 230208 for std
global brfss=431701.1
global tot=$act+$brfss

putexcel set "G:\Laura\ACT transport\Output\develop weights by 231009.xlsx", sheet(Survey and odds wts) modify
putexcel A1="Survey and odds wts"
 
putexcel A2="Be sure and update N's if needed."
putexcel A3="p-values are for non-missing values"
putexcel B6="BRFSS", hcenter
putexcel D6="ACT", hcenter
putexcel F6="Total", hcenter
putexcel B7="n=$brfss", hcenter
putexcel D7="n=$act", hcenter
putexcel F7="n=$tot", hcenter
putexcel C7="Percent", right
putexcel E7="Percent", right
putexcel G7="Percent", right
putexcel H7="P-value", right
putexcel A6:H6, border(top) 
putexcel A7:H7, border(bottom)
local i=8
qui foreach x in Age Sex Education Race hispanic marry work smoke bpcurr cholcurr heart_dis stroke asthma copd diabetes cancer osteoa rate2 diffdres diffwalk {
	local j=`i'+1
	qui svy: tab `x' act, /*ci*/ count format(%9.1f) // miss
		matrix A=e(N_pop)*e(Prop) // this gets the cell counts.
		putexcel A`j' = matrix(A), rownames right 
		putexcel C`j' = matrix(A), right 
		loc varlab: var l `x'
		putexcel A`i'="`varlab'", left 
		* p values for nonmissing
		preserve
		recode `x' (9=.)
		qui svy: tab `x' act, /*ci*/ count format(%9.1f) 
		restore
		local p=e(p_Pear)
		putexcel H`i'=`p'
	qui levelsof `x'
	local i=`j'+r(r)
	local k=`i'-1
	local m= r(levels)
	local c=`j'
	foreach l in `m' {
		local lab : label (`x') `l'
		*di in red "`lab'"
		putexcel A`c'="`lab'"
		local c=`c' + 1
		}
	forvalues r=`j'/`k' {
		putexcel C`r'=formula(B`r'/$brfss)
		putexcel E`r'=formula(D`r'/$act)
		putexcel F`r'=formula(=sum(B`r',D`r')) 
		putexcel G`r'=formula(F`r'/$tot)
		}
	}
