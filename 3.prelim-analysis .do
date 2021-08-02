

/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: PRELIMINARY ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 26/01/2021
LAST MODIFIED: 21/07/2021

PURPOSE: Preliminary analysis. Based on "analysis by Anya suggestion.dta" by Tanvir Ahmed and word document "Anya suggested analysis plan". 


------------------------------------------------------------------------------*/



*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 

	set scheme s2mono 


	cd "$output"

	use ECD_compiled, clear  
	

*-------------------------------------------------------------------------------
*						TABLE 1. DESCRIPTIVE STATISTICS 
*
*------------------------------------------------------------------------------- 

	global desc "Gender base_age_year father_education mother_education household_income treated child_type base_acskill base_exfunction "


	eststo homevisit: estpost summarize $desc if treat1==2
	eststo preschool: estpost summarize $desc if treat1==1
	eststo both: estpost summarize $desc if treat1==3
	eststo control: estpost summarize $desc if treat1==4



* See how it looks in Stata:
	esttab control homevisit preschool both, mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label


*In tex: 
	esttab control homevisit preschool both using "$results/tables/descstats.tex", mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label frag replace 




*-------------------------------------------------------------------------------
*			TABLE 1. (APPENDIX) DESCRIPTIVE STATISTICS - SPECIFIC FOR TREATED AND UNTREATED 
*
*------------------------------------------------------------------------------- 

	global desc "Gender base_age_year father_education mother_education household_income child_type base_acskill base_exfunction "


	eststo homevisit_treat: estpost summarize $desc if treat1==2 & treated==1
	eststo homevisit_untreated: estpost summarize $desc if treat1==2 & treated==0
	eststo both_treated: estpost summarize $desc if treat1==3 & treated==1
	eststo both_untreated: estpost summarize $desc if treat1==3 & treated==0



* See how it looks in Stata:
esttab homevisit_treat homevisit_untreated both_treated both_untreated, mtitles("HV-T" "HV-UT" "HV and PK-T" "HV and PK-UT") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label


*In tex: 
esttab homevisit_treat homevisit_untreated both_treated both_untreated using "$results/tables/descstats_bytreatment.tex", mtitles("HV-T" "HV-UT" "HV and PK-T" "HV and PK-UT") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label frag replace 



* To count 
 count if HV_20==1 & child_treat_status==4 // In HV village but doesn't get HV. 

 
 
 
*-------------------------------------------------------------------------------
*			TABLE 2. WORD TABLE (NO STATA)
*
*------------------------------------------------------------------------------- 

	
*-------------------------------------------------------------------------------
*			TABLE 3. v1 REGRESSION - ITT 
*
*------------------------------------------------------------------------------- 

	
	use ECD_compiled.dta, clear 
	
	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6

	local controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
foreach outcome of local outcomes{
	reg `outcome' $treatments `controls' `parents_educ', cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}




* See how it looks in Stata:
esttab est1 est2 est3 est4 , se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg1_std.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))



*Graph 

coefplot (est1, label("Midline")) (est2, label("Endline")), bylabel("Academic Skills") ||  est3 est4, bylabel("Executive Function") ||, base keep($treatments)
graph export "$results/graphs/reg1_std.pdf", replace 



*-------------------------------------------------------------------------------
*			TABLE 3. v2 REGRESSION - ITT 
*			Eliminating kids added on year 2, assigning 0 to missing values in baseline scores 
*------------------------------------------------------------------------------- 

	
	use ECD_compiled.dta, clear 
	
	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}

	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6


	local controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
foreach outcome of local outcomes{
	reg `outcome' $treatments `controls' `parents_educ', cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}




* See how it looks in Stata:
esttab est1 est2 est3 est4 , se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg1_std_v2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))




*-------------------------------------------------------------------------------
*			TABLE 3. v3 REGRESSION - ITT 
*	Eliminating kids added on year 2, keeping only those that continued. Assigning 0 to missing values in baseline scores 
*------------------------------------------------------------------------------- 

	
	use ECD_compiled.dta, clear 
	
	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	drop if Project_continuation=="No" & !treat1(control)
	
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}

	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6


	local controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
foreach outcome of local outcomes{
	reg `outcome' $treatments `controls' `parents_educ', cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}




* See how it looks in Stata:
esttab est1 est2 est3 est4 , se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg1_std_v3.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))




*-------------------------------------------------------------------------------
*			TABLE 3. v4 REGRESSION - ITT 
* 	Using spillover kids as control kids for hv and hvpk -- question
*------------------------------------------------------------------------------- 

	
	use ECD_compiled.dta, clear 
	
	keep if  CT==1 
	*Drop control 
	drop if  child_treat_status==9 
	*Change treatment variables
	replace hvonly=0 if  child_treat_status==4
	replace pk_hv=0 if child_treat_status==8 
	
	
	
	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pk_hv
	
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6

	local controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
foreach outcome of local outcomes{
	reg `outcome' $treatments `controls' `parents_educ', cluster(VILLAGE_ID)
	eststo 
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	
}




* See how it looks in Stata:
esttab est1 est2 est3 est4 , se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff2 N, labels("Post estimation" "HV=HV+PK" "N") fmt(3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg1_std_v4.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant stats(empty p_diff2 N, labels("Post estimation" "HV=HV+PK" "N") fmt(3 3 0)) nogaps  



*Graph 

coefplot (est1, label("Midline")) (est2, label("Endline")), bylabel("Academic Skills") ||  est3 est4, bylabel("Executive Function") ||, base keep($treatments)
graph export "$results/graphs/reg1_std.pdf", replace 







*-------------------------------------------------------------------------------
*			TABLE 4. REGRESSION  - TOT 
*
*------------------------------------------------------------------------------- 

	use ECD_compiled.dta, clear 
	
*We need attendance to perform the 2sls 

	
*STANDARDIZED - MAIN RESULTS 

/*
eststo clear 
global treatments hvonly pkonly pk_hv

local controls  zbase_acskill zbase_exfunction Gender base_age_year 
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
foreach outcome of local outcomes{
	ivregress 2sls `outcome' `controls' pkonly (hvonly pk_hv=HV_treated HVPK_treated), vce(cluster VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
	
} 

*/  


*-------------------------------------------------------------------------------
*			TABLE 5.v1 SPILLOVER EFFECTS
*
*------------------------------------------------------------------------------- 

	

*  STANDARDIZED - MAIN RESULTS - HV and HVPK 



use ECD_compiled.dta, clear 


keep if CT==1

keep if  child_treat_status==4 | child_treat_status==8 | child_treat_status==9 


eststo clear 
local controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income
local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6


global  treatmentshv HV_10 HV_20 HV_30
global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction



foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk `controls' `parents_educ', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est2 est3 est4, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg3_spillovers.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant nogaps





*-------------------------------------------------------------------------------
*			TABLE 5. v2 SPILLOVER EFFECTS
*	Eliminating kids added on year 2, assigning 0 to missing values in baseline scores 
*------------------------------------------------------------------------------- 

	

*  STANDARDIZED - MAIN RESULTS - HV and HVPK 



	use ECD_compiled.dta, clear 


	keep if CT==1
	keep if  child_treat_status==4 | child_treat_status==8 | child_treat_status==9 
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	


eststo clear 
local controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction
global  treatmentshv HV_10 HV_20 HV_30
global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6




foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk `controls' `parents_educ', cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est2 est3 est4, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg3_spilloversv2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant nogaps





*--------------------------------------------------------------------------------------------------------
*					TABLE 6.v1 SPILLOVER REGRESSIONS - SIBILLINGS 
*			Siblings of treated kids vs siblings of untreated kids and control. 
*---------------------------------------------------------------------------------------------------------


*2. SIBILLINGS AND COUSINS 

use ECD_compiled.dta, clear 

*Keep only siblings and cousings 
keep if proj_child!=1
*Keep only those added in year2 (only 50 siblings were added in year1)
keep if added_year2==1

	
	*Assigning 0 to missing at midline (as midline is the baseline for siblings/cousings)
	local midline acskill exfunction
	foreach var of local midline {
	replace zmid_`var'=0 if missing(zmid_`var')
	}
	

*a. spillovers of HV program on siblings

gen siblings_PK=1 if treat1==1 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_PK=0 if missing(siblings_PK) 

*gen siblings_PK=1 if treat1==1 



gen siblings_HV=1 if treat1==2 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HV=0 if missing(siblings_HV)
*gen siblings_HV=1 if treat1==2 



gen siblings_HVPK=1 if treat1==3 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HVPK=0 if missing(siblings_HVPK) 
*gen siblings_HVPK=1 if treat1==3 



label var siblings_PK "Sibling of PK kid"
label var siblings_HV "Sibling of HV kid"
label var siblings_HVPK "Sibling of HVPK kid"

*Generating age variables 
gen group_age=1 if base_age_year<=2 
replace group_age=2 if base_age_year>2 & base_age_year<=5 
replace group_age=3 if base_age_year>5 
label define group_age 1 "0-2" 2 "3-5" 3 "6-8"
label values group_age group_age 


	
*  STANDARDIZED - SIBLINGS 
eststo clear 
local controls zmid_acskill zmid_exfunction Gender base_age_year ln_household_income
local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6

global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zend_acskill zend_exfunction 
	foreach outcome of local outcomes{
		reg `outcome' $treatments `controls' `parents_educ', cluster(VILLAGE_ID)
		eststo  
		estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est2, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps

	  
*Fragment for tex 
esttab est1 est2 using "$results/tables/reg4_spillovers.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments `controls') order($treatments `controls')  constant extracols(4 7) nogaps




* b. STANDARDIZED - SIBLINGS - BY GROUP AGE 
eststo clear 
local controls Gender ln_household_income
local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_HV siblings_HVPK
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 
	foreach outcome of local outcomes{
		forvalues i=1/3{
		reg `outcome' $treatments `controls' `parents_educ' if group_age==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		estadd scalar r_squared = e(r2)
		}
	
}



* See how it looks in Stata:

esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls')  constant nogaps 

	  
*Fragment for tex 



esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3 using "$results/tables/reg4_spillovers_mid_age.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments `controls') order($treatments `controls')  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


	
	
* See how it looks in Stata:

esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps

  
*Fragment for tex 



esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3 using "$results/tables/reg4_spillovers_end_age.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments `controls') order($treatments `controls')  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))






*--------------------------------------------------------------------------------------------------------
*					TABLE 7.v1 EFFECTS BY INCOME QUARTILES 
*
*---------------------------------------------------------------------------------------------------------

	


	use ECD_compiled.dta, clear 
	
	*Income quartiles of the full sample 
	xtile quart_income=ln_household_income, nq(4)
	
	
	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv

	local controls  zbase_acskill zbase_exfunction Gender base_age_year has_base_acskill has_base_exfunction
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction

forvalues i=1/4 {
	foreach outcome of local outcomes{
		reg `outcome' $treatments `controls' if quart_income==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	
}
}




* See how it looks in Stata - Academic Skills:
esttab zmid_acskill1 zend_acskill1 zmid_acskill2 zend_acskill2 zmid_acskill3 zend_acskill3 zmid_acskill4 zend_acskill4  , se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab  zmid_acskill1 zend_acskill1 zmid_acskill2 zend_acskill2 zmid_acskill3 zend_acskill3 zmid_acskill4 zend_acskill4 using "$results/tables/acskills_inc_quart.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))




* See how it looks in Stata - Executive Function:
esttab zmid_exfunction1 zend_exfunction1 zmid_exfunction2 zend_exfunction2 zmid_exfunction3 zend_exfunction3 zmid_exfunction4, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab  zmid_exfunction1 zend_exfunction1 zmid_exfunction2 zend_exfunction2 zmid_exfunction3 zend_exfunction3 zmid_exfunction4 zend_exfunction4 using "$results/tables/exfunctions_inc_quart.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))




*--------------------------------------------------------------------------------------------------------
*					TABLE 7.v3 EFFECTS BY BASELINE ACSKILL 
*
*---------------------------------------------------------------------------------------------------------


	use ECD_compiled.dta, clear 
	
	*Median base academic skills of full sample
	xtile median_base_acskill=zbase_acskill, nq(2) 



	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv

	local controls zbase_exfunction Gender base_age_year ln_household_income has_base_exfunction
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

forvalues i=1/2 {
	foreach outcome of local outcomes{
		reg `outcome' $treatments `controls' `parents_educ' if median_base_acskill==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	
}
}




* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_acskill1 zend_acskill1 zmid_acskill2 zend_acskill2 zmid_exfunction1 zend_exfunction1 zmid_exfunction2 zend_exfunction2, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill1 zend_acskill1 zmid_acskill2 zend_acskill2 zmid_exfunction1 zend_exfunction1 zmid_exfunction2 zend_exfunction2 using "$results/tables/mainreg_median_acskill.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))



*--------------------------------------------------------------------------------------------------------
*					TABLE 7.v3.2 EFFECTS BY BASELINE ACSKILL 
*				Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------


	use ECD_compiled.dta, clear 
	
	*Median base academic skills of full sample
	xtile median_base_acskill=zbase_acskill, nq(2) 
	label define median_base_acskill 1 "Below" 2 "Above Median"
	label values median_base_acskill median_base_acskill
	label var median_base_acskill "Above median"
	
	



	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv
	
	
	local interactions 1.hvonly#2.median_base_acskill 1.pkonly#2.median_base_acskill 1.pk_hv#2.median_base_acskill
	
	
	local controls median_base_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_exfunction
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

	foreach outcome of local outcomes{
		reg `outcome' $treatments `interactions' `controls' `parents_educ', cluster(VILLAGE_ID)
		eststo `outcome'
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	

}




* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_acskill zend_acskill zmid_exfunction zend_exfunction, se(3) replace label b(3) keep($treatments median_base_acskill `interactions') order($treatments median_base_acskill `interactions'') nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill zend_acskill zmid_exfunction zend_exfunction using "$results/tables/mainreg_median_acskillv2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments median_base_acskill `interactions') order($treatments median_base_acskill `interactions'') nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))








*--------------------------------------------------------------------------------------------------------
*					TABLE 7.v4 EFFECTS BY BASELINE EF
*
*---------------------------------------------------------------------------------------------------------


	use ECD_compiled.dta, clear 
	
	*Median Executive function of full sample 
	xtile median_base_exfunction=zbase_exfunction, nq(2) 



	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv
	
	local controls zbase_acskill Gender base_age_year ln_household_income  has_base_acskill
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

forvalues i=1/2 {
	foreach outcome of local outcomes{
		reg `outcome' $treatments `controls' `parents_educ' if median_base_exfunction==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	
}
}




* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_acskill1 zend_acskill1 zmid_acskill2 zend_acskill2 zmid_exfunction1 zend_exfunction1 zmid_exfunction2 zend_exfunction2, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill1 zend_acskill1 zmid_acskill2 zend_acskill2 zmid_exfunction1 zend_exfunction1 zmid_exfunction2 zend_exfunction2 using "$results/tables/mainreg_median_exfunction.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))




*--------------------------------------------------------------------------------------------------------
*					TABLE 7.v4.2 EFFECTS BY BASELINE EF
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------


	use ECD_compiled.dta, clear 
	
	*Median Executive function of full sample 
	xtile median_base_exfunction=zbase_exfunction, nq(2) 
	label define median_base_exfunction 1 "Below" 2 "Above Median"
	label values median_base_exfunction median_base_exfunction
	label var median_base_exfunction "Above Median"


	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv

	local interactions 1.hvonly#2.median_base_exfunction 1.pkonly#2.median_base_exfunction 1.pk_hv#2.median_base_exfunction
	local controls median_base_exfunction zbase_acskill Gender base_age_year ln_household_income  has_base_acskill
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

	
	foreach outcome of local outcomes{
		reg `outcome' $treatments `interactions' `controls' `parents_educ', cluster(VILLAGE_ID)
		eststo `outcome'
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	

}



* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_acskill zend_acskill zmid_exfunction zend_exfunction, se(3) replace label b(3) keep($treatments median_base_exfunction `interactions') order($treatments median_base_exfunction `interactions'') nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill zend_acskill zmid_exfunction zend_exfunction using "$results/tables/mainreg_median_exfunctionv2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments median_base_exfunction `interactions') order($treatments median_base_exfunction `interactions'') nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))






*--------------------------------------------------------------------------------------------------------
*					TABLE 7.v5 EFFECTS BY GENDER
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------


	use ECD_compiled.dta, clear 
	
	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv

	local interactions 1.hvonly#1.Gender 1.pkonly#1.Gender 1.pk_hv#1.Gender
	local controls zbase_acskill Gender base_age_year ln_household_income  has_base_acskill
	local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

	
	foreach outcome of local outcomes{
		reg `outcome' $treatments `interactions' `controls' `parents_educ', cluster(VILLAGE_ID)
		eststo `outcome'
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	

}



* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_acskill zend_acskill zmid_exfunction zend_exfunction, se(3) replace label b(3) keep($treatments Gender `interactions') order($treatments Gender `interactions') nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill zend_acskill zmid_exfunction zend_exfunction using "$results/tables/mainreg_female_int.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments Gender `interactions') order($treatments Gender `interactions') nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))






*--------------------------------------------------------------------------------------------------------
*					GRAPH 
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------


use ECD_compiled.dta, clear 
	
keep child_treat_status mid_acskill end_acskill mid_exfunction end_exfunction
rename (mid_acskill mid_exfunction) (acskill1 exfunction1)
rename (end_acskill end_exfunction) (acskill2 exfunction2)
collapse acskill1 acskill2 exfunction1 exfunction2, by(child_treat_status)
*reshape long acskill exfunction, i(child_treat_status) j(year)
*reshape wide 

	gen treatment=child_treat_status
 graph bar acskill1 acskill2, over(treatment) legend(pos(6) cols(2) symxsize(4) order(1 "AC skills year 1" 2 "AC skills year 2")) note("1:HV-10 students-1 teacher, 2:HV-20 students-2 teachers, 3:HV-30 students-3 teachers" "4:HV-didn't get HV, 5 HV+preK-10 students-1 teacher, 6:HV+preK-20 students-2 teachers" "7: HV+preK-30 students-3 teacher, 8:HV+preK-only gets preK no HV, 9:Control, 10:Pre-K only") graphregion(color(white)) ylabel(0(5)30, nogrid angle(0))

graph export "$results/graphs/acskills.png", replace  


graph bar exfunction1 exfunction2, over(treatment) legend(pos(6) cols(2) symxsize(4) order(1 "EF skills year 1" 2 "EF skills year 2")) note("1:HV-10 students-1 teacher, 2:HV-20 students-2 teachers, 3:HV-30 students-3 teachers" "4:HV-didn't get HV, 5 HV+preK-10 students-1 teacher, 6:HV+preK-20 students-2 teachers" "7: HV+preK-30 students-3 teacher, 8:HV+preK-only gets preK no HV, 9:Control, 10:Pre-K only") graphregion(color(white)) ylabel(0(5)30, nogrid angle(0))

graph export "$results/graphs/exfunction.png", replace  

 
 
*-------------------------------------------------------------------------------
*						APPENDIX TABLE ATTRITION RATES BY PROGRAM 
*
*------------------------------------------------------------------------------- 

	use ECD_compiled, clear  
	
	*Keep only project children 
	keep if  CT==1 

	*Count attrition
	forvalues i=1/4{
	count if attrited_year1==1 & treat1==`i'
	local attrited_year1_`i'=r(N)
	
	}
	
	*Count continued
	forvalues i=1/4{
	count if attrited_year1==0 & treat1==`i'
	local continued_year2_`i'=r(N)
	
	}
	
	*Count new in Year 1 
	forvalues i=1/4{
	count if added_year2==0 & treat1==`i'
	local added_year1_`i'=r(N)
	
	}
	
	*Count new in Year 2 
	forvalues i=1/4{
	count if added_year2==1 & treat1==`i'
	local added_year2_`i'=r(N)
	
	}
	
	local treatments PK HV PK-HV Control




capture file close st
	
	file open 	st using "$results/tables/attrition.tex", write replace
		*file write 	st _n  "\begin{tabular}{ccc}" 
		*file write 	st _n "\hline \hline \\"
		file write 	st _n "\textbf{Treatment} & \textbf{Added Year 1} & \textbf{Added Year 2} & \textbf{Continued Year 2} & \textbf{Attrited Year 1}  \\ \hline"
		file write 	st  " PK & `added_year1_1' & `added_year2_1' & `continued_year2_1' & `attrited_year1_1' \\  "	
		file write 	st  " HV & `added_year1_2' & `added_year2_2' & `continued_year2_2' & `attrited_year1_2' \\  "
		file write 	st  " PK-HV & `added_year1_3' &  `added_year2_3' & `continued_year2_3' & `attrited_year1_3' \\  "
		file write 	st  " Control & `added_year1_4' & `added_year2_4' & `continued_year2_4' & `attrited_year1_4' \\  "
				*file write 	st _n " \hline"
		
		
		*file write 	st _n "\end{tabular}"
	file close 	st




	
	
	

capture file close st
	
	file open 	st using "interviews.tex", write replace
		*file write 	st _n  "\begin{tabular}{llllllll}" 
		*file write 	st _n "\hline\hline \\"
		file write 	st _n "\textbf{Day} & \textbf{Location} & \textbf{Team} & \textbf{TIK} & \textbf{\# C}  & \textbf{IP} & \textbf{IL} & \textbf{COVID} \\ \hline"
		foreach today of local dates {
			foreach i of local levels{
				file write 	st _n %td (`today') "& `location2_`today'_`i'' & Pura Vida & `puravidatot_`today'_`i'' &  `puravidacal_`today'_`i'' & `puravidaexpint_`today'_`i''  & `puravidaexpinvit_`today'_`i'' & \multirow{2}{*}{`covid_`today''} \\  "
				file write 	st _n %td (`today') "& `location1_`today'_`i'' & Dream Team & `dreamteamtot_`today'_`i'' &  `dreamteamcal_`today'_`i'' & `dreamteamexpint_`today'_`i''  & `dreamteamexpinvit_`today'_`i'' & \\   "
		}
			file write 	st _n " \hline"
		
		}
		
	
		
		*file write 	st _n "\end{tabular}"
	file close 	st

	


**** END **** 

	






***------------------------  /////  ----------------------------***


 
 
 
 
 
 
 
 
 /*
 
 
 /*****************************************************************************************************************************************************
 
												POTENTIAL APPENDIX TABLES 
												(Tables based on tables above)
 ***************************************************************************************************************************************************/
 

*--------------------------------------------------------------------------------------------------------
*							PRELIMINARY REGRESSIONS - INCLUDING SELF-REPORTED SURVEY
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
esttab  est1 est2 est3 est4 est5 est6 using "$results/tables/reg1_std_all.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant extracols(4 7) nogaps



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










