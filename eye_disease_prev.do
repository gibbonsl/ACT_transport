cd "G:\Laura\ACT transport"

*** doesn't need MI except for wts *******************

use wtbaseby, clear	// primary analyses use swiowbase (zswiowbase for sensitivity analyses)
rename id subject

merge 1:m subject using "G:\Paul\Cecilia\eyedxpx220707", keep(3) nogen 
	// 5 people don't have weights.
keep if visit==0

* to get CI

foreach x in dr amd gl cataract {
	proportion `x'todate
	}

	************ not bootstrapped *********************
svyset [pweight=wsiowbase] 

svy: tab drtodate, col // 
svy: tab amdtodate, col // 
svy: tab gltodate, col // 
svy: tab cataracttodate, col // 

