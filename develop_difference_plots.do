cd "G:\Laura\ACT transport"

* This code is a bit hacky. I'm sure someone has a better way of doing this.
* I didn't want to spend the time. 

* use MI
use impute40by, clear
merge 1:1 id using baseallby, keepusing(svyodds) nogen
qui foreach x of varlist *ratehealth {
	recode `x' (1/3=1 "Good - Excellent") (4/5=0 "Fair - Poor"),gen(`x'2)
}

*mi svyset [pweight=xmmsawt] // survey only - use for those numbers
mi svyset [pweight=svyodds] // combined

foreach x in sex hispanic bpcurr cholcurr heart_dis stroke asthma copd diabetes cancer osteoa ratehealth2 diffdres diffwalk {
	qui {
	preserve
	mi estimate: svy: mean `x', over(act) 
	local mb=e(b_mi)[1,1]
	local ma=e(b_mi)[1,2]
	local sdb=sqrt((e(V_mi)[1,1])*e(_N)[1,1])
	local d_mi=(`ma'-`mb')/`sdb'
	}
	di in red %7.3f `d_mi' "  `x'"
	restore
}

* Categorical variables
* Coauthors say use level vs all else, not just reference
* Positive value means ACT is greater. We hope for an absolute value <0.10. 

foreach x in ed3 ageg5yr race3 marry work smoke  {
	qui {
	preserve
	levelsof `x', local(i) // to get values
	tokenize `i'
	tab `x' // to generate r(r)
	local m=r(r) // don't understand why I have to make this another macro but I do.
	forvalues j= `1'/``m'' {
		tempvar c
		gen `c'=`x'==`j' if `x'<.
		mi estimate: svy: mean `c', over(act) // local `1' is the base value
		local mb=e(b_mi)[1,1]
		local ma=e(b_mi)[1,2]
		local sdb=sqrt((e(V_mi)[1,1])*e(_N)[1,1])
		local d_mi=(`ma'-`mb')/`sdb'
		noisily di %7.3f `d_mi' ", `x'==`j' vs rest"
		}
		restore
	}
}	
stop

/*Results window looked like this (combined weights)
 -0.016  sex
  0.026  hispanic
 -0.012  bpcurr

 Then I pasted the values into Excel, which is hardly elegant, but straight-forward!
   Excel data looked like this:
   Survey   Combined   Variab  
     .051     -0.016  sex 
    -.072      0.026  hispanic  
    -.131     -0.012  bpcurr 
	
  Next I numbered in "varn" the order I wanted them to occur in the figure:	
   Survey    Combined   varn   Variab  
     .051      -0.016       5   sex  
    -.072       0.026      12   hispanic  
    -.131      -0.012      23   bpcurr  
*/

*  graphing
import excel using "G:\Laura\ACT transport\Output\develop weights by 240212", sheet(Unstd figure 1) clear first

* These labels help, but the figure is hard to read because they had to be fairly short, so I had someone edit in better labels in InDesign.
la def varn 5	"Female" 12	"Hispanic" 23	"Hyperten. med" 24	"Cholesterol med" 25	"Heart disease" 26	"Stroke" 27	"Asthma" 28	"COPD" 29	"Diabetes" 30	"Cancer" 31	"Osteoarthritis" 32	"Good-exc. health" 33	"Diff. dress/bath" 34	"Diff. walk/stairs" 6	"< HS" 7	"HS" 8	"College" 1	"Age 65-69" 2	"Age 70-74" 3	"Age 75-79" 4	"Age 80-99" 9	"White" 10	"Black" 11	"Other" 13	"Never married" 14	"Married/Living" 15	"Sep/Div/Other" 16	"Widowed" 17	"Retired" 18	"Employed" 19	"Other" 20	"Never smoked" 21	"Past smoker" 22	"Current smoker" 
la val varn varn
tab varn

scatter varn Survey, msymbol(Oh) mcolor(black) ///
	|| scatter varn Combined, scheme(s1mono) msymbol(O) mcolor(black) ///
	yscale(reverse) ylabel(1(1)34, angle(0) valuelabel notick labsize(vsmall)) ///
	ytitle("") xtitle("" "Standardized Mean Difference") ///
	xline(-0.1 0 0.1,lpattern(dash)) xlabel(-0.4(0.1)0.4, format(%4.1f) labsize(vsmall)) ///
	legend(label(1 "Survey weights only") label(2 "Combined weights")) legend(size(small)) ///
	ysize(12) xsize(12)

graph export "Figure 1.pdf", replace	


