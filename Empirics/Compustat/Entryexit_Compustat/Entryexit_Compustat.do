clear

/*use "F:\Compustat\Data\final.dta",clear
cd "F:\Compustat\Data"*/

use "D:\Dropbox\Exporting Papers\Trade-Growth-LRSR\Accepted Submission\Empirics\Compustat\Data\Compustat_final.dta",clear
cd "D:\Dropbox\Exporting Papers\Trade-Growth-LRSR\Accepted Submission\Empirics\Compustat\Entryexit_Compustat"

set more off
set matsize 600
version 13
//Generate all needed variables
ren idfirm firm
ren exp exports
ren sic ind
xtset firm year
gen exs = exports/sales
gen lnemp = ln(emp)

drop if ind<2000
drop if ind>=4000
 
gen chgexs = exs-l.exs
qui sum chgexs
local dev = 3*r(sd)
gen flagup = (exs-l.exs>`dev' & exs-l.exs!=.) & (exs-f.exs>`dev' & exs-f.exs!=.)
gen flagdown = (l.exs-exs>`dev' & l.exs-exs!=.) & (f.exs-exs>`dev' & exs-f.exs!=.)
*replace exs = 0.5*(l.exs+f.exs) if flagup==1 | flagdown==1

replace exs = 1 if exs>1 & exs!=.
gen exporter = exs >= 0.0001
replace exporter = . if exs == .

gen starter = exporter==1 & l.exporter==0
replace starter = . if exs==.
replace starter = . if l.exporter==. & exporter==1
replace starter = . if year==1980

gen stopper = exporter==1 & f.exporter==0
replace stopper = . if exs == .
replace stopper = . if f.exporter==. & exporter==1
replace stopper = . if year==1997


*Firms that enter and exit in the same period
gen starterstopper = stopper==1 & starter==1
replace starterstopper=. if exs==.

*Firms that leave foreign market for only one period
gen stopperstarter = 0
replace stopperstarter=1 if l.exporter==1 & exporter==0 & f.exporter==1

*Firms that export in their final year
gen final    = 0
replace final=1 if exporter==1 & f.exporter==.
egen final2= max(final), by(firm)

*Firms that export in their initial year
gen initial = 0
replace initial = 1 if exporter==1 & l.exporter==.
egen initial2 = max(initial), by(firm)

*Firms that exported 2 years ago but not one  year ago
gen last2 =.
replace last2 =0 if l2.exporter==0
replace last2 =0 if l2.exporter==1 & l.exporter==1
replace last2 =1 if l.exporter==0 & l2.exporter==1

*Firms that are exporting at the beginning of the panel
local start 1984
local end 1992
local country Compustat
keep if year>=`start' & year<=`end'
gen initialexporter=0
replace initialexporter=1 if exporter==1 & year==`start'
egen Xin = total(initialexporter), by(firm)
gen temp =1
egen obs = total(temp), by(firm)
*These help to identify small and volatile firms
egen minsales = min(sales), by(firm)
egen sdemp = sd(lnemp), by(firm)
egen minemp = min(emp), by(firm)
egen avgemp = mean(emp), by(firm)

gen falseexit = 0
replace falseexit =1 if l.exs>0.5 & l.exs<=1 & exs==0 & f.exs>0.5 & f.exs<=1
/*replace exs =1/2*(l.exs +f.exs) if falseexit==1*/
gen falsestart = 0
replace falsestart=1 if l.exs==0 & exs>0.5 & exs<=1 & f.exs==0
/*replace exs =1/2*(l.exs +f.exs) if falseexit==1*/

ren firm plant

putexcel A2=("Unbalanced") A3 = ("Unbalanced (Starters)") A4=("Balanced") A5=("Balanced volatile") B1=("Final Part") C1 = ("Final Exports") D1=("Annual Part.") E1 = ("Annual Exports") F1=("Marginal Discount") G1 = ("exs1/exs") H1=("rhoexs") I1=("Yr avg") J1=("exs20/exs") K1=("Export Prob") L1 = ("Start") M1 = ("Last2") using `country', modify


foreach panel of num 1 2 3 {
/*qui drop if avgemp>20000*/
preserve
if `panel'==2 { 
qui keep if obs==9
}
if `panel'==3 {
qui keep if obs==9
/* Drop small and noisy firms*/
qui drop if minsales==0
qui drop if minemp==0
qui drop if avgemp<20
}

/* PART 1 - Summarize the whole dataset*/
qui gen lfalseexit = l.falseexit
qui egen Texp = total(exports), by(year)
qui egen Sexp = total(exports) if starter==1, by(year)
qui egen Startsum = mean(Sexp), by(year)
qui drop Sexp
qui egen Sexp = total(exports) if stopper==1, by(year)
qui egen Stopsum = mean(Sexp), by(year)
qui drop Sexp
qui egen Tsales= total(sales), by(year)
qui gen Esales = Texp/Tsales
qui egen Expsales= total(sales) if exporter==1, by(year)
qui gen Eintensity = Texp/Expsales
qui gen stopshare = Stopsum/ Texp
qui gen startshare = Startsum/ Texp
qui egen Part = mean(exporter), by(year)
qui egen Nplants = count(plant), by(year)
qui egen N0 	=sum(exporter) if exporter==1 & Xin==1, by(year)
qui egen Nx 	= sum(exporter), by(year)
qui gen  Npart 		= N0/Nx
qui egen exports0 =sum(exports) if exporter==1 & Xin==1, by(year)
qui gen  eshare0t = exports0/Texp
qui format eshare0t Npart %9.3f
tabstat Nplants Part Esales Eintensity starter stopper startshare stopshare Npart eshare0t lfalseexit falsestart if exporter==1, by(year) format(%9.3g)

/* Compute Exporter Churn Statistics */
keep if year>=`start' & year<=`end' & falseexit==0
qui gen NpSS = 1-Npart
qui gen eshareSS = 1 - eshare0t
qui egen Nstart = mean(starter) if exporter==1, by(year)
qui egen Nstop = mean(stopper) if exporter==1, by(year)
qui egen Nstartstop = mean(starterstopper) if exporter==1, by(year)
*qui gen NpSSA = (Nstart+Nstop-Nstartstop)/2*
qui gen NpSSA = (Nstart+Nstop)/2
qui egen Sexp = total(exports) if starterstopper==1, by(year)
qui egen Startstopsum = mean(Sexp), by(year)
*qui gen eshareSSA = 0.5*(Startsum+Stopsum-Startstopsum)/Texp*
qui gen eshareSSA = 0.5*(Startsum+Stopsum)/Texp
qui format eshareSS NpSS eshareSSA NpSSA %9.3f

if `panel'==1 {
	qui gen NpSA = Nstart
	qui format NpSA %9.3f
	qui sum NpSS if year==`end'
	putexcel B2=(`: di %9.1f 100*r(mean)') B3 = (`: di %9.1f 100*r(mean)') using `country', modify
	qui sum eshareSS if year==`end', f
	putexcel C2=(`: di %9.1f 100*r(mean)') C3 = (`: di %9.1f 100*r(mean)') using `country', modify
	qui sum NpSSA, f
	putexcel D2 =(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum eshareSSA, f
	putexcel E2 =(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum NpSA, f
	putexcel D3=(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum startshare, f
	putexcel E3=(`: di %9.1f 100*r(mean)') using `country', modify
}
if `panel'==2 {
	qui sum NpSS if year==`end'
	putexcel B4=(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum eshareSS if year==`end'
	putexcel C4=(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum NpSSA
	qui sum Nstart
	putexcel D4 =(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum eshareSSA
	qui sum startshare, f
	putexcel E4 =(`: di %9.1f 100*r(mean)') using `country', modify
}
if `panel'==3 {
	qui sum NpSS if year==`end'
	putexcel B5=(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum eshareSS if year==`end'
	putexcel C5=(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum NpSSA
	qui sum Nstart
	putexcel D5 =(`: di %9.1f 100*r(mean)') using `country', modify
	qui sum eshareSSA
	qui sum startshare, f
	putexcel E5 =(`: di %9.1f 100*r(mean)') using `country', modify
}

/*A. STARTER EXPORT INTENSITY DYNAMICS */
set more off
estimates clear
qui reg exs exporter i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa000
qui reg exs exporter l.lnemp i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa00
qui reg exs l(0/1).exporter l.lnemp i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa10
qui reg exs l.exs l(0/1).exporter l.lnemp i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa11
qui reg exs l.exs l(0/1).exporter i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa11a
qui reg exs l.exs l(0/1).exporter stopper /*l.lnemp*/ i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa110
qui reg exs l(0/1).exporter l.exs starter f(0).stopper starterstopper stopperstarter l.lnemp i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa12
qui reg exs l(0/1).exporter l.exs starter stopper starterstopper stopperstarter /*l.lnemp*/ i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa121a
qui reg exs l(0/1).exporter l.exs starter stopper starterstopper stopperstarter last2 /*l.lnemp*/ i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa121
*est tab expa000 expa00  expa*, b(%7.4f)  star(0.01 0.05 0.1) stfmt(%10.2g) stats(N r2_a) title("			EXPORT INTENSITY DYNAMICS - `country' (`start' to `end') ") drop(i.year i.ind)
esttab expa* using "`country'Regs`panel'.csv", b(%8.3f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap /*mtitles(exs exs exs exs exs exs exs exs exs exs)*/ title("			EXPORT INTENSITY DYNAMICS - `country' (`start' to `end')")  drop(*year* *ind* *cons*)  uns replace

/*A. STARTER EXPORT INTENSITY DYNAMICS - WEIGHTED BY SALES TO MAKE CONSISTENT WITH AGGREGATE TRADE VOLUMES*/
set more off
estimates clear
qui reg exs exporter i.year /*i.ind*/ [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa000
gen exsbar = _b[exporter]

replace exporter=0 if starter==1
qui reg exs exporter starter /*i.year i.ind*/ [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa0001
gen exs1bar = _b[starter]/_b[exporter]
replace exporter=1 if starter==1

qui reg exs exporter l.lnemp i.year i.ind [aw=sales]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa00
qui reg exs l(0/1).exporter l.lnemp i.year i.ind [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa10
qui reg exs l.exs l(0/1).exporter l.lnemp i.year i.ind [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa11
qui reg exs l.exs l(0/1).exporter i.year i.ind [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa11a
qui reg exs l.exs l(0/1).exporter stopper /*l.lnemp*/ i.year i.ind [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa110
qui reg exs l(0/1).exporter l.exs starter f(0).stopper starterstopper stopperstarter l.lnemp i.year i.ind [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa12
/*qui reg exs l(0/1).exporter l.exs starter stopper starterstopper stopperstarter /*l.lnemp*/ i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)*/
qui reg exs l(0).exporter l.exs starter /*stopper l.lnemp*/ i.year  [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa121a
gen exs20 = _b[exporter]+_b[starter]
gen its = 0
foreach i of numlist 2/20 {
	replace exs20 = _b[exporter]/*+_b[l.exporter]*/+_b[l.exs]*exs20
	if exs20>=exsbar & its==0 {
		gen yravg = `i'
		replace its = 1
	}
}
if `panel'==1 {
	putexcel G2=(`: di %9.3f exs1bar') using `country', modify
	putexcel G3=(`: di %9.3f exs1bar') using `country', modify
	putexcel H2=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel H3=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel I2=(yravg) using `country', modify
	putexcel I3=(yravg) using `country', modify
	putexcel J2=(`: di %9.3f exs20/exsbar') using `country', modify
	putexcel J3=(`: di %9.3f exs20/exsbar') using `country', modify
}
if `panel'==2 {
	putexcel G4=(`: di %9.3f exs1bar') using `country', modify
	putexcel H4=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel I4=(yravg) using `country', modify
	putexcel J4=(`: di %9.3f exs20/exsbar') using `country', modify
}
if `panel'==3 {
	putexcel G5=(`: di %9.3f exs1bar') using `country', modify
	putexcel H5=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel I5=(yravg) using `country', modify
	putexcel J5=(`: di %9.3f exs20/exsbar') using `country', modify
}
qui reg exs l(0/1).exporter l.exs starter stopper starterstopper stopperstarter last2 /*l.lnemp*/ i.year i.ind [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa121
qui reg exs exporter i.year [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store W_N_IND_0
qui reg exs l.exs l(0/1).exporter i.year [aw=sales] if year>=`start' & year<=`end', vce(cluster plant)
estimates store W_N_IND_1
*est tab expa000 expa00  expa* W_N* , b(%7.4f)  star(0.01 0.05 0.1) stfmt(%10.2g) stats(N r2_a) title("			EXPORT INTENSITY DYNAMICS - `country' (`start' to `end') - WEIGHTED") drop(i.year i.ind)
esttab expa* W_N* using "`country'Regs`panel'.csv", b(%8.3f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap /*mtitles(exs exs exs exs exs exs exs exs exs exs)*/ title("			EXPORT INTENSITY DYNAMICS - `country' (`start' to `end') WEIGHTED")  drop(*year* *ind* *cons*)  uns append

/*b. Marginal EXPORTER SIZE DISCOUNT */
gen marginal =0
replace marginal =1 if starter==1|stopper==1
gen lnsales = ln(sales)
set more off

estimates clear
qui reg lnemp exporter marginal i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store Employ
qui reg lnemp exporter marginal i.year i.ind if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Employ2
qui reg lnsales exporter marginal i.year i.ind if year>=`start' & year<=`end', vce(cluster plant)
estimates store Sales
qui reg lnsales exporter marginal i.year i.ind if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2
qui reg lnsales exporter starter stopper i.year i.ind if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2SS
qui reg lnsales exporter starter stopper i.year if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2SSNoI

qui reg lnemp exporter marginal i.year i.ind [aw=sales]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store EmployW
qui reg lnemp exporter marginal i.year i.ind [aw=sales]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Employ2W
qui reg lnsales exporter marginal i.year i.ind [aw=sales]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store SalesW
qui reg lnsales exporter marginal i.year i.ind [aw=sales]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store SalesW
qui reg lnsales exporter marginal i.year [aw=sales]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store SalesWnoI
if `panel'==1 {
	putexcel F2=(`: di %9.3f exp(_b[marginal])') using `country', modify
}
if `panel'==2 {
	putexcel F4=(`: di %9.3f exp(_b[marginal])') using `country', modify
}
qui reg lnsales exporter marginal i.year i.ind [aw=sales]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2W
qui reg lnsales exporter starter stopper i.year i.ind [aw=sales]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2WSS
qui reg lnsales exporter starter i.year [aw=sales]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2WSSNoI
if `panel'==1 {
	putexcel F3=(`: di %9.3f exp(_b[starter])') using `country', modify
}
if `panel'==3 {
	putexcel F5=(`: di %9.3f exp(_b[starter])') using `country', modify
}
*est tab Employ* Sales*, b(%7.4f)  star(0.01 0.05 0.1) stfmt(%8.2g) stats(N r2_a) title("			Entrant/Exitter Log Premia - `country' (`start' to `end')") drop(i.year i.ind _cons)
esttab Employ* Sales* using "`country'Regs`panel'.csv", b(%8.2f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap  title("		Entrant/Exitter Log Premia - `country' (`start' to `end')")  drop(*year* *ind* *cons*)  uns append

/*c. Linear Probability model on export participation*/
estimates clear
qui reg exporter l.exporter i.year i.ind if year>=`start', vce(cluster plant)
estimates store expa000
qui reg exporter l.exporter l.lnemp i.year i.ind if year>=`start', vce(cluster plant)
estimates store expa00
qui reg exporter l(1/2).exporter l.lnemp i.year i.ind if year>=`start', vce(cluster plant)
estimates store expa01
qui reg exporter l.exporter l.lnemp l(1/2).starter i.year i.ind if year>=`start', vce(cluster plant)
estimates store expa01a
qui reg exporter l.exporter l.lnemp l.exs l(1/2).starter i.year i.ind if year>=`start', vce(cluster plant)
estimates store expa02
qui reg exporter l.exporter last2 l.lnemp l.starter i.year i.ind if year>=`start', vce(cluster plant)
estimates store expa01aa
qui reg exporter l.exporter last2 l.lnemp l.exs l.starter i.year i.ind if year>=`start', vce(cluster plant)
estimates store expa02a
qui reg exporter l.exporter last2 l.lnemp l.starter i.year i.ind [aw=sales] if year>=`start', vce(cluster plant)
estimates store expa01aw
if `panel'==1 {
	putexcel K2=(`: di %9.3f _b[l.exporter]') using `country', modify
	putexcel L2=(`: di %9.3f _b[l.exporter]+_b[l.starter]') using `country', modify
	putexcel M2=(`: di %9.3f _b[last2]') using `country', modify
	putexcel K3=(`: di %9.3f _b[l.exporter]') using `country', modify
	putexcel L3=(`: di %9.3f _b[l.exporter]+_b[l.starter]') using `country', modify
	putexcel M3=(`: di %9.3f _b[last2]') using `country', modify
}
if `panel'==2 {
	putexcel K4=(`: di %9.3f _b[l.exporter]') using `country', modify
	putexcel L4=(`: di %9.3f _b[l.exporter]+_b[l.starter]') using `country', modify
	putexcel M4=(`: di %9.3f _b[last2]') using `country', modify
}
if `panel'==3 {
	putexcel K5=(`: di %9.3f _b[l.exporter]') using `country', modify
	putexcel L5=(`: di %9.3f _b[l.exporter]+_b[l.starter]') using `country', modify
	putexcel M5=(`: di %9.3f _b[last2]') using `country', modify
}
qui reg exporter l.exporter last2 l.lnemp l.starter i.year [aw=sales] if year>=`start', vce(cluster plant)
estimates store expa01awNoIND
qui reg exporter l.exporter last2 l.lnemp l.exs l.starter i.year i.ind [aw=sales] if year>=`start', vce(cluster plant)
estimates store expa02aw
qui reg exporter l.exporter last2 l.lnemp l.exs l.starter i.year [aw=sales] if year>=`start', vce(cluster plant)
estimates store expa02awNoIND
*est tab expa000 expa00  expa*, b(%7.4f)  star(0.01 0.05 0.1) stfmt(%10.2g) stats(N r2_a) title("			Linear Probability AND ENTRY ") drop(i.year i.ind)
esttab expa* using "`country'Regs`panel'.csv", b(%8.3f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap mtitles(Exporter Exporter Exporter Exporter Exporter Exporter Exporter ExporterW ExporterW ) title("			Linear Probability AND ENTRY ")  drop(*year* *ind* *cons*)  uns append


restore
}
