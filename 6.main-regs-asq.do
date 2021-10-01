/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: MAIN ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 21/07/2021
LAST MODIFIED: 

PURPOSE: Main analysis. Based on 4.main-regs. Generates the same tables of 4.main-regs but 
for ASQ. 

REQUIREMENTS: Run 0.master.do to set paths correctly. 

------------------------------------------------------------------------------*/




*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 

	set scheme s2mono 
	
	*import excel "$input/full_child_list.xlsx", sheet("Sheet1") firstrow clear 
	
	*save "$output/ECD_compiled_v2", replace 


	cd "$output"
	

	use ECD_compiled, clear  

	
	

      

                
*-------------------------------------------------------------------------------
*						TABLE 1. DESCRIPTIVE STATISTICS 
*
*------------------------------------------------------------------------------- 

	global desc "Gender base_age_year father_education mother_education household_income treated child_type base_asq_gm base_asq_fm base_asq_comm base_asq_prbs base_asq_psc base_asq_overall "


	eststo homevisit: estpost summarize $desc if treat1==2
	eststo preschool: estpost summarize $desc if treat1==1
	eststo both: estpost summarize $desc if treat1==3
	eststo control: estpost summarize $desc if treat1==4



* See how it looks in Stata:
	esttab control homevisit preschool both, mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label


*In tex: 
	esttab control homevisit preschool both using "$results/tables/descstats_asq.tex", mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label frag replace 
	
	
	


*-------------------------------------------------------------------------------------------------------------------------
*						TABLE 3. - ITT 
* 							(Version 3) 
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
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	

	eststo clear 
	global treatments hvonly pkonly pk_hv
	global controls  zbase_gm  zbase_fm zbase_comm zbase_prbs zbase_psc Gender base_age_year ln_household_income has_base_gm has_base_fm has_base_comm has_base_prbs has_base_psc father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	
	
	local variables gm fm comm prbs psc overall
	foreach var of local variables {
	local outcomes_`var' zmid_`var' zend_`var' 
	global controls  zbase_`var' Gender base_age_year ln_household_income has_base_`var' father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	}
 
 
 *Without controls 
 
 local outcomes  outcomes_gm  outcomes_fm  outcomes_comm  outcomes_prbs  outcomes_psc  outcomes_overall 
 
 foreach var of local outcomes{
 	foreach outcome of local `var'{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo `outcome'_nc
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	
}
}

 
 
 *With controls 
foreach var of local outcomes{
 	foreach outcome of local `var'{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo `outcome'_c
	test hvonly=pkonly
	estadd scalar p_diff1 = r(p)
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	test pkonly=pk_hv 
	estadd scalar p_diff3 = r(p)
	}
}


*GM 

* See how it looks in Stata:
esttab zmid_gm_nc zmid_gm_c zend_gm_nc zend_gm_c, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   zmid_gm_nc zmid_gm_c zend_gm_nc zend_gm_c using "$results/tables/reg1_std_gm.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*FM

* See how it looks in Stata:
esttab zmid_fm_nc zmid_fm_c zend_fm_nc zend_fm_c, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	


*Communication Skills 

*Fragment for tex 
esttab   zmid_comm_nc zmid_comm_c zend_comm_nc zend_comm_c using "$results/tables/reg1_std_comm.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 



*Problem Solving 

*Fragment for tex 
esttab   zmid_prbs_nc zmid_prbs_c zend_prbs_nc zend_prbs_c using "$results/tables/reg1_std_prbs.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 



*Fragment for tex 
esttab   zmid_psc_nc zmid_psc_c zend_psc_nc zend_psc_c using "$results/tables/reg1_std_psc.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 



*Fragment for tex 
esttab   zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c using "$results/tables/reg1_std_overall.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 







*-------------------------------------------------------------------------------
*			TABLE 4. REGRESSION  - TOT 
*
*------------------------------------------------------------------------------- 

	use ECD_compiled.dta, clear 
	
	
	
	*Keep relevant observations 
	keep if  proj_child==1
	*dropping those children that are in HV-Didn't get HV and HV+prek - Only gets Prek 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	

	**** SIMPLE OLS **** 
	
	
	eststo clear 
	global controls  zbase_overall Gender base_age_year ln_household_income has_base_overall father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	global treatments ts_2017_2018_hv_only ts_2017_2018_pk_only ts_2017_2018_pk_hv
	local outcomes zmid_overall zend_overall
	
	label var ts_2017_2018_hv_only "Home Visit Only"
	label var ts_2017_2018_pk_only "Pre-K Only"
	label var ts_2017_2018_pk_hv "Pre-K + HV "
 
 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo `outcome'_nc
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo `outcome'_c
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}



* See how it looks in Stata:
esttab zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c using "$results/tables/simple_ols_asq.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 

	
	

**** WITH THE RATE - IV ****
	
	
 eststo clear 
 *Without controls 
 foreach outcome of local outcomes{
	ivregress 2sls `outcome'  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo `outcome'_nc
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
	eststo `outcome'_c
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}


* See how it looks in Stata:
esttab zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c, se(3) replace label b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  


*Fragment for tex 
esttab   zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c using "$results/tables/tot_rate_asq.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 






*-------------------------------------------------------------------------------
*			TABLE 5. SPILLOVER EFFECTS
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
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}


	eststo clear 
	global  treatmentshv HV_10 HV_20 HV_30
	global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
	global controls  zbase_overall Gender base_age_year ln_household_income has_base_overall father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_overall zend_overall
 
 *Without controls
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk, cluster(VILLAGE_ID)
	eststo `outcome'_nc
	estadd scalar r_squared = e(r2)
	
}


*With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatmentshv  $treatmentshvpk $controls, cluster(VILLAGE_ID)
	eststo `outcome'_c
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  
	  
*Fragment for tex 
esttab zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c using "$results/tables/reg3_spilloversv2_asq.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*-------------------------------------------------------------------------------
*			TABLE 6. SPILLOVER EFFECTS - SIBLINGS AND COUSINS
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
local outcomes zmid_overall zend_overall 



 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo `outcome'_nc
	estadd scalar r_squared = e(r2)
}

 
 
 *With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo `outcome'_c
	estadd scalar r_squared = e(r2)
	
}



* See how it looks in Stata:
esttab zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

  
*Fragment for tex 
esttab zmid_overall_nc zmid_overall_c zend_overall_nc zend_overall_c using "$results/tables/reg4_spillovers_asq.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*-------------------------------------------------------------------------------
*				TABLE 7. TEST SCORES BY AGE GROUP - SIBLINGS/COUSINS
*
*------------------------------------------------------------------------------- 


	use temp.dta, clear 
	keep   mid_asq_overall end_asq_overall siblings_HV siblings_PK siblings_HVPK group_age
	gen id=_n 
	reshape wide mid_asq_overall end_asq_overall, i(id) j(group_age)
	global desc "mid_asq_overall1 end_asq_overall1 mid_asq_overall2 end_asq_overall2 mid_asq_overall3 end_asq_overall3"
	
	
	label var mid_asq_overall1 "End Y1 ASQ - 0-2 years"
	label var end_asq_overall1 "End Y2 ASQ - 0-2 years"
	label var mid_asq_overall2 "End Y1 ASQ - 3-5 years"
	label var end_asq_overall2 "End Y2 ASQ - 3-5 years"
	label var mid_asq_overall3 "End Y1 ASQ - 6-8 years"
	label var end_asq_overall3 "End Y2 ASQ - 6-8 years"
	
		


	eststo homevisit: estpost summarize $desc if siblings_HV==1
	eststo preschool: estpost summarize $desc if siblings_PK==1
	eststo both: estpost summarize $desc if siblings_HVPK==1
	eststo control: estpost summarize $desc if siblings_HV==0 & siblings_PK==0 & siblings_HVPK==0 


	
* See how it looks in Stata:
	esttab control preschool homevisit both, mtitles("Control"  "Siblings PK" "Siblings HV" "Siblings HV and PK") cells("count(label(N) pattern(1 1 1) fmt(0)) mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label


*In tex: 
	esttab control homevisit preschool both using "$results/tables/siblings_age_groups_asq.tex", mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("count(label(N) pattern(1 1 1) fmt(0)) mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label frag replace 

	
	

*--------------------------------------------------------------------------------------------------------
*					TABLE 8 EFFECTS BY BASELINE ASQ 
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------


	use ECD_compiled.dta, clear 
	
	*Median base ASQ of full sample
	xtile median_base_overall=zbase_overall, nq(2) 
	label define median_base_overall 1 "Below" 2 "Above Median"
	label values median_base_overall median_base_overall
	label var median_base_overall "Above median"
	
	
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol median_base_overall
	global interactions 1.hvonly#2.median_base_overall 1.pkonly#2.median_base_overall 1.pk_hv#2.median_base_overall
	global controls  Gender base_age_year ln_household_income father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_overall zend_overall 

	

*Without controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions, cluster(VILLAGE_ID)
		eststo `outcome'_wo
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	

}

*With controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions $controls, cluster(VILLAGE_ID)
		eststo `outcome'_w
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)	
}




* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab   zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w using "$results/tables/mainreg_median_overallasq.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 





*--------------------------------------------------------------------------------------------------------
*					TABLE 9. EFFECTS BY GENDER
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------

	use ECD_compiled.dta, clear 
	
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}

	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol Gender
	global interactions 1.hvonly#1.Gender 1.pkonly#1.Gender 1.pk_hv#1.Gender
	global controls zbase_overall base_age_year ln_household_income has_base_overall father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_overall zend_overall 
	

*Without controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions, cluster(VILLAGE_ID)
		eststo `outcome'_wo
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	

}

*With controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions $controls, cluster(VILLAGE_ID)
		eststo `outcome'_w
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)	
}




* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab  zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w using "$results/tables/mainreg_female_int_asq.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*--------------------------------------------------------------------------------------------------------
*					TABLE 10. EFFECTS BY HOUSEHOLD INCOME
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------

	use ECD_compiled.dta, clear 
	
	*Median household income of full sample 
	xtile median_income=household_income, nq(2) 
	label define median_income 1 "Below" 2 "Above Median"
	label values median_income median_income
	label var median_income "Above Median"
	
	
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}

	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol median_income
	global interactions 1.hvonly#2.median_income 1.pkonly#2.median_income 1.pk_hv#2.median_income
	global controls zbase_overall base_age_year ln_household_income has_base_overall father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_overall zend_overall 

	
*Without controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions, cluster(VILLAGE_ID)
		eststo `outcome'_wo
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	

}

*With controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions $controls, cluster(VILLAGE_ID)
		eststo `outcome'_w
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)	
}




* See how it looks in Stata - Academic Skills and Executive Function:
esttab zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab  zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w using "$results/tables/mainreg_median_income_asq.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*--------------------------------------------------------------------------------------------------------
*					TABLE 11. EFFECTS BY MOTHER EDUCATION
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------

	use ECD_compiled.dta, clear 
	
	*Median mother education of full sample 
	xtile median_mother_educ=mother_education, nq(2) 
	label define median_mother_educ 1 "Below" 2 "Above Median"
	label values median_mother_educ median_mother_educ
	label var median_mother_educ "Above Median"
	
	
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
*Assigning 0 to missing at baseline 
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}

	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol median_mother_educ
	global interactions 1.hvonly#2.median_mother_educ 1.pkonly#2.median_mother_educ 1.pk_hv#2.median_mother_educ
	global controls zbase_overall base_age_year ln_household_income has_base_overall father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_overall zend_overall 

	
*Without controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions, cluster(VILLAGE_ID)
		eststo `outcome'_wo
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)
	

}

*With controls 
	foreach outcome of local outcomes{
		reg `outcome' $treatments $maincontrol $interactions $controls, cluster(VILLAGE_ID)
		eststo `outcome'_w
		test hvonly=pkonly
		estadd scalar p_diff1 = r(p)
		test hvonly=pk_hv 
		estadd scalar p_diff2 = r(p)
		test pkonly=pk_hv 
		estadd scalar p_diff3 = r(p)	
}




* See how it looks in Stata - Academic Skills and Executive Function:
esttab  zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab    zmid_overall_wo zmid_overall_w zend_overall_wo zend_overall_w using "$results/tables/mainreg_median_mother_educ_asq.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 






*--------------------------------------------------------------------------------------------------------
*					TABLE 12. SIBLINGS - BY GROUP AGE 
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------


use ECD_compiled.dta, clear 

keep if  proj_child!=1 	
	*Keep only those added at year 1
	keep if added_year2==1
	
	*Assigning 0 to missing at baseline 
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
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


	

eststo clear 
local controls Gender ln_household_income
local parents_educ father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_HV siblings_HVPK
local outcomes zmid_overall zend_overall

	foreach outcome of local outcomes{
		forvalues i=1/3{
		reg `outcome' $treatments `controls' `parents_educ' if group_age==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'
		estadd scalar r_squared = e(r2)
		}
	
}



* See how it looks in Stata:

esttab zmid_overall1 zend_overall1 zmid_overall2 zend_overall2 zmid_overall3 zend_overall3, se(3) replace label b(3) keep($treatments `controls') order($treatments `controls')  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0))

	  
*Fragment for tex 



esttab zmid_overall1 zend_overall1 zmid_overall2 zend_overall2 zmid_overall3 zend_overall3  using "$results/tables/reg_spillovers_asq_age.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments `controls') order($treatments `controls')  constant nogaps mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


	
	
*------------------------------------------------------------------------------- 	
*-------------------------------------------------------------------------------
*						ADDITIONAL TABLES 
*
*------------------------------------------------------------------------------- 
*------------------------------------------------------------------------------- 



*-------------------------------------------------------------------------------
*			TABLE 13. REGRESSION  - TOT for dissagregated measures
*
*------------------------------------------------------------------------------- 

	use ECD_compiled.dta, clear 
	
	
	
	*Keep relevant observations 
	keep if  proj_child==1
	*dropping those children that are in HV-Didn't get HV and HV+prek - Only gets Prek 
	drop if  child_treat_status==4 | child_treat_status==8  
	keep if added_year2==0
	*drop if Project_continuation=="No" & treat1!=4
	
	*Assigning 0 to missing at baseline 
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	label var ts_2017_2018_hv_only "Home Visit Only"
	label var ts_2017_2018_pk_only "Pre-K Only"
	label var ts_2017_2018_pk_hv "Pre-K + HV "
 
 


	local variables gm fm comm prbs psc
	foreach var of local variables {
	local outcomes_`var' zmid_`var' zend_`var' 
	global controls  zbase_`var' Gender base_age_year ln_household_income has_base_`var' father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	}
 
 **** WITH THE RATE - IV ****

 *Without controls 
 
 local outcomes  outcomes_gm  outcomes_fm  outcomes_comm  outcomes_prbs  outcomes_psc  
 
 foreach var of local outcomes{
 	foreach outcome of local `var'{
	ivregress 2sls `outcome'  (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo `outcome'_nc
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}
}

 *With controls 
 foreach var of local outcomes{
 	foreach outcome of local `var'{
	ivregress 2sls `outcome' $controls   (ts_2017_2018_pk_only ts_2017_2018_hv_only ts_2017_2018_pk_hv=pkonly hvonly pk_hv), vce(cluster VILLAGE_ID)
	eststo `outcome'_c
	test ts_2017_2018_hv_only=ts_2017_2018_pk_only
	estadd scalar p_diff1 = r(p)
	test ts_2017_2018_hv_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff2 = r(p)
	test ts_2017_2018_pk_only=ts_2017_2018_pk_hv 
	estadd scalar p_diff3 = r(p)
	
}
}

	


*GM 

* See how it looks in Stata:
esttab zmid_gm_nc zmid_gm_c zend_gm_nc zend_gm_c, se(3) replace label b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  

		  
local variables gm fm comm prbs psc
	foreach var of local variables {
*Fragment for tex 
esttab   zmid_`var'_nc zmid_`var'_c zend_`var'_nc zend_`var'_c using "$results/tables/tot_rate_`var'.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 

	}


	
	


*-------------------------------------------------------------------------------
*			TABLE 14. SPILLOVER EFFECTS - DISSAGREGATED (SAME TABLE 5)
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
	local baseline gm fm comm prbs psc overall 
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(zbase_`var')
	replace zbase_`var'=0 if missing(zbase_`var')
	}


	eststo clear 
	global  treatmentshv HV_10 HV_20 HV_30
	global treatmentshvpk HVPK_10 HVPK_20 HVPK_30
	
	

	local variables gm fm comm prbs psc
	foreach var of local variables {
	local outcomes_`var' zmid_`var' zend_`var' 
	global controls  zbase_`var' Gender base_age_year ln_household_income has_base_`var' father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	}
 

 
 local outcomes  outcomes_gm  outcomes_fm  outcomes_comm  outcomes_prbs  outcomes_psc  
  *Without controls
 foreach var of local outcomes{
 	foreach outcome of local `var'{
	reg `outcome' $treatmentshv  $treatmentshvpk, cluster(VILLAGE_ID)
	eststo `outcome'_nc
	estadd scalar r_squared = e(r2)
	
}
}


*With controls 
foreach var of local outcomes{
 	foreach outcome of local `var'{
	reg `outcome' $treatmentshv  $treatmentshvpk $controls, cluster(VILLAGE_ID)
	eststo `outcome'_c
	estadd scalar r_squared = e(r2)
	
}
}




* See how it looks in Stata:
esttab zmid_gm_nc zmid_gm_c zend_gm_nc zend_gm_c, se(3) replace label b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  
	  
	  
		  
local variables gm fm comm prbs psc
	foreach var of local variables {
*Fragment for tex 
esttab   zmid_`var'_nc zmid_`var'_c zend_`var'_nc zend_`var'_c using "$results/tables/spilloversv2_`var'.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	}
	

	
	
	


*-------------------------------------------------------------------------------
*	TABLE 15. SPILLOVER EFFECTS - SIBLINGS AND COUSINS -  DISSAGREGATED (SAME TABLE 6)
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


 

	
eststo clear 
global controls  Gender base_age_year ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK


	local variables gm fm comm prbs psc
	foreach var of local variables {
	local outcomes_`var' zmid_`var' zend_`var' 	
	}

	
 local outcomes  outcomes_gm  outcomes_fm  outcomes_comm  outcomes_prbs  outcomes_psc  
  *Without controls
 foreach var of local outcomes{
 	foreach outcome of local `var'{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo `outcome'_nc
	estadd scalar r_squared = e(r2)
	
}
}


 
 *With controls 
foreach var of local outcomes{
 	foreach outcome of local `var'{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo `outcome'_c
	estadd scalar r_squared = e(r2)
	
}
}



* See how it looks in Stata:
esttab zmid_gm_nc zmid_gm_c zend_gm_nc zend_gm_c, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 


	  
	  
		  
local variables gm fm comm prbs psc
	foreach var of local variables {
*Fragment for tex 
esttab   zmid_`var'_nc zmid_`var'_c zend_`var'_nc zend_`var'_c using "$results/tables/spillovers_siblings_`var'.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep(`treatments') order(`treatments') constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

	}
	


