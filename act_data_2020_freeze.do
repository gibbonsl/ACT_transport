cd "G:\Laura\ACT transport"

use "G:\Paul\ACT\ACT data 2020 freeze\frz2020_biennial_analysis_220511.dta", clear
ren *, lower
rename id subject
keep subject visit visitdt birthdt deathdt age sex marital htnmed cholmed mi angina stroke asthma cancer copd kidneydis diabetes osteoa smoke alcohol ratehealth adl_bath adl_dress stairs halfmil adl_walk exercise income heart_dis race4c hispanic degree education diabetes_yr cohort

merge 1:1 subject visit using "G:\Paul\ACT\ACT data Sept 2018 freeze\Form data\frm78", nogen keepusing(EP1)

merge 1:1 subject visit using "G:\Paul\ACT\ACT data Sept 2018 freeze\Form data\frm73", nogen keepusing(MEM7)
ren *, lower
recode degree (0 9=1 "<HS") (1/2=2 HS) (3/5=3 "Bach +") (6=.), gen(ed3) // fix 6 below
replace ed3=1 if ed3==. & education<12
replace ed3=2 if ed3==. & inrange(education,12,15)
replace ed3=3 if ed3==. & inrange(education,16,21)
notes ed3: ACT degree=9 all have 8 years of education so I put in < HS. "Other" I based on years, my best guess

recode age (65/69=10) (70/74=11) (75/79=12) (80/99=13), gen(ageg5yr)
gen xmmsawt=1
gen act=1
drop if age>99
notes: 35 ACT people with age >=100 dropped for positivity with BRFSS
recode htnmed (2=0 No) (1=1 "Yes"), gen(bpcurr)
recode cholmed (2=0 No) (1=1 "Yes"), gen(cholcurr)
recode ep1 (9=.)

la def employ 1 Employed 2 Homemaker 3 Retired 4 "Disabled, unable" 5 "Seeking work" 6 "Unempl, not seeking"
la val ep1 employ

bys subj (visit):gen lastvisit=_n==_N
save actdata2020, replace
