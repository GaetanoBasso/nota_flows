*** Carichiamo i dataset RFL separatamente per 2009-18 2019-20 e 2021-25
clear
forvalues y=2009/2018 { 
	forvalues j=1/4 {
		append using ${source3}/`j'_`y'.dta
	}
}
keep cond3 sg11 sg13 cat12 trim anno coef etam dipaut edulev c24 /*c59ab*/ c73 f6_* f16-f25 coistr educst courat piepar cittad h1 c48 c16_c profm tn2* ate2d mfrfam relparm esplav durad
drop f24a*
replace educst= 1 if h1==1&anno<2014
run ${do}/rename_rfl.do
tempfile pre2019
save `pre2019'

clear
forvalues y=2019/2020 { 
	forvalues j=1/4 {
		append using ${source3}/`j'_`y'.dta
	}
}
keep cond3new sg11 sg13 cat12 trim anno coef etam dipaut edulev c24 /*c59ab*/ c73 f6_* f16-f25 coistr educst courat piepar cittad c48 c16_c profm tn2m ate2d mfrfam relparm esplav durad
drop f24a*
run ${do}/rename_rfl.do
tempfile pre2021
save `pre2021'

clear
forvalues y=2021/2025 { 
	forvalues j=1/4 {
		append using ${source3}/`y'_`j'.dta
	}
} 

keep cond3 qsf11 qsf17 qsf20 cat12 trim anno coef_ccp etam dipaut qsf24 edulev qc21 qc62 qf15-qf25 coistr educfed4 educnfe4 piepar cittad qc52 ate2d profm tn2m mfrfam relparm esplav durad
append using `pre2021'
append using `pre2019'
replace coef = coef_ccp if coef_ccp!=.&coef==.
rename qsf20 statonascita
rename qsf17 cittadinanza_dettaglio
rename qsf24 annoarrivo
rename qc21 somministrazione
*rename c59ab canaleinserimento
rename qc62 soddisfazionelavoro
rename qc52 wfh
recode wfh (1/2 4=1) (3=0) (997=.)
tempfile post2021
save `post2021'


* Definizione variabili
gen pop=1
gen occ=(cond3==1)
gen unempl=(cond3==2)
gen inatt=(cond3==3)
gen straniero=(cittadinanza_dettaglio==2)
gen fborn=(statonascita==2)
drop dipaut
gen female = qsf11==2
recode esplav (2=0)
recode durad (999=.)

gen lessthanHS=edulev<=3
gen HS=edulev==4|edulev==5
gen collegemore=edulev==6

replace coef=coef/40 if anno<=2025

* Selezione campione 
drop if etam<15

keep if unempl==1
collapse (mean) female eta fborn lessthanHS HS collegemore durad esplav ///
	(p10) eta_p10=eta durad_p10=durad ///
	(p50) eta_p50=eta durad_p50=durad ///
	(p90) eta_p90=eta durad_p90=durad [pw=coef], by(anno)
save ${dta}/unempl_composition_rfl.dta, replace
	
