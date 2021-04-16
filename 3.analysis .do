

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

	

	cd "$output"
	
	
	use ECD_compiled, clear  
	
	

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
label var HV_10 "HV -- 10"
label var HV_20  "HV -- 20"
label var HVPK_10 "HV+PK -- 10"
label var HVPK_20 "HV+PK -- 20"




save temp_PK.dta, replace

drop if missing(child_treat_status) //only HV villages and control

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
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps




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
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1_std.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps




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
global controls  base_acskill base_exfunction Gender base_age_year 


local  treatments HV_10 HV_20 HVPK_10 HVPK_20
local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall  

foreach treatment of local treatments{
	foreach outcome of local outcomes{
		reg `outcome' `treatment' $controls, cluster(VILLAGE_ID)
		eststo `treatment'_`outcome'
		estadd scalar r_squared = e(r2)
	
}
}




* See how it looks in Stata:
local  treatments HV_10 HV_20 HVPK_10 HVPK_20

foreach treatment of local treatments{
esttab `treatment'_mid_acskill `treatment'_end_acskill `treatment'_mid_exfunction `treatment'_end_exfunction `treatment'_mid_asq_overall `treatment'_end_asq_overall, se(3) replace label b(3) keep(`treatment' $controls) order(`treatment' $controls) constant extracols(4 7) nogaps
}
	  
*Fragment for tex 


foreach treatment of local treatments{
esttab `treatment'_mid_acskill `treatment'_end_acskill `treatment'_mid_exfunction `treatment'_end_exfunction `treatment'_mid_asq_overall `treatment'_end_asq_overall using "$results/tables/spillovers_`treatment'.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep(`treatment' $controls)  order(`treatment' $controls)  constant extracols(4 7) nogaps
}



*  STANDARDIZED - MAIN RESULTS 
eststo clear 
global controls  zbase_acskill zbase_exfunction Gender base_age_year 

local  treatments HV_10 HV_20 HVPK_10 HVPK_20
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction zmid_overall zend_overall 

foreach treatment of local treatments{
	foreach outcome of local outcomes{
		reg `outcome' `treatment' $controls, cluster(VILLAGE_ID)
		eststo `treatment'_`outcome'
		estadd scalar r_squared = e(r2)
	
}
}




* See how it looks in Stata:
local  treatments HV_10 HV_20 HVPK_10 HVPK_20

foreach treatment of local treatments{
esttab `treatment'_zmid_acskill `treatment'_zend_acskill `treatment'_zmid_exfunction `treatment'_zend_exfunction `treatment'_zmid_overall `treatment'_zend_overall, se(3) replace label b(3) keep(`treatment' $controls) order(`treatment' $controls) constant extracols(4 7) nogaps
}
	  
*Fragment for tex 


foreach treatment of local treatments{
esttab `treatment'_zmid_acskill `treatment'_zend_acskill `treatment'_zmid_exfunction `treatment'_zend_exfunction `treatment'_zmid_overall `treatment'_zend_overall using "$results/tables/spillovers_`treatment'_std.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep(`treatment' $controls)  order(`treatment' $controls)  constant extracols(4 7) nogaps
}









*2. SIBILLINGS AND COUSINS 

use temp.dta, clear 




*a. spillovers of HV program on siblings

keep if CT==2 

gen siblings_HV=1 if treat1==2 | treat1==3 
replace siblings_HV=0 if treat1==4

label var siblings_HV "Sibling"



*Not standardized 
eststo clear 
global controls Gender base_age_year 
global treatments siblings_HV

local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall  

	foreach outcome of local outcomes{
		reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
		eststo  
		estadd scalar r_squared = e(r2)
	
}





* See how it looks in Stata:

esttab est1 est2 est3 est4 est5 est6, se(3) replace label b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps

	  
*Fragment for tex 



esttab est1 est2 est3 est4 est5 est6 using "$results/tables/spillovers_siblings_hv.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments $controls) order($treatments $controls)  constant extracols(4 7) nogaps




*  STANDARDIZED - SIBLINGS 
eststo clear 
global controls  Gender base_age_year 
global treatments siblings_HV 


local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction zmid_overall zend_overall 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
		eststo  
		estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:

esttab est1 est2 est3 est4 est5 est6, se(3) replace label b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps

	  
*Fragment for tex 



esttab est1 est2 est3 est4 est5 est6 using "$results/tables/spillovers_siblings_hv_std.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments $controls) order($treatments $controls)  constant extracols(4 7) nogaps






*b. Spillovers of PK program on siblings 

use temp_PK.dta, clear 
keep if CT ==2 
gen siblings_PK = 1 if treat1 == 1|treat1 == 3 
replace siblings_PK = 0 if treat1 == 4 
label var siblings_PK "Sibling"


*Not standardized 
eststo clear 
global controls Gender base_age_year 
global treatments siblings_PK 

local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall  

	foreach outcome of local outcomes{
		reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
		eststo  
		estadd scalar r_squared = e(r2)
	
}



*See how it looks in Stata 
esttab est1 est2 est3 est4 est5 est6, se(3) replace label b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps

*Tex 
esttab est1 est2 est3 est4 est5 est6 using "$results/tables/spillovers_siblings_pk.tex" , label replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments $controls) order($treatments $controls)  constant extracols(4 7) nogaps






*Standardized 
eststo clear 
global controls  Gender base_age_year 
global treatments siblings_PK  


local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction zmid_overall zend_overall 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
		eststo  
		estadd scalar r_squared = e(r2)
	
}
*See how it looks in Stata 
esttab est1 est2 est3 est4 est5 est6, se(3) replace label b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps


*Tex
esttab est1 est2 est3 est4 est5 est6 using "$results/tables/spillovers_siblings_pk_std.tex" , label tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments $controls) order($treatments $controls) constant extracols(4 7) nogaps







*--------------------------------------------------------------------------------------------------------
*							COMPARING TREATMENTS 
*
*---------------------------------------------------------------------------------------------------------

/*
In this section we want to run a few regressions to compare various treatments. 
*/

*1. HV_xx and HVPK_xx treatments 


use temp.dta, clear 

*Generating variables 





*a. Method 1 - creating new variable 
eststo clear 
local nums "10"
foreach num of local nums{
	capture drop additional_PK_`num'
	gen additional_PK_`num' = 1 if HVPK_`num' == 1 
	label var additional_PK_`num' "Additional PK - `num'"
	replace additional_PK_`num' = 0 if HV_`num' == 1 

	global treatment additional_PK_`num' 
	global controls  base_acskill base_exfunction Gender base_age_year 

	local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall 

	foreach outcome of local outcomes { 
		qui reg `outcome' $treatment $controls, cluster(VILLAGE_ID)
		eststo 
	}
}

esttab est1 est2 est3 est4 est5 est6, se(3) replace label b(3) keep($treatment $controls) order($treatment $controls) constant extracols(4 7) nogaps

esttab est1 est2 est3 est4 est5 est6 using "$results/tables/additional_pk_10.tex" , label tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatment $controls) order($treatment $controls) constant extracols(4 7) nogaps

/*
The regressions above compare each type (10, 20, 30) of HVPK treatment with the corresponding HV treatment, on all the outcomes we're interested in. We do this by creating the dummy additional_PK_xx, which is 1 for villages which received BOTH HV and PK (xx) and 0 for villages which received only HV. So, it measures the additional effect of a PK treatment where the HV treatment was already given (for a particular xx) level.
*/


local nums "20"
foreach num of local nums{
	capture drop additional_PK_`num'
	gen additional_PK_`num' = 1 if HVPK_`num' == 1 
	label var additional_PK_`num' "Additional PK - `num'"
	replace additional_PK_`num' = 0 if HV_`num' == 1 

	global treatment additional_PK_`num' 
	global controls  base_acskill base_exfunction Gender base_age_year 

	local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall 

	foreach outcome of local outcomes { 
		qui reg `outcome' $treatment $controls, cluster(VILLAGE_ID)
		eststo 
	}
}

esttab est7 est8 est9 est10 est11 est12, se(3) replace label b(3) keep($treatment $controls) order($treatment $controls) constant extracols(4 7) nogaps

esttab est7 est8 est9 est10 est11 est12 using "$results/tables/additional_pk_20.tex" , label tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatment $controls) order($treatment $controls) constant extracols(4 7) nogaps



local nums "30"
foreach num of local nums{
	capture drop additional_PK_`num'
	gen additional_PK_`num' = 1 if HVPK_`num' == 1 
	label var additional_PK_`num' "Additional PK - `num'"
	replace additional_PK_`num' = 0 if HV_`num' == 1 

	global treatment additional_PK_`num' 
	global controls  base_acskill base_exfunction Gender base_age_year 

	local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall 

	foreach outcome of local outcomes { 
		qui reg `outcome' $treatment $controls, cluster(VILLAGE_ID)
		eststo 
	}
}



//Stata output
esttab est13 est14 est15 est16 est17 est18, se(3) replace label b(3) keep($treatment $controls) order($treatment $controls) constant extracols(4 7) nogaps

//TeX output 
esttab est13 est14 est15 est16 est17 est18 using "$results/tables/additional_pk_30.tex" , label tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatment $controls) order($treatment $controls) constant extracols(4 7) nogaps




 



*b. Method 2 - Using HVPK_xx and HV_xx in the same specification 

/*
I'm not sure what the best way to do this is (or whether what I'm doing) makes 
complete sense, but the idea here is to run regression specifications where both 
HV_xx and HVPK_xx are used as covariates. Note that: 

1. In order to do this, we will need to change how these are defined since 
as of now they are only 0 for treat1 == 4 (i.e. control group; given no treatment)

2. This raises the question of what we want to keep as the 0 category in the new variables. POssibilities include keeping HV_xx and control = 0 in the HVPK_xx dummy (for example), keeping on HV_xx = 0 in the HVPK_xx dummy, or keeping everything else = 0. 
*/


*Here, trying one of these

use temp.dta, clear 



eststo clear 

local nums "10 20 30"
foreach num of local nums{

	gen HVPK_`num'_c = 1 if HVPK_`num' == 1
	replace HVPK_`num'_c = 0 if HVPK_`num' == 0|HV_`num' == 1 

	gen HV_`num'_c = 1 if HV_`num' == 1
	replace HV_`num'_c = 0 if HV_`num' == 0|HVPK_`num' == 1


	global treatments HV_`num'_c HVPK_`num'_c
	global controls  base_acskill base_exfunction Gender base_age_year 

	local outcomes mid_acskill end_acskill mid_exfunction end_exfunction mid_asq_overall end_asq_overall 

		foreach outcome of local outcomes { 
			reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
			eststo 
	}

}


/*
Here, the following regressions are run: 

- We use HV_xx and HVPK_xx in the same specification with the usual controls 
- These variables are slightly modified, stored in new variables called HVPK_xx_c 
and HV_xx_c. HVPK_xx_c = 1 where HVPK_xx = 1 and 0 for the main control group 
(treat1 == 4) OR the HV_xx = 1 group. Similarly, HV_xx_c = 1 where HV_xx = 1 and 
0 for the main control group (treat1 == 4) AND where HVPK_xx = 1. In other words 
in both cases we are controlling for the main control group as well as the other
group (HVPK for HV, HV for HVPK)

*/

*Enter esttab command here as needed: 










erase temp.dta 
erase temp_PK.dta 


