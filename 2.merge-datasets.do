

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


*global input "C:\Users\tanvi\Dropbox (Personal)\ECD_Data_documents_2020\Final Data_ALL rounds"
*global output "C:\Users\tanvi\Dropbox (Personal)\ECD_Data_documents_2020\Final Data_ALL rounds\Compiled Dataset"


if c(os)=="Windows" {
	cd "C:/Users/`c(username)'/Dropbox"
	
}
else if c(os)=="MacOSX" {
	cd "/Users/`c(username)'/Dropbox"
	
}

global dropbox `c(pwd)'

	gl input "$dropbox/Chicago/UChicago/ECD_Data_documents_2020/Final Data_ALL rounds"
	gl output "$dropbox/Chicago/UChicago/ECD_Data_documents_2020/Final Data_ALL rounds/Compiled Dataset"

	


*-------------------------------------------------------------------------------
*					MERGE CT, CB AND GENDER TO ALL DATASETS 	
*
*------------------------------------------------------------------------------- 


local  dataset `" "Baseline ASQ" "Baseline Literacy" "Baseline Numeracy" "Baseline OS" "Baseline SS" "Midline ASQ" "Midline Literacy" "Midline Numeracy" "Midline OS" "Midline SS" "Midline PSRA" "Midline Dial-4 & homevisit" "Endline ASQ" "Endline Literacy" "Endline Numeracy" "Endline OS" "Endline SS" "Endline PSRA" "Endline Dial-4 & homevisit" "'

foreach var of local dataset {
use "$output/`var'.dta", clear
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
gen source="Attrited on Mid" if _merge==1
replace source="New subject Mid" if _merge==2 & CT==1 
replace source="Sibiling Mid" if _merge==2 & CT==2 
replace source="Cousin Mid" if _merge==2 & CT==3 
replace source="Merged Mid" if _merge==3
drop _merge 

merge 1:1 CHILD_ID using "$output/Endline `var'.dta"
replace source="Attrited on End" if _merge==1 & CT==1 
replace source="Attrited on End (sibiling)" if _merge==1 & CT==2 
replace source="Attrited on End (cousin)" if _merge==1 & CT==3 
replace source="New subject End" if _merge==2 & CT==1 
replace source="New Sibiling End" if _merge==2 & CT==2 
replace source="New Cousin End" if _merge==2 & CT==3 
replace source="Merged Base,mid and Endline" if _merge==3 & source=="Merged Mid" 
replace source="Merged Base and Endline" if _merge==3 & missing(source)
replace source="Merged Sibilings mid-end" if _merge==3 & CT==2
replace source="Merged Cousin mid-end" if _merge==3 & CT==3
drop _merge 

rename source source_`var'

save "$output/compiled_`var'.dta", replace 
erase "$output/Baseline `var'.dta"
erase "$output/Midline `var'.dta"
erase "$output/Endline `var'.dta"

}

*PSRA and Dial-4 & Homevisit are only in Midline and Endline

use "$output/Midline Dial-4 & homevisit.dta", clear
erase "$output/Midline Dial-4 & homevisit.dta"
save "$output/Midline Dial.dta", replace 


use "$output/Endline Dial-4 & homevisit.dta", clear
erase "$output/Endline Dial-4 & homevisit.dta"
save "$output/Endline Dial.dta", replace 


local survey "PSRA Dial"
foreach var of local survey{
use "$output/Midline `var'.dta", clear
merge 1:1 CHILD_ID using "$output/Endline `var'.dta"
gen source="Attrited on End" if _merge==1 & CT==1 
replace source="Attrited on End (sibiling)" if _merge==1 & CT==2 
replace source="Attrited on End (cousin)" if _merge==1 & CT==3 
replace source="New subject End" if _merge==2 & CT==1 
replace source="New Sibiling End" if _merge==2 & CT==2 
replace source="New Cousin End" if _merge==2 & CT==3  
replace source="Merged Mid and Endline" if _merge==3 
replace source="Merged Sibilings mid-end" if _merge==3 & CT==2
replace source="Merged Cousin mid-end" if _merge==3 & CT==3
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
use "$input/Midline Data/By home visit analysis/ecd_home_final.dta", clear

keep  VILLAGE_ID treat_home
duplicates drop 


merge 1:m VILLAGE_ID using "$output/Early childhood Development.dta"

rename treat_home num_stud_village 
label var num_stud_village "Number of student treated per village"
drop _merge 

save "$output/temp.dta", replace  


*Visit + Pre-school
use "$input/Midline Data/By home visit analysis/ecd_home_PreK_FINAL.dta", clear

keep  VILLAGE_ID ctype 
duplicates drop 

merge 1:m VILLAGE_ID using "$output/temp.dta"
replace num_stud_village=1 if ctype==1 
replace num_stud_village=1 if ctype==2
replace num_stud_village=1 if ctype==3
drop ctype 
drop _merge 


generate str b_date="01022017"
gen base_date = date(b_date, "DMY")
format base_date %td
gen base_age_month = round((base_date-Date_of_birth)/(365/12))
gen base_age_year=round(base_age_month/12)
label variable base_age_month "Age 1st February, 2017 (Baseline survey) in months"
label variable base_age_year "Age 1st February, 2017 (Baseline survey) in years"


save "$output/Early childhood Development compiled.dta", replace
erase "$output/Early childhood Development.dta"
erase "$output/temp.dta"

