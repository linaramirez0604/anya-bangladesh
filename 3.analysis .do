

/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: PRELIMINARY ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 26/01/2021
LAST MODIFIED: 

PURPOSE: Preliminary analysis. Based on "analysis by Anya suggestion.dta" by Tanvir Ahmed and word document "Anya suggested analysis plan". 


------------------------------------------------------------------------------*/



*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 

clear all 

if c(os)=="Windows" {
	cd "C:/Users/`c(username)'/Dropbox"
	
}
else if c(os)=="MacOSX" {
	cd "/Users/`c(username)'/Dropbox"
	
}

global dropbox `c(pwd)'

	
	gl data "$dropbox/Chicago/UChicago/ECD_Data_documents_2020/Final Data_ALL rounds/Compiled Dataset"

	

	cd "$data"
	
	
	use ECD_compiled, clear  

	
	

*--------------------------------------------------------------------------------------------------------
*						CREATING STD. VARIABLES (Based on control group means and sd.)
*
*---------------------------------------------------------------------------------------------------------

*Academic Skill variable: Literacy + Numeracy 

gen base_acskill=base_lit_overall+base_num_overall
gen mid_acskill=mid_lit_overall+mid_num_overall
gen end_acskill=end_lit_overall+end_num_overall
order base_acskill mid_acskill end_acskill, after(source_lit)

*Standardized variables 

local asq "gm fm comm prbs psc overall"

foreach var of local  asq{
quietly summ base_asq_`var' if treat1==4
scalar `var'_mean=r(mean)
scalar `var'_sd=r(sd)
gen zbase_`var'=(base_asq_`var'-`var'_mean)/`var'_sd
gen zmid_`var'=(mid_asq_`var'-`var'_mean)/`var'_sd
gen zend_`var'=(end_asq_`var'-`var'_mean)/`var'_sd


}


local skill "lit num os ss"

foreach var of local skill {
quietly summ base_`var'_overall  if treat1==4
scalar `var'_mean=r(mean)
scalar `var'_sd=r(sd)
gen zbase_`var'_overall=(base_`var'_overall-`var'_mean)/`var'_sd
gen zmid_`var'_overall=(mid_`var'_overall-`var'_mean)/`var'_sd
gen zend_`var'_overall=(end_`var'_overall-`var'_mean)/`var'_sd

}



quietly summ base_acskill if treat1==4
scalar acskill_mean=r(mean)
scalar acskill_sd=r(sd)
gen zbase_acskill=(base_acskill-acskill_mean)/acskill_sd
gen zmid_acskill=(mid_acskill-acskill_mean)/acskill_sd
gen zend_acskill=(end_acskill-acskill_mean)/acskill_sd




