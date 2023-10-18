cd "G:\Laura\ACT transport"

*** doesn't need MI except for wts *******************

use wtbaseby, clear	// primary analyses use swiowbase (zswiowbase for sensitivity analyses)
rename id subject

merge 1:m subject using "G:\Paul\Cecilia\eyedxpx220707", keep(3) nogen 
	// 5 people don't have weights.
keep if visit==0
recode age (65/69=1 "65-69") (70/74=2 "70-74") (75/79=3 "75-79") (80/max=4 "80-99"), gen(ageg5yr)

tab1 gltodate amdtodate drtodate cataracttodate // 9.2, 9.5, 4.1, 48.6
tab ageg5yr
tab gltodate ageg5y, col // 
tab amdtodate ageg5y, col // 
tab drtodate ageg5y, col // 
tab cataracttodate ageg5y, col // 34 45 58 65

* to get CI
foreach x in dr amd gl cataract {
	proportion `x'todate, over(ageg5yr)
	}

foreach x in dr amd gl cataract {
	proportion `x'todate
	}

	************ not bootstrapped *********************
svyset [pweight=wsiowbase] 
svy: tab ageg5yr, count format(%9.1f) 

svy: tab drtodate ageg5yr, col // 
svy: tab amdtodate ageg5yr, col // 
svy: tab gltodate ageg5yr, col // 
svy: tab cataracttodate ageg5yr, col // 

