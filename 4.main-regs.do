
/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: MAIN ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 21/07/2021
LAST MODIFIED: 

PURPOSE: Main analysis. Based on 3.prelim-analysis. Generates the tables and figures in pdf "regs-v2.pdf"

REQUIREMENTS: Run 0.master.do to set paths correctly. 

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
*						TABLE 2. CONSTRUCTS (NO STATA)
*
*------------------------------------------------------------------------------- 


*-------------------------------------------------------------------------------------------------------------------------
*						TABLE 3. - ITT 
* 							(Version 3) 
*	Eliminating kids added on year 2, keeping only those that continued. Assigning 0 to missing values in baseline scores 
*--------------------------------------------------------------------------------------------------------------------------

	
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





*-------------------------------------------------------------------------------
*			TABLE 4. REGRESSION  - TOT 
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


	**** WITH THE MAX  ****
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 
 
 
 *Without controls 
 foreach outcome of local outcomes{
	ivregress 2sls `outcome'  (pkonly hvonly pk_hv=inst_pkonly_max  inst_hvonly_max inst_hvpk_max), vce(cluster VILLAGE_ID)
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
	ivregress 2sls `outcome' $controls  (pkonly hvonly pk_hv=inst_pkonly_max  inst_hvonly_max inst_hvpk_max), vce(cluster VILLAGE_ID)
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
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/tot_max.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 

	
	
	
	**** WITH THE MEAN ****	
	eststo clear 
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
	
	
	
 *Without controls 
 foreach outcome of local outcomes{
	ivregress 2sls `outcome'  (pkonly hvonly pk_hv=inst_pkonly_mean inst_hvonly_mean inst_hvpk_mean), vce(cluster VILLAGE_ID)
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
	ivregress 2sls `outcome' $controls  (pkonly hvonly pk_hv=inst_pkonly_mean  inst_hvonly_mean inst_hvpk_mean), vce(cluster VILLAGE_ID)
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
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/tot_mean.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 

	
	
		**** WITH THE P75 ****	
	eststo clear 
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
	
	
	
 *Without controls 
 foreach outcome of local outcomes{
	ivregress 2sls `outcome'  (pkonly hvonly pk_hv=inst_pkonly_p75 inst_hvonly_p75 inst_hvpk_p75), vce(cluster VILLAGE_ID)
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
	ivregress 2sls `outcome' $controls  (pkonly hvonly pk_hv=inst_pkonly_p75 inst_hvonly_p75 inst_hvpk_p75), vce(cluster VILLAGE_ID)
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
esttab   est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/tot_p75.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) indicate("Controls = ${controls}", labels("\checkmark" " ")) 

	





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
*			TABLE 6. SPILLOVER EFFECTS - SIBLINGS AND COUSINS
*
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*------------------------------------------------------------------------------- 


use ECD_compiled.dta, clear 

*Keep only siblings and cousings (and all kids in control group)
keep if proj_child!=1
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



*-------------------------------------------------------------------------------
*				TABLE 7. TEST SCORES BY AGE GROUP - SIBLINGS/COUSINS
*
*------------------------------------------------------------------------------- 


	use temp.dta, clear 
	keep mid_acskill mid_exfunction end_acskill end_exfunction siblings_HV siblings_PK siblings_HVPK group_age
	gen id=_n 
	reshape wide mid_acskill end_acskill mid_exfunction end_exfunction, i(id) j(group_age)
	global desc "mid_acskill1 end_acskill1 mid_exfunction1 end_exfunction1 mid_acskill2 end_acskill2 mid_exfunction2 end_exfunction2 mid_acskill3 end_acskill3 mid_exfunction3 end_exfunction3"
	
	
	label var mid_acskill1 "End Y1 AS - 0-2 years"
	label var end_acskill1 "End Y2 AS - 0-2 years"
	label var mid_acskill2 "End Y1 AS - 3-5 years"
	label var end_acskill2 "End Y2 AS - 3-5 years"
	label var mid_acskill3 "End Y1 AS - 6-8 years"
	label var end_acskill3 "End Y2 AS - 6-8 years"
	
	label var mid_exfunction1 "End Y1 EF - 0-2 years"
	label var end_exfunction1 "End Y2 EF - 0-2 years"
	label var mid_exfunction2 "End Y1 EF - 3-5 years"
	label var end_exfunction2 "End Y2 EF - 3-5 years"
	label var mid_exfunction3 "End Y1 EF - 6-8 years"
	label var end_exfunction3 "End Y2 EF - 6-8 years"
	
		


	eststo homevisit: estpost summarize $desc if siblings_HV==1
	eststo preschool: estpost summarize $desc if siblings_PK==1
	eststo both: estpost summarize $desc if siblings_HVPK==1
	eststo control: estpost summarize $desc if siblings_HV==0 & siblings_PK==0 & siblings_HVPK==0 


	
* See how it looks in Stata:
	esttab control preschool homevisit both, mtitles("Control"  "Siblings PK" "Siblings HV" "Siblings HV and PK") cells("count(label(N) pattern(1 1 1) fmt(0)) mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label


*In tex: 
	esttab control homevisit preschool both using "$results/tables/siblings_age_groups.tex", mtitles("Control" "Only HV" "Only PK" "HV and PK") cells("count(label(N) pattern(1 1 1) fmt(0)) mean(label(Mean) pattern(1 1 1) fmt(3)) sd(label(Std. Dev.) pattern(1 1 1) fmt(3))") label frag replace 


	
	
*--------------------------------------------------------------------------------------------------------
*					TABLE 8 EFFECTS BY BASELINE ACSKILL 
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------


	use ECD_compiled.dta, clear 
	
	*Median base academic skills of full sample
	xtile median_base_acskill=zbase_acskill, nq(2) 
	label define median_base_acskill 1 "Below" 2 "Above Median"
	label values median_base_acskill median_base_acskill
	label var median_base_acskill "Above median"
	
	
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol median_base_acskill
	global interactions 1.hvonly#2.median_base_acskill 1.pkonly#2.median_base_acskill 1.pk_hv#2.median_base_acskill
	global controls  zbase_exfunction Gender base_age_year ln_household_income has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

	

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
esttab zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w using "$results/tables/mainreg_median_acskillv2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 



*--------------------------------------------------------------------------------------------------------
*					TABLE 9 EFFECTS BY BASELINE EF 
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------





	use ECD_compiled.dta, clear 
	
	*Median Executive function of full sample 
	xtile median_base_exfunction=zbase_exfunction, nq(2) 
	label define median_base_exfunction 1 "Below" 2 "Above Median"
	label values median_base_exfunction median_base_exfunction
	label var median_base_exfunction "Above Median"


	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol median_base_exfunction
	global interactions 1.hvonly#2.median_base_exfunction 1.pkonly#2.median_base_exfunction 1.pk_hv#2.median_base_exfunction
	global controls  zbase_acskill Gender base_age_year ln_household_income  has_base_acskill father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

	
	

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
esttab zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w using "$results/tables/mainreg_median_exfunctionv2.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*--------------------------------------------------------------------------------------------------------
*					TABLE 10. EFFECTS BY GENDER
*					Interaction term of median x treatments 
*---------------------------------------------------------------------------------------------------------

	use ECD_compiled.dta, clear 
	
	keep if  proj_child==1 
	drop if  child_treat_status==4 | child_treat_status==8  
	
	*Keep only those added at year 1
	keep if added_year2==0
	
	*Assigning 0 to missing at baseline 
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol Gender
	global interactions 1.hvonly#1.Gender 1.pkonly#1.Gender 1.pk_hv#1.Gender
	global controls zbase_acskill zbase_exfunction base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 
	

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
esttab zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w using "$results/tables/mainreg_female_int.tex.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 







*--------------------------------------------------------------------------------------------------------
*					TABLE 11. EFFECTS BY HOUSEHOLD INCOME
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
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol median_income
	global interactions 1.hvonly#2.median_income 1.pkonly#2.median_income 1.pk_hv#2.median_income
	global controls  zbase_acskill zbase_exfunction Gender base_age_year  has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

	
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
esttab zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w using "$results/tables/mainreg_median_income.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




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
	local baseline acskill exfunction
	foreach var of local baseline {
	replace zbase_`var'=0 if missing(zbase_`var')
	}
	
	
	
	eststo clear 
	global treatments hvonly pkonly pk_hv
	global maincontrol median_mother_educ
	global interactions 1.hvonly#2.median_mother_educ 1.pkonly#2.median_mother_educ 1.pk_hv#2.median_mother_educ
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction 

	
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
esttab zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w, se(3) replace label b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex) constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post estimation" "HV=PK" "HV=HV+PK" "PK=HV+PK""N") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 
	  	  
	  
*Fragment for tex 
esttab   zmid_acskill_wo zmid_acskill_w zend_acskill_wo zend_acskill_w  zmid_exfunction_wo zmid_exfunction_w zend_exfunction_wo zend_exfunction_w using "$results/tables/mainreg_median_mother_educ.tex", label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01) se(3) b(3) keep($treatments $maincontrol $interactions ) order($treatments $maincontrol $interactions) nobaselevels interaction(" $\times$ ")style(tex)  constant nogaps stats(empty p_diff1 p_diff2 p_diff3 N, labels("Post-estimation" "HV=PK" "HV=PK+HV" "PK=PK+HV""Number of observations") fmt(0 3 3 3 0)) nogaps  indicate("Controls = ${controls}", labels("\checkmark" " ")) 









*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*			
* 							APPENDIX TABLES 	
*
*------------------------------------------------------------------------------- 
*-------------------------------------------------------------------------------





*-------------------------------------------------------------------------------
*							TABLE A.1 
* 			(Previous Table3v4 REGRESSION - ITT)
* 			Using spillover kids as control kids for hv and hvpk
*------------------------------------------------------------------------------- 

	
	use ECD_compiled.dta, clear 
	
	keep if  proj_child==1 
	*Drop control 
	drop if  child_treat_status==9 
	keep if added_year2==0
	*drop if Project_continuation=="No" 
	
	*Change treatment variables
	replace hvonly=0 if  child_treat_status==4
	replace pk_hv=0 if child_treat_status==8 
	

	eststo clear 
	global treatments hvonly pk_hv
	global controls  zbase_acskill zbase_exfunction Gender base_age_year ln_household_income has_base_acskill has_base_exfunction father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
	local outcomes zmid_acskill zend_acskill zmid_exfunction zend_exfunction
 
 

 *Without controls 
 foreach outcome of local outcomes{
	reg `outcome' $treatments, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
}

 
*With controls 
foreach outcome of local outcomes{
	reg `outcome' $treatments $controls, cluster(VILLAGE_ID)
	eststo 
	test hvonly=pk_hv 
	estadd scalar p_diff2 = r(p)
	
}




* See how it looks in Stata:
esttab est1 est5 est2 est6 est3 est7 est4 est8, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff2 N, labels("Post estimation" "HV=HV+PK" "N") fmt(3 3 0)) nogaps indicate("Controls = ${controls}", labels("\checkmark" " "))  
	  	
		
	  
*Fragment for tex 
esttab est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/reg1_std_v4.tex", se(3) replace label fragment tex b(3) keep($treatments) order($treatments) constant nogaps stats(empty p_diff2 N, labels("Post estimation" "HV=HV+PK" "N") fmt(3 3 0)) nogaps indicate("Controls = ${controls}", labels("\checkmark" " "))  



*-------------------------------------------------------------------------------
*			TABLE A.2 and A.3 SPILLOVER EFFECTS - SIBLINGS AND COUSINS - BY AGE 
*
*	Keeping only kids added on year 2, assigning 0 to missing values in midline scores 
*  HV and HVPK are siblings of treated kids and are compared to siblings of untreated kids and control 
*  PK are siblings of treated kids and are only compared to control kids. 
*------------------------------------------------------------------------------- 

use temp.dta, clear

eststo clear 
global controls Gender ln_household_income  father_educ_2 father_educ_3 father_educ_4 father_educ_5 father_educ_6 mother_educ_2 mother_educ_3 mother_educ_4 mother_educ_5 mother_educ_6
global treatments siblings_PK siblings_HV siblings_HVPK
local outcomes zmid_acskill zmid_exfunction  zend_acskill zend_exfunction
 *Without controls 
	foreach outcome of local outcomes{
		forvalues i=1/3{
		reg `outcome' $treatments if group_age==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'_wo
		estadd scalar r_squared = e(r2)
		}
	
}

 *With controls 
	foreach outcome of local outcomes{
		forvalues i=1/3{
		reg `outcome' $treatments $controls if group_age==`i', cluster(VILLAGE_ID)
		eststo `outcome'`i'_w
		estadd scalar r_squared = e(r2)
		}
	
}



* Academic Skills-midline: See how it looks in Stata:
esttab zmid_acskill1_wo zmid_acskill1_w zmid_acskill2_wo zmid_acskill2_w zmid_acskill3_wo zmid_acskill3_w, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

 
*Academic Skills-midline: Fragment for tex 
esttab zmid_acskill1_wo zmid_acskill1_w zmid_acskill2_wo zmid_acskill2_w zmid_acskill3_wo zmid_acskill3_w using "$results/tables/reg4_spillovers_mid_age_ac.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments) order($treatments)  constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


* Executive Function-midline: See how it looks in Stata:
esttab zmid_exfunction1_wo zmid_exfunction1_w zmid_exfunction2_wo zmid_exfunction2_w zmid_exfunction3_wo zmid_exfunction3_w, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

 
* Executive Function-midline: Fragment for tex 
esttab zmid_exfunction1_wo zmid_exfunction1_w zmid_exfunction2_wo zmid_exfunction2_w zmid_exfunction3_wo zmid_exfunction3_w using "$results/tables/reg4_spillovers_mid_age_ef.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments) order($treatments)  constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))




* Academic Skills-endline: See how it looks in Stata:
esttab zend_acskill1_wo zend_acskill1_w zend_acskill2_wo zend_acskill2_w zend_acskill3_wo zend_acskill3_w, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

 
*Academic Skills-endline: Fragment for tex 
esttab zend_acskill1_wo zend_acskill1_w zend_acskill2_wo zend_acskill2_w zend_acskill3_wo zend_acskill3_w using "$results/tables/reg4_spillovers_end_age_ac.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments) order($treatments)  constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))


* Executive Function-endline: See how it looks in Stata:
esttab zend_exfunction1_wo zend_exfunction1_w zend_exfunction2_wo zend_exfunction2_w zend_exfunction3_wo zend_exfunction3_w, se(3) replace label b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 

 
* Executive Function-endline: Fragment for tex 
esttab zend_exfunction1_wo zend_exfunction1_w zend_exfunction2_wo zend_exfunction2_w zend_exfunction3_wo zend_exfunction3_w using "$results/tables/reg4_spillovers_end_age_ef.tex" , label fragment tex replace starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) keep($treatments) order($treatments)  constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) mgroups( "0-2 years" "3-5 years" "6-8 years", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

erase temp.dta 







