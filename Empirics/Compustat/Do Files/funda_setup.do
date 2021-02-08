clear
set more off
use "F:\Compustat\funda_orig\funda_orig.dta" 

egen idfirm = group(gvkey)
destring sic, replace
destring naics, replace
gen year = year(datadate)
drop if fic!="USA"
drop if year<1976
gen active = costat=="A"  //Generate variable to indicate if the firm is still active.
drop fyear emp_fn consol popsrc datafmt indfmt costat fic


*Indicate mergers/acquisitions based on the sales footnote.
*See http://web.utk.edu/~prdaves/Computerhelp/COMPUSTAT/Compustat_manuals/user_06.pdf
gen mergacq = 0
local fnotes AA AB AR AS FA FB FC FD FE FF FW
foreach i in `fnotes' {
replace mergacq = 1 if sale_fn =="`i'"
}
drop sale_fn


/*
If there are multiple observations for a plant in one year, replace any missing
data with data from the other observation. Likewise, if one observation indicates
no merger took place and the other does, change the data so that each observation
indicates a merger.
*/
egen id = group(gvkey year)
local vars emp sale
foreach i in `vars' {
	by id, sort: replace `i' = `i'[_n+1] if `i'==. & `i'[_n+1]!=. & id==id[_n+1]
	by id, sort: replace `i' = `i'[_n-1] if `i'==. & `i'[_n-1]!=. & id==id[_n-1]
}
by id, sort: replace mergacq = 1 if mergacq==0 & mergacq[_n+1]==1 & id==id[_n+1]
by id, sort: replace mergacq = 1 if mergacq==0 & mergacq[_n-1]==1 & id==id[_n-1]
duplicates drop gvkey year emp sale mergacq, force


*If data is different for each observation in the year, keep the one with the most recent date.
by id: egen maxdate = max(datadate)
drop if datadate!=maxdate
drop maxdate
drop id 

/*
Some plants had more than one observation with the same datadate and different 
data. For these firms, first replace any missing data with the other observation's
value. Then drop duplicates. There may be a better way to do this.
*/
egen id = group(gvkey datadate)
foreach i in `vars' {
	by id, sort: replace `i' = `i'[_n+1] if `i'==. & `i'[_n+1]!=. & id==id[_n+1]
	by id, sort: replace `i' = `i'[_n-1] if `i'==. & `i'[_n-1]!=. & id==id[_n-1]
	by id, sort: replace `i' = `i'[_n+1] if `i'==0 & `i'[_n+1]!=0 & id==id[_n+1]
	by id, sort: replace `i' = `i'[_n-1] if `i'==0 & `i'[_n-1]!=0 & id==id[_n-1]
}
duplicates drop gvkey year, force
drop id datadate

*Drop firms if there are less than __ observations
by idfirm, sort: egen numyear = count(year)
drop if numyear < 3
drop numyear

*Drop firms that report negative sales or employment
gen neg = sale<0 | emp<0
by idfirm, sort: egen nega = total(neg)
drop if nega>0
drop neg nega

*Rename variables so that when merged, we can tell them apart.
ren emp f_emp
ren sale f_sales
ren sic f_sic
ren naics f_naics
ren idfirm f_idfirm
ren conm f_conm

sort gvkey year


save "$rootda\funda_final.dta", replace
