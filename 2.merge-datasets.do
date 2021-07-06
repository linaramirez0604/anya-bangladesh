

/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: PREPARING DATASETS FOR MERGE
AUTHOR: TANVIR AHMED  AND LINA RAMIREZ 
DATE CREATED: 21/01/2021
LAST MODIFIED: 

PURPOSE: This dofile is based on the second part of the dofile "Merging all data.do" (after line 641) written by Tanvir to clean and create datasets to be merged, and modifies it to explore the merge in depth. 
	

NOTES: 
-The original dofile ("Merging all data.do") can be find in the folder/Users/bfiuser/Dropbox/Chicago/UChicago/ECD_Data_documents_2020/Final Data_ALL rounds/Compiled Dataset 
-Change the directory as required. 
-Run "1.pre-merge(tanvir)" before running this dofile. 
-This dofile was modified by Lina Ramirez (only the directory).

------------------------------------------------------------------------------*/




*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 



	gl input "$dropbox/Chicago/UChicago/ECD_Bangladesh/input"
	gl output "$dropbox/Chicago/UChicago/ECD_Bangladesh/output"
	gl results "$dropbox/Chicago/UChicago/ECD_Bangladesh/results"

	


*-------------------------------------------------------------------------------
*					MERGE CT, CB AND GENDER TO ALL DATASETS 	
*
*------------------------------------------------------------------------------- 


local  dataset `" "Baseline ASQ" "Baseline Literacy" "Baseline Numeracy" "Baseline OS" "Baseline SS" "Midline ASQ" "Midline Literacy" "Midline Numeracy" "Midline OS" "Midline SS" "Midline PSRA" "Endline ASQ" "Endline Literacy" "Endline Numeracy" "Endline OS" "Endline SS" "Endline PSRA" "'

foreach var of local dataset {
use "$input/`var'.dta", clear
capture drop CT CB Gender
merge 1:1 CHILD_ID using "$input/Child informations.dta", keepusing (CT CB Gender) keep(match) nogen 
drop if missing(CT)
save "$output/`var'.dta", replace 
}



*-------------------------------------------------------------------------------
*					MERGE BY SURVEY TYPE	
*
*------------------------------------------------------------------------------- 

local survey "ASQ Literacy Numeracy OS SS"
foreach var of local survey{
use "$output/Baseline `var'.dta", clear 
merge 1:1 CHILD_ID using "$output/Midline `var'.dta"
gen source="attrited-mid" if _merge==1
replace source="new-mid" if _merge==2 
replace source="merged-mid" if _merge==3
drop _merge 

merge 1:1 CHILD_ID using "$output/Endline `var'.dta"
replace source="attrited-end" if _merge==1 
replace source="new-end" if _merge==2 
replace source="merged-base-mid-end" if _merge==3 & source=="merged-mid"
replace source="merged-mid-endline" if _merge==3 & source=="new-mid" 
replace source="merged-base-end" if _merge==3 & missing(source)
drop _merge 

rename source source_`var'

save "$output/compiled_`var'.dta", replace 
erase "$output/Baseline `var'.dta"
erase "$output/Midline `var'.dta"
erase "$output/Endline `var'.dta"

}

*PSRA and are only in Midline and Endline

local survey "PSRA"
foreach var of local survey{
use "$output/Midline `var'.dta", clear
merge 1:1 CHILD_ID using "$output/Endline `var'.dta"
gen source="attrited-end" if _merge==1 
replace source="new-end" if _merge==2 
replace source="merged-mid-end" if _merge==3 
drop _merge 


rename source source_`var'

save "$output/compiled_`var'.dta", replace 
erase "$output/Midline `var'.dta"
erase "$output/Endline `var'.dta"

}



*-------------------------------------------------------------------------------
*					COMPILE A SINGLE DATASET 
*
*------------------------------------------------------------------------------- 

use "$output/compiled_ASQ.dta", clear

*Numeracy 
merge 1:1 CHILD_ID using  "$output/compiled_Numeracy.dta"
gen questionnaire="ASQ+Numeracy" if _merge==3 
replace questionnaire="Only ASQ" if _merge==1 
replace questionnaire="Only Numeracy" if _merge==2 
drop _merge 

*Literacy 
merge 1:1 CHILD_ID using "$output/compiled_Literacy.dta"
replace questionnaire="ASQ+Numeracy+Literacy" if _merge==3 & questionnaire=="ASQ+Numeracy"
replace questionnaire="ASQ+Literacy" if _merge==3 & questionnaire=="Only ASQ" 
replace questionnaire="Numeracy+Literacy" if _merge==3 & questionnaire=="Only Numeracy" 
replace questionnaire="Only Literacy" if _merge==2 
drop _merge 

*OS
merge 1:1 CHILD_ID using "$output/compiled_OS.dta"
replace questionnaire="ASQ+Numeracy+OS" if _merge==3 & questionnaire=="ASQ+Numeracy"
replace questionnaire="ASQ+Literacy+OS" if _merge==3 & questionnaire=="ASQ+Literacy"
replace questionnaire="ASQ+Numeracy+Literacy+OS" if _merge==3 & questionnaire=="ASQ+Numeracy+Literacy"
replace questionnaire="Numeracy+Literacy+OS" if _merge==3 & questionnaire=="Numeracy+Literacy"
replace questionnaire="Literacy+OS" if _merge==3 & questionnaire=="Only Literacy" 
replace questionnaire="Numeracy+OS" if _merge==3 & questionnaire=="Only Numeracy" 
replace questionnaire="Only OS" if _merge==2 
drop _merge 

*SS
merge 1:1 CHILD_ID using "$output/compiled_SS.dta"
replace questionnaire="ASQ+Numeracy+OS+SS" if _merge==3 & questionnaire=="ASQ+Numeracy+OS" 
replace questionnaire="ASQ+Literacy+OS+SS" if _merge==3 & questionnaire=="ASQ+Literacy+OS"
replace questionnaire="ASQ+Numeracy+Literacy+OS+SS" if _merge==3 & questionnaire=="ASQ+Numeracy+Literacy+OS"
replace questionnaire="Numeracy+Literacy+OS+SS" if _merge==3 & questionnaire=="Numeracy+Literacy+OS"
replace questionnaire="Literacy+OS+SS" if _merge==3 & questionnaire=="Literacy+OS" 
replace questionnaire="Numeracy+OS+SS" if _merge==3 & questionnaire=="Numeracy+OS"
replace questionnaire="Only SS" if _merge==2 
drop _merge

*PSRA 
merge 1:1 CHILD_ID using "$output/compiled_PSRA.dta"
replace questionnaire="ASQ+Numeracy+OS+SS+PSRA" if _merge==3 & questionnaire=="ASQ+Numeracy+OS+SS"
replace questionnaire="ASQ+Literacy+OS+SS+PSRA" if _merge==3 & questionnaire=="ASQ+Literacy+OS+SS"
replace questionnaire="ASQ+Numeracy+Literacy+OS+SS+PSRA" if _merge==3 & questionnaire=="ASQ+Numeracy+Literacy+OS+SS"
replace questionnaire="Numeracy+Literacy+OS+SS+PSRA" if _merge==3 & questionnaire=="Numeracy+Literacy+OS+SS"
replace questionnaire="Literacy+OS+SS+PSRA" if _merge==3 & questionnaire=="Literacy+OS+SS"
replace questionnaire="Numeracy+OS+SS+PSRA" if _merge==3 & questionnaire=="Numeracy+OS+SS"
replace questionnaire="Only PSRA" if _merge==2 
drop _merge

*DIAL 
merge 1:1 CHILD_ID using "$output/compiled_Dial.dta"
replace questionnaire="ASQ+Numeracy+OS+SS+PSRA+Dial" if _merge==3 & questionnaire=="ASQ+Numeracy+OS+SS+PSRA"
replace questionnaire="ASQ+Literacy+OS+SS+PSRA+Dial" if _merge==3 & questionnaire=="ASQ+Literacy+OS+SS+PSRA"
replace questionnaire="ASQ+Numeracy+Literacy+OS+SS+PSRA+Dial" if _merge==3 & questionnaire=="ASQ+Numeracy+Literacy+OS+SS+PSRA"
replace questionnaire="Numeracy+Literacy+OS+SS+PSRA+Dial" if _merge==3 & questionnaire=="Numeracy+Literacy+OS+SS+PSRA"
replace questionnaire="Literacy+OS+SS+PSRA+Dial" if _merge==3 & questionnaire=="Literacy+OS+SS+PSRA"
replace questionnaire="Numeracy+OS+SS+PSRA+Dial" if _merge==3 & questionnaire=="Numeracy+OS+SS+PSRA"
drop _merge


*Socio-economic data 
merge 1:1 CHILD_ID using "$output/socio_economic.dta"
drop if _merge==2 
gen socioeconomic=1 if _merge==3 
replace socioeconomic=0 if _merge==1 
label define socioeconomic 1 "Socio-econ data available" 0 "No socio-econ data available"
label values socioeconomic socioeconomic 
label variable socioeconomic "Socio economic data available"
drop _merge

order questionnaire CT, after(VILLAGE_ID)



foreach var in questionnaire source_ASQ source_Literacy source_Numeracy source_OS source_SS source_PSRA source_Dial {
	encode `var', gen(`var'1)
	order `var'1, after(`var')
	drop `var' 
	rename `var'1 `var'
	
}



*Treatments 
merge m:1 VILLAGE_ID using "$input/Treatment and control village list.dta", keepusing(treat1)
order treat1, after(VILLAGE_ID)
label define treatments 1 "Pre-school only" 2 "Home visit only" 3 "Pre-school+home visit" 4 "Control"
label values treat1 treatments
drop _merge 



tostring CB, gen(BD)
gen dt=strlen(BD)
replace BD="0"+BD if dt==7
gen Date_of_birth = date(BD, "DMY")
format Date_of_birth %td
drop CB BD dt
label variable treat1 "Treatment type"
label variable CT "Child type (project child of sibling/cousine)"
label variable Date_of_birth "Date of the birth of the child"


save "$output/Early childhood Development.dta", replace




*-------------------------------------------------------------------------------
*					NUMBER OF STUDENTS TREATED PER VILLAGE 
*
*------------------------------------------------------------------------------- 

*Variable num_stud_village will report the number of students treated per village (10,20 or 30)


*Only visit 
use "$input/ecd_home_final.dta", clear

keep  VILLAGE_ID RECORD_ID btype
duplicates drop 


merge 1:m VILLAGE_ID RECORD_ID using "$output/Early childhood Development.dta"
drop if _merge==1 
replace btype=4 if treat1==2 & btype==.
drop _merge 



rename btype child_treat_status

label var child_treat_status "Children treatment status inside village"


save "$output/temp.dta", replace  


*Visit + Pre-school
use "$input/ecd_home_PreK_FINAL.dta", clear

keep  VILLAGE_ID RECORD_ID ctype 
duplicates drop 
merge 1:m VILLAGE_ID RECORD_ID using "$output/temp.dta"
drop if _merge==1

replace treat1=3 if ctype==2 
replace ctype=4 if treat1==3 & ctype==.

replace child_treat_status=5 if ctype==1 & treat1==3
replace child_treat_status=6 if ctype==2 & treat1==3
replace child_treat_status=7 if ctype==3 & treat1==3
replace child_treat_status=8 if ctype==4 & treat1==3

drop ctype 
drop _merge 

*Control 
replace child_treat_status=9 if treat1==4 

*Pre-school 
replace child_treat_status=10 if treat1==1

label define child_treat_status 1 "HV-10 students-1 teacher" 2 "HV-20 students-2 teachers" 3 "HV-30 students-3 teachers" 4 "HV-didn't get HV" 5 "HV+preK-10 students-1 teacher" 6 "HV+preK-20 students-2 teachers" 7 "HV+preK-30 students-3 teachers" 8 "HV+preK-only gets preK no HV" 9 "Control" 10 "Pre-K only"



label values child_treat_status child_treat_status 

*Fix treat1 variable based on child_treat_status variable

replace treat1=2 if (child_treat_status==2 | child_treat_status==3) & missing(treat1)



generate str b_date="01022017"
gen base_date = date(b_date, "DMY")
format base_date %td
gen base_age_month = round((base_date-Date_of_birth)/(365/12))
gen base_age_year=round(base_age_month/12)
label variable base_age_month "Age 1st February, 2017 (Baseline survey) in months"
label variable base_age_year "Age 1st February, 2017 (Baseline survey) in years"




*-------------------------------------------------------------------------------
*					GENERATING homevisit2 preschoo2 both2 
*
*------------------------------------------------------------------------------- 



*1 if Family ONLY got offered HV program, 0 if control or didn't get offered any program. 
gen homevisit2=.
replace homevisit2=1 if child_treat_status<=3 
replace homevisit2=0 if missing(homevisit2)
label define homevisit2 1 "Offered HV program" 0 "Control, didn't get offered any program"
label values homevisit2 homevisit2


*1 if Family ONLY got offered preschool (in HV+preschool village), 0 if control or didn't get offered any program. 
gen preschool2=. 
replace preschool2=1 if child_treat_status==8
replace preschool2=0 if missing(preschool2)
label define preschool2 1 "Belongs to school+HV but only got school" 0 "Control, didn't get offered any program"
label values preschool2 preschool2

*1 if Family gets offered both PreK and HV, 0 if control or didn't get offered any program. 
gen both2=. 
replace both2=1 if child_treat_status==5 | child_treat_status==6 | child_treat_status==7
replace both2=0 if  missing(both2)
label define both2 1 "Received both sch & HV" 0 "Control, didn't get offered any program"
label values both2 both2





label variable homevisit2 "family was ONLY offered the HV program"
label variable preschool2 "families who ONLY got offered the preschool (in HV+preK villages)"
label variable both2 "families who got offered BOTH preschool and HV"

save "$output/temp.dta", replace 



*------------------------------------------------------------------------------------
*					GENERATING HV_10, HV_20, HV_30 HVPK_10, HVPK_20, HVPK_30 
*
*------------------------------------------------------------------------------------

*Villages with home visit 
use "$input/ecd_home_final.dta", clear

keep  VILLAGE_ID treat_home
duplicates drop 

merge 1:m VILLAGE_ID using "$output/temp.dta"
drop if _merge==1 
drop _merge 

gen HV_10=1 if treat_home==1 
*replace HV_10=0 if treat1==4

gen HV_20=1 if treat_home==2 
*replace HV_20=0 if treat1==4


gen HV_30=1 if treat_home==3 
*replace HV_30=0 if treat1==4


replace HV_10=0 if missing(HV_10)
replace HV_20=0 if missing(HV_20)
replace HV_30=0 if missing(HV_30)



save "$output/temp.dta", replace 


*Villages with  home visit + preK 


use "$input/ecd_home_PreK_FINAL.dta", clear

keep  VILLAGE_ID ctype 
duplicates drop 

merge 1:m VILLAGE_ID using "$output/temp.dta"
drop if _merge==1
drop _merge 
replace ctype=. if ctype==2 & child_treat_status==4



gen HVPK_10=1 if ctype==1 
*replace HVPK_10=0 if treat1==4


gen HVPK_20=1 if ctype==2
*replace HVPK_20=0 if treat1==4

gen HVPK_30=1 if ctype==3
*replace HVPK_30=0 if treat1==4

replace HV_20=1 if child_treat_status==4 & HVPK_20==1


replace HVPK_10=0 if missing(HVPK_10)
replace HVPK_20=0 if missing(HVPK_20)
replace HVPK_30=0 if missing(HVPK_30)

label define ctype 1 "10 students, 1 teacher" 2 "20 students, 2 teachers" 3 "30 students, 3 teachers"
label values ctype ctype 





*-------------------------------------------------------------------------------
*					FURTHER ORGANIZING VARIABLES 
*
*------------------------------------------------------------------------------- 


label define CT 1 "Project child" 2 "Sibiling" 3 "Cousin"
label values CT CT 
order  FAMILY_ID RECORD_ID CHILD_NUMBER CHILD_ID CT Gender child_treat_status, after(VILLAGE_ID)
label var questionnaire "Tests completed by child"
label var Gender "Gender" 
order source_ASQ, after(questionnaire) 
label var source_ASQ "Report of participation in base-mid-endline ASQ"
rename source_Numeracy source_num 
label var source_num "Report of participation base-mid-end numeracy"
order source_num, after(end_asq_overall)
rename source_Literacy source_lit
label var source_lit "Report of participation base-mid-end literacy"
order source_lit, after(end_lit_overall)
order source_OS, after(end_os_overall)
label var source_OS "Report of participation base-mid-end OS"
order source_SS, after(end_ss_overall)
label var source_SS "Report of participation base-mid-end SS"
label var source_PSRA "Report of participation base-mid-end PSRA"
label var source_Dial "Report of participation base-mid-end Dial"
order end_D4 end_D4 source_Dial end_hv, after(mid_D4)
rename Date_of_birth birthday 
order mother*, after(father_education)
label var b_date "Baseline date"
label var base_date "Baseline date"



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
	egen zbase_`var'=std(base_asq_`var')
	egen zmid_`var'=std(mid_asq_`var')
	egen zend_`var'=std(end_asq_`var') 
	
}


/*
foreach var of local  asq{
quietly summ base_asq_`var' if treat1==4
scalar `var'_mean=r(mean)
scalar `var'_sd=r(sd)
gen zbase_`var'=(base_asq_`var'-`var'_mean)/`var'_sd
gen zmid_`var'=(mid_asq_`var'-`var'_mean)/`var'_sd
gen zend_`var'=(end_asq_`var'-`var'_mean)/`var'_sd


}

*/ 



local skill "lit num os ss"

foreach var of local skill {
	egen zbase_`var'_overall=std(base_`var'_overall)
	egen zmid_`var'_overall=std(mid_`var'_overall)
	egen zend_`var'_overall=std(end_`var'_overall)

}



/*
foreach var of local skill {
quietly summ base_`var'_overall  if treat1==4
scalar `var'_mean=r(mean)
scalar `var'_sd=r(sd)
gen zbase_`var'_overall=(base_`var'_overall-`var'_mean)/`var'_sd
gen zmid_`var'_overall=(mid_`var'_overall-`var'_mean)/`var'_sd
gen zend_`var'_overall=(end_`var'_overall-`var'_mean)/`var'_sd

}
*/ 

*Academic Skills 
egen zbase_acskill=std(base_acskill-acskill_mean)
egen zmid_acskill=std(mid_acskill-acskill_mean)
egen zend_acskill=std(end_acskill-acskill_mean)


*Executive funciton
egen zbase_exfunction=std(base_exfunction-exfunction_mean)
egen zmid_exfunction=std(mid_exfunction-exfunction_mean)
egen zend_exfunction=std(end_exfunction-exfunction_mean)




/*
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
*/

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
label var  base_asq_overall "Baseline ASQ" 
label var  mid_asq_overall "Midline ASQ" 
label var end_asq_overall "Endline ASQ"
label var zbase_acskill "Baseline AS (std)" 
label var zbase_exfunction "Baseline EF (std)"
label var zmid_acskill "Midline AS(std)" 
label var zend_acskill "Endline AS (std)" 
label var zmid_exfunction "Midline EF (std)" 
label var zend_exfunction "Endline EF (std)"
label var zbase_overall "Baseline ASQ (std)"
label var zmid_overall "Midline ASQ (std)" 
label var zend_overall "Endline ASQ (std)"
label var mother_education "Mother Education" 
label var household_income "Household Income"
label var HV_10 "HV -- 10"
label var HV_20  "HV -- 20"
label var HV_30  "HV -- 30"
label var HVPK_10 "HV+PK -- 10"
label var HVPK_20 "HV+PK -- 20"
label var HVPK_30 "HV+PK -- 30"



tab treat1, gen(treatment)
rename treatment1 pkonly
label var pkonly "Pre-K only"
rename treatment2 hvonly
label var hvonly "Home Visit only"
rename treatment3 pk_hv
label var pk_hv "Pre-K + HV"
rename treatment4 control 
label var control "Control"
	
	* Generating variables for descriptive statistics 
	
gen HV_treated=1 if child_treat_status<4 
replace HV_treated=0 if child_treat_status==4 
	
gen HVPK_treated=1 if child_treat_status>4 & child_treat_status<8 
replace HVPK_treated=0 if child_treat_status==8
	
label define treated 1 "Treated" 0 "Untreated"
label values HV_treated treated 
label values HVPK_treated treated 
	
gen treated=1 if HV_treated==1 | HVPK_treated==1 | treat1==1 
replace treated=0 if missing(treated)
label var treated "Treated"
	
gen child_type=1 if CT==1 
replace child_type=0 if missing(child_type) 
	
label define child_type 1 "Project Child" 0 "Sibiling/Cousin"
label values child_type child_type 
label var child_type "Child Type"
	
label var father_education "Father's Education"
label var mother_education "Mother's Education"

drop if missing(child_treat_status)

	




save "$output/ECD_compiled.dta", replace
erase "$output/Early childhood Development.dta"
erase "$output/temp.dta"


*** END *** 

