
/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: MAIN ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 8/11/2021
LAST MODIFIED: 

PURPOSE: Main analysis manipulating the sample: 
1. Reshape the dataset by record id so we can drop siblings of those project children that were added in year 2. 
2. Redo the overall spillover and spillover analysis.
3. Check the original dataset for treatment categories (e.g that there are 30 families that were treated in HV-30 and 10 in HV-10)



REQUIREMENTS: Run 0.master.do to set paths correctly. 

------------------------------------------------------------------------------*/




*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 

	set scheme s2mono 
	

	cd "$output"
	
	
	use ECD_compiled.dta, clear 
	
	egen num_recordid=count(CHILD_ID), by(RECORD_ID)
	
	
	egen num_siblings_recordid=count(CHILD_ID), by(RECORD_ID proj_child)
	
	br if num_recordid==3 & num_siblings_recordid!=3-1
	
	*drop siblings/cousins that have no project child
	drop if num_recordid==1 & proj_child==0
	
	*Drop those families that have more than one project child and have only siblings or only project childs 
	drop if num_recordid>=2 & num_siblings_recordid==num_recordid

	
	*Drop kids in families with more than one project child: 
	drop if num_recordid>2 & num_siblings_recordid>1 & proj_child==1 
	drop if num_recordid>2 & num_siblings_recordid<num_recordid-1 & proj_child==0
	
	save temp.dta, replace 
	
	
*-------------------------------------------------------------------------------
*			TABLE 6. SPILLOVER EFFECTS
* 				(Version 2)
*	Eliminating kids added on year 2, assigning 0 to missing values in baseline scores 
*------------------------------------------------------------------------------- 



	use temp.dta, clear 

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
*esttab est1 est5 est2 est6 est3 est7 est4 est8  using "$results/tables/reg3_spilloversv2.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatmentshv $treatmentshvpk) order($treatmentshv  $treatmentshvpk) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 








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
*esttab est1 est5 est2 est6 est3 est7 est4 est8 using "$results/tables/reg4_spillovers.tex",  replace label starlevels(* 0.10 ** 0.05 *** 0.01) fragment tex se(3) b(3) keep($treatments) order($treatments) constant nogaps stats(empty r_squared N, labels(" " "R-squared" "N") fmt(0 3 0))  indicate("Controls = ${controls}", labels("\checkmark" " ")) 




*-------------------------------------------------------------------------------
*						CHECKING TREATMENT CATEGORIES 
*
*------------------------------------------------------------------------------- 


cd "$output"

use ECD_compiled.dta, clear 


 keep CHILD_ID VILLAGE_ID FAMILY_ID proj_child HV_10 HV_20 HV_30 HVPK_10 HVPK_20 HVPK_30 treat1 treated 

 keep if proj_child==1
 keep if treat1==2 | treat1==3
 
 egen num_fam=count(FAMILY_ID), by(VILLAGE_ID)
 egen num_treated=sum(treated), by(VILLAGE_ID)
 
 drop CHILD_ID FAMILY_ID proj_child treat1 treated
 collapse HV_10 HV_20 HV_30 HVPK_10 HVPK_20 HVPK_30 num_fam num_treated, by(VILLAGE_ID)
 
 gen treated_homes=1 if HV_10==1 
 replace treated_homes=2 if HV_20==1
 replace treated_homes=3 if HV_30==1
 replace treated_homes=4 if HVPK_10==1
 replace treated_homes=5 if HVPK_20==1
 replace treated_homes=6 if HVPK_30==1

 label define treated_homes 1 "HV_10" 2 "HV_20" 3 "HV_30" 4 "HVPK_10" 5 "HVPK_20" 6 "HVPK_30" 
 label values treated_homes treated_homes 
 
 drop HV_10 HV_20 HV_30 HVPK_10 HVPK_20 HVPK_30
 
 sort treated_homes
 
 export delimited using "treated_homes.csv", replace
 
 
 collapse num_treated, by(treated_homes)
 
 
 
