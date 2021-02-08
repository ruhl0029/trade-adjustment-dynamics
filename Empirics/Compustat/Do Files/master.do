clear
set more off

global rootdo = "F:\Compustat\Do Files"
global rootda = "F:\Compustat\Data"

/*
funda_setup.do cleans and arranges firm level data from Compustat's "Annual 
Fundamentals" dataset. This data includes employment, sales (though I use the
sales data from the historical segment data), industry, and, most importantly,
the sales footnote includes an indicator for whether or not the data reflects a 
merger or acquisition.
*/
do "$rootdo\funda_setup.do"

/*
This do file cleans, arranges, and aggregates the plant level geographic segment
data from Compustat. Data includes sales, export sales, and employment (though I use 
employment data from the Annual Fundamentals).
*/
do "$rootdo\segment_setup.do"

/*This do file merges the data from Annual Fundamentals and historical segments.*/
do "$rootdo\merge.do"



do "$rootdo\analysis.do"
