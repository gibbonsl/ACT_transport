cd "G:\Laura\ACT transport"

/**** note that using stattransfer directly from the xpt file corrupted the data, maybe because the file was so large? I made a SAS dataset first and then used stattransfer for that (fdause failed because of SAS formatting)
***************************************************************************/

use "G:\Laura\FH2021\studies not used\BRFSS\2019\MMSA2019", clear
keep if _MMSA==42644 /// Seattle-Bellevue-Everett, WA, Metropolitan Division
keep if _AGE65YR ==2 // 3 means missing
ren _* x* // to get all in lower case; keep as x
ren *, lower

* age 80+ is 80 for xage80.
la def age5 10 "65-69" 11 "70-74" 12 "75-79" 13 "80-99"
la val xageg5yr age5
tab1 xageg5yr xage80

la def sex 1 Male 2 Female
la val xsex ximpsex sexvar sex

la def marital 1 Married 2 Divorced 3 Widowed 4 Separated 5 "Never married" 6 "member unmarried couple" .a "Refused or DK"
recode marital xrace (9=.a)
la val marital marital
la def xrace 1 "White, non-Hisp" 2 "Black, non-Hisp" 3 "Am Indian or AL Native, Non-Hisp" 4 "Asian, non-Hisp" 5 "Native HI/PI, Non-Hisp" 6 "Other race, non-Hisp" 7 "Multiracial, non-Hisp" 8 Hispanic .a "Refused or DK"
la val xrace xrace

foreach x in ageg5yr sex {
	rename x`x' `x'
	notes `x':originally _`x'
	}
	
rename xeducag edlevel
notes edlevel: from _educag
recode edlevel (9=.a)
la def ed 1 "< HS" 2 "HS" 3 "college/tech attend" 4 "college/tech grad" .a "DK/unsure/miss"
la val edlevel ed

recode weight2 (7777=.a) (9999=.b)
la def weight2 .a "DK/unsure" .b Refused
la val weight2 weight2
replace weight2=ceil((weight2-9000)*0.4536) if inrange(weight2,9001,9998)
	// If respondent answers in metrics, put 9 in first column.
notes weight2: About how much do you weigh without shoes? Round fractions up
recode height3 (7777=.a) (9999=.b)
la def height3 .a "DK/unsure" .b Refused
la val height3 height3
replace height3=ceil((height3-9000)*0.3937) if inrange(height3,9001,9998)
	// If respondent answers in metrics, put 9 in first column.
notes height3: About how tall are you without shoes? Round fractions down

rename xsmoker smoker
recode smoker (9=.)
la def smoker 1 "Daily" 2 "Current occas." 3 "Former" 4 "Never"
la val smoker smoker	

foreach x in drnkany5 genhlth diffwalk diffdres diffalon xincomg xtotinda hlthpln1 bpmeds cholmed bphigh toldhi2 cvdinfr4 cvdstrk3 chcocncr chccopd2 cvdcrhd4 chckdny2  havarth4  diabete4  {
	recode `x' (7/9=.)
	}

recode employ1 (9=.)	
la def employ1 	1 "Employed for wages" 2 "Self-employed" 3 "Out of work for 1 year or more" 4 "Out of work for less than 1 year" 5 "Homemaker" 6 "Student" 7 Retired 8 "Unable to work"
la val employ1 employ1

recode income2 (77/max=.)
la def income2 1 "< $10,000" 2 "< $15,000" 3 "< $20,000" 4 "< $25,000" 5 "< $35,000"  6 "< $50,000"  7 "< $75,000" 8 ">=$75,000"
la val income2 income2

*QSTLANG - how to import?
sort seq
gen id=_n
save seabrfss2019, replace
