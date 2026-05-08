clear 

use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear

/****************************
 Efficiency IT FL potenziali
*****************************/
tw scatter log_ui_e_q1only log_v1_ui, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log nonE-to-E transitions (q1 only)") xtit("log V/U2") 
*graph export $graphs/scatter_v_ui_ui_e_q1only_2016_2025.png, as(png) replace
tw scatter log_ui_e_q1only log_v10_ui, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log nonE-to-E transitions (q1 only)") xtit("log V/U2") 
*graph export $graphs/scatter_v_ui_ui_e_q1only_2005_2025.png, as(png) replace

cap drop ehat_ui
cap drop ehat_ui_ma4

reg log_ui_e_q1only log_v10_ui if anno<=2020
reg log_ui_e_q1only log_v10_ui if anno<=2020, nocons

reg log_ui_e_q1only log_v10_ui
reg log_ui_e_q1only log_v10_ui, nocons
predict ehat_ui, resid

tsset anno
gen ehat_ui_ma4 = (f.ehat_ui+2*ehat_ui+l.ehat_ui)/4
replace ehat_ui_ma4 = ehat_ui if anno==2004|anno==2025
tw line ehat_ui_ma4 anno, xlabel(2004(2)2025) xtit("") ytit("") yline(0) ylab(,angle(0))
*graph export $graphs/resid_v_ui_ui_e_q1only_2004_2025.png, as(png) replace
tw line ehat_ui anno, xlabel(2004(2)2025) xtit("") yline(0) ylab(,angle(0)) ytit("")

/****************************
 Efficiency IT unemployed
*****************************/
tw scatter log_u_e_q1only log_v1_u, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log transizioni U-to-E ") xtit("log V/U") ///
	|| lfit log_u_e_q1only log_v1_u if anno>2015, color(red) range(-2.75 -1) ylab(,angle(0)) legend(label(1 "U-E vs. V/U") label(2 "Fitted values post-2015"))
*graph export $graphs/scatter_v_u_u_e_q1only_2016_2025.png, as(png) replace

tw scatter log_u_e_q1only log_v10_u, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log transizioni U-to-E (q1 only)") xtit("log V10+/U") ///
	|| lfit log_u_e_q1only log_v10_u if anno<2020, color(red) range(-3.5 -1) ylab(,angle(0)) legend(label(1 "U-E vs. V/U") label(2 "Fitted values pre-2020"))
*graph export $graphs/scatter_v_u_u_e_q1only_2005_2025.png, as(png) replace

cap drop ehat_u
cap drop ehat_u_ma4

reg log_u_e_q1only log_v10_u if anno<=2020
reg log_u_e_q1only log_v10_u if anno<=2020, nocons

reg log_u_e_q1only log_v10_u
reg log_u_e_q1only log_v10_u, nocons
predict ehat_u, resid

tsset anno
gen ehat_u_ma4 = (f.ehat_u+2*ehat_u+l.ehat_u)/4
replace ehat_u_ma4 = ehat_u if anno==2004|anno==2025
tw line ehat_u_ma4 anno, xlabel(2004(1)2025) xtit("") ytit("") yline(0) ylab(,angle(0))
*graph export $graphs/resid_v_u_u_e_2005_2025.png, as(png) replace
tw line ehat_u anno, xlabel(2004(1)2025) xtit("") yline(0) ylab(,angle(0))


/* All quarters */

/****************************
 Efficiency IT FL potenziali
*****************************/
tw scatter log_ui_e log_v1_ui, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log nonE-to-E transitions") xtit("log V/U2") 
*graph export $graphs/scatter_v_ui_ui_e_2016_2025.png, as(png) replace
tw scatter log_ui_e log_v10_ui, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log nonE-to-E transitions") xtit("log V/U2") 
*graph export $graphs/scatter_v_ui_ui_e_2005_2025.png, as(png) replace

cap drop ehat_ui
cap drop ehat_ui_ma4

reg log_ui_e log_v10_ui

reg log_ui_e log_v10_ui, nocons
predict ehat_ui, resid

tsset anno
gen ehat_ui_ma4 = (f.ehat_ui+2*ehat_ui+l.ehat_ui)/4
replace ehat_ui_ma4 = ehat_ui if anno==2004|anno==2016
tw line ehat_ui_ma4 anno, xlabel(2004(2)2025) xtit("") ytit("") yline(0) ylab(,angle(0))
*graph export $graphs/resid_v_ui_ui_e_2004_2017.png, as(png) replace
tw line ehat_ui anno, xlabel(2004(2)2025) xtit("") yline(0) ylab(,angle(0)) ytit("")

/****************************
 Efficiency IT unemployed
*****************************/
tw scatter log_u_e log_v1_u, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log transizioni U-to-E ") xtit("log V/U") ///
	|| lfit log_u_e log_v1_u if anno>2015, color(red) range(-2.75 -1) ylab(,angle(0)) legend(label(1 "U-E vs. V/U") label(2 "Fitted values post-2015"))
*graph export $graphs/scatter_v_u_u_e_2016_2025.png, as(png) replace

tw scatter log_u_e_q1only log_v10_u, connect(l) sort(anno) mlab(y_l) col(navy) ///
	ytit("log transizioni U-to-E (q1 only)") xtit("log V10+/U") ///
	|| lfit log_u_e_q1only log_v10_u if anno<2020, color(red) range(-3.5 -1) ylab(,angle(0)) legend(label(1 "U-E vs. V/U") label(2 "Fitted values pre-2020"))
*graph export $graphs/scatter_v_u_u_e_2005_2025.png, as(png) replace

cap drop ehat_u
cap drop ehat_u_ma4
reg log_u_e log_v1_u

reg log_u_e log_v1_u, nocons
predict ehat_u, resid

tsset anno
gen ehat_u_ma4 = (f.ehat_u+2*ehat_u+l.ehat_u)/4
replace ehat_u_ma4 = ehat_u if anno==2017|anno==2025
tw line ehat_u_ma4 anno if anno>2016, xlabel(2017(1)2025) xtit("") ytit("") yline(0) ylab(,angle(0))
*graph export $graphs/resid_v_u_u_e_2005_2017.png, as(png) replace
tw line ehat_u anno if anno>2016, xlabel(2017(1)2025) xtit("") yline(0) ylab(,angle(0))

