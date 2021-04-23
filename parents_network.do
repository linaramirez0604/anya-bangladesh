

cd "/Users/tanmaygupta/Dropbox/ECD_Bangladesh/Parents Network Data"

use "Parents network survey main.dta", clear 



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
