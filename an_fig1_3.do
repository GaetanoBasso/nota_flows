/*******************************************************************************
 FIGURE 1 e 3 – Tassi di transizione e tasso di disoccupazione controfattuale
 Replicazione di Elsby et al. (2015), JEL 53(3):571-630
   Figure 1 (panel A, B)  → flussi U-E / E-U e controfattuali a 2 stati
   Figure 3 (panel A, B)  → tutti i flussi (modello a 3 stati) e controfattuali

 Periodo principale: 2004-2025 (solo Q1)
 Robustezza:         2013-2025 (tutti i trimestri, dove disponibili)

 Dataset: data_jvr_u_transitions_2004_2025.dta
 Output:  Figure 1, 3.xlsx
*******************************************************************************/

clear
use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear
tsset anno

local figfile "${dta}/../Figure 1, 3.xlsx"

/*==============================================================================
 FIGURA 1A
 Tassi di transizione U→E (job finding) e E→U (separazione)
 Spec. principale: solo Q1, 2004-2025
 Robustezza:       tutti i trimestri, 2013-2025
==============================================================================*/

* Spec. principale – Q1 only
twoway ///
    (tsline u_e_q1only, yaxis(1) lcolor(navy) lwidth(medthick)) ///
    (tsline e_u_q1only, yaxis(2) lcolor(cranberry) lwidth(medthick)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tasso di job finding U→E", axis(1)) ///
    ytitle("Tasso di separazione E→U", axis(2)) ///
    legend(order(1 "Job finding U→E (sx.)" 2 "Separazione E→U (dx.)") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig1a_q1, replace)
*graph export ${graphs}/fig1_pannello_a_q1.png, replace

* Robustezza – tutti i trimestri (2013-2025)
twoway ///
    (tsline u_e, yaxis(1) lcolor(navy) lwidth(medthick)) ///
    (tsline e_u, yaxis(2) lcolor(cranberry) lwidth(medthick)) if anno >= 2014, ///
    xlabel(2013(2)2025) xtitle("") ///
    ytitle("Tasso di job finding U→E", axis(1)) ///
    ytitle("Tasso di separazione E→U", axis(2)) ///
    legend(order(1 "Job finding U→E (sx.)" 2 "Separazione E→U (dx.)") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig1a_4q, replace)
*graph export ${graphs}/fig1_pannello_a_4trim.png, replace

preserve
    keep anno u_e_q1only e_u_q1only u_e e_u
    sort anno
    label var anno          "Anno"
    label var u_e_q1only    "Job finding U→E (Q1)"
    label var e_u_q1only    "Separazione E→U (Q1)"
    label var u_e           "Job finding U→E (4 trim., dal 2014)"
    label var e_u           "Separazione E→U (4 trim., dal 2014)"
    export excel using "`figfile'", sheet("Fig1_pannello_a") sheetreplace firstrow(varlabels)
restore

/*==============================================================================
 FIGURA 1B
 Tasso di disoccupazione osservato vs. steady-state e controfattuali
 (modello a 2 stati: U, E)

 Metodologia – Elsby et al. (2015):
   Steady-state:  u* = s / (s + f),   s = E→U,  f = U→E
   CF "solo f varia":   u*_f = s̄ / (s̄ + f_t)   [separazione fissa al pre-crisi]
   CF "solo s varia":   u*_s = s_t / (s_t + f̄)  [job finding fisso al pre-crisi]

 Due periodi di riferimento:
   (i)  2004-2007: pre-crisi finanziaria globale
   (ii) 2004-2019: pre-COVID
==============================================================================*/

* Steady-state a 2 flussi
gen ur_ss2 = 100 * e_u_q1only / (e_u_q1only + u_e_q1only)

* --- Periodo di riferimento: 2004-2007 ---
quietly summ e_u_q1only if anno <= 2007
local s_bar07 = r(mean)
quietly summ u_e_q1only if anno <= 2007
local f_bar07 = r(mean)

gen ur_cf1b_find_07 = 100 * `s_bar07' / (`s_bar07' + u_e_q1only)
gen ur_cf1b_sep_07  = 100 * e_u_q1only / (e_u_q1only + `f_bar07')

* --- Periodo di riferimento: 2004-2019 (pre-COVID) ---
quietly summ e_u_q1only if anno <= 2019
local s_bar19 = r(mean)
quietly summ u_e_q1only if anno <= 2019
local f_bar19 = r(mean)

gen ur_cf1b_find_19 = 100 * `s_bar19' / (`s_bar19' + u_e_q1only)
gen ur_cf1b_sep_19  = 100 * e_u_q1only / (e_u_q1only + `f_bar19')

* Grafico principale (riferimento 2004-2007)
twoway ///
    (line ur             anno, lcolor(black)     lwidth(medthick)) ///
    (line ur_ss2         anno, lcolor(black)     lwidth(medium) lp(dash)) ///
    (line ur_cf1b_find_07 anno, lcolor(navy)     lwidth(medium) lp(longdash)) ///
    (line ur_cf1b_sep_07  anno, lcolor(cranberry) lwidth(medium) lp(longdash)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
    legend(order(1 "Osservato" 2 "Steady-state (2 flussi)" ///
                 3 "CF: solo U→E varia" 4 "CF: solo E→U varia") row(2)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig1b, replace)
*graph export ${graphs}/fig1_pannello_b.png, replace

preserve
    keep anno ur ur_ss2 ur_cf1b_find_07 ur_cf1b_sep_07 ur_cf1b_find_19 ur_cf1b_sep_19
    sort anno
    label var anno                "Anno"
    label var ur                  "Tasso di disoccupazione osservato"
    label var ur_ss2              "Steady-state (2 flussi)"
    label var ur_cf1b_find_07     "CF: solo U→E varia (rif. 2004-07)"
    label var ur_cf1b_sep_07      "CF: solo E→U varia (rif. 2004-07)"
    label var ur_cf1b_find_19     "CF: solo U→E varia (rif. 2004-19)"
    label var ur_cf1b_sep_19      "CF: solo E→U varia (rif. 2004-19)"
    export excel using "`figfile'", sheet("Fig1_pannello_b") sheetreplace firstrow(varlabels)
restore

drop ur_ss2 ur_cf1b_*

/*==============================================================================
 FIGURA 3A
 Tutti i sei tassi di transizione fra i tre stati (E, U, I)
 Spec. principale: solo Q1, 2004-2025
 Robustezza:       tutti i trimestri, 2013-2025
==============================================================================*/

* Flussi da/verso disoccupazione (Q1 only)
twoway ///
    (tsline u_e_q1only,  lcolor(navy)         lp(solid)    lwidth(medthick)) ///
    (tsline e_u_q1only,  lcolor(cranberry)    lp(solid)    lwidth(medthick)) ///
    (tsline u_i_q1only,  lcolor(forest_green) lp(dash)     lwidth(medium)) ///
    (tsline i_u_q1only,  lcolor(orange)       lp(dash)     lwidth(medium)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tassi di transizione") ylab(, angle(0)) ///
    legend(order(1 "U→E" 2 "E→U" 3 "U→I" 4 "I→U") row(2)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig3a_ud, replace)
*graph export ${graphs}/fig3_pannello_a_flussi_u.png, replace

* Flussi da/verso inattività: I→E e E→I (Q1 only)
twoway ///
    (tsline i_e_q1only, yaxis(1) lcolor(navy)      lwidth(medthick)) ///
    (tsline e_i_q1only, yaxis(2) lcolor(cranberry) lwidth(medthick)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("I→E (sx.)", axis(1)) ytitle("E→I (dx.)", axis(2)) ///
    legend(order(1 "I→E (sx.)" 2 "E→I (dx.)") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig3a_id, replace)
*graph export ${graphs}/fig3_pannello_a_flussi_i.png, replace

* Robustezza – tutti i trimestri (2013-2025)
twoway ///
    (tsline u_e,  lcolor(navy)         lp(solid) lwidth(medthick)) ///
    (tsline e_u,  lcolor(cranberry)    lp(solid) lwidth(medthick)) ///
    (tsline u_i,  lcolor(forest_green) lp(dash)  lwidth(medium)) ///
    (tsline i_u,  lcolor(orange)       lp(dash)  lwidth(medium)) if anno >= 2014, ///
    xlabel(2013(2)2025) xtitle("") ///
    ytitle("Tassi di transizione") ylab(, angle(0)) ///
    legend(order(1 "U→E" 2 "E→U" 3 "U→I" 4 "I→U") row(2)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig3a_ud_4q, replace)
*graph export ${graphs}/fig3_pannello_a_4trim.png, replace

preserve
    keep anno u_e_q1only e_u_q1only u_i_q1only i_u_q1only i_e_q1only e_i_q1only ///
              u_e e_u u_i i_u i_e e_i
    sort anno
    label var anno            "Anno"
    label var u_e_q1only      "U→E (Q1)"
    label var e_u_q1only      "E→U (Q1)"
    label var u_i_q1only      "U→I (Q1)"
    label var i_u_q1only      "I→U (Q1)"
    label var i_e_q1only      "I→E (Q1)"
    label var e_i_q1only      "E→I (Q1)"
    label var u_e             "U→E (4 trim., dal 2014)"
    label var e_u             "E→U (4 trim., dal 2014)"
    label var u_i             "U→I (4 trim., dal 2014)"
    label var i_u             "I→U (4 trim., dal 2014)"
    label var i_e             "I→E (4 trim., dal 2014)"
    label var e_i             "E→I (4 trim., dal 2014)"
    export excel using "`figfile'", sheet("Fig3_pannello_a") sheetreplace firstrow(varlabels)
restore

/*==============================================================================
 FIGURA 3B
 Tasso di disoccupazione controfattuale – modello a 3 stati (E, U, I)

 Shimer (2012, RED, eq. unnumbered + eq. 7):
   π_U ∝ λ_EU·(λ_IU+λ_IE) + λ_EI·λ_IU  =  e_u*(i_u+i_e) + e_i*i_u
   π_E ∝ λ_UE·(λ_IU+λ_IE) + λ_UI·λ_IE  =  u_e*(i_u+i_e) + u_i*i_e
   u*  = π_U/(π_U+π_E)  [U/(E+U), quota sulla forza lavoro]

 Sei controfattuali (riferimento pre-crisi 2004-2007):
   per ciascuno si fissa UN flusso al livello pre-crisi,
   lasciando variare liberamente gli altri cinque.
   CF_ue: U→E fisso   CF_eu: E→U fisso   CF_ei: E→I fisso
   CF_ui: U→I fisso   CF_iu: I→U fisso   CF_ie: I→E fisso

 Robustezza: steady-state con tutti i trimestri (2013-2025)
==============================================================================*/

* -- Steady-state a 3 flussi (Shimer 2012) --
gen _NUM3q = e_u_q1only*(i_u_q1only+i_e_q1only) + e_i_q1only*i_u_q1only
gen _DEN3q = u_e_q1only*(i_u_q1only+i_e_q1only) + u_i_q1only*i_e_q1only
gen ur_ss3  = 100 * _NUM3q / (_NUM3q + _DEN3q)
drop _NUM3q _DEN3q

* -- Medie pre-crisi (2004-2007) per i 6 tassi --
foreach r in e_u u_e e_i u_i i_u i_e {
    quietly summ `r'_q1only if anno <= 2007
    local `r'_bar = r(mean)
}

* CF_ue: U→E fisso al pre-crisi (non appare nel numeratore)
gen _N1 = e_u_q1only*(i_u_q1only+i_e_q1only) + e_i_q1only*i_u_q1only
gen _D1 = `u_e_bar'*(i_u_q1only+i_e_q1only) + u_i_q1only*i_e_q1only
gen ur_cf3_ue = 100 * _N1 / (_N1 + _D1)
drop _N1 _D1

* CF_eu: E→U fisso al pre-crisi (non appare nel denominatore)
gen _N2 = `e_u_bar'*(i_u_q1only+i_e_q1only) + e_i_q1only*i_u_q1only
gen _D2 = u_e_q1only*(i_u_q1only+i_e_q1only) + u_i_q1only*i_e_q1only
gen ur_cf3_eu = 100 * _N2 / (_N2 + _D2)
drop _N2 _D2

* CF_ei: E→I fisso al pre-crisi (appare solo nel numeratore come e_i*i_u)
gen _N3 = e_u_q1only*(i_u_q1only+i_e_q1only) + `e_i_bar'*i_u_q1only
gen _D3 = u_e_q1only*(i_u_q1only+i_e_q1only) + u_i_q1only*i_e_q1only
gen ur_cf3_ei = 100 * _N3 / (_N3 + _D3)
drop _N3 _D3

* CF_ui: U→I fisso al pre-crisi (appare solo nel denominatore come u_i*i_e)
gen _N4 = e_u_q1only*(i_u_q1only+i_e_q1only) + e_i_q1only*i_u_q1only
gen _D4 = u_e_q1only*(i_u_q1only+i_e_q1only) + `u_i_bar'*i_e_q1only
gen ur_cf3_ui = 100 * _N4 / (_N4 + _D4)
drop _N4 _D4

* CF_iu: I→U fisso al pre-crisi (appare in entrambi: e_u*(i_u+i_e)+e_i*i_u e u_e*(i_u+i_e))
gen _N5 = e_u_q1only*(`i_u_bar'+i_e_q1only) + e_i_q1only*`i_u_bar'
gen _D5 = u_e_q1only*(`i_u_bar'+i_e_q1only) + u_i_q1only*i_e_q1only
gen ur_cf3_iu = 100 * _N5 / (_N5 + _D5)
drop _N5 _D5

* CF_ie: I→E fisso al pre-crisi (appare in entrambi: e_u*(i_u+i_e) e u_e*(i_u+i_e)+u_i*i_e)
gen _N6 = e_u_q1only*(i_u_q1only+`i_e_bar') + e_i_q1only*i_u_q1only
gen _D6 = u_e_q1only*(i_u_q1only+`i_e_bar') + u_i_q1only*`i_e_bar'
gen ur_cf3_ie = 100 * _N6 / (_N6 + _D6)
drop _N6 _D6

* Grafico
twoway ///
    (line ur          anno, lcolor(black)        lwidth(medthick)) ///
    (line ur_ss3      anno, lcolor(black)        lwidth(medium) lp(dash)) ///
    (line ur_cf3_ue   anno, lcolor(navy)         lwidth(medium) lp(longdash)) ///
    (line ur_cf3_eu   anno, lcolor(cranberry)    lwidth(medium) lp(longdash)) ///
    (line ur_cf3_ei   anno, lcolor(forest_green) lwidth(medium) lp(shortdash)) ///
    (line ur_cf3_ui   anno, lcolor(orange)       lwidth(medium) lp(shortdash)) ///
    (line ur_cf3_iu   anno, lcolor(purple)       lwidth(medium) lp(dot)) ///
    (line ur_cf3_ie   anno, lcolor(sienna)       lwidth(medium) lp(dot)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
    legend(order(1 "Osservato" 2 "Steady-state (3 flussi)" ///
                 3 "CF: U→E fisso" 4 "CF: E→U fisso" ///
                 5 "CF: E→I fisso" 6 "CF: U→I fisso" ///
                 7 "CF: I→U fisso" 8 "CF: I→E fisso") row(4)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig3b, replace)
*graph export ${graphs}/fig3_pannello_b.png, replace

* -- Robustezza: steady-state con tutti i trimestri (2013-2025) --
gen _NUM3_4q = e_u*(i_u+i_e) + e_i*i_u   if anno >= 2014
gen _DEN3_4q = u_e*(i_u+i_e) + u_i*i_e   if anno >= 2014
gen ur_ss3_4q = 100 * _NUM3_4q / (_NUM3_4q + _DEN3_4q)
drop _NUM3_4q _DEN3_4q

preserve
    keep anno ur ur_ss3 ur_cf3_ue ur_cf3_eu ur_cf3_ei ur_cf3_ui ur_cf3_iu ur_cf3_ie ///
              ur_ss3_4q
    sort anno
    label var anno          "Anno"
    label var ur            "Tasso di disoccupazione osservato"
    label var ur_ss3        "Steady-state (3 flussi, Shimer 2012, Q1)"
    label var ur_cf3_ue     "CF: U→E fisso al 2004-07"
    label var ur_cf3_eu     "CF: E→U fisso al 2004-07"
    label var ur_cf3_ei     "CF: E→I fisso al 2004-07"
    label var ur_cf3_ui     "CF: U→I fisso al 2004-07"
    label var ur_cf3_iu     "CF: I→U fisso al 2004-07"
    label var ur_cf3_ie     "CF: I→E fisso al 2004-07"
    label var ur_ss3_4q     "Steady-state (3 flussi, 4 trim.)"
    export excel using "`figfile'", sheet("Fig3_pannello_b") sheetreplace firstrow(varlabels)
restore

drop ur_ss3 ur_cf3_* ur_ss3_4q
