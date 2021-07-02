

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
*			TABLE 3. REGRESSION - ITT 
*
*------------------------------------------------------------------------------- 

	

	use ECD_compiled.dta, clear 
	
	keep if  CT==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	

	*STANDARDIZED - MAIN RESULTS 
	eststo clear 
	*global treatments homevisit2 preschool2 both2 
	global treatments hvonly pkonly pk_hv

	local controls  zbase_acskill zbase_exfunction Gender base_age_year 
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
foreach outcome of local outcomes{
	reg `outcome' $treatments `controls', cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}




* See how it looks in Stata:
esttab est1 est2 est3 est4 , se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant extracols(4 7) nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(3 3 3 0)) nogaps  
	  	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg1_std.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments  `controls') order($treatments  `controls') constant extracols(4 7) nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0))



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
*			TABLE 5. SPILLOVER EFFECTS
*
*------------------------------------------------------------------------------- 

	

*  STANDARDIZED - MAIN RESULTS - HV and HVPK 



use ECD_compiled.dta, clear 


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



* See how it looks in Stata:
esttab est1 est2 est3 est4, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant extracols(4 7) nogaps stats(r_squared N, fmt(3 0))
	  
	  
*Fragment for tex 
esttab  est1 est2 est3 est4 using "$results/tables/reg3_spillovers.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatmentshv $treatmentshvpk `controls') order($treatmentshv  $treatmentshvpk `controls') constant extracols(4 7) nogaps


*--------------------------------------------------------------------------------------------------------
*					TABLE 6. SPILLOVER REGRESSIONS - SIBILLINGS 
*
*---------------------------------------------------------------------------------------------------------


*2. SIBILLINGS AND COUSINS 

use ECD_compiled.dta, clear 


*Apparently there are only sibilings of untreated kids. Is there a possibility that the sibilings are categorized as project child? 
tab child_treat_status CT


/*
*a. spillovers of HV program on siblings

keep if CT!=1

gen siblings_HV=1 if treat1==2 & (child_treat_status!=4 & child_treat_status!=8) 
gen sibilings_HVPK=1 if treat1==3 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HV=0 if missing(siblings_HV)
replace sibilings_HVPK=0 if missing(sibilings_HVPK)

label var siblings_HV "Sibling of HV kid"
label var sibilings_HVPK "Sibling of HVPK kid"

*Generating age variables 
gen group_age=1 if base_age_year<=2 
replace group_age=2 if base_age_year>2 & base_age_year<=5 
replace group_age=3 if base_age_year>5 
label define group_age 1 "0-2" 2 "3-5" 3 "6-8"
label values group_age group_age 


*  STANDARDIZED - SIBLINGS 
eststo clear 
local controls  Gender base_age_year 
global treatments siblings_HV sibilings_HVPK
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 
	foreach outcome of local outcomes{
		reg `outcome' $treatments `controls', cluster(VILLAGE_ID)
		eststo  
		estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est2 est3 est4, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps

	  
*Fragment for tex 
esttab est1 est2 est3 est4 using "$results/tables/reg4_spillovers.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments) order($treatments)  constant extracols(4 7) nogaps


*  STANDARDIZED - SIBLINGS - BY GROUP AGE 
eststo clear 
local controls  Gender 
global treatments siblings_HV sibilings_HVPK
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 
	foreach outcome of local outcomes{
		forvalues i=1/3{
		reg `outcome' $treatments `controls' if group_age==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		estadd scalar r_squared = e(r2)
		}
	
}



* See how it looks in Stata:

esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls')  constant nogaps 

	  
*Fragment for tex 



esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3 using "$results/tables/reg4_spillovers_mid_age.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments) order($treatments)  constant extracols(4 7) nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


	
	
* See how it looks in Stata:

esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls') constant nogaps

  
*Fragment for tex 



esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3 using "$results/tables/reg4_spillovers_end_age.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments) order($treatments)  constant extracols(4 7) nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


*/


	
	
	
	
	
	


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










