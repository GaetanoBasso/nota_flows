clear

/*
/****************************************
*** Upload Italian cross-sectional LFS data
****************************************/
clear 

foreach x of numlist 2009/2017 {
append using ${source}/1_`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
append using ${source}/2_`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
append using ${source}/3_`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
append using ${source}/4_`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
}

foreach x of numlist 2004/2008 {
append using ${source2}/a`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
append using ${source2}/l`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
append using ${source2}/o`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
append using ${source2}/g`x'.dta, keep(anno trim coef1 reg cletas cletad rip3 cond3 i5 cond10 c18 cat12 c55 c57 duratt)
}

gen empl         = (cond3==1)
gen unempl       = (cond3==2)
gen unempl_inact = (cond10>=2&cond10<=7)
gen empl_10      = (cond3==1&c18>=2&c18<=8&c18!=7&cat12>=2&cat12<=9)
gen hire         = (cond3==1&c18>=2&c18<=8&c18!=7&cat12>=2&cat12<=9&c55==anno) & ((trim==1&c57>=1&c57<=3) | (trim==2 & c57>=4&c57<=6) | (trim==3 & c57>=7&c57<=9) | (trim==4 & c57>=10&c57<=12))
gen peso         = coef1/4

***keep working age 15+
keep if cletas>=5

preserve
collapse (sum) empl empl_10 unempl_inact unempl hire [pw=peso], by(anno)

gen urate  = 100*unempl/(empl+unempl)
gen urate2 = 100*unempl_inact/(empl+unempl_inact)

save $dir_dta/unrate_2004q1_2017q4_national_anno.dta, replace
restore
	
preserve
collapse (sum) empl empl_10 unempl_inact unempl hire [pw=peso], by(anno rip3)

gen urate  = 100*unempl/(empl+unempl)
gen urate2 = 100*unempl_inact/(empl+unempl_inact)

save $dir_dta/unrate_2004q1_2017q4_macro_area_anno.dta, replace
restore
*/


/****************************************
*** Upload Italian longitudinal LFS data
****************************************/
* === ANNI MENO RECENTI (struttura t0/t1 non già esplicita) e c'è solo Q1 ===
local pair = 1
local start_year = 4  // anno iniziale = 2004

forvalues y = 4/12 {
    local y1 : di %02.0f `y'
    local y2 : di %02.0f `y' + 1
    forvalues j = 1/1 {

	use anno_`y1'`j' trim_`y1'`j' coef_panel ///
            anno_`y2'`j' trim_`y2'`j' ///
            reg_`y1'`j' cletad_`y1'`j' rip3_`y1'`j' ///
            cond3_`y1'`j' cond10_`y1'`j' ///
            cond3_`y2'`j' cond10_`y2'`j' ///
            b3_`y1'`j' b3_`y2'`j' ///
            using ${source}/L20`y1'_20`y2'_`j'trim.dta, clear

        renvars _all, postsub(`y1'`j' t0)
        renvars _all, postsub(`y2'`j' t1)

        saveold "${dta}/tmp_data/temp_20`y2'_`j'", replace
    }
}

* === ANNI RECENTI (struttura t0/t1 già esplicita) ===
* Carica il primo file come base
use anno_t0 trim_t0 anno_t1 trim_t1 coef_panel ///
    reg_t0 cletad_t0 rip3_t0 cond3_t0 cond10_t0 ///
    cond3_t1 cond10_t1 b3_t0 b3_t1 ///
    using ${source}/L2013_2014_1trim.dta, clear

* Append degli altri trimestri e anni recenti
foreach x in L2013_2014 L2014_2015 L2015_2016 L2016_2017 L2017_2018 L2018_2019 L2019_2020 {
    forvalues j = 1/4 {
        * Salta il primo file già caricato come base
        if "`x'" == "L2013_2014" & `j' == 1 continue

        append using ${source}/`x'_`j'trim.dta, ///
            keep(anno_t0 trim_t0 coef_panel anno_t1 trim_t1 ///
                 reg_t0 cletad_t0 rip3_t0 ///
                 cond3_t0 cond10_t0 cond3_t1 cond10_t1 ///
                 b3_t0 b3_t1)
    }
}

* Append anni 2021 in poi (struttura _Q1.dta)
foreach x in L2021_2022 L2022_2023 L2023_2024 {
    forvalues j = 1/4 {
    append using ${source}/`x'_Q`j'.dta, ///
            keep(anno_t0 trim_t0 coef_panel anno_t1 trim_t1 ///
                 regio_t0 cletad_t0 rip3_t0 ///
                 cond3_t0 cond10_t0 cond3_t1 cond10_t1 ///
                 qb06_t0 qb06_t1)
    }
}
foreach x in L2024_2025 {
    forvalues j = 1/3 {
    append using ${source}/`x'_Q`j'.dta, ///
            keep(anno_t0 trim_t0 coef_panel anno_t1 trim_t1 ///
                 regio_t0 cletad_t0 rip3_t0 ///
                 cond3_t0 cond10_t0 cond3_t1 cond10_t1 ///
                 qb06_t0 qb06_t1)
    }
}

* Append dei file temporanei dalla parte precedente (2004-2012)
forvalues y = 5/13 {
    local y2 : di %02.0f `y'
    forvalues j = 1/1 {
        append using "${dta}/tmp_data/temp_20`y2'_`j'.dta"
    }
}

* Cleaning
replace anno_t1=2022 if anno_t0==2021&anno_t1==.
replace anno_t1=2023 if anno_t0==2022&anno_t1==.
replace b3_t0 = qb06_t0 if b3_t0!=.&qb06_t0==.
replace b3_t1 = qb06_t1 if b3_t1!=.&qb06_t1==.
drop qb06_t*
foreach v of varlist b3_t0 b3_t1 {
	recode `v' (1=7) (2=9) (3=6) (4=12) (5=13) (6=14) (7=11) (8=11) (9=1) (10=15) (11=995) (12=996) if anno_t0 >= 2021
}
saveold "${dta}/rfl_long_2005_2025.dta", replace


/***********************************
 Job flow (annual panel - q1 only)
***********************************/
use "${dta}/rfl_long_2005_2025.dta", clear

keep if b3_t0!=11&b3_t1!=11

* keep Q1 only
keep if trim_t0==1

* keep working age 15+
keep if cletad_t0>=2

gen unempl_t0 =(cond3_t0==2)
gen unempl_inact_t0 =(cond10_t0>=2&cond10_t0<=7)

gen inact_t0 =(cond10_t0>=3&cond10_t0<=7)
gen inact_t1 =(cond10_t1>=3&cond10_t1<=7)

gen unempl_t1 =(cond3_t1==2)
gen unempl_inact_t1 =(cond10_t1>=2&cond10_t1<=7)

gen empl_t0 =(cond3_t0==1)
gen empl_t1 =(cond3_t1==1)

gen ui_e =(cond10_t0>=2&cond10_t0<=7)&(cond3_t1==1)
gen u_e =(cond3_t0==2)&(cond3_t1==1)

gen e_ui =(cond3_t0==1)&(cond10_t1>=2&cond10_t1<=7)
gen e_u =(cond3_t0==1)&(cond3_t1==2)

gen i_u =(cond10_t0>=3&cond10_t0<=7)&(cond3_t1==2)
gen u_i =(cond3_t0==2)&(cond10_t1>=3&cond10_t1<=7)

gen i_e =(cond10_t0>=3&cond10_t0<=7)&(cond3_t1==1)
gen e_i =(cond3_t0==1)&(cond10_t1>=3&cond10_t1<=7)

gen agegr=1534 if cletad_t0==2|cletad_t0==3
replace agegr=3554 if cletad_t0==4|cletad_t0==5
replace agegr=55 if cletad_t0>=6

preserve
	keep if trim_t1==1
	collapse (sum) *empl* inact* e_ui e_u ui_e u_e i_u u_i i_e e_i [pw=coef_panel/10], by(anno_t0)
	replace ui_e = ui_e/unempl_inact_t0
	replace u_e = u_e/unempl_t0
	replace e_ui = e_ui/empl_t0
	replace e_u = e_u/empl_t0
	replace i_u = i_u/inact_t0
	replace u_i = u_i/unempl_t0
	replace i_e = i_e/inact_t0
	replace e_i = e_i/empl_t0
	compress 
	gen anno_t1=anno_t0+1
	saveold ${dta}/jobfinding_q1_2004_2024.dta, replace
restore

preserve
	keep if trim_t1==1
	collapse (sum) *empl* inact* e_ui e_u ui_e u_e i_u u_i i_e e_i [pw=coef_panel/10], by(anno_t0 agegr)
	replace ui_e = ui_e/unempl_inact_t0
	replace u_e = u_e/unempl_t0
	replace e_ui = e_ui/empl_t0
	replace e_u = e_u/empl_t0
	replace i_u = i_u/inact_t0
	replace u_i = u_i/unempl_t0	
	replace i_e = i_e/inact_t0
	replace e_i = e_i/empl_t0
	keep ui_e u_e e_ui e_u i_u u_i e_i i_e anno_t0 agegr
	reshape wide ui_e u_e e_ui e_u i_u u_i e_i i_e, i(anno_t0) j(agegr)
	compress 
	gen anno_t1=anno_t0+1
	saveold ${dta}/jobfinding_q1_agegr_2004_2024.dta, replace
restore

/***********************************
 Job flow (annual panel - q1-q4)
***********************************/
preserve
	keep if anno_t0>=2013
	collapse (sum) *empl* inact* e_ui e_u ui_e u_e i_u u_i i_e e_i [pw=coef_panel/40], by(anno_t0)
	replace ui_e = ui_e/unempl_inact_t0
	replace u_e = u_e/unempl_t0
	replace e_ui = e_ui/empl_t0
	replace e_u = e_u/empl_t0
	replace i_u = i_u/inact_t0
	replace u_i = u_i/unempl_t0	
	replace i_e = i_e/inact_t0
	replace e_i = e_i/empl_t0
	compress 
	gen anno_t1=anno_t0+1
	saveold ${dta}/jobfinding_q1q4_2013_2024.dta, replace
restore

preserve
	keep if anno_t0>=2013
	collapse (sum) *empl* inact* e_ui e_u ui_e u_e i_u u_i i_e e_i [pw=coef_panel/40], by(anno_t0 agegr)
	replace ui_e = ui_e/unempl_inact_t0
	replace u_e = u_e/unempl_t0
	replace e_ui = e_ui/empl_t0
	replace e_u = e_u/empl_t0
	replace i_u = i_u/inact_t0
	replace u_i = u_i/unempl_t0	
	replace i_e = i_e/inact_t0
	replace e_i = e_i/empl_t0
	keep ui_e u_e e_ui e_u i_u u_i e_i i_e anno_t0 agegr
	reshape wide ui_e u_e e_ui e_u i_u u_i e_i i_e, i(anno_t0) j(agegr)
	compress 
	gen anno_t1=anno_t0+1
	saveold ${dta}/jobfinding_agegr_q1q4_2013_2024.dta, replace
restore


*** Create dataset 
use ${source2}/posti_vacanti/dta/pvt_1.dta, clear
keep TOTN anno
rename TOTN jvr1
collapse (mean) jvr1, by(anno)
tempfile jvr1
save `jvr1'

use ${source2}/posti_vacanti/dta/pvt_10.dta, clear
keep TOTN anno
rename TOTN jvr10
collapse (mean) jvr10, by(anno)
tempfile jvr10
save `jvr10'

use ${source2}/forze_lavoro_trimestrali/dta/ury.dta, clear
keep ury anno
rename ury ur
tempfile ur
save `ur'

import excel using "${dta}/Condizione professionale (IT1,152_1185_DF_DCCV_INATTIV1_UNT2020_3,1.0).xlsx", sheet("rawdata") clear first
keep anno lfp
rename anno anno
destring anno, replace
drop if anno>=2018
tempfile flpotenzialipre2020
save `flpotenzialipre2020'

use ${source2}/forze_lavoro_trimestrali/dta/DCCV_INATTIV.dta, clear
keep if sex==9&tst==99&ter=="IT"&cit=="TOTAL"&condich=="99"&eta=="Y15_74"&condprof=="LFP"
gen anno=real(substr(time,1,4))
rename value lfp
collapse (mean) lfp, by(anno)
keep lfp anno
append using `flpotenzialipre2020'
sort anno
tempfile flpotenziali
save `flpotenziali'

use ${source2}/forze_lavoro_trimestrali/dta/DCCV_DISOCCUPT.dta, clear
keep if sex==9&tst==99&ter=="IT"&cit=="TOTAL"&durd=="TOTAL"&eta=="Y15_74"&condprof=="99"
gen anno=real(substr(time,1,4))
rename value unempl
collapse (mean) unempl, by(anno)
keep unempl anno
tempfile unempl
save `unempl'

use ${source2}/forze_lavoro_trimestrali/dta/DCCV_DISOCCUPT.dta, clear
keep if sex==9&tst==99&ter=="IT"&cit=="TOTAL"&durd=="M_GE12"&eta=="Y15_74"&condprof=="99"
gen anno=real(substr(time,1,4))
rename value ltunempl
collapse (mean) ltunempl, by(anno)
keep ltunempl anno
tempfile ltunempl
save `ltunempl'

use ${source2}/forze_lavoro_trimestrali/dta/DCCV_OCCUPATIT.dta, clear
keep if sex==9&tst==99&ter=="IT"&cit=="TOTAL"&eta=="Y15_89"&pos=="9"&a02=="0010"&a07=="0010"&pr1==99&pr2==99&pro==99&ror=="9"&cro=="9"
gen anno=real(substr(time,1,4))
rename value empl
collapse (mean) empl, by(anno)
keep empl anno
tempfile empl
save `empl'


*** Merge
use `jvr1', clear
merge 1:1 anno using `jvr10', nogen
merge 1:1 anno using `flpotenziali', nogen
merge 1:1 anno using `unempl', nogen
merge 1:1 anno using `ltunempl', nogen
merge 1:1 anno using `empl', nogen
merge 1:1 anno using `ur', nogen

gen ur2=100*(unempl+lfp)/(unempl+lfp+empl)
gen ltur=100*(ltunempl)/(unempl+empl)
gen ltshare=100*(ltunempl)/(unempl)

rename anno anno_t1

merge 1:1 anno_t1 using ${dta}/jobfinding_q1_agegr_2004_2024.dta, nogen
merge 1:1 anno_t1 using ${dta}/jobfinding_q1_2004_2024.dta, nogen
foreach v in e_ui e_u ui_e u_e i_u u_i i_e e_i {
	rename `v' `v'_q1only
	rename `v'15* `v'15*_q1only
	rename `v'35* `v'35*_q1only
	rename `v'55* `v'55*_q1only
}
merge 1:1 anno_t1 using ${dta}/jobfinding_q1q4_2013_2024.dta, nogen
merge 1:1 anno_t1 using ${dta}/jobfinding_agegr_q1q4_2013_2024.dta, nogen

gen v1_u = jvr1/ur
gen v10_u = jvr10/ur
gen v1_ui = jvr1/(ur2)
gen v10_ui = jvr10/(ur2)

gen log_v1_u = log(v1_u)
gen log_v10_u = log(v10_u)
gen log_v1_ui = log(v1_ui)
gen log_v10_ui = log(v10_ui)
gen log_ui_e = log(ui_e)
gen log_u_e = log(u_e)
gen log_u_e_q1only = log(u_e_q1only)
gen log_ui_e_q1only = log(ui_e_q1only)
gen log_e_ui_q1only = log(e_ui_q1only)

rename anno_t1 anno
tostring anno, gen(y_l)

save ${dta}/data_jvr_u_transitions_2004_2025.dta, replace


