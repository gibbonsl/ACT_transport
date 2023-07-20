cd "G:\Laura\ACT transport"

use actdata211223, clear

append using seabrfss2019
replace act=0 if act==.
replace id=subject if id==.

replace ed3=1 if edlevel==1
replace ed3=2 if edlevel==2 | edlevel==3
replace ed3=3 if edlevel==4

replace bpcurr=1 if bpcurr==. & bpmed==1
replace bpcurr=0 if bpcurr==. & bpmed==2
replace bpcurr=0 if bpcurr==. & inlist(bphigh,2,3,4)
replace cholcurr=1 if cholcurr==. & cholmed2==1
replace cholcurr=0 if cholcurr==. & cholmed2==2
replace cholcurr=0 if cholcurr==. & inlist(toldhi,2)
replace mi=0 if cvdinfr4==2
replace mi=1 if cvdinfr4==1
replace stroke=0 if cvdstrk3==2
replace stroke=1 if cvdstrk3==1
replace asthma=0 if asthma3==2
replace asthma=1 if asthma3==1
replace cancer=0 if chcocncr==2
replace cancer=1 if chcocncr==1
replace copd=0 if chccopd2==2
replace copd=1 if chccopd2==1
replace kidney=0 if chckdny2==2
replace kidney=1 if chckdny2==1
replace osteoa=0 if havarth4==2
replace osteoa=1 if havarth4==1
replace diabetes=1 if diabete4==1
replace diabetes=0 if inlist(diabete4,2,3,4)
notes diabetes: BRFSS n=34 prediab==no, 1 gestational only = no.
replace smoke=0 if smoker==4
replace smoke=1 if smoker==3
replace smoke=2 if smoker==1 | smoker==2
replace heart_dis=1 if cvdcrhd4==1
replace heart_dis=0 if cvdcrhd4==2

recode ep1 (2 4 5 6=2 Other), gen(w) 
replace w=1 if inlist(employ1,1,2)
replace w=3 if inlist(employ1,7)
replace w=2 if inlist(employ1,3,4,5,6,8)
recode w (3=0 "Retired"), gen(work)
drop w

tab ep1 work
tab employ1 work
recode diff* (2=0)
replace diffdres=1 if inlist(adl_bath,2,3,4) | inlist(adl_dress,2,3,4)
replace diffdres=0 if inlist(adl_bath,0,1) & inlist(adl_dress,0,1)
replace diffwalk=1 if inlist(stairs,2,3,4) | inlist(adl_walk,2,3,4) | inlist(half,2,3,4)
replace diffwalk=0 if inlist(stairs,0,1) & inlist(adl_walk,0,1) & inlist(half,0,1)

replace ratehealth=genhlth if ratehealth==.
la val ageg5yr age5
la val sex sex
la var ageg5yr "Age, 4 cat, as in BRFSS"
la var ed3 "Educ, 3 levels"
notes ed3: from _educag (B) and degree (A)
la var bpcurr "On HTN meds"
la var cholcurr "On cholestorol meds"
capture la def noyes 0 No 1 Yes
la val heart_dis mi stroke asthma cancer copd kidneydis diabetes osteoa diffdres diffwalk noyes
la def smoke 0 Never 1 Past 2 Current
la val smoke smoke
la var work "Employment status"
la drop work
la def work 1 Employed 2 Other 0 Retired 
la val work work
notes diffdres: from adl_bath and adl_dress in ACT
notes diffwalk: from stairs, adl_walk, and half in ACT

* align marital, both called marital
gen marry=marital if act==1
replace marry=0 if inlist(marital,5) & act==0
replace marry=1 if inlist(marital,1,6) & act==0
replace marry=2 if inlist(marital,2,4) & act==0
replace marry=3 if inlist(marital,3) & act==0
replace marry=2 if marry==4 // could put with 0 or 3 instead
la def marry 0 "Never Married" 1 "Married/Living" 2 "Separated/Div/Other" 3  Widowed 
la val marry marry 
la var marry "Marital status"

gen raceth=xrace
replace raceth=8 if hisp==1
replace raceth=1 if (race==1 & hisp==0)
replace raceth=2 if (race==2 & hisp==0)
replace raceth=3 if (race==4 & hisp==0)
replace raceth=4 if (race==3 & hisp==0)
replace raceth=5 if (race==5 & hisp==0)
replace raceth=6 if (race==6 & hisp==0)
replace raceth=6 if xrace==7
replace raceth=.a if raceth==.
la val raceth xrace
recode raceth (3/7=3) (8=4), gen(race4)
la def race4  1 "White, non-Hisp" 2 "Black, non-Hisp" 3 "Other, non-Hisp" 4 Hispanic .a "Refused or DK"
la val race4 race4
la var race4 "Race/ethnicity"
replace hispanic=1 if xhispan==1
replace hispanic=0 if xhispan==2

recode xmrace1 (3/7=3) (77 99 =.), gen(race3)
replace race3=1 if race==1
replace race3=2 if race==2
replace race3=3 if inrange(race,3,6)
la def race3  1 "White" 2 "Black" 3 "Other"
la val race3 race3
la var race3 "Race W/B/O"

la def act 0 BRFSS 1 ACT
la val act act
la var act "Cohort"
save combined211223, replace

