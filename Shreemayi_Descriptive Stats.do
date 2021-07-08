
/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: DESCRIPTIVE STATISTICS 
AUTHOR: SHREEMAYI SAMUJJWALA
LAST MODIFIED: 07/08/2021

PURPOSE: Descriptive Statistics and Balance Table. Based on "analysis by Anya suggestion.dta" by Tanvir Ahmed and word document "Anya suggested analysis plan". 


------------------------------------------------------------------------------*/



*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 

	
cd "$output"
	
	
	use ECD_compiled, clear  
	drop if missing(child_treat_status)
	
	/*
	duplicates drop VILLAGE_ID child_treat_status,force
	sort VILLAGE_ID child_treat_status
	bysort child_treat_status  : gen new=_n
	br VILLAGE_ID child_treat_status new
	egen new1=max(new), by(child_treat_status)

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
	
		*/
		
	label var father_age "Father's Age'"
	label var mother_age "Mother's Age"
	label var base_asq_overall "Base ASQ"
	

foreach var in mother_education father_education{
	gen `var'_zero=`var'==0 & !missing(`var')
	label var `var'_zero "`var' no education"
	gen `var'_two_eight=`var'==2|`var'==5|`var'==8 & !missing(`var') 
	label var `var'_two_eight "`var' 2 to 8 years"
	gen `var'_ten_twelve=`var'==10|`var'==11|`var'==12 & !missing(`var')
	label var `var'_ten_twelve "`var' 10 to 12 years"
	gen `var'_greater_twelve=`var'==14|`var'==18 & !missing(`var')
	label var `var'_greater_twelve "`var' more than 12 years"
}	

foreach var in base_acskill base_exfunction base_asq_overall{
	gen has_`var'=1 if !missing(`var')
	replace has_`var'=0 if missing(`var')
}


foreach var in mid_acskill mid_exfunction mid_asq_overall{
	gen has_`var'=1 if !missing(`var')
	replace has_`var'=0 if missing(`var')
}

foreach var in end_acskill end_exfunction end_asq_overall{
	gen has_`var'=1 if !missing(`var')
	replace has_`var'=0 if missing(`var')
}

label var has_base_acskill  "Has Base AS"
label var has_base_exfunction  "Has Base EF"
label var has_base_asq_overall  "Has Base ASQ"

gen added_in_second_year=1 if missing(base_asq_gm)& missing(base_asq_fm)& missing( base_asq_comm)& missing( base_asq_prbs)& missing( base_asq_psc)& missing( base_asq_overall)& missing( base_num_overall)& missing( base_lit_overall)& missing( base_acskill)& missing( base_os_overall)& missing( base_ss_overall) 
replace added_in_second_year=0 if missing(added_in_second_year)

label define added_in_second_year 1 "added in second year" 0 "Added in year 1"
label values added_in_second_year added_in_second_year
label var added_in_second_year "Added in Year 2" 

*save temp.dta, replace 


cd "$tot"
preserve
global desc "Gender base_age_year added_in_second_year father_education mother_education *education_* household_income  base_acskill base_exfunction base_asq_overall has_base_acskill has_base_exfunction has_base_asq_overall father_age mother_age"
drop if child_type==0
*iebaltab $desc, grpvar(child_treat_status)  pttest total format(%9.2f) save("balance_treatment_control_disaggregated") replace stdev  order(1 2 3 4 5 6 7 8 9 10) control(9) rowvarlabels tblnote("")
replace treat1=5 if treat1==2 & child_treat_status==4
label define treatments 5 "HV-didn't get HV", modify
*iebaltab $desc, grpvar(treat1)  pttest total format(%9.2f) save("balance_treatment_control") replace stdev  order(1 2 3 5 4) control(4) rowvarlabels tblnote("")
gen hv_assignments=1 if child_treat_status<4 
replace hv_assignments=2 if child_treat_status==4 
replace hv_assignments=3 if child_treat_status==9 

gen hv_prek_assignments=1 if child_treat_status>=5 & child_treat_status<=7 
replace hv_prek_assignments=2 if child_treat_status==8
replace hv_prek_assignments=3 if child_treat_status==9 


label define hv_assignments 1 "HV-Treated" 2 "HV-Control" 3 "Super Control"
label define hv_prek_assignments 1 "HV+Prek: Both" 2 "HV+Prek: Only Prek" 3 "Super Control"

label values hv_assignments hv_assignments
label values hv_prek_assignments hv_prek_assignments

iebaltab $desc, grpvar(hv_assignments)  pttest total format(%9.2f) save("hv_balance_treatment_control") replace stdev  order(1 2 3) control(2) rowvarlabels tblnote("")
*iebaltab $desc, grpvar(hv_prek_assignments)  pttest total format(%9.2f) save("hv_prek_balance_treatment_control") replace stdev  order(1 2 3) control(2) rowvarlabels tblnote("")

restore


cd "$tables"

replace treat1=5 if treat1==2 & child_treat_status==4
label define treatments 5 "HV-didn't get HV", modify

global desc "Gender base_age_year added_in_second_year father_education mother_education *education_* household_income  base_acskill base_exfunction base_asq_overall has_base_acskill has_base_exfunction has_base_asq_overall father_age mother_age child_type"
global desc1 child_type
/*
iebaltab $desc, grpvar(child_treat_status)  pttest total format(%9.2f) save("balance_treatment_control_disaggregated") replace stdev  order(1 2 3 4 5 6 7 8 9 10) control(9) rowvarlabels tblnote("")
iebaltab $desc, grpvar(treat1)  pttest total format(%9.2f) save("balance_treatment_control") replace stdev  order(1 2 3 5 4) control(4) rowvarlabels tblnote("")
*/

iebaltab $desc1, grpvar(treat1)  pttest total format(%9.2f) save("balance_treatment_control_child") replace stdev  order(1 2 3 5 4) control(4) rowvarlabels tblnote("")

gen hv_assignments=1 if child_treat_status<4 
replace hv_assignments=2 if child_treat_status==4 
replace hv_assignments=3 if child_treat_status==9 

gen hv_prek_assignments=1 if child_treat_status>=5 & child_treat_status<=7 
replace hv_prek_assignments=2 if child_treat_status==8
replace hv_prek_assignments=3 if child_treat_status==9 


label define hv_assignments 1 "HV-Treated" 2 "HV-Control" 3 "Super Control"
label define hv_prek_assignments 1 "HV+Prek: Both" 2 "HV+Prek: Only Prek" 3 "Super Control"

label values hv_assignments hv_assignments
label values hv_prek_assignments hv_prek_assignments


/*
iebaltab $desc, grpvar(hv_assignments)  pttest total format(%9.2f) save("hv_balance_treatment_control") replace stdev  order(1 2 3) control(2) rowvarlabels tblnote("")
iebaltab $desc, grpvar(hv_prek_assignments)  pttest total format(%9.2f) save("hv_prek_balance_treatment_control") replace stdev  order(1 2 3) control(2) rowvarlabels tblnote("")
*/

iebaltab $desc1, grpvar(hv_assignments)  pttest total format(%9.2f) save("hv_balance_treatment_control_child") replace stdev  order(1 2 3) control(2) rowvarlabels tblnote("")
iebaltab $desc1, grpvar(hv_prek_assignments)  pttest total format(%9.2f) save("hv_prek_balance_treatment_control_child") replace stdev  order(1 2 3) control(2) rowvarlabels tblnote("")


label define treat_separate1 1 "Prek Only"		    0 "Control"
label define treat_separate2 1 "HV Only"      		0 "Control"
label define treat_separate3 1 "HV + Prek"			0 "Control"      
label define treat_separate4 1 "Control"			0 "Control"
label define treat_separate5 1 "HV, Didn't get HV"	0 "Control"

tab treat1, gen(treat_separate)
forvalues i=1(1)5{
	replace treat_separate`i'=. if treat_separate`i'==0 & child_treat_status!=9
	label values treat_separate`i' treat_separate`i'
}

ren treat_separate1 treat_separate_prek_only
ren treat_separate2 treat_separate_hv_only
ren treat_separate3 treat_separate_hv_prek
ren treat_separate5 treat_separate_hv_no_hv


drop z*
**standardizing variables

local asq "gm fm comm prbs psc overall"


***standardized variables different from Lina's - Have to Ask Why? 
foreach var of local asq{
foreach time in base mid end{
egen z`time'_`var'try=std(`time'_asq_`var') if !missing(`time'_asq_`var')
}
}



local skill "lit num os ss"

foreach var of local skill{
foreach time in base mid end{
egen z`time'_`var'_overall=std(`time'_`var'_overall) if !missing(`time'_`var'_overall)
}
}


foreach var in acskill exfunction{
foreach time in base mid end{
egen z`time'_`var'=std(`time'_`var') if !missing(`time'_`var')
}
}
