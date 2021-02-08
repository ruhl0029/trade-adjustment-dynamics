clear
set more off
use "F:\Compustat\segment_orig\segment_orig.dta" 

/*
This do file follows closely what Ana did. 
*/

destring sic, replace
destring geotp, replace
destring naics, replace
drop if geotp==. | geotp==1
drop stype
drop if sid == 99  //These are intersegment operations
egen idfirm = group(gvkey)
gen year = year(datadate)

/*
If there are multiple observations within a year, fill missing data with the 
other observation and then drop duplicates.
*/
egen id = group(gvkey geotp sid year)
local vars emps sales salexg
foreach i in `vars' {
	by id, sort: replace `i' = `i'[_n+1] if `i'==. & `i'[_n+1]!=. & id==id[_n+1]
	by id, sort: replace `i' = `i'[_n-1] if `i'==. & `i'[_n-1]!=. & id==id[_n-1]
}
duplicates drop gvkey geotp sid year emps sales salexg, force

/*
Keep only the most recent report.
*/
gen month = month(datadate)
by id: egen maxmonth = max(month)
drop if month!=maxmonth
drop month maxmonth
drop id

//Some observation were wrongly classified as geotp 2 even though U.S. was specified.
replace geotp = 2 if geotp==3 & snms == "United States"


*Create aggregate variables
egen id = group(gvkey geotp year)
local vars emps sales salexg
foreach i in `vars' {
	by id, sort: egen agg`i' = sum(`i')
	by id, sort: replace `i' = agg`i'
	replace `i'=. if `i'==0
	drop agg`i'
}
duplicates drop gvkey geotp year id, force
drop id snms sid datadate srcdate
*Now there are two observations for each firm-year. One for geotp==2 and one for geotp==3.

save "$rootda\segment_clean.dta", replace

use "$rootda\segment_clean.dta", clear

*reshape as panel data. There should now be one observation for each firm-year.
reshape wide emps sales salexg, i(idfirm gvkey year) j(geotp)

save "$rootda\segment_wide.dta", replace

use "$rootda\segment_wide.dta", clear

*Drop firms if there are less than __ observations
by idfirm, sort: egen numyear = count(year)
drop if numyear < 3
drop numyear

*Drop firms that report negative sales in either market
gen neg = sales2<0 | sales3<0 | salexg2<0 | salexg3<0
by idfirm, sort: egen nega = total(neg)
drop if nega>0
drop neg nega

*Generate needed variables
gen domsales = sales2
egen sales = rowtotal(sales2 sales3)
replace sales=. if sales==0
egen exp = rowtotal(salexg2 salexg3)
replace exp=. if exp==0
egen emp = rowtotal(emps2 emps3)
replace emp=. if emp==0

drop emps2 sales2 salexg2 emps3 sales3 salexg3 

save "$rootda\segment_final.dta", replace





