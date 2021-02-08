clear
set more off
use "$rootda\segment_final.dta"

sort gvkey year
merge gvkey year using "$rootda\funda_final.dta"

replace f_emp = 1000*f_emp //f_emp measured in thousands of employees.
drop if f_sales==. & f_emp==. & sales==. & emp==. & exp==. //drop obs with no data
drop if year<1980  //1978 marks beginning of required segment data. 
drop if year>1997  //Due to changed reporting norms.
drop idfirm f_idfirm
egen idfirm = group(gvkey)
gen a = _merge!=3
*Get rid of firms for which segment data is missing in one year even though the 
*firm was still operating and shows up in the annual fundamentals data.
gen c= a==1 & a[_n-1]==0 & a[_n+1]==0 & idfirm==idfirm[_n-1] & idfirm==idfirm[_n+1] 
by idfirm, sort: egen b = total(c)
drop if b>0
drop b c

*Drop firms that are only in one dataset for their entire life.
by idfirm, sort: egen b = total(a)
by idfirm, sort: egen ny = count(year)
drop if b==ny
*drop if b>0 //Drops all firms that have any unmatched data (about 1.5% of firms per year)
drop a b ny

*The remaining unmatched firms are either in only one dataset and can be dropped
*or appear in FUNDA only for a time and then in both from then on.
drop if _merge!=3

*Make the Funda measure for emp the default measure, as employment in the segment
*data is known to sometimes be problematic. Keep segmentsales as default since
*the relation between sales and export sales is very important.
ren emp s_emp
ren f_emp emp

replace exp=0 if exp==. & sales!=.

save "$rootda\final.dta", replace



