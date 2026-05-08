clear 

global fig75file "${figures}/dati_per_grafici/Fig_7.5.xlsx"

use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear

*** Beveridge curve
foreach y in 1 2 {
	foreach j in 1 10 {
	if `y' == 1 global suff
	if `y' == 2 global suff 2
	if `y' == 1 local lb "Tasso di disoccupazione"
	if `y' == 2 local lb "Tasso di disoccupazione + scoraggiati"
	if `y' == 1 local tick "5(1)15"
	if `y' == 2 local tick "12(2)26"
	
	twoway (scatter jvr`j' ur${suff}, mlab(y_l)) ///
	     (line    jvr`j' ur${suff} if anno<= 2007, lcolor(blue)) ///
	     (line    jvr`j' ur${suff} if anno>= 2007 & anno <= 2013, lcolor(midgreen)) ///
	     (line    jvr`j' ur${suff} if anno>= 2013 & anno <= 2020, lcolor(red)) ///
	     (line    jvr`j' ur${suff} if anno>= 2020 & anno <= 2025, lcolor(black) ///
	     xlabel(`tick') ///
	     xtitle("`lb'") ytitle("Tasso di posti vacanti (B-N)") ///
	     legend(on order(2 "2004-2007" 3 "2008-2013" 4 "2014-2019" 4 "2020-2025") span row(1)) ///
	     graphregion(color(white)) plotregion(color(white)) name(bc`j'`y', replace))
	*graph export $dir_graphs/beveridge_curve_ur${suff}_national_anno.png, as(png) replace	     
	}
}

*** evolution of labour market tightness
foreach y in v1_u v1_ui v10_u v10_ui {
	tw line `y' anno, lcolor(black) ///
		graphregion(color(white)) plotregion(color(white)) ///
		ylab(,angle(0)) name(`y', replace) xtit("")
	*graph export $dir/tsline_`y'.png, as(png) replace	     
}

preserve
	keep if anno >= 2019
	keep anno v1_u
	sort anno
	label var anno "Anno"
	label var v1_u  "Tightness"
	export excel using "$fig75file", ///
		sheet("pannello b") sheetreplace firstrow(varlabels)
restore

*** Beveridge curve
* Counterfactual BC with E-U fixed at avg. pre 2020
egen x=mean(e_ui_q1only) if anno<2020
egen e_ui_q1only_pre2019=max(x)
drop x
foreach j in 1 10 {
	gen jvr`j'_eui_pre2020=jvr`j'*(e_ui_q1only/e_ui_q1only_pre2019)^(-2)
}
foreach y in 1 2 {
	foreach j in 1 10 {
	if `y' == 1 global suff
	if `y' == 2 global suff 2
	if `y' == 1 local lb "Tasso di disoccupazione"
	if `y' == 2 local lb "Tasso di disoccupazione + scoraggiati"
	if `y' == 1 local tick "5(1)15"
	if `y' == 2 local tick "12(2)26"
	
	twoway (scatter jvr`j'_eui_pre2020 ur${suff}, mlab(y_l)) ///
	     (line    jvr`j'_eui_pre2020 ur${suff} if anno<= 2007, lcolor(blue)) ///
	     (line    jvr`j'_eui_pre2020 ur${suff} if anno>= 2007 & anno <= 2013, lcolor(midgreen)) ///
	     (line    jvr`j'_eui_pre2020 ur${suff} if anno>= 2013 & anno <= 2020, lcolor(red)) ///
	     (line    jvr`j'_eui_pre2020 ur${suff} if anno>= 2020 & anno <= 2025, lcolor(black) ///
	     xlabel(`tick') ///
	     xtitle("`lb'") ytitle("Tasso di posti vacanti (B-N), controfattuale") ///
	     legend(on order(2 "2004-2007" 3 "2008-2013" 4 "2014-2019" 4 "2020-2025") span row(1)) ///
	     graphregion(color(white)) plotregion(color(white)) name(bc`j'`y', replace))
	*graph export $dir_graphs/beveridge_curve_ur${suff}_national_anno.png, as(png) replace	     
	}
}

