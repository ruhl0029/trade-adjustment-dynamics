/* Colombia - This code estimates how export intensity and survival probability depend on time since entry or time to exit

0. We do this for different panels from the CENSUS (Unbalanced, Balanced, Balanced minus small and volatile firms)

1. The first set of statistics reports the importance of the initial exporters/non-exporters 
	at different horizons 

	2. The second set runs some regressions about Exporter A) intensity B) Sales Premia C) Survival 

*/

clear all
global rootdo = "D:\Dropbox\Exporting Papers\Trade-Growth-LRSR\Accepted Submission\Empirics\Colombia"
global rootor = "D:\Dropbox\Exporting Papers\Trade-Growth-LRSR\Accepted Submission\Empirics\Colombia"
global rootda = "D:\Dropbox\Exporting Papers\Trade-Growth-LRSR\Accepted Submission\Empirics\Colombia"
global rootfi=  "D:\Dropbox\Exporting Papers\Trade-Growth-LRSR\Accepted Submission\Empirics\Colombia"

/*------------------------------------------------------------------------------
Compute Statistics of export intensity
------------------------------------------------------------------------------*/
*use "$rootda\ColombiaALL.dta", clear
*cd "G:\RA_George\Colombia"

use "Colombia.dta", clear
version 13

keep datayear plant sic l1 s5 s4
rename datayear year
rename sic industry
rename l1 employees
rename s5 sales
rename s4 exports
replace sales=sales*1000 if year>79
replace exports=exports*1000 if year>79
drop if year>=90  /*The measure of sales is missing for most plants in 1991*/
drop if year<=80  /*The measure of exports is missing for most plants in 1980*/

rename plant plant_id_code
rename sales total_income
rename industry ind_code

collapse (sum) exports total_income employees (mean) ind_code, by( plant_id_code year)

set more off
gen lnemp = ln(emp)
tsset plant year
gen exs = exports/total

/* FIX SOME OUTLIERS - This is a big plant that is probably exported the whole time*/
replace exports =0.5*(f.exs+f2.exs)*total if plant==12292 & year==81 
replace exs =exports/total if plant==12292 & year==81 
replace exports =0 if plant==15530 & year==82 
replace exs =0 if plant==15530 & year==82 

gen falseexit = 0
replace falseexit =1 if l.exs>0.5 & l.exs<=1 & exs==0 & f.exs>0.5 & f.exs<=1
/*replace exs =1/2*(l.exs +f.exs) if falseexit==1*/
gen falsestart = 0
replace falsestart=1 if l.exs==0 & exs>0.5 & exs<=1 & f.exs==0
/*replace exs =1/2*(l.exs +f.exs) if falseexit==1*/

replace exs = 1 if exs>1 & exs!=.
gen exporter = 0
replace exporter=1 if exs>0.0001 & exs!=.

gen stopper  = 0
replace stopper =1 if exporter==1 & f.exporter==0
replace stopper =. if exporter==1 & f.exporter==.
replace stopper =. if year==89

gen starter  = 0
replace starter =1 if exporter==1 & l.exporter==0 /* Initial guys show up as l.exporter==.*/
replace starter =. if exporter==1 & l.exporter==. /* Initial guys show up as l.exporter==.*/
replace starter  = . if year==81

gen stopperstarter = 0
replace stopperstarter=1 if l.exporter==1 & exporter==0 & f.exporter==1

gen starterstopper=0
replace starterstopper=1 if starter==1 & stopper==1

gen final    = 0
replace final=1 if exporter==1 & f.exporter==.
egen final2= max(final), by(plant)

gen initial = 0
replace initial = 1 if exporter==1 & l.exporter==.
egen initial2 = max(initial), by(plant)


gen last2 =.
replace last2 =0 if l2.exporter==0
replace last2 =0 if l2.exporter==1 & l.exporter==1
replace last2 =1 if l.exporter==0 & l2.exporter==1

gen initialexporter=0
replace initialexporter=1 if exporter==1 & year==81
egen Xin = total(initialexporter), by(plant)
gen temp =1
egen obs = total(temp), by(plant)

egen minsales = min(total_income), by(plant)
egen sdemp = sd(lnemp), by(plant)
egen minemp = min(emp), by(plant)
egen avgemp = mean(emp), by(plant)

local country Colombia
local start 81
local end 89
version 13
putexcel A2=("Unbalanced") A3 = ("Unbalanced (Starters)") A4=("Balanced") A5=("Balanced volatile") B1=("Final Part") C1 = ("Final Exports") D1=("Annual Part.") E1 = ("Annual Exports") F1=("Marginal Discount") G1 = ("exs1/exs") H1=("rhoexs") I1=("Yr avg") J1=("exs20/exs") K1=("Export Prob") L1 = ("Start") M1 = ("Last2") using `country', modify


foreach panel of num 1 2 3 {
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
qui egen Tsales= total(total), by(year)
qui gen Esales = Texp/Tsales
qui egen Expsales= total(total) if exporter==1, by(year)
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
*qui gen NpSSA = (Nstart+Nstop-Nstartstop)/2
qui gen NpSSA = (Nstart+Nstop)/2
qui egen Sexp = total(exports) if starterstopper==1, by(year)
qui egen Startstopsum = mean(Sexp), by(year)
*qui gen eshareSSA = 0.5*(Startsum+Stopsum-Startstopsum)/Texp
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
est tab expa000 expa00  expa*, b(%7.4f)  star(0.01 0.05 0.1) stfmt(%10.2g) stats(N r2_a) title("			EXPORT INTENSITY DYNAMICS - COLOMBIA (82 to 87) ") drop(i.year i.ind)
esttab expa* using "ColombiaRegs`panel'.csv", b(%8.3f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap /*mtitles(exs exs exs exs exs exs exs exs exs exs)*/ title("			EXPORT INTENSITY DYNAMICS - COLOMBIA (82 to 87)")  drop(*year* *ind* *cons*)  uns replace

/*A. STARTER EXPORT INTENSITY DYNAMICS - WEIGHTED BY SALES TO MAKE CONSISTENT WITH AGGREGATE TRADE VOLUMES*/
set more off
estimates clear
qui reg exs exporter i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa000
gen exsbar = _b[exporter]
qui reg exs exporter l.lnemp i.year i.ind [aw=total]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa00
qui reg exs l(0/1).exporter l.lnemp i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa10
qui reg exs l.exs l(0/1).exporter l.lnemp i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa11
qui reg exs l.exs l(0/1).exporter i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa11a
qui reg exs l.exs l(0/1).exporter stopper /*l.lnemp*/ i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa110
qui reg exs l(0/1).exporter l.exs starter f(0).stopper starterstopper stopperstarter l.lnemp i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa12
qui reg exs l(0/1).exporter l.exs starter stopper starterstopper stopperstarter /*l.lnemp*/ i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa121a
gen exs20 = _b[exporter]+_b[starter]
gen its = 0
foreach i of numlist 2/20 {
	replace exs20 = _b[exporter]+_b[l.exporter]+_b[l.exs]*exs20
	if exs20>=exsbar & its==0 {
		gen yravg = `i'
		replace its = 1
	}
}
if `panel'==1 {
	putexcel G2=(`: di %9.3f (_b[exporter]+_b[starter])/exsbar') using `country', modify
	putexcel G3=(`: di %9.3f (_b[exporter]+_b[starter])/exsbar') using `country', modify
	putexcel H2=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel H3=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel I2=(yravg) using `country', modify
	putexcel I3=(yravg) using `country', modify
	putexcel J2=(`: di %9.3f exs20/exsbar') using `country', modify
	putexcel J3=(`: di %9.3f exs20/exsbar') using `country', modify
}
if `panel'==2 {
	putexcel G4=(`: di %9.3f (_b[exporter]+_b[starter])/exsbar') using `country', modify
	putexcel H4=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel I4=(yravg) using `country', modify
	putexcel J4=(`: di %9.3f exs20/exsbar') using `country', modify
}
if `panel'==3 {
	putexcel G5=(`: di %9.3f (_b[exporter]+_b[starter])/exsbar') using `country', modify
	putexcel H5=(`: di %9.3f _b[l.exs]') using `country', modify
	putexcel I5=(yravg) using `country', modify
	putexcel J5=(`: di %9.3f exs20/exsbar') using `country', modify
}
qui reg exs l(0/1).exporter l.exs starter stopper starterstopper stopperstarter last2 /*l.lnemp*/ i.year i.ind [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store expa121
qui reg exs exporter i.year [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store W_N_IND_0
qui reg exs l.exs l(0/1).exporter i.year [aw=total] if year>=`start' & year<=`end', vce(cluster plant)
estimates store W_N_IND_1
est tab expa000 expa00  expa* W_N* , b(%7.4f)  star(0.01 0.05 0.1) stfmt(%10.2g) stats(N r2_a) title("			EXPORT INTENSITY DYNAMICS - COLOMBIA (82 to 87) - WEIGHTED") drop(i.year i.ind)
esttab expa* W_N* using "ColombiaRegs`panel'.csv", b(%8.3f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap /*mtitles(exs exs exs exs exs exs exs exs exs exs)*/ title("			EXPORT INTENSITY DYNAMICS - COLOMBIA (82 to 87) WEIGHTED")  drop(*year* *ind* *cons*)  uns append

/*b. Marginal EXPORTER SIZE DISCOUNT */
gen marginal =0
replace marginal =1 if starter==1|stopper==1
gen lnsales = ln(total_income)
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

qui reg lnemp exporter marginal i.year i.ind [aw=total]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store EmployW
qui reg lnemp exporter marginal i.year i.ind [aw=total]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Employ2W
qui reg lnsales exporter marginal i.year i.ind [aw=total]  if year>=`start' & year<=`end', vce(cluster plant)
estimates store SalesW
if `panel'==1 {
	putexcel F2=(`: di %9.3f exp(_b[marginal])') using `country', modify
}
if `panel'==2 {
	putexcel F4=(`: di %9.3f exp(_b[marginal])') using `country', modify
}
if `panel'==3 {
	putexcel F5=(`: di %9.3f exp(_b[marginal])') using `country', modify
}
qui reg lnsales exporter marginal i.year i.ind [aw=total]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2W
qui reg lnsales exporter starter stopper i.year i.ind [aw=total]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2WSS
if `panel'==1 {
	putexcel F3=(`: di %9.3f exp(_b[starter])') using `country', modify
}
qui reg lnsales exporter marginal i.year i.ind [aw=total]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2W
qui reg lnsales exporter starter stopper i.year i.ind [aw=total]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2WSS
qui reg lnsales exporter starter stopper i.year [aw=total]  if year>=`start' & year<=`end' & exporter==1, vce(cluster plant)
estimates store Sales2WSSNoI
est tab Employ* Sales*, b(%7.4f)  star(0.01 0.05 0.1) stfmt(%8.2g) stats(N r2_a) title("			Entrant/Exitter Log Premia - COLOMBIA (82 to 87)") drop(i.year i.ind _cons)
esttab Employ* Sales* using "ColombiaRegs`panel'.csv", b(%8.2f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap  title("		Entrant/Exitter Log Premia - COLOMBIA (82 to 87)")  drop(*year* *ind* *cons*)  uns append

/*c. Linear Probability model on export participation*/
estimates clear
qui reg exporter l.exporter i.year i.ind if year>=84, vce(cluster plant)
estimates store expa000
qui reg exporter l.exporter l.lnemp i.year i.ind if year>=84, vce(cluster plant)
estimates store expa00
qui reg exporter l(1/2).exporter l.lnemp i.year i.ind if year>=84, vce(cluster plant)
estimates store expa01
qui reg exporter l.exporter l.lnemp l(1/2).starter i.year i.ind if year>=83, vce(cluster plant)
estimates store expa01a
qui reg exporter l.exporter l.lnemp l.exs l(1/2).starter i.year i.ind if year>=83, vce(cluster plant)
estimates store expa02
qui reg exporter l.exporter last2 l.lnemp l.starter i.year i.ind if year>=84, vce(cluster plant)
estimates store expa01aa
qui reg exporter l.exporter last2 l.lnemp l.exs l.starter i.year i.ind if year>=84, vce(cluster plant)
estimates store expa02a
qui reg exporter l.exporter last2 l.lnemp l.starter i.year i.ind [aw=total] if year>=84, vce(cluster plant)
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
qui reg exporter l.exporter last2 l.lnemp l.starter i.year [aw=total] if year>=84, vce(cluster plant)
estimates store expa01awNoIND
qui reg exporter l.exporter last2 l.lnemp l.exs l.starter i.year i.ind [aw=total] if year>=84, vce(cluster plant)
estimates store expa02aw
qui reg exporter l.exporter last2 l.lnemp l.exs l.starter i.year [aw=total] if year>=84, vce(cluster plant)
estimates store expa02awNoIND
est tab expa000 expa00  expa*, b(%7.4f)  star(0.01 0.05 0.1) stfmt(%10.2g) stats(N r2_a) title("			Linear Probability AND ENTRY ") drop(i.year i.ind)
esttab expa* using "ColombiaRegs`panel'.csv", b(%8.3f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap mtitles(Exporter Exporter Exporter Exporter Exporter Exporter Exporter ExporterW ExporterW ) title("			Linear Probability AND ENTRY ")  drop(*year* *ind* *cons*)  uns append

/*d. Probit model on export participation*/
estimates clear
qui probit exporter l.exporter i.year i.ind if year>=84, vce(cluster plant)
estimates store expa000
qui probit exporter l.exporter l.lnemp i.year i.ind if year>=84, vce(cluster plant)
estimates store expa00
qui probit exporter l(1/2).exporter l.lnemp i.year i.ind if year>=84, vce(cluster plant)
estimates store expa01
qui probit exporter l.exporter l.lnemp l(1/2).starter i.year i.ind if year>=83, vce(cluster plant)
estimates store expa01a
qui probit exporter l.exporter l.lnemp l.exs l(1/2).starter i.year i.ind if year>=83, vce(cluster plant)
estimates store expa02
/*qui reg exporter l(1/2).exporter l.lnemp l.exs l(1/2).starter i.year i.ind if year>=83, vce(cluster plant)
estimates store expa03*/
est tab expa000 expa00  expa*, b(%7.4f)  star(0.01 0.05 0.1) stfmt(%10.2g) stats(N r2_a) title("			Probit ") drop(i.year i.ind)
esttab expa* using "ColombiaRegs`panel'.csv", b(%8.3f) nostar nonote nonum stats(N r2_a, fmt(%9.2g)) nopa li nogap mtitles(Exporter Exporter Exporter Exporter Exporter Exporter Exporter Exporter ) title("			Probit AND ENTRY ")  drop(*year* *ind* *cons*)  uns append

/*collapse (mean) Nplants Part Esales Eintensity starter stopper startshare stopshare Npart eshare0t lfalseexit falsestart if exporter==1, by(year)
if `panel' ==1 {
qui export excel year Nplants Part Esales Eintensity starter stopper startshare stopshare Npart eshare0t using "D:\Dropbox (Phil Research)\Exporting Papers\Trade-Growth-LRSR\Data\Colombia\Colombiasummary.xls", firstrow(variables) replace
}
if `panel' ==2 {
export excel year Nplants Part Esales Eintensity starter stopper startshare stopshare Npart eshare0t using "D:\Dropbox (Phil Research)\Exporting Papers\Trade-Growth-LRSR\Data\Colombia\Colombiasummary.xls", sheetmodify cell(A12) firstrow(variables) nolabel
}

if `panel' ==3 {
export excel year Nplants Part Esales Eintensity starter stopper startshare stopshare Npart eshare0t using "D:\Dropbox (Phil Research)\Exporting Papers\Trade-Growth-LRSR\Data\Colombia\Colombiasummary.xls", sheetmodify cell(A24) firstrow(variables) nolabel
}*/
restore
}
