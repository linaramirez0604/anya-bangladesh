

/* -----------------------------------------------------------------------------
PROJECT: BANGLADESH EDUCATION PROJECT 
TOPIC: PREPARING DATASETS FOR MERGE
AUTHOR: TANVIR AHMED 
DATE CREATED: 21/01/2021
LAST MODIFIED: 

PURPOSE: This is the first part of the dofile "Merging all data.do" (until line 641) written by Tanvir to clean and create datasets to be merged. 
	

NOTES: 
-The original dofile ("Merging all data.do") can be find in the folder/Users/bfiuser/Dropbox/Chicago/UChicago/ECD_Data_documents_2020/Final Data_ALL rounds/Compiled Dataset 
-Change the directory as required. 
-This dofile was not modified by Lina Ramirez (only the directory)

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
	gl output "$dropbox/Chicago/UChicago/Personal/ECD_Bangladesh/input"
	


	
	
****************************************** Ages and stages
use "$input/Baseline Data/Baseline ASQ.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID CHILD_NUMBER Gender  treat1 Score_1 Score_2 Score_3 Score_4 Score_5 fscore
rename Score_1 base_asq_gm
rename Score_2 base_asq_fm
rename Score_3 base_asq_comm
rename Score_4 base_asq_prbs
rename Score_5 base_asq_psc
rename fscore base_asq_overall

label variable base_asq_gm "Total gross motor score in baseline (out of 60)"
label variable base_asq_fm "Total fine motor score in baseline (Out of 60)"
label variable base_asq_comm "Total communication score in baseline (Out of 60)"
label variable base_asq_prbs "Total Problem solving score in baseline (Out of 60)"
label variable base_asq_psc "Total Personal-scoial score in baseline (Out of 60)"
label variable base_asq_overall "Total asq score in baseline (out of 300)"

save "$output/Baseline ASQ.dta", replace



use "$input/Midline Data/Midline ASQ.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID CHILD_NUMBER Gender treat1 Score_1 Score_2 Score_3 Score_4 Score_5 fscore
rename Score_1 mid_asq_gm
rename Score_2 mid_asq_fm
rename Score_3 mid_asq_comm
rename Score_4 mid_asq_prbs
rename Score_5 mid_asq_psc
rename fscore mid_asq_overall

label variable mid_asq_gm "Total gross motor score in midline (out of 60)"
label variable mid_asq_fm "Total fine motor score in midline (Out of 60)"
label variable mid_asq_comm "Total communication score in midline(Out of 60)"
label variable mid_asq_prbs "Total Problem solving score in midline (Out of 60)"
label variable mid_asq_psc "Total Personal-scoial score in midline(Out of 60)"
label variable mid_asq_overall "Total asq score in midline (out of 300)"

save "$output/Midline ASQ.dta", replace

use "$input/Endline Data/Endline ASQ.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID CHILD_NUMBER Gender treat1 Score_1 Score_2 Score_3 Score_4 Score_5 fscore
rename Score_1 end_asq_gm
rename Score_2 end_asq_fm
rename Score_3 end_asq_comm
rename Score_4 end_asq_prbs
rename Score_5 end_asq_psc
rename fscore end_asq_overall

label variable end_asq_gm "Total gross motor score in endline (out of 60)"
label variable end_asq_fm "Total fine motor score in endline (Out of 60)"
label variable end_asq_comm "Total communication score in endline (Out of 60)"
label variable end_asq_prbs "Total Problem solving score in endline (Out of 60)"
label variable end_asq_psc "Total Personal-scoial score in endline (Out of 60)"
label variable end_asq_overall "Total asq score in endline (out of 300)"

save "$output/Endline ASQ.dta", replace



******************************** Literacy 
use "$input/Baseline Data/Baseline Literacy.dta", clear
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID treat1 Gender  score
rename score base_lit_overall
label variable base_lit_overall "Total literacy score in baseline(out of 27)"

save "$output/Baseline Literacy.dta", replace


use "$input/Midline Data/Midline Literacy.dta", clear
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score mid_lit_overall
label variable mid_lit_overall "Total literacy score in Midline(out of 27)"

save "$output/Midline Literacy.dta", replace


use "$input/Endline Data/Endline Literacy.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score end_lit_overall
label variable end_lit_overall "Total literacy score in Endline(out of 27)"

save "$output/Endline Literacy.dta", replace


******************************** Numeracy 
use "$input/Baseline Data/Baseline Numeracy.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1  score
rename score base_num_overall
label variable base_num_overall "Total Numeracy score in baseline(out of 17)"

save "$output/Baseline Numeracy.dta", replace


use "$input/Midline Data/Midline Numeracy.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score mid_num_overall
label variable mid_num_overall "Total Numeracy score in Midline(out of 17)"

save "$output/Midline Numeracy.dta", replace


use "$input/Endline Data/Endline Numeracy.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score end_num_overall
label variable end_num_overall "Total Numeracy score in Endline(out of 17)"

save "$output/Endline Numeracy.dta", replace



******************************** Operation Span
use "$input/Baseline Data/Baseline Operation Span.dta", replace

keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1  score
rename score base_os_overall
label variable base_os_overall "Total Numeracy score in baseline(out of 17)"

save "$output/Baseline OS.dta", replace


use "$input/Midline Data/Midline Operation Span.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score mid_os_overall
label variable mid_os_overall "Total Numeracy score in Midline(out of 17)"

save "$output/Midline OS.dta", replace


use "$input/Endline Data/Endline Operation Span.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score end_os_overall
label variable end_os_overall "Total Numeracy score in Endline(out of 17)"

save "$output/Endline OS.dta", replace


******************************** Something Same
use "$input/Baseline Data/Baseline Something Same.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID treat1 RECORD_ID Gender  score
rename score base_ss_overall
label variable base_ss_overall "Total Numeracy score in baseline(out of 15)"

save "$output/Baseline SS.dta", replace


use "$input/Midline Data/Midline Something Same.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score mid_ss_overall
label variable mid_ss_overall "Total Numeracy score in Midline(out of 15)"

save "$output/Midline SS.dta", replace


use "$input/Endline Data/Endline Something Same.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 score
rename score end_ss_overall
label variable end_ss_overall "Total Numeracy score in Endline(out of 15)"

save "$output/Endline SS.dta", replace



********************************* PSRA
use "$input/Midline Data/Midline PSRA.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 gscore ascore
rename gscore mid_psra_cper
rename ascore mid_psra_cbeh

label variable mid_psra_cper "Midline PSRA child performance score(out of 59)"
label variable mid_psra_cbeh "Midline PSRA child behavior score(out of 70)"

save "$output/Midline PSRA.dta", replace


use "$input/Endline Data/Endline PSRA.dta", replace
keep CHILD_ID VILLAGE_ID FAMILY_ID RECORD_ID Gender treat1 gscore ascore
rename gscore end_psra_cper
rename ascore end_psra_cbeh

label variable end_psra_cper "Endline PSRA child performance score(out of 59)"
label variable end_psra_cbeh "Endline PSRA child behavior score(out of 70)"

save "$output/Endline PSRA.dta", replace



************************************ Dial-4 
use "$input/Midline Data/DIAL-4 and Home Visit Data/DIAL-4 & Home Visit Data all child.dta", replace
drop if Q1==.

gen s1_1=0					//Question: Child Laughs or smiles when something is funny
replace s1_1=2 if Q1_1==1
replace s1_1=1 if Q1_1==2

gen s1_2=0					//Question: Argues when denied own way
replace s1_2=2 if Q1_2==3    //scored in inverse direction
replace s1_2=1 if Q1_2==2

gen s1_3=0					//Question: Breaks toy or other objects on purpose
replace s1_3=2 if Q1_3==3    //scored in inverse direction
replace s1_3=1 if Q1_3==2

gen s1_4=0					//Question: Plays well with other children
replace s1_4=2 if Q1_4==1
replace s1_4=1 if Q1_4==2

gen s1_5=0					//Question: Has tantrums(stamps feet,screams etc)
replace s1_5=2 if Q1_5==3    //scored in inverse direction
replace s1_5=1 if Q1_5==2

gen s1_6=0					//Question: Solves problem by talking rather than by hitting, pushing, or biting
replace s1_6=2 if Q1_6==1
replace s1_6=1 if Q1_6==2

gen s1_7=0					//Question: Acts without thinking (Runs into street without looking both ways, etc)
replace s1_7=2 if Q1_7==3    //scored in inverse direction
replace s1_7=1 if Q1_7==2

gen s1_8=0					//Question: Admits when he or she makes mistakes
replace s1_8=2 if Q1_8==1
replace s1_8=1 if Q1_8==2

gen s1_9=0					//Question: Stays calm when things do not go as planned
replace s1_9=2 if Q1_9==1
replace s1_9=1 if Q1_9==2

gen s1_10=0					//Question: Blames others when bad things happen
replace s1_10=2 if Q1_10==3    //scored in inverse direction
replace s1_10=1 if Q1_10==2

gen s1_11=0					//Question: Knows when people are happy or sad
replace s1_11=2 if Q1_11==1
replace s1_11=1 if Q1_11==2

gen s1_12=0					//Question: Interrupts (Talks when others are speaking)
replace s1_12=2 if Q1_12==3    //scored in inverse direction
replace s1_12=1 if Q1_12==2

gen s1_13=0					//Question: Goes to bed easily
replace s1_13=2 if Q1_13==1
replace s1_13=1 if Q1_13==2

gen s1_14=0					//Question: Asks before using other peoples things
replace s1_14=2 if Q1_14==1
replace s1_14=1 if Q1_14==2

gen s1_15=0					//Question: Works well with others
replace s1_15=2 if Q1_15==1
replace s1_15=1 if Q1_15==2

gen s1_16=0					//Question: Shows pride in doing something well
replace s1_16=2 if Q1_16==1
replace s1_16=1 if Q1_16==2

gen s1_17=0					//Question: Bangs head on the floor, wall, or bed
replace s1_17=2 if Q1_17==3    //scored in inverse direction
replace s1_17=1 if Q1_17==2

gen s1_18=0					//Question: Clings or Hangs on you
replace s1_18=2 if Q1_18==3    //scored in inverse direction
replace s1_18=1 if Q1_18==2

gen s1_19=0					//Question: Whines or pouts
replace s1_19=2 if Q1_19==3    //scored in inverse direction
replace s1_19=1 if Q1_19==2

gen s1_20=0					//Question: Seems afraid of many things
replace s1_20=2 if Q1_20==3    //scored in inverse direction
replace s1_20=1 if Q1_20==2

gen s1_21=0					//Question: Shows concern for someone who is crying
replace s1_21=2 if Q1_21==1
replace s1_21=1 if Q1_21==2

gen s1_22=0					//Question: Hurts Others (hits, bites, kicks, punches, etc.)
replace s1_22=2 if Q1_22==3    //scored in inverse direction
replace s1_22=1 if Q1_22==2

gen s1_23=0					//Question: Gives up easily
replace s1_23=2 if Q1_23==3    //scored in inverse direction
replace s1_23=1 if Q1_23==2

gen s1_24=0					//Question: Makes transitions easily (Moves easily from one activity to the next, etc
replace s1_24=2 if Q1_24==1
replace s1_24=1 if Q1_24==2

gen s1_25=0					//Question: Falls and hurts self
replace s1_25=2 if Q1_25==3    //scored in inverse direction
replace s1_25=1 if Q1_25==2

gen s1_26=0					//Question: Is restless and can't sit still
replace s1_26=2 if Q1_26==3    //scored in inverse direction
replace s1_26=1 if Q1_26==2

gen s1_27=0					//Question: Wanders away from you in public places
replace s1_27=2 if Q1_27==3    //scored in inverse direction
replace s1_27=1 if Q1_27==2

gen s1_28=0					//Question: Acts very sad or withdrawn
replace s1_28=2 if Q1_28==3    //scored in inverse direction
replace s1_28=1 if Q1_28==2

gen D4_scored_positively= s1_1+s1_4+s1_6+s1_8+s1_9+s1_11+s1_13+s1_14+s1_15+s1_16+s1_21+s1_24
gen D4_scored_inverse= s1_2+s1_3+s1_5+s1_7+s1_10+s1_12+s1_17+s1_18+s1_19+s1_20+s1_22+s1_23+s1_25+s1_26+s1_27+s1_28
gen D4_score= s1_1+s1_2+s1_3+s1_4+s1_5+s1_6+s1_7+s1_8+s1_9+s1_10+s1_11+s1_12+s1_13+s1_14+s1_15+s1_16+s1_17+s1_18+s1_19+s1_20+s1_21+s1_22+s1_23+s1_24+s1_25+s1_26+s1_27+s1_28

gen s2_1=0
replace s2_1=1 if Q2_1==1

gen s2_2=0
replace s2_2=1 if Q2_2==1

gen s2_3=0
replace s2_3=1 if Q2_3==1

gen s2_4=0
replace s2_4=1 if Q2_4==1

gen s2_5=0
replace s2_5=1 if Q2_5==1

gen s2_6=0
replace s2_6=1 if Q2_6==1

gen s2_7=0
replace s2_7=1 if Q2_7==1

gen s2_8=0
replace s2_8=1 if Q2_8==1

gen s2_9=0
replace s2_9=1 if Q2_9==1

gen s2_10=0
replace s2_10=1 if Q2_10==1

gen s2_11=0
replace s2_11=1 if Q2_11==1

gen s2_12=0
replace s2_12=1 if Q2_12==0

gen s2_13=0
replace s2_13=1 if Q2_13==0

gen s2_14=0
replace s2_14=1 if Q2_14==0

gen s2_15=0
replace s2_15=1 if Q2_15==1

gen s2_16=0
replace s2_16=1 if Q2_16==1

gen s2_17=0
replace s2_17=1 if Q2_17==1

gen s2_18=0
replace s2_18=1 if Q2_18==1

gen s2_19=0
replace s2_19=1 if Q2_19==1

gen s2_20=0
replace s2_20=1 if Q2_20==1

gen s2_21=0
replace s2_21=1 if Q2_21==0

gen home_visit_score=s2_1+s2_2+s2_3+s2_4+s2_5+s2_6+s2_7+s2_8+s2_9+s2_10+s2_11+s2_12+s2_1+s2_14+s2_15+s2_16+s2_1+s2_18+s2_19+s2_20+s2_21

keep CHILD_ID treat1 VILLAGE_ID FAMILY_ID RECORD_ID Gender D4_score home_visit_score
rename D4_score mid_D4 
rename home_visit_score mid_hv
label variable mid_D4 "Midline DIAL-4 score"
label variable mid_hv "Endline Home visit score"
duplicates drop CHILD_ID, force
save "$output/Midline Dial-4 & homevisit.dta", replace



use "$input/Endline Data/DIAL-4 & home visit/DIAL-4.dta", replace
drop if Q1==.

gen s1_1=0					//Question: Child Laughs or smiles when something is funny
replace s1_1=2 if Q1_1==1
replace s1_1=1 if Q1_1==2

gen s1_2=0					//Question: Argues when denied own way
replace s1_2=2 if Q1_2==3    //scored in inverse direction
replace s1_2=1 if Q1_2==2

gen s1_3=0					//Question: Breaks toy or other objects on purpose
replace s1_3=2 if Q1_3==3    //scored in inverse direction
replace s1_3=1 if Q1_3==2

gen s1_4=0					//Question: Plays well with other children
replace s1_4=2 if Q1_4==1
replace s1_4=1 if Q1_4==2

gen s1_5=0					//Question: Has tantrums(stamps feet,screams etc)
replace s1_5=2 if Q1_5==3    //scored in inverse direction
replace s1_5=1 if Q1_5==2

gen s1_6=0					//Question: Solves problem by talking rather than by hitting, pushing, or biting
replace s1_6=2 if Q1_6==1
replace s1_6=1 if Q1_6==2

gen s1_7=0					//Question: Acts without thinking (Runs into street without looking both ways, etc)
replace s1_7=2 if Q1_7==3    //scored in inverse direction
replace s1_7=1 if Q1_7==2

gen s1_8=0					//Question: Admits when he or she makes mistakes
replace s1_8=2 if Q1_8==1
replace s1_8=1 if Q1_8==2

gen s1_9=0					//Question: Stays calm when things do not go as planned
replace s1_9=2 if Q1_9==1
replace s1_9=1 if Q1_9==2

gen s1_10=0					//Question: Blames others when bad things happen
replace s1_10=2 if Q1_10==3    //scored in inverse direction
replace s1_10=1 if Q1_10==2

gen s1_11=0					//Question: Knows when people are happy or sad
replace s1_11=2 if Q1_11==1
replace s1_11=1 if Q1_11==2

gen s1_12=0					//Question: Interrupts (Talks when others are speaking)
replace s1_12=2 if Q1_12==3    //scored in inverse direction
replace s1_12=1 if Q1_12==2

gen s1_13=0					//Question: Goes to bed easily
replace s1_13=2 if Q1_13==1
replace s1_13=1 if Q1_13==2

gen s1_14=0					//Question: Asks before using other peoples things
replace s1_14=2 if Q1_14==1
replace s1_14=1 if Q1_14==2

gen s1_15=0					//Question: Works well with others
replace s1_15=2 if Q1_15==1
replace s1_15=1 if Q1_15==2

gen s1_16=0					//Question: Shows pride in doing something well
replace s1_16=2 if Q1_16==1
replace s1_16=1 if Q1_16==2

gen s1_17=0					//Question: Bangs head on the floor, wall, or bed
replace s1_17=2 if Q1_17==3    //scored in inverse direction
replace s1_17=1 if Q1_17==2

gen s1_18=0					//Question: Clings or Hangs on you
replace s1_18=2 if Q1_18==3    //scored in inverse direction
replace s1_18=1 if Q1_18==2

gen s1_19=0					//Question: Whines or pouts
replace s1_19=2 if Q1_19==3    //scored in inverse direction
replace s1_19=1 if Q1_19==2

gen s1_20=0					//Question: Seems afraid of many things
replace s1_20=2 if Q1_20==3    //scored in inverse direction
replace s1_20=1 if Q1_20==2

gen s1_21=0					//Question: Shows concern for someone who is crying
replace s1_21=2 if Q1_21==1
replace s1_21=1 if Q1_21==2

gen s1_22=0					//Question: Hurts Others (hits, bites, kicks, punches, etc.)
replace s1_22=2 if Q1_22==3    //scored in inverse direction
replace s1_22=1 if Q1_22==2

gen s1_23=0					//Question: Gives up easily
replace s1_23=2 if Q1_23==3    //scored in inverse direction
replace s1_23=1 if Q1_23==2

gen s1_24=0					//Question: Makes transitions easily (Moves easily from one activity to the next, etc
replace s1_24=2 if Q1_24==1
replace s1_24=1 if Q1_24==2

gen s1_25=0					//Question: Falls and hurts self
replace s1_25=2 if Q1_25==3    //scored in inverse direction
replace s1_25=1 if Q1_25==2

gen s1_26=0					//Question: Is restless and can't sit still
replace s1_26=2 if Q1_26==3    //scored in inverse direction
replace s1_26=1 if Q1_26==2

gen s1_27=0					//Question: Wanders away from you in public places
replace s1_27=2 if Q1_27==3    //scored in inverse direction
replace s1_27=1 if Q1_27==2

gen s1_28=0					//Question: Acts very sad or withdrawn
replace s1_28=2 if Q1_28==3    //scored in inverse direction
replace s1_28=1 if Q1_28==2

gen D4_scored_positively= s1_1+s1_4+s1_6+s1_8+s1_9+s1_11+s1_13+s1_14+s1_15+s1_16+s1_21+s1_24
gen D4_scored_inverse= s1_2+s1_3+s1_5+s1_7+s1_10+s1_12+s1_17+s1_18+s1_19+s1_20+s1_22+s1_23+s1_25+s1_26+s1_27+s1_28
gen D4_score= s1_1+s1_2+s1_3+s1_4+s1_5+s1_6+s1_7+s1_8+s1_9+s1_10+s1_11+s1_12+s1_13+s1_14+s1_15+s1_16+s1_17+s1_18+s1_19+s1_20+s1_21+s1_22+s1_23+s1_24+s1_25+s1_26+s1_27+s1_28

gen s2_1=0
replace s2_1=1 if Q2_1==1

gen s2_2=0
replace s2_2=1 if Q2_2==1

gen s2_3=0
replace s2_3=1 if Q2_3==1

gen s2_4=0
replace s2_4=1 if Q2_4==1

gen s2_5=0
replace s2_5=1 if Q2_5==1

gen s2_6=0
replace s2_6=1 if Q2_6==1

gen s2_7=0
replace s2_7=1 if Q2_7==1

gen s2_8=0
replace s2_8=1 if Q2_8==1

gen s2_9=0
replace s2_9=1 if Q2_9==1

gen s2_10=0
replace s2_10=1 if Q2_10==1

gen s2_11=0
replace s2_11=1 if Q2_11==1

gen s2_12=0
replace s2_12=1 if Q2_12==0

gen s2_13=0
replace s2_13=1 if Q2_13==0

gen s2_14=0
replace s2_14=1 if Q2_14==0

gen s2_15=0
replace s2_15=1 if Q2_15==1

gen s2_16=0
replace s2_16=1 if Q2_16==1

gen s2_17=0
replace s2_17=1 if Q2_17==1

gen s2_18=0
replace s2_18=1 if Q2_18==1

gen s2_19=0
replace s2_19=1 if Q2_19==1

gen s2_20=0
replace s2_20=1 if Q2_20==1

gen s2_21=0
replace s2_21=1 if Q2_21==0

gen home_visit_score=s2_1+s2_2+s2_3+s2_4+s2_5+s2_6+s2_7+s2_8+s2_9+s2_10+s2_11+s2_12+s2_1+s2_14+s2_15+s2_16+s2_1+s2_18+s2_19+s2_20+s2_21

keep CHILD_ID treat1 VILLAGE_ID FAMILY_ID RECORD_ID Gender D4_score home_visit_score
rename D4_score end_D4 
rename home_visit_score end_hv
label variable end_D4 "Midline DIAL-4 score"
label variable end_hv "Endline Home visit score"
duplicates drop CHILD_ID, force
save "$output/Endline Dial-4 & homevisit.dta", replace



use "$input/Socio-Economic survey/Socio-economic Survey Part-2 Data (2017)/Socio-economic Part 2 data all.dta", replace
append using "$input/Socio-Economic survey/Socio economic part 1 (2019).dta", nolabel nonotes force
drop treat treat1 treatmentStatus Treatments_different treat_homeonly_different
drop ENUMERATOR_CODE DATE ST RNAME RCHILD F2O Q2_F_4 F6O M2O Q2_M_4 M6O Q2_M_12 Q3_1_1_O Q3_11 Q3_115_10_2 Q3_115_10_3 FM_ID_2 FM_ID_3 FM_ID_4 FM_ID_5 FM_NAME_2 FM_NAME_3 FM_NAME_4 FM_NAME_5 RH_2 RH_3 RH_4 RH_5 MMONTH_2 MMONTH_3 MMONTH_4 MMONTH_5 MYEAR_2 MYEAR_3 MYEAR_4 MYEAR_5 TO_WH_2 TO_WH_3 TO_WH_4 TO_WH_5 ZILLA_CODE_2 ZILLA_CODE_3 ZILLA_CODE_4 ZILLA_CODE_5 COUNTRY_2 COUNTRY_3 COUNTRY_4 COUNTRY_5 Q3_COUN_O_1 Q3_COUN_O_2 Q3_COUN_O_3 Q3_COUN_O_4 Q3_COUN_O_5 OCCUPATION_2 OCCUPATION_3 OCCUPATION_4 OCCUPATION_5 NABROAD_2 NABROAD_3 NABROAD_4 NABROAD_5 HABROAD_2 HABROAD_3 HABROAD_4 HABROAD_5 NMONEY_2 NMONEY_3 NMONEY_4 NMONEY_5 MONEY_LY_2 MONEY_LY_3 MONEY_LY_4 MONEY_LY_5 Q4_1_1 Q4_1_2 Q4_4_2 Q4_5_2 Q4_4_3 Q4_5_3 Q4_4_4 Q4_5_4 Q4_4_5 Q4_5_5 Q4_4_6 Q4_5_6 Q5_5 Q5_5O Q5_6 Q5_7 Q5_8
duplicates drop CHILD_ID, force
merge m:m VILLAGE_ID using "$input/Socio-Economic survey/Socio-economic Survey Part-2 Data (2017)/Treatment and control.dta", keepusing(treat treat1 treatmentStatus Treatments_different treat_homeonly_different)
drop if _merge!=3
drop _merge

gen F5n=F5
replace F5n=0 if F5==1 | F5==10
replace F5n=2 if F5==2 
replace F5n=5 if F5==3 
replace F5n=8 if F5==4
replace F5n=10 if F5==5 
replace F5n=11 if F5==6
replace F5n=12 if F5==7 
replace F5n=14 if F5==8 
replace F5n=18 if F5==9

rename F5n father_education

gen M5n=M5
replace M5n=0 if M5==1 | M5==10
replace M5n=2 if M5==2 
replace M5n=5 if M5==3 
replace M5n=8 if M5==4
replace M5n=10 if M5==5 
replace M5n=11 if M5==6
replace M5n=12 if M5==7 
replace M5n=14 if M5==8 
replace M5n=18 if M5==9
rename M5n mother_education

rename F6 father_occupation
rename M6 mother_occupation

label variable father_education "Father's education year"
label variable mother_education "Mother's education year"

rename F7 father_income
rename M7 mother_income
egen parent_income=rowtotal(father_income mother_income)

label variable father_income "Father's monthly income (BDT)"
label variable mother_income "Mother's monthly income (BDT)"
label variable parent_income "Parent's monthly income (BDT)"

rename F3 father_age
rename M3 mother_age


egen household_income=rowtotal(father_income mother_income Q2_12_0* Q2_13_0*)
label variable household_income "Household's total monthly income (BDT)"
rename GENDER Gender
keep CHILD_ID Gender VILLAGE_ID FAMILY_ID RECORD_ID treat1 father_age father_occupation father_income mother_age father_education mother_education parent_income household_income

save "$output/socio_economic.dta", replace
