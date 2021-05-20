

cd "/Users/tanmaygupta/Dropbox/ECD_Bangladesh/Parents Network Data"




//merging data 

cd "/Users/tanmaygupta/Dropbox/ECD_Bangladesh"
use "output/ECD_compiled.dta", clear 

cd "/Users/tanmaygupta/Dropbox/ECD_Bangladesh/Parents Network Data"

rename _merge old_merge 

merge 1:m CHILD_ID using "pnetwork.dta"

//note: 3000 children do not match from ECD_compiled. These CHILD_ID's are not there in the network data. Not sure how to get around this. 


keep if _merge == 3 
keep if !missing(R1)


 




/*
****************************************************************
Constructing a measure for 'neighbors'
****************************************************************


Note: This will follow what was done in (paper) 

For this, we need "neighborhood radii" to define a pair of neighbors. We don't have distances here but we have times, so we can do the same with "radii" for time. This is in Q2
*/




//Note that "don't know him" relations have Q2 == 0 minutes, which will mess up our "closeness" measure, so changing this: 
replace Q2 = . if R1 == 8

br R1 if Q2 == 0 //seeing what 0 values there are. Some of these are "distant neighbor", which doesn't make sense. There are some errors in the data here. 

replace Q2 = . if Q2 == 0 & R1 == 4 //doesn't make sense for distant neighbor to have 0 time between them


//we now get 

sum Q2

/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
          Q2 |    121,298    6.483883    4.674818          0         77



In the paper, the mean of the distance variable is 8km with SD 8.07km, but they use radii 1, 3, 5, 7 (all less than mean). Not sure what values we should use: our mean is 6.48 mins and SD is 4.67 mins. 
*/



foreach i in 3 4 5 6 7 { 
	gen neighbor_`i' = 1 if Q2 < `i' 
	replace neighbor_`i' = 0 if neighbor_`i' != 1 & !missing(Q2)
	label var neighbor_`i' "Neighbor (`i')"
}

*We now have "neighbor_i" variables which measure closeness 



//Balance of treatments based on neighbor_i variables


eststo clear 
quietly estpost tabstat neighbor_*, by(treat1) statistics(mean) column(statistics)  
eststo balance 


cd "/Users/tanmaygupta/Dropbox/ECD_Bangladesh/Parents Network Data/Tables"
esttab balance using "balance.tex", cells("mean(label(Mean) fmt(2))") main(mean) replace label 



//Regressions to test balance of treatments 


label define treat 1 "PK" 2 "HV" 3 "HVPK" 4 "Control"
label values treat1 treat

eststo clear 
foreach i in 3 4 5 6 7 { 
	quietly reg neighbor_`i' ib4.treat1 
	eststo reg_`i' 
}
cd "/Users/tanmaygupta/Dropbox/ECD_Bangladesh/Parents Network Data/Tables"
esttab reg_3 reg_4 reg_5 reg_6 reg_7 using "balance_reg.tex", label replace fragment tex starlevels(* 0.10 ** 0.05 *** 0.01)  se(3) b(3) constant nogaps




*1. Some summary graphs 


//relations
graph hbar (count), over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green))

graph hbar (count) if R1 != 3 & R1 != 4 & R1 != 8 , over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green))


//geographical proximity 
histogram Q2, percent graphregion(fcolor(white)) plotregion(fcolor(white)) fcolor(green) lcolor(black)

histogram Q2 if R1!=8, percent graphregion(fcolor(white)) plotregion(fcolor(white)) fcolor(green) lcolor(black)

graph hbar (mean) Q2 if R1 != 8, over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green)) 


//Yes no questions 
foreach var in Q3 Q4 Q5 Q6 Q7 { 
	replace `var' = "0" if `var' == "2"
	replace `var' = "1" if `var' == "1"
	destring `var', replace
}


label variable Q3 "Worked with them" 
label variable Q4 "Visited them"
label variable Q5 "Were visited"
label variable Q6 "Money borrow"
label variable Q7 "Sickness help"
eststo summaries: quietly estpost summarize Q3 Q4 Q5 Q6 Q7
esttab summaries using "Tables/summaries.tex", cells("mean(fmt(2)) sd(fmt(2))") replace label 


graph hbar (mean) Q3, over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green))

graph hbar (mean) Q4, over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green))

graph hbar (mean) Q5, over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green))

graph hbar (mean) Q6, over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green))

graph hbar (mean) Q7, over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green))


//Friends

graph hbar (count) if 0<=Q8 & Q8 <= 10, over(Q8) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green)) 

graph hbar (mean) Q8 if 0<=Q8 & Q8 <= 10, over(R1) graphregion(fcolor(white)) plotregion(fcolor(white)) bar(1, fcolor(green)) 

eststo clear
estpost tabstat Q8, statistics(mean sd) by(R1) column(statistics) listwise 


esttab using "Tables/rankings.tex", cells("mean(label(Mean) fmt(2)) sd(label(Std. Dev)fmt(2))") main(mean) aux(sd) replace label 
