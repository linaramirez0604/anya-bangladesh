

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
merge 1:1 CHILD_ID using "$input/Child informations.dta", keepusing (CT CB Gender Project_continuation) keep(match) nogen 
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

*Attrition version 1
gen attrited_year1_v1=1 if Project_continuation=="No" 
replace attrited_year1_v1=0 if Project_continuation=="Yes" 
label define attrited_year1_v1 1 "Attrited" 0 "Continued"
label values attrited_year1_v1 attrited_year1_v1
label var attrited_year1_v1 "Attrited on year 1"

egen total_children_village=count(CHILD_ID), by(VILLAGE_ID)
egen attrited_year1_totalvillage_v1=total(attrited_year1_v1), by(VILLAGE_ID)
gen attrited_year1_rate_v1=attrited_year1_totalvillage_v1/total_children_village




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


save "$output/temp.dta", replace 


*---------------------------------------------------------------------------------------------------------
*					IDENTIFYING THE PROJECT CHILD
*	CT had assigned to the Project Child those that were sibilings or cousins in the hv and 
*	hvpk treatments. In here we correct the project child
*------------------------------------------------------------------------------------------------------------

import excel "$input/project-child-hv-hvpk.xlsx", sheet("Sheet1") firstrow clear

duplicates drop 
gen proj_child=1 

merge 1:1 CHILD_ID using  "$output/temp.dta"
keep if _merge!=1 
drop _merge 


save "$output/temp.dta", replace 



import excel "$input/project-child-hv-hvpk.xlsx",  sheet("HV+prek") firstrow clear

duplicates drop 
gen proj_child=1

merge 1:1 CHILD_ID using  "$output/temp.dta"
keep if _merge!=1 
drop _merge 


*Apparently there are only sibilings of untreated kids.
*tab child_treat_status CT
*proj_child corrects this: 
*tab child_treat_status proj_child

replace proj_child=1 if CT==1 & missing(proj_child) & (child_treat_status==4 | child_treat_status==8 | child_treat_status==9 | child_treat_status==10 )
replace proj_child=0 if missing(proj_child) 

order proj_child, after(CHILD_ID) 
label define proj_child 1 "Proj Child" 0 "Sibiling/Cousin"
label values proj_child proj_child 
label var proj_child "Project Child (corrected)"


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

order Project_continuation attrited_year1*, after(CT)



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
egen zbase_acskill=std(base_acskill)
egen zmid_acskill=std(mid_acskill)
egen zend_acskill=std(end_acskill)


*Executive funciton
egen zbase_exfunction=std(base_exfunction)
egen zmid_exfunction=std(mid_exfunction)
egen zend_exfunction=std(end_exfunction)




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
label var mid_acskill "End Y1 AS" 
label var end_acskill "End Y2 AS"
label var mid_exfunction "End Y1 EF"
label var end_exfunction "End Y2 EF"
label var  base_asq_overall "Baseline ASQ" 
label var  mid_asq_overall "End Y1 ASQ" 
label var end_asq_overall "End Y2 ASQ"
label var zbase_acskill "Baseline AS" 
label var zbase_exfunction "Baseline EF"
label var zmid_acskill "End Y1 AS" 
label var zend_acskill "End Y2 AS" 
label var zmid_exfunction "End Y1 EF" 
label var zend_exfunction "End Y2 EF"
label var zbase_overall "Baseline ASQ"
label var zmid_overall "End Y1 ASQ" 
label var zend_overall "End Y2 ASQ"
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

label define hvonly 1 "HV only" 0 "Otherwise"
label define pkonly 1 "PK only" 0 "Otherwise"
label define pk_hv 1 "PK+HV" 0 "Otherwise"
label values hvonly hvonly 
label values pkonly pkonly 
label values pk_hv pk_hv 


gen female=1 if Gender==0 
replace female=0 if Gender==1 
order female, after(Gender)
drop Gender 
rename female Gender 
label define Gender 1 "female" 0 "male"
label values Gender Gender
label var Gender "Female"


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


*Generating categorical variable for mother's and father's education 


* Beginning 2011: mandatory elementary school cycle of eight years, followed by four years of secondary education. 

label define categories 1 "No education" 2 "Some primary" 3 "Finished primary" 4 "Some secondary" 5 "Finished secondary" 6 "Postgraduate"
local education father mother

	foreach var of local education {
		
		gen `var'_educ_cat=1 if `var'_education==0 
		replace `var'_educ_cat=2 if `var'_education>0 & `var'_education<8 
		replace `var'_educ_cat=3 if `var'_education==8 
		replace `var'_educ_cat=4 if `var'_education>8 &  `var'_education<12
		replace `var'_educ_cat=5 if `var'_education==12
		replace `var'_educ_cat=6 if `var'_education>12 & !missing(`var'_education)
		replace `var'_educ_cat=. if missing(`var'_education)
		order `var'_educ_cat, after(`var'_education)
		label var `var'_educ_cat "`var' education - categories"
		label values `var'_educ_cat categories 
		tab `var'_educ_cat, gen(`var'_educ_)
			order `var'_educ_1 `var'_educ_2 `var'_educ_3 `var'_educ_4 `var'_educ_5 `var'_educ_6, after(`var'_educ_cat)
		
	} 

	
*Log of household income
gen ln_household_income=ln(household_income)
label var ln_household_income "Household income"

* Added in year 2
gen added_year2=1 if missing(base_asq_gm)& missing(base_asq_fm)& missing( base_asq_comm)& missing( base_asq_prbs)& missing( base_asq_psc)& missing( base_asq_overall)& missing( base_num_overall)& missing( base_lit_overall)& missing( base_acskill)& missing( base_os_overall)& missing( base_ss_overall) 
replace added_year2=0 if missing(added_year2)

label define added_year2 1 "added in second year" 0 "Added in year 1"
label values added_year2 added_year2
label var added_year2 "Added in Year 2" 

order ln_household_income, after(household_income)
order added_year2, after(treat1)


* Attrition version 2 

*Midline 
gen attrited_year1_v2=1 if  missing(mid_asq_gm)& missing(mid_asq_fm)& missing(mid_asq_comm)& missing(mid_asq_prbs)& missing(mid_asq_psc)& missing(mid_asq_overall)& missing(mid_num_overall)& missing(mid_lit_overall)& missing(mid_acskill)& missing(mid_os_overall)& missing(mid_ss_overall) 
replace attrited_year1_v2=0 if missing(attrited_year1_v2)
label define attrited_year1_v2 1 "Attrited" 0 "Continued"
label values attrited_year1_v2 attrited_year1_v2 
label var attrited_year1_v2 "Attrited on year 1"

*Endline 

gen attrited_year2=1 if  missing(end_asq_gm)& missing(end_asq_fm)& missing(end_asq_comm)& missing(end_asq_prbs)& missing(end_asq_psc)& missing(end_asq_overall)& missing(end_num_overall)& missing(end_lit_overall)& missing(end_acskill)& missing(end_os_overall)& missing(end_ss_overall) 
replace attrited_year2=0 if missing(attrited_year2)
label define attrited_year2 "Attrited" 0 "Continued"
label values attrited_year2 attrited_year2
label var attrited_year2 "Attrited on year 2"



*Variable to know if they have scores at baseline 
local baseline acskill exfunction
	foreach var of local baseline {
	gen has_base_`var'=1 if !missing(zbase_`var')
	replace has_base_`var'=0 if missing(has_base_`var')
	}
	
	label var has_base_acskill "Has Baseline AS"
	label var has_base_exfunction "Has Baseline EF"

order has_*, after(zend_exfunction)


save "$output/temp.dta", replace

*--------------------------------------------------------------------------------------------------------
*						VILLAGE_ID 
*
*---------------------------------------------------------------------------------------------------------

import excel "$input/village-list.xlsx",  sheet("Data") firstrow clear

rename vid VILLAGE_ID

merge 1:m VILLAGE_ID using "$output/temp.dta"

rename vname Village_Name
label var Village_Name "Village Name"
label var VILLAGE_ID "VILLAGE ID"

drop _merge 

save "$output/temp.dta", replace



*--------------------------------------------------------------------------------------------------------
*						ATTENDANCE DATA 
*
*---------------------------------------------------------------------------------------------------------

import excel "$input/attendance-hv-and-pk.xlsx", sheet("Sheet1") firstrow clear 

rename NumberofHomeVisitinApril20 attendance_april_2017 
rename NumberofHomeVisitinMay2017 attendance_may_2017 
rename NumberofHomeVisitinJune201 attendance_june_2017
rename  NumberofHomeVisitinJuly201 attendance_july_2017 
rename NumberofHomeVisitinAugust2 attendance_august_2017 
rename NumberofHomeVisitinSeptembe attendance_sept_2017 
rename NumberofHomeVisitinOctobar attendance_oct_2017 
rename  NumberofHomeVisitinNovember attendance_nov_2017 
rename  NumberofHomeVisitinDecember attendance_dec_2017 
rename NumberofHomeVisitinJanuary attendance_jan_2018
rename  NumberofHomeVisitinFebruary attendance_feb_2018 
rename NumberofHomeVisitinMarch20 attendance_mar_2018 
rename U attendance_apr_2018 
rename NumberofHomeVisitinMay2018 attendance_may_2018 
rename  W attendance_june_2018 
rename  X attendance_july_2018 
rename  Y attendance_aug_2018 
rename Z  attendance_sept_2018 
rename AA attendance_oct_2018 
rename AB attendance_nov_2018 

drop CT CB Gender CHILD_NUMBER

merge 1:1 CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID  using "$output/temp.dta"

rename _merge merge_attendance_hv_and_pk 

save "$output/temp.dta", replace

import excel "$input/attendance-hv-only.xlsx", sheet("Sheet1") firstrow clear 


rename HomeVisitinApril2017 attendance_april_2017
rename HomeVisitinMay2017 attendance_may_2017
rename HomeVisitinJune2017 attendance_june_2017
rename HomeVisitinJuly2017 attendance_july_2017
rename HomeVisitinAugust2017 attendance_august_2017
rename HomeVisitinSeptember2017 attendance_sept_2017
rename HomeVisitinOctobar2017 attendance_oct_2017
rename HomeVisitinNovember2017 attendance_nov_2017
rename HomeVisitinDecember2017 attendance_dec_2017
rename HomeVisitinJanuary2018 attendance_jan_2018
rename HomeVisitinFebruary2018 attendance_feb_2018
rename HomeVisitinMarch2018 attendance_mar_2018
rename HomeVisitinApril2018 attendance_apr_2018
rename HomeVisitinMay2018 attendance_may_2018
rename HomeVisitinJune2018 attendance_june_2018
rename HomeVisitinJuly2018 attendance_july_2018
rename HomeVisitinAugust2018 attendance_aug_2018
rename HomeVisitinSeptember2018 attendance_sept_2018
rename HomeVisitinOctobar2018 attendance_oct_2018
rename HomeVisitinNovember2018 attendance_nov_2018


drop CT CB Gender CHILD_NUMBER

merge 1:1 CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID  using "$output/temp.dta"

rename _merge merge_attendance_hv_only 

save "$output/temp.dta", replace



import excel "$input/attendance-pk-only.xlsx", sheet("Sheet1") firstrow clear 


rename NumberofclassattendedinSept attendance_sept_2017
rename  NumberofclassattendedinOcto attendance_oct_2017
rename  NumberofclassattendedinNove attendance_nov_2017
rename NumberofclassattendedinJanu attendance_jan_2018
rename  NumberofclassattendedinFebr attendance_feb_2018
rename NumberofclassattendedinMarc attendance_mar_2018
rename NumberofclassattendedinApri attendance_apr_2018
rename NumberofclassattendedinMay attendance_may_2018
rename NumberofclassattendedinJune attendance_june_2018
rename NumberofclassattendedinJuly attendance_july_2018
rename NumberofclassattendedinAugu attendance_aug_2018
rename  U attendance_sept_2018
rename V attendance_oct_2018
rename NumberofclassattendedinDec attendance_dec_2018


drop CT CB Gender CHILD_NUMBER Project_continuation 

merge 1:1 CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID  using "$output/temp.dta"

rename _merge merge_attendance_pk_only 


order attendance*, after(child_type)



local attendance april_2017 may_2017 june_2017 july_2017 august_2017 sept_2017 oct_2017 nov_2017  dec_2017 jan_2018 feb_2018 mar_2018 apr_2018 may_2018 june_2018 july_2018 aug_2018 sept_2018 oct_2018 nov_2018 dec_2018
foreach var of local attendance{
	
	gen participated_`var'=1 if !missing(attendance_`var') & attendance_`var'!=0
	replace  participated_`var'=0 if missing(participated_`var') & attendance_`var'==0
	label var participated_`var' "1=attended at least once"
}

egen total_sessions_2017=rowtotal(attendance_april_2017 attendance_may_2017 attendance_june_2017 attendance_july_2017 attendance_august_2017 attendance_sept_2017 attendance_oct_2017 attendance_nov_2017  attendance_dec_2017)
egen total_sessions_2018=rowtotal(attendance_jan_2018 attendance_feb_2018 attendance_mar_2018 attendance_apr_2018 attendance_may_2018 attendance_june_2018 attendance_july_2018 attendance_aug_2018 attendance_sept_2018 attendance_oct_2018 attendance_nov_2018 attendance_dec_2018)
egen total_sessions_2017_2018=rowtotal(attendance_april_2017 attendance_may_2017 attendance_june_2017 attendance_july_2017 attendance_august_2017 attendance_sept_2017 attendance_oct_2017 attendance_nov_2017  attendance_dec_2017 attendance_jan_2018 attendance_feb_2018 attendance_mar_2018 attendance_apr_2018 attendance_may_2018 attendance_june_2018 attendance_july_2018 attendance_aug_2018 attendance_sept_2018 attendance_oct_2018 attendance_nov_2018 attendance_dec_2018)


label var total_sessions_2017 "Total number of sessions in 2017 that child attended to at least one session"
label var total_sessions_2018 "Total number of sessions in 2018 that child attended to at least one session"
label var total_sessions_2017_2018 "Total number of sessions in 2017 and 2018 that child attended to at least one session"





egen total_months_2017=rowtotal(participated_april_2017 participated_may_2017 participated_june_2017 participated_july_2017 participated_august_2017 participated_sept_2017 participated_oct_2017 participated_nov_2017  participated_dec_2017) 
egen total_months_2018=rowtotal(participated_jan_2018 participated_feb_2018 participated_mar_2018 participated_apr_2018 participated_may_2018 participated_june_2018 participated_july_2018 participated_aug_2018 participated_sept_2018 participated_oct_2018 participated_nov_2018 participated_dec_2018)
egen total_months_2017_2018=rowtotal(participated_april_2017 participated_may_2017 participated_june_2017 participated_july_2017 participated_august_2017 participated_sept_2017 participated_oct_2017 participated_nov_2017  participated_dec_2017 participated_jan_2018 participated_feb_2018 participated_mar_2018 participated_apr_2018 participated_may_2018 participated_june_2018 participated_july_2018 participated_aug_2018 participated_sept_2018 participated_oct_2018 participated_nov_2018 participated_dec_2018)


label var total_months_2017 "Number of months in 2017 that child attended to at least one session"
label var total_months_2018 "Number of months in 2018 that child attended to at least one session"
label var total_months_2017_2018 "Number of months in 2017 and 2018 that child attended to at least one session"





*--------------------------------------------------------------------------------------------------------
*						CREATING ATTENDANCE VARIABLES 
*
*---------------------------------------------------------------------------------------------------------


* VERSION 0: Rates created with total sessions 


egen max_sessions_village_treatment=max(total_sessions_2017_2018), by(VILLAGE_ID treat1)
label var max_sessions_village_treatment "Max. no. of sessions per village per treatment (2018-2019)"
order max_sessions_village_treatment, after(total_sessions_2017_2018)



/*
forvalues i=1/3 {
sum total_sessions_2017_2018 if treat1==`i'
local max_total_`i'=`r(max)'
}

gen ts_2017_2018_pk_only= total_sessions_2017_2018/`max_total_1' if pkonly==1
gen ts_2017_2018_hv_only= total_sessions_2017_2018/`max_total_2' if hvonly==1
gen ts_2017_2018_pk_hv= total_sessions_2017_2018/`max_total_3' if pk_hv==1

*/ 

gen ts_2017_2018_pk_only= total_sessions_2017_2018/max_sessions_village_treatment if pkonly==1
gen ts_2017_2018_hv_only= total_sessions_2017_2018/max_sessions_village_treatment if hvonly==1
gen ts_2017_2018_pk_hv= total_sessions_2017_2018/max_sessions_village_treatment if pk_hv==1


replace ts_2017_2018_pk_only=0 if pkonly!=1
replace ts_2017_2018_hv_only=0 if hvonly!=1
replace ts_2017_2018_pk_hv=0 if pk_hv!=1



*VERSION 1: Dummies created with the max. 

forvalues i=1/3 {
sum total_months_2017_2018 if treat1==`i'
local max_total_`i'=`r(max)'
}

gen inst_pkonly_max=1 if total_months_2017_2018==`max_total_1' & treat1==1
replace  inst_pkonly_max=0 if missing(inst_pkonly_max)
gen inst_hvonly_max=1 if total_months_2017_2018==`max_total_2'  & treat1==2
replace  inst_hvonly_max=0 if missing(inst_hvonly_max)
gen inst_hvpk_max=1 if total_months_2017_2018==`max_total_3'  & treat1==3
replace  inst_hvpk_max=0 if missing(inst_hvpk_max)




*VERSION 2: Dummies created with the mean. 

forvalues i=1/3 {
sum total_months_2017_2018 if treat1==`i'
local mean_total_`i'=`r(mean)'
}

gen inst_pkonly_mean=1 if total_months_2017_2018>=`mean_total_1' & treat1==1
replace  inst_pkonly_mean=0 if missing(inst_pkonly_mean)
gen inst_hvonly_mean=1 if total_months_2017_2018>=`mean_total_2'  & treat1==2
replace  inst_hvonly_mean=0 if missing(inst_hvonly_mean)
gen inst_hvpk_mean=1 if total_months_2017_2018>=`mean_total_3'  & treat1==3
replace  inst_hvpk_mean=0 if missing(inst_hvpk_mean)



* VERSION 3: Dummies created with the 75th percentile 


forvalues i=1/3 {
sum total_months_2017_2018 if treat1==`i', d
local p75_total_`i'=`r(p75)'
}

gen inst_pkonly_p75=1 if total_months_2017_2018>=`p75_total_1' & treat1==1
replace  inst_pkonly_p75=0 if missing(inst_pkonly_p75)
gen inst_hvonly_p75=1 if total_months_2017_2018>=`p75_total_2'  & treat1==2
replace  inst_hvonly_p75=0 if missing(inst_hvonly_p75)
gen inst_hvpk_p75=1 if total_months_2017_2018>=`p75_total_3'  & treat1==3
replace  inst_hvpk_p75=0 if missing(inst_hvpk_p75)




* VERSION 4: Dummies created with the median 

forvalues i=1/3 {
sum total_months_2017_2018 if treat1==`i', d
local p50_total_`i'=`r(p50)'
}

gen inst_pkonly_p50=1 if total_months_2017_2018>=`p50_total_1' & treat1==1
replace  inst_pkonly_p50=0 if missing(inst_pkonly_p50)
gen inst_hvonly_p50=1 if total_months_2017_2018>=`p50_total_2'  & treat1==2
replace  inst_hvonly_p50=0 if missing(inst_hvonly_p50)
gen inst_hvpk_p50=1 if total_months_2017_2018>=`p50_total_3'  & treat1==3
replace  inst_hvpk_p50=0 if missing(inst_hvpk_p50)





* VERSION 5: Dummies created with the 25th percentile 

forvalues i=1/3 {
sum total_months_2017_2018 if treat1==`i', d
local p25_total_`i'=`r(p25)'
}

gen inst_pkonly_p25=1 if total_months_2017_2018>=`p25_total_1' & treat1==1
replace  inst_pkonly_p25=0 if missing(inst_pkonly_p25)
gen inst_hvonly_p25=1 if total_months_2017_2018>=`p25_total_2'  & treat1==2
replace  inst_hvonly_p25=0 if missing(inst_hvonly_p25)
gen inst_hvpk_p25=1 if total_months_2017_2018>=`p25_total_3'  & treat1==3
replace  inst_hvpk_p25=0 if missing(inst_hvpk_p25)





save "$output/ECD_compiled.dta", replace
erase "$output/Early childhood Development.dta"
erase "$output/temp.dta"



*--------------------------------------------------------------------------------------------------------
*					ATTRITION RATES 
*
*---------------------------------------------------------------------------------------------------------



use "$output/ECD_compiled.dta", clear 


keep  VILLAGE_ID attrited*

collapse attrited*, by(VILLAGE_ID)


keep VILLAGE_ID  attrited_year1_v2 attrited_year2 

gen attrited_year1=attrited_year1_v2*100
replace attrited_year2=attrited_year2*100

keep  VILLAGE_ID attrited_year1_v1_1 attrited_year1_v1_2 attrited_year1_v2

*attrited_year1_v1_1!=attrited_year1_v1_2 because in the first one is taking into account only those kids that have non missing data, whereas in the second the denominator is larger. 

export delimited "$output/attrition-by-village.csv", replace	



*** END *** 

