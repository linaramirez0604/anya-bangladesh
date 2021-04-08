

/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: PRELIMINARY ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 26/01/2021
LAST MODIFIED: 30/03/2021

PURPOSE: Preliminary analysis. Based on "analysis by Anya suggestion.dta" by Tanvir Ahmed and word document "Anya suggested analysis plan". 


------------------------------------------------------------------------------*/



*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 


if c(os)=="Windows" {
	cd "C:/Users/`c(username)'/Dropbox"
	
}
else if c(os)=="MacOSX" {
	cd "/Users/`c(username)'/Dropbox"
	
}

global dropbox `c(pwd)'

	gl input "$dropbox/Chicago/UChicago/Personal/ECD_Bangladesh/input"
	gl output "$dropbox/Chicago/UChicago/Personal/ECD_Bangladesh/output"
	gl results "$dropbox/Chicago/UChicago/Personal/ECD_Bangladesh/results"

	
	

	cd "$output"
	
	
	use ECD_compiled, clear  
	
	*Keep only villages with HV and control
	drop if missing(child_treat_status)

	
	

*--------------------------------------------------------------------------------------------------------
*						CREATING STD. VARIABLES (Based on control group means and sd.)
*
*---------------------------------------------------------------------------------------------------------

*1. POOLING SOME MEASURES 
*Academic Skill variable: Literacy + Numeracy 

gen base_acskill=base_lit_overall+base_num_overall
gen mid_acskill=mid_lit_overall+mid_num_overall
gen end_acskill=end_lit_overall+end_num_overall
order base_acskill mid_acskill end_acskill, after(source_lit)


*Executive function (excluded PSRA because we onlyh have it for mid and endline)
gen base_exfunction=base_os_overall+base_ss_overall
gen mid_exfunction=mid_os_overall+mid_ss_overall
gen end_exfunction=end_os_overall+end_ss_overall

*2. STANDARDIZING VARIABLES 

local asq "gm fm comm prbs psc overall"

foreach var of local  asq{
quietly summ base_asq_`var' if treat1==4
scalar `var'_mean=r(mean)
scalar `var'_sd=r(sd)
gen zbase_`var'=(base_asq_`var'-`var'_mean)/`var'_sd
gen zmid_`var'=(mid_asq_`var'-`var'_mean)/`var'_sd
gen zend_`var'=(end_asq_`var'-`var'_mean)/`var'_sd


}


local skill "lit num os ss"

foreach var of local skill {
quietly summ base_`var'_overall  if treat1==4
scalar `var'_mean=r(mean)
scalar `var'_sd=r(sd)
gen zbase_`var'_overall=(base_`var'_overall-`var'_mean)/`var'_sd
gen zmid_`var'_overall=(mid_`var'_overall-`var'_mean)/`var'_sd
gen zend_`var'_overall=(end_`var'_overall-`var'_mean)/`var'_sd

}



quietly summ base_acskill if treat1==4
scalar acskill_mean=r(mean)
scalar acskill_sd=r(sd)
gen zbase_acskill=(base_acskill-acskill_mean)/acskill_sd
gen zmid_acskill=(mid_acskill-acskill_mean)/acskill_sd
gen zend_acskill=(end_acskill-acskill_mean)/acskill_sd


quietly summ base_exfunction if treat1==4
scalar exfunction_mean=r(mean)
scalar exfunction_sd=r(sd)
gen zbase_exfunction=(base_exfunction-exfunction_mean)/exfunction_sd
gen zmid_exfunction=(mid_exfunction-exfunction_mean)/exfunction_sd
gen zend_exfunction=(end_exfunction-exfunction_mean)/exfunction_sd

replace Gender=. if Gender>1 


*3. LABELS FOR REGRESSIONS

label var homevisit2 "Only Home Visit"
label var preschool2 "Only PK (In HV village)"
label var both2 "Home Visit and PK (In HV village)"
label var base_acskill "Baseline AS"
label var base_exfunction "Baseline EF" 
label var Gender "Gender"
label var base_age_year "Age"
label var mid_acskill "Midline AS" 
label var end_acskill "Endline AS"
label var mid_exfunction "Midline EF"
label var end_exfunction "Endline EF"
label var  mid_asq_overall "Midline ASQ" 
label var end_asq_overall "Endline ASQ"
label var zbase_acskill "Baseline AS (std)" 
label var zbase_exfunction "Baseline EF (std)"
label var zmid_acskill "Midline AS(std)" 
label var zend_acskill "Endline AS (std)" 
label var zmid_exfunction "Midline EF (std)" 
label var zend_exfunction "Endline EF (std)"
label var zmid_overall "Midline ASQ (std)" 
label var zend_overall "Endline ASQ (std)"
label var mother_education "Mother Education" 
label var household_income "Household Income"

save temp.dta, replace 




*-------------------------------------------------------------------------------
*						DESCRIPTIVE STATISTICS 
*
*------------------------------------------------------------------------------- 

global desc "Gender base_age_year mother_education household_income base_acskill base_exfunction "


eststo homevisit: estpost summarize $desc if homevisit2==1
eststo preschool: estpost summarize $desc if preschool2==1
eststo both: estpost summarize $desc if both2==1
eststo control: estpost summarize $desc if both2!=1 & homevisit2!=1 & preschool2!=1



* See how it looks in Stata:
esttab control homevisit preschool both, mtitles("Control" "Only HV" "Only PK (HV vill.)" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label


*In tex: 
esttab control homevisit preschool both using "$results/tables/descstats.tex", mtitles("Control" "Only HV" "Only PK (HV vill.)" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label frag replace 




***------------------------  /////  ----------------------------***




*--------------------------------------------------------------------------------------------------------
*							PRELIMINARY REGRESSIONS 
*
*---------------------------------------------------------------------------------------------------------





*1. NOT STANDARDIZED - MAIN RESULTS 
eststo clear 
global treatments homevisit2 preschool2 both2 
global controls  base_acskill base_exfunction Gender base_age_year 

local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall 
 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	
}



* See how it looks in Stata:
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) /// 
  keep($treatments $controls) ///
 order($treatments $controls) ///
      constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)




*2. STANDARDIZED - MAIN RESULTS 
eststo clear 
global treatments homevisit2 preschool2 both2 
global controls  zbase_acskill zbase_exfunction Gender base_age_year 

local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction zmid_overall zend_overall 
 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	
}



* See how it looks in Stata:
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) /// 
  keep($treatments $controls) ///
 order($treatments $controls) ///
      constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1_std.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)




*--------------------------------------------------------------------------------------------------------
*							SPILLOVER REGRESSIONS  
*
*---------------------------------------------------------------------------------------------------------

use temp.dta, clear 

*1. UNTREATED KIDS IN TREATED VILLAGES 

keep if HV_10==1 | HV_20==1 | HVPK_10==1 | HVPK_20==1 | child_treat_status==9

*Keep only kids not selected for HV treatment in the HV villages, not selected for HV treatment in HV+PK villages and kids that were in control villages
keep if child_treat_status==4 | child_treat_status==8 | child_treat_status==9 



*1. NOT STANDARDIZED - MAIN RESULTS 
eststo clear 
global treatments HVPK_20
global controls  base_acskill base_exfunction Gender base_age_year 


local  treatments HV_10 HV_20 HVPK_10 HVPK_20
local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall  

foreach treatment of local treatments{
	foreach outcome of local outcomes{
		reg `outcome' `treatment' $controls, cluster(VILLAGE_ID)
		eststo `treatment'_`outcome'
	
}
}



* See how it looks in Stata:
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) /// 
  keep($treatments $controls) ///
 order($treatments $controls) ///
      constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)






*2. SIBILLINGS AND COUSINS 


erase temp.dta 

