

/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: PRELIMINARY ANALYSIS 
AUTHOR: LINA RAMIREZ 
DATE CREATED: 26/01/2021
LAST MODIFIED: 30/03/2021

PURPOSE: Master do


------------------------------------------------------------------------------*/



*-------------------------------------------------------------------------------
*						DIRECTORY
*
*------------------------------------------------------------------------------- 


if c(os)=="Windows" {
	cd "C:/Users/`c(username)'/Dropbox"
	
}
else if c(os)=="MacOSX" {
	cd "/Users/`c(username)'/Dropbox"
	
}

global dropbox `c(pwd)'

	gl main "$dropbox/Chicago/UChicago/Personal/ECD_Bangladesh"
	gl input "$main/input"
	gl output "$main/output"
	gl results "$main/results"

	
	
