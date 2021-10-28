
/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: MAIN ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 7/10/2021
LAST MODIFIED: 

PURPOSE: Main analysis manipulationg the sample: 
1. Removing kids that are in families without project children 
2. Removing kids that are in families with more than one project children 
3. Using CT_actual instead of CT 

Based on 4.main-regs. Generates the tables and figures in pdf "alt-specs.tex"

REQUIREMENTS: Run 0.master.do to set paths correctly. 

------------------------------------------------------------------------------*/




*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 

	set scheme s2mono 
	

	cd "$output"
	
	use ECD_compiled.dta, clear 
 

*-------------------------------------------------------------------------------------------------------------------------
*						TABLE 3. - ITT - ORIGINAL (Same as 4.main-regs)
* 			
*	Eliminating kids added on year 2, keeping only those that continued. Assigning 0 to missing values in baseline scores 
*--------------------------------------------------------------------------------------------------------------------------

	
	use ECD_compiled.dta, clear 
	
	*Keep relevant observations 
	keep if  proj_child==1
	*dropping those children that are in HV-Didn't get HV and HV+prek - Only gets Prek 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}


	eststo clear 
	global treatments hvonly pkonly pk_hv
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 
 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/reg1_std_v3.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 


	

*-------------------------------------------------------------------------------------------------------------------------
*						TABLE 3. - ITT - ALTERNATIVE SPEC - V1 
* 			V1. Eliminatiing those 388 kids that have more than 1 proj_child per family (RECORD ID)
*	Eliminating kids added on year 2, keeping only those that continued. Assigning 0 to missing values in baseline scores 
*--------------------------------------------------------------------------------------------------------------------------

	
	use ECD_compiled.dta, clear 
	
	drop if num_proj_child_recid==3
	
	*Keep relevant observations 
	keep if  proj_child==1
	*dropping those children that are in HV-Didn't get HV and HV+prek - Only gets Prek 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}


	eststo clear 
	global treatments hvonly pkonly pk_hv
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 
 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/itt_altreg_v1.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 



*-------------------------------------------------------------------------------------------------------------------------
*						TABLE 2. - ITT - ALTERNATIVE SPECIFICATION V2 
* 			V2. USING THE NEW CT_ACTUAL 
*	Eliminating kids added on year 2, keeping only those that continued. Assigning 0 to missing values in baseline scores 
*--------------------------------------------------------------------------------------------------------------------------

	
	use ECD_compiled.dta, clear 

	
	
	*Keep relevant observations using CT_actual
	keep if  CT_actual==1
	
	*dropping those children that are in HV-Didn't get HV and HV+prek - Only gets Prek 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}


	eststo clear 
	global treatments hvonly pkonly pk_hv
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 
 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/itt_altreg_v2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 





*-------------------------------------------------------------------------------
*			TABLE 4. REGRESSION  - TOT - ORIGINAL 
*
*------------------------------------------------------------------------------- 

	use ECD_compiled.dta, clear 
	
	*Keep relevant observations 
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	
	eststo clear 
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	global treatments ts_2017_2018_hv_only ts_2017_2018_pk_only ts_2017_2018_pk_hv
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
	
	label var ts_2017_2018_hv_only "Home Visit Only"
	label var ts_2017_2018_pk_only "Pre-K Only"
	label var ts_2017_2018_pk_hv "Pre-K + HV "
 

	 **** WITH THE RATE  ****
	
	
 
 *Without controls 
 foreach outcome of local outcomes{
	ivregress 2sls `outcome'  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo 
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}

 
 
 *With controls 
foreach outcome of local outcomes{
	ivregress 2sls `outcome' $controls  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo 
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}


* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/tot_rate.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 


	


*-------------------------------------------------------------------------------
*			TABLE 5. REGRESSION  - TOT - ALTERNATIVE SPEC - V1 
*		Eliminating the kids without proj_child in their family 
*------------------------------------------------------------------------------- 

	use ECD_compiled.dta, clear 
	
	drop if num_proj_child_recid==3


	*Keep relevant observations 
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	
	eststo clear 
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	global treatments ts_2017_2018_hv_only ts_2017_2018_pk_only ts_2017_2018_pk_hv
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
	
	label var ts_2017_2018_hv_only "Home Visit Only"
	label var ts_2017_2018_pk_only "Pre-K Only"
	label var ts_2017_2018_pk_hv "Pre-K + HV "
 

	 **** WITH THE RATE  ****
	
	
 
 *Without controls 
 foreach outcome of local outcomes{
	ivregress 2sls `outcome'  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo 
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}

 
 
 *With controls 
foreach outcome of local outcomes{
	ivregress 2sls `outcome' $controls  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo 
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}


* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/tot_rate_altspec_v1.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 


	

*-------------------------------------------------------------------------------
*			TABLE 5. REGRESSION  - TOT - ALTERNATIVE SPEC - V2
*						Using CT_actual
*------------------------------------------------------------------------------- 

	use ECD_compiled.dta, clear 
	
	
	*Keep relevant observations using CT_actual
	keep if  CT_actual==1
	
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	
	eststo clear 
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	global treatments ts_2017_2018_hv_only ts_2017_2018_pk_only ts_2017_2018_pk_hv
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
	
	label var ts_2017_2018_hv_only "Home Visit Only"
	label var ts_2017_2018_pk_only "Pre-K Only"
	label var ts_2017_2018_pk_hv "Pre-K + HV "
 

	 **** WITH THE RATE  ****
	
	
 
 *Without controls 
 foreach outcome of local outcomes{
	ivregress 2sls `outcome'  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo 
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}

 
 
 *With controls 
foreach outcome of local outcomes{
	ivregress 2sls `outcome' $controls  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo 
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}


* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/tot_rate_altspec_v2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 







*-------------------------------------------------------------------------------
*			TABLE 6. SPILLOVER EFFECTS
* 				(Version 2)
*	Eliminating kids added on year 2, assigning 0 to missing values in baseline scores 
*------------------------------------------------------------------------------- 



	use ECD_compiled.dta, clear 

	*Keep relevant observations 
	keep if proj_child==1
	keep if  child_treat_status==4 | child_treat_status==8 | child_treat_status==9 
	
	*Keep only those added at year 1
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	


eststo clear 
global  treatmentshv HV_10 HV_20 HV_30
global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 *Without controls
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}


*With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  
	  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8  using "$results/tables/reg3_spilloversv2.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 







*-------------------------------------------------------------------------------
*			TABLE 7. SPILLOVER EFFECTS - ALTERNATIVE SPECIFICATION VERSION 1 
* 			
*	Eliminating kids added on year 2, assigning 0 to missing values in baseline scores 
*------------------------------------------------------------------------------- 



	use ECD_compiled.dta, clear 
	
	drop if num_proj_child_recid==3


	*Keep relevant observations 
	keep if proj_child==1
	keep if  child_treat_status==4 | child_treat_status==8 | child_treat_status==9 
	
	*Keep only those added at year 1
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	


eststo clear 
global  treatmentshv HV_10 HV_20 HV_30
global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 *Without controls
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}


*With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  
	  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8  using "$results/tables/spillovers1_altspecs_v1.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 







*-------------------------------------------------------------------------------
*			TABLE 8. SPILLOVER EFFECTS - ALTERNATIVE SPECIFICATION VERSION 2 
* 			
*	Eliminating kids added on year 2, assigning 0 to missing values in baseline scores 
*------------------------------------------------------------------------------- 



	use ECD_compiled.dta, clear 
	

	
	*Keep relevant observations using CT_actual
	keep if  CT_actual==1
	
	keep if  child_treat_status==4 | child_treat_status==8 | child_treat_status==9 
	
	*Keep only those added at year 1
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	


eststo clear 
global  treatmentshv HV_10 HV_20 HV_30
global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 *Without controls
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}


*With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  
	  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8  using "$results/tables/spillovers1_altspecs_v2.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 


*-------------------------------------------------------------------------------
*			TABLE 9. SPILLOVER EFFECTS - SIBLINGS AND COUSINS - ORIGINAL 
*
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*------------------------------------------------------------------------------- 


use ECD_compiled.dta, clear 


*Keep only siblings and cousings (and all kids in control group)
keep if (proj_child!=1  & treat1!=4) | treat1==4 
*Keep only those added in year2 (only 50 siblings were added in year1)
*keep if added_year2==1


gen siblings_PK=1 if treat1==1 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_PK=0 if missing(siblings_PK) 

gen siblings_HV=1 if treat1==2 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HV=0 if missing(siblings_HV)

gen siblings_HVPK=1 if treat1==3 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HVPK=0 if missing(siblings_HVPK) 


label var siblings_PK "Sibling of PK treated kid"
label var siblings_HV "Sibling of HV treated kid"
label var siblings_HVPK "Sibling of HVPK treated kid"

*Generating age variables 
gen group_age=1 if base_age_year<=2 
replace group_age=2 if base_age_year>2 & base_age_year<=5 
replace group_age=3 if base_age_year>5 
label define group_age 1 "0-2" 2 "3-5" 3 "6-8"
label values group_age group_age 

save temp.dta, replace 

 
	
eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction




 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/reg4_spillovers.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*-------------------------------------------------------------------------------------------------------
*			TABLE 10. SPILLOVER EFFECTS - SIBLINGS AND COUSINS - ALTERNATIVE SPECIFICATIONS - V1
*	Dropping those that are in families with more than one project child 
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*---------------------------------------------------------------------------------------------------------


use ECD_compiled.dta, clear 


*Keep only siblings and cousings (and all kids in control group)
keep if (proj_child!=1  & treat1!=4) | treat1==4 
*Keep only those added in year2 (only 50 siblings were added in year1)
*keep if added_year2==1

drop if num_proj_child_recid==3


gen siblings_PK=1 if treat1==1 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_PK=0 if missing(siblings_PK) 

gen siblings_HV=1 if treat1==2 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HV=0 if missing(siblings_HV)

gen siblings_HVPK=1 if treat1==3 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HVPK=0 if missing(siblings_HVPK) 


label var siblings_PK "Sibling of PK treated kid"
label var siblings_HV "Sibling of HV treated kid"
label var siblings_HVPK "Sibling of HVPK treated kid"

*Generating age variables 
gen group_age=1 if base_age_year<=2 
replace group_age=2 if base_age_year>2 & base_age_year<=5 
replace group_age=3 if base_age_year>5 
label define group_age 1 "0-2" 2 "3-5" 3 "6-8"
label values group_age group_age 



 

	
eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction




 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/siblings_spillovers_altspec_v1.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 






*-------------------------------------------------------------------------------------------------------
*			TABLE 11. SPILLOVER EFFECTS - SIBLINGS AND COUSINS - ALTERNATIVE SPECIFICATIONS - V2
*	Dropping those that are in families with no project child 
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*---------------------------------------------------------------------------------------------------------


use ECD_compiled.dta, clear 


*Keep only siblings and cousings (and all kids in control group)
keep if (proj_child!=1  & treat1!=4) | treat1==4 
*Keep only those added in year2 (only 50 siblings were added in year1)
*keep if added_year2==1

drop if num_proj_child_recid==2


gen siblings_PK=1 if treat1==1 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_PK=0 if missing(siblings_PK) 

gen siblings_HV=1 if treat1==2 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HV=0 if missing(siblings_HV)

gen siblings_HVPK=1 if treat1==3 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HVPK=0 if missing(siblings_HVPK) 


label var siblings_PK "Sibling of PK treated kid"
label var siblings_HV "Sibling of HV treated kid"
label var siblings_HVPK "Sibling of HVPK treated kid"

*Generating age variables 
gen group_age=1 if base_age_year<=2 
replace group_age=2 if base_age_year>2 & base_age_year<=5 
replace group_age=3 if base_age_year>5 
label define group_age 1 "0-2" 2 "3-5" 3 "6-8"
label values group_age group_age 


 

	
eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction




 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/siblings_spillovers_altspec_v2.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 





*-------------------------------------------------------------------------------------------------------
*			TABLE 12. SPILLOVER EFFECTS - SIBLINGS AND COUSINS - ALTERNATIVE SPECIFICATIONS - V3
*	Dropping those that are in families with no project child or more than one 
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*---------------------------------------------------------------------------------------------------------


use ECD_compiled.dta, clear 


*Keep only siblings and cousings (and all kids in control group)
keep if (proj_child!=1  & treat1!=4) | treat1==4 
*Keep only those added in year2 (only 50 siblings were added in year1)
*keep if added_year2==1

drop if num_proj_child_recid==2 | num_proj_child_recid==3


gen siblings_PK=1 if treat1==1 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_PK=0 if missing(siblings_PK) 

gen siblings_HV=1 if treat1==2 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HV=0 if missing(siblings_HV)

gen siblings_HVPK=1 if treat1==3 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HVPK=0 if missing(siblings_HVPK) 


label var siblings_PK "Sibling of PK treated kid"
label var siblings_HV "Sibling of HV treated kid"
label var siblings_HVPK "Sibling of HVPK treated kid"

*Generating age variables 
gen group_age=1 if base_age_year<=2 
replace group_age=2 if base_age_year>2 & base_age_year<=5 
replace group_age=3 if base_age_year>5 
label define group_age 1 "0-2" 2 "3-5" 3 "6-8"
label values group_age group_age 

save temp2.dta, replace 
 

	
eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction




 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/siblings_spillovers_altspec_v3.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 










*-------------------------------------------------------------------------------------------------------
*			TABLE 13. SPILLOVER EFFECTS - SIBLINGS AND COUSINS - ALTERNATIVE SPECIFICATIONS - V4
*	With CT_actual
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*---------------------------------------------------------------------------------------------------------


use ECD_compiled.dta, clear 


*Keep only siblings and cousings (and all kids in control group) using CT_actual 
keep if (CT_actual!=1  & treat1!=4) | treat1==4 
*Keep only those added in year2 (only 50 siblings were added in year1)
*keep if added_year2==1



gen siblings_PK=1 if treat1==1 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_PK=0 if missing(siblings_PK) 

gen siblings_HV=1 if treat1==2 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HV=0 if missing(siblings_HV)

gen siblings_HVPK=1 if treat1==3 & (child_treat_status!=4 & child_treat_status!=8) 
replace siblings_HVPK=0 if missing(siblings_HVPK) 


label var siblings_PK "Sibling of PK treated kid"
label var siblings_HV "Sibling of HV treated kid"
label var siblings_HVPK "Sibling of HVPK treated kid"

*Generating age variables 
gen group_age=1 if base_age_year<=2 
replace group_age=2 if base_age_year>2 & base_age_year<=5 
replace group_age=3 if base_age_year>5 
label define group_age 1 "0-2" 2 "3-5" 3 "6-8"
label values group_age group_age 


 

	
eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction




 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/siblings_spillovers_altspec_v4.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 






*-------------------------------------------------------------------------------------------------------
*			TABLE 14. SIBLINGS SPILLOVERS BY AGE 
*
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*---------------------------------------------------------------------------------------------------------



use temp.dta, clear 


eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction


	foreach outcome of local outcomes{
		forvalues i=1/3{
		reg `outcome' $treatments `controls' if group_age==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		estadd scalar r_squared = e(r2)
		}
	
}



* See how it looks in Stata:

esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3, se(3) replace label b(3) keep($treatments ) constant nogaps 

	  
*Fragment for tex 



esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3 using "$results/tables/siblings_reg_spillovers_mid_age.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments )  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


	
	
* See how it looks in Stata:

esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3, se(3) replace label b(3) keep($treatments ) constant nogaps

  
*Fragment for tex 



esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3 using "$results/tables/siblings_reg_spillovers_end_age.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments )  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


 
 
 
 
*-------------------------------------------------------------------------------------------------------
*			TABLE 15. SIBLINGS SPILLOVERS BY AGE 
*
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*---------------------------------------------------------------------------------------------------------



use temp2.dta, clear 


eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction


	foreach outcome of local outcomes{
		forvalues i=1/3{
		reg `outcome' $treatments `controls' if group_age==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		estadd scalar r_squared = e(r2)
		}
	
}



* See how it looks in Stata:

esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3, se(3) replace label b(3) keep($treatments ) constant nogaps 

	  
*Fragment for tex 



esttab zmid_acskill1 zmid_exfunction1 zmid_acskill2 zmid_exfunction2 zmid_acskill3 zmid_exfunction3 using "$results/tables/siblings_reg_spillovers_mid_age_altspec_v3.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments )  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


	
	
* See how it looks in Stata:

esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3, se(3) replace label b(3) keep($treatments ) constant nogaps

  
*Fragment for tex 



esttab zend_acskill1 zend_exfunction1 zend_acskill2 zend_exfunction2 zend_acskill3 zend_exfunction3 using "$results/tables/siblings_reg_spillovers_end_age_altspec_v3.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments )  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


 





**** END **** 
