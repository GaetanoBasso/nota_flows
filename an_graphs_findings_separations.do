clear 
global fig74file "${figures}/dati_per_grafici/Fig_7.4.xlsx"

use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear

** job finding and separation rates, whole country
tsset anno
graph twoway (tsline u_e, yaxis(1) lcolor(blue) ylabel(,angle(0))) ///
	(tsline e_u, yaxis(2) lcolor(red)  ylabel(, axis(2) angle(0))) if anno>=2014, ///
	xlabel(2013(2)2024) ///
	ytitle("", axis(1)) ytitle("", axis(2)) xtitle("") ///
	legend(on order(1 "transizioni U-E (sx.)" 2 "transizioni E-U (dx.)") col(2)) ///
	graphregion(color(white)) plotregion(color(white))
*graph export $dir_graphs/tsline_u_e_e_u_2013_2024.png, as(png) replace

preserve
	keep if anno >= 2014
	keep anno u_e e_u
	sort anno
	label var anno "Anno"
	label var u_e  "Transizioni U-E (sx.)"
	label var e_u  "Transizioni E-U (dx.)"
	export excel using "$fig74file", ///
		sheet("pannello a") sheetreplace firstrow(varlabels)
restore

graph twoway (tsline u_e_q1only, yaxis(1) lcolor(blue) ylabel(,angle(0))) ///
	(tsline e_u_q1only, yaxis(2) lcolor(red)  ylabel(, axis(2) angle(0))), ///
	xlabel(2004(2)2024) ///
	ytitle("", axis(1)) ytitle("", axis(2)) xtitle("") ///
	legend(on order(1 "transizioni U-E (sx.)" 2 "transizioni E-U (dx.)") col(2)) ///
	graphregion(color(white)) plotregion(color(white))
*graph export $dir_graphs/tsline_u_e_e_u_2004_2024.png, as(png) replace

** job finding and separation rates (LFP), whole country
tsset anno
graph twoway (tsline ui_e, yaxis(1) lcolor(blue) ylabel(,angle(0))) ///
	(tsline e_ui, yaxis(2) lcolor(red)  ylabel(, axis(2) angle(0))), ///
	xlabel(2013(2)2024) ///
	ytitle("", axis(1)) ytitle("", axis(2)) xtitle("") ///
	legend(on order(1 "transizioni nonE-E (sx.)" 2 "transizioni E-nonE (dx.)") col(2)) ///
	graphregion(color(white)) plotregion(color(white))
*graph export $dir_graphs/tsline_u_e_e_u_2013_2024.png, as(png) replace

graph twoway (tsline ui_e_q1only, yaxis(1) lcolor(blue) ylabel(,angle(0))) ///
	(tsline e_ui_q1only, yaxis(2) lcolor(red)  ylabel(, axis(2) angle(0))), ///
	xlabel(2004(2)2024) ///
	ytitle("", axis(1)) ytitle("", axis(2)) xtitle("") ///
	legend(on order(1 "transizioni nonE-E (sx.)" 2 "transizioni E-nonE (dx.)") col(2)) ///
	graphregion(color(white)) plotregion(color(white))
*graph export $dir_graphs/tsline_u_e_e_u_2004_2024.png, as(png) replace

*** counterfactual unemployment (2 flows)
gen ur_ss=100*e_u_q1only/(e_u_q1only+u_e_q1only)
egen x = mean(e_u_q1only) if anno<2021
egen eu_pre2021=max(x)
drop x
egen x = mean(u_e_q1only) if anno<2021
egen ue_pre2021=max(x)
gen ur_finding_only=100*eu_pre2021/(eu_pre2021+u_e_q1only)
gen ur_separation_only=100*e_u_q1only/(e_u_q1only+ue_pre2021)
gr tw line ur anno || line ur_ss anno, lp(dash) xtitle("") ///
	|| line ur_finding_only anno, lp(longdash) lcol(black) ///
	|| line ur_separation_only anno, lp(longdash) lcol(red) 

preserve
	keep anno ur ur_ss ur_finding_only 
	sort anno
	label var anno               "Anno"
	label var ur                 "Tasso di disoccupazione osservato"
	label var ur_ss              "Tasso di disoccupazione steady state"
	label var ur_finding_only    "Controfattuale: solo job finding variabile"
	export excel using "$fig74file", ///
		sheet("pannello b") sheetreplace firstrow(varlabels)
restore

*** counterfactual unemployment (3 flows)
drop ur_ss x ue_pre2021 eu_pre2021 ur_finding_only ur_separation_only
gen ur_ss=100*(e_u_q1only+i_u_q1only)/(e_u_q1only+e_u_q1only+u_e_q1only)
egen x = mean(e_u_q1only) if anno<2021
egen eu_pre2021=max(x)
drop x
egen x = mean(u_e_q1only) if anno<2021
egen ue_pre2021=max(x)
gen ur_finding_only=100*eu_pre2021/(eu_pre2021+u_e_q1only)
gen ur_separation_only=100*e_u_q1only/(e_u_q1only+ue_pre2021)
gr tw line ur anno || line ur_ss anno, lp(dash) xtitle("") ///
	|| line ur_finding_only anno, lp(longdash) lcol(black) ///
	|| line ur_separation_only anno, lp(longdash) lcol(red) 

	
/* DA FARE perché vanno uniformati i nomi delle covariates tra anni
** 2. determinanti flussi utilizzando il dataset worker level
use ${dta}/rfl_long_2005_2025.dta, clear
foreach yy of numlist 2004/2024 {
	qui reg u_e i.fborn##i.edu##i.cletad i.female##i.esplav##i.cletad i.esplav##i.edu##i.cletad if unempl==1&anno_t0==`yy' [aw=coef_panel], 
	predict in_jf_y`yy' if e(sample), xb
	predict out_jf_y`yy' if unempl==1, xb
}

* Actual JF probabilities
preserve
	collapse (mean) in_jf_y*, by(anno rip)
	drop anno rip3
	collapse (mean) in_jf_y*
	gen id = 1 
	reshape long in_jf_y, i(id) j(anno)
	renvars _all, postsub(y ) 
	tsset anno
	replace anno = anno + 1
	tw tsline in_jf, lp(solid) ///
		legend(label(1 "Nord") label(2 "Centro") label(3 "Sud") row(1)) xtit("") ytitle("") xlabel(2005(2)2017) ylabel(,angle(0))
	*graph export $dir_graphs/tsline_compadj_jf_u_e.png, as(png) replace 
restore
*/



