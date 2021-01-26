

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
	
	
