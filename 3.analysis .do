

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
	
	drop if missing(child_treat_status)
	*drop if child_treat_status==10 //only HV villages and control
	
	tab treat1, gen(treatment)
	rename treatment1 pkonly
	label var pkonly "Pre-K only"
	rename treatment2 hvonly
	label var hvonly "Home Visit only"
	rename treatment3 pk_hv
	label var pk_hv "Pre-K + HV"
	rename treatment4 control 
	label var control "Control"
	
	

	save temp.dta, replace 




*-------------------------------------------------------------------------------
*						DESCRIPTIVE STATISTICS 
*
*------------------------------------------------------------------------------- 

global desc "Gender base_age_year mother_education household_income base_acskill base_exfunction "


eststo homevisit: estpost summarize $desc if treat1==2
eststo preschool: estpost summarize $desc if treat1==1
eststo both: estpost summarize $desc if treat1==3
eststo control: estpost summarize $desc if treat1==4



* See how it looks in Stata:
esttab control homevisit preschool both, mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label


*In tex: 
esttab control homevisit preschool both using "$results/tables/descstats.tex", mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label frag replace 





*-------------------------------------------------------------------------------
*						ATTRITION 
*
*------------------------------------------------------------------------------- 


	rename source_num source_Num 
	rename source_lit source_Lit
	local tests ASQ Num Lit OS SS
	
	
	foreach test of local tests{
	count if source_`test'==1 
	local attrited_`test'_endline=r(N)
	
	count if source_`test'==2 
	local attrited_`test'_midline=r(N)
	
	}
	




capture file close st
	
	file open 	st using "$results/tables/attrition.tex", write replace
		*file write 	st _n  "\begin{tabular}{ccc}" 
		*file write 	st _n "\hline \hline \\"
		file write 	st _n "\textbf{Test} & \textbf{Midline} & \textbf{Endline}  \\ \hline"
		
		foreach test of local tests {
				file write 	st  " `test' & `attrited_`test'_midline' & `attrited_`test'_endline' \\  "	
				*file write 	st _n " \hline"
		}
		
		*file write 	st _n "\end{tabular}"
	file close 	st





***------------------------  /////  ----------------------------***




*--------------------------------------------------------------------------------------------------------
*							PRELIMINARY REGRESSIONS 
*
*---------------------------------------------------------------------------------------------------------





*STANDARDIZED - MAIN RESULTS 
eststo clear 
*global treatments homevisit2 preschool2 both2 
global treatments hvonly pkonly pk_hv

local controls1  zbase_acskill zbase_exfunction Gender base_age_year 
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
foreach outcome of local outcomes{
	reg `outcome' $treatments `controls1', cluster(VILLAGE_ID)
	eststo 
	
}


local controls2  zbase_acskill zbase_exfunction zbase_overall Gender base_age_year 
local outcomes zmid_overall zend_overall 
foreach outcome of local outcomes{
	reg `outcome' $treatments `controls2', cluster(VILLAGE_ID)
	eststo 
	
}

local controls zbase_acskill zbase_exfunction zbase_overall Gender base_age_year 

* See how it looks in Stata:
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1_std.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant extracols(4 7) nogaps




*--------------------------------------------------------------------------------------------------------
*							SPILLOVER REGRESSIONS  
*
*---------------------------------------------------------------------------------------------------------

use temp.dta, clear 




*1. UNTREATED KIDS IN TREATED VILLAGES 

*keep if HV_10==1 | HV_20==1 | HVPK_10==1 | HVPK_20==1 | child_treat_status==9
keep if CT==1

*Keep only kids not selected for HV treatment in the HV villages, and kids that were in control villages
keep if child_treat_status==4 |  child_treat_status==9 

*  STANDARDIZED  HV
eststo clear 
local controls  zbase_acskill zbase_exfunction Gender base_age_year 
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
global  treatmentshv HV_10 HV_20 HV_30



foreach outcome of local outcomes{
	reg `outcome' $treatmentshv `controls', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}


local controls  zbase_acskill zbase_exfunction zbase_overall Gender base_age_year 
local outcomes zmid_overall zend_overall 


foreach outcome of local outcomes{
	reg `outcome' $treatmentshv `controls', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) keep($treatmentshv `controls') order($treatmentshv `controls') constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1_spillovers.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatmentshv `controls') order($treatmentshv `controls') constant extracols(4 7) nogaps




*  STANDARDIZED - MAIN RESULTS - HVPK 


use temp.dta, clear 


keep if CT==1

*Keep kids not selected for HV treatment in HV+PK villages and kids that were in control villages
keep if  child_treat_status==8 | child_treat_status==9 

eststo clear 

global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
local controls  zbase_acskill zbase_exfunction Gender base_age_year 
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction


foreach outcome of local outcomes{
	reg `outcome' $treatmentshvpk `controls', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}


local controls  zbase_acskill zbase_exfunction zbase_overall Gender base_age_year 
local outcomes zmid_overall zend_overall 


foreach outcome of local outcomes{
	reg `outcome' $treatmentshvpk `controls', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}





* See how it looks in Stata:
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) keep($treatmentshvpk `controls') order($treatmentshvpk `controls') constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg2_spillovers.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatmentshvpk  `controls') order($treatmentshvpk  `controls') constant extracols(4 7) nogaps




*  STANDARDIZED - MAIN RESULTS - HV and HVPK 



use temp.dta, clear 


keep if CT==1

keep if  child_treat_status==4 | child_treat_status==8 | child_treat_status==9 


eststo clear 
global controls  zbase_acskill zbase_exfunction Gender base_age_year 

global  treatmentshv HV_10 HV_20 HV_30
global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
local controls  zbase_acskill zbase_exfunction Gender base_age_year 
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction



foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk `controls', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}


local controls  zbase_acskill zbase_exfunction zbase_overall Gender base_age_year 
local outcomes zmid_overall zend_overall 


foreach outcome of local outcomes{
	reg `outcome' $treatmentshv $treatmentshvpk `controls', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}




* See how it looks in Stata:
esttab est1 est2 est3 est4 est5 est6 , se(3) replace label b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg3_spillovers.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant extracols(4 7) nogaps




*--------------------------------------------------------------------------------------------------------
*							SPILLOVER REGRESSIONS - SIBILLINGS AND COUSINS  
*
*---------------------------------------------------------------------------------------------------------




*2. SIBILLINGS AND COUSINS 

use temp.dta, clear 



*a. spillovers of HV program on siblings

keep if CT==2 

gen siblings_HV=1 if treat1==2 
gen sibilings_HVPK=1 if treat1==3 
replace siblings_HV=0 if missing(siblings_HV)
replace sibilings_HVPK=0 if missing(sibilings_HVPK)

label var siblings_HV "Sibling of HV kid"
label var sibilings_HVPK "Sibling of HVPK kid"




*  STANDARDIZED - SIBLINGS 
eststo clear 
local controls  Gender base_age_year 
global treatments siblings_HV sibilings_HVPK
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction zmid_overall zend_overall 
	foreach outcome of local outcomes{
		reg `outcome' $treatments `controls', cluster(VILLAGE_ID)
		eststo  
		estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:

esttab est1 est2 est3 est4 est5 est6, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant extracols(4 7) nogaps

	  
*Fragment for tex 



esttab est1 est2 est3 est4 est5 est6 using "$results/tables/reg4_spillovers.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments `controls') order($treatments `controls')  constant extracols(4 7) nogaps





* To count 
 count if HV_20==1 & child_treat_status==4 // In HV village but doesn't get HV. 








/**************************/


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


