cd "D:\Dropbox (Phil Research)\Research Assistant\Exportintensity - RA\Compustat\Carter\Data" 
/*use "$rootda\final.dta", clear*/
use "final.dta", clear

/* Focus on Manufacturing*/
drop if sic<2000|sic>3999

/* Eliminate Duplicates - some countries report consolidated results - for panel results we need to be careful how we do this*/
duplicates drop sales domsales year, force
drop idfirm
egen idfirm = group(gvkey)
xtset idfirm year
gen exs = exp/sales

gen chgexs = exs-l.exs
qui sum chgexs
local dev = 3*r(sd)
gen flagup = (exs-l.exs>`dev' & exs-l.exs!=.) & (exs-f.exs>`dev' & exs-f.exs!=.)
gen flagdown = (l.exs-exs>`dev' & l.exs-exs!=.) & (f.exs-exs>`dev' & f.exs-exs!=.)

gen exporter = exs >= 0.0001
replace exporter = . if exs == .
gen entrant = exporter==1 & l.exporter==0
replace entrant = . if exs==.
replace entrant = . if l.exporter==. & exporter==1
replace entrant = . if year==1980
gen exiter = exporter==1 & f.exporter==0
replace exiter = . if exs == .
replace exiter = . if f.exporter==. & exporter==1
replace exiter = . if year==2014
gen startstop = exiter==1 & entrant==1
replace startstop=. if exs==.
gen lnemp = ln(emp)

gen newfirm = l.exs==. & year>1995
replace newfirm = . if year==1995
gen exitfirm = f.exs==. & year <2007
replace exitfirm = . if year==2007

egen totalexp = total(exp), by(year)
egen entexp = total(exp) if entrant==1, by(year)
gen startshare = entexp/totalexp
drop entexp
egen exexp = total(exp) if exiter==1, by(year)
gen stopshare = exexp/totalexp
drop exexp
egen totalsales = total(sales), by(year)
gen exptosales = totalexp/totalsales
egen expsales = total(domsales) if exporter==1, by(year)
gen expintensity = totalexp/expsales
egen participation = mean(exporter), by(year)
egen no_plants = count(idfirm), by(year)
egen totalemp = total(emp), by(year)
egen newemp = total(emp) if newfirm==1, by(year)
egen exitemp = total(emp) if exitfirm==1, by(year)
gen newempshare = newemp/totalemp
gen exitempshare = exitemp/totalemp
tabstat no_plants participation exptosales expintensity entrant exiter startshare stopshare newfirm exitfirm newempshare exitempshare if exporter==1, by(year) format(%9.3g)
latabstat no_plants participation exptosales expintensity entrant exiter startshare stopshare newfirm exitfirm newempshare exitempshare if exporter==1, by(year) format(%9.3g)
qui drop totalexp startshare stopshare totalsales exptosales expsales expintensity participation no_plants totalemp newemp exitemp newempshare exitempshare



