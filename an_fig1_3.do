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

 Notazione (Elsby et al. 2015):
   s = e_u  (E→U),    f = u_e  (U→E)
   δ = e_i  (E→I),    η = u_i  (U→I)
   μ = i_u  (I→U),    ν = i_e  (I→E)

 Soluzione dello steady-state (equazioni di bilancio dei flussi):
   Denominator D = f·(μ+ν) + ν·η
   π_U/π_E = [ s·(μ+ν) + μ·δ ] / D
   π_I/π_E = [ δ·(f+η)  + s·η ] / D
   u*       = π_U / (π_E + π_U + π_I)

 Quattro controfattuali (riferimento pre-crisi 2004-2007):
   CF1: solo U→E (f) varia; s, δ, η, μ, ν al pre-crisi
   CF2: solo E→U (s) varia; tutto il resto al pre-crisi
   CF3: solo flussi da/verso inattività (μ, ν, δ, η) variano
   CF4: solo E→nonE (s + δ) varia; tutto il resto al pre-crisi

 Robustezza (tutti i trimestri, 2013-2025): CF1 con 4 trimestri
==============================================================================*/

* -- Steady-state a 3 flussi (Q1 only) --
gen _D3q   = u_e_q1only*(i_u_q1only+i_e_q1only) + i_e_q1only*u_i_q1only
gen _piU3q = (e_u_q1only*(i_u_q1only+i_e_q1only) + i_u_q1only*e_i_q1only) / _D3q
gen _piI3q = (e_i_q1only*(u_e_q1only+u_i_q1only) + e_u_q1only*u_i_q1only) / _D3q
gen ur_ss3  = 100 * _piU3q / (1 + _piU3q + _piI3q)
drop _D3q _piU3q _piI3q

* -- Medie pre-crisi (2004-2007) per i 6 tassi --
foreach r in e_u u_e e_i u_i i_u i_e {
    quietly summ `r'_q1only if anno <= 2007
    local `r'_bar = r(mean)
}

* CF1: solo f = u_e varia; tutti gli altri al pre-crisi
local D_cf1 "u_e_q1only*(`i_u_bar'+`i_e_bar') + `i_e_bar'*`u_i_bar'"
gen _D1 = `D_cf1'
gen _pU1 = (`e_u_bar'*(`i_u_bar'+`i_e_bar') + `i_u_bar'*`e_i_bar') / _D1
gen _pI1 = (`e_i_bar'*(u_e_q1only+`u_i_bar') + `e_u_bar'*`u_i_bar') / _D1
gen ur_cf3_find = 100 * _pU1 / (1 + _pU1 + _pI1)
drop _D1 _pU1 _pI1

* CF2: solo s = e_u varia; tutti gli altri al pre-crisi
local D_cf2 "`u_e_bar'*(`i_u_bar'+`i_e_bar') + `i_e_bar'*`u_i_bar'"
gen _D2 = `D_cf2'
gen _pU2 = (e_u_q1only*(`i_u_bar'+`i_e_bar') + `i_u_bar'*`e_i_bar') / _D2
gen _pI2 = (`e_i_bar'*(`u_e_bar'+`u_i_bar') + e_u_q1only*`u_i_bar') / _D2
gen ur_cf3_sep = 100 * _pU2 / (1 + _pU2 + _pI2)
drop _D2 _pU2 _pI2

* CF3: solo flussi da/verso inattività (μ, ν, δ, η) variano; s, f al pre-crisi
gen _D3 = `u_e_bar'*(i_u_q1only+i_e_q1only) + i_e_q1only*u_i_q1only
gen _pU3 = (`e_u_bar'*(i_u_q1only+i_e_q1only) + i_u_q1only*e_i_q1only) / _D3
gen _pI3 = (e_i_q1only*(`u_e_bar'+u_i_q1only) + `e_u_bar'*u_i_q1only) / _D3
gen ur_cf3_inact = 100 * _pU3 / (1 + _pU3 + _pI3)
drop _D3 _pU3 _pI3

* CF4: solo E→nonE (s=e_u e δ=e_i) variano; f, η, μ, ν al pre-crisi
gen _D4 = `u_e_bar'*(`i_u_bar'+`i_e_bar') + `i_e_bar'*`u_i_bar'
gen _pU4 = (e_u_q1only*(`i_u_bar'+`i_e_bar') + `i_u_bar'*e_i_q1only) / _D4
gen _pI4 = (e_i_q1only*(`u_e_bar'+`u_i_bar') + e_u_q1only*`u_i_bar') / _D4
gen ur_cf3_enonE = 100 * _pU4 / (1 + _pU4 + _pI4)
drop _D4 _pU4 _pI4

* Grafico
twoway ///
    (line ur            anno, lcolor(black)        lwidth(medthick)) ///
    (line ur_ss3        anno, lcolor(black)        lwidth(medium) lp(dash)) ///
    (line ur_cf3_find   anno, lcolor(navy)         lwidth(medium) lp(longdash)) ///
    (line ur_cf3_sep    anno, lcolor(cranberry)    lwidth(medium) lp(longdash)) ///
    (line ur_cf3_inact  anno, lcolor(forest_green) lwidth(medium) lp(shortdash)) ///
    (line ur_cf3_enonE  anno, lcolor(orange)       lwidth(medium) lp(shortdash_dot)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
    legend(order(1 "Osservato" 2 "Steady-state (3 flussi)" ///
                 3 "CF: solo U→E varia" 4 "CF: solo E→U varia" ///
                 5 "CF: solo flussi I variano" 6 "CF: solo E→nonE varia") row(3)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig3b, replace)
*graph export ${graphs}/fig3_pannello_b.png, replace

* -- Robustezza: steady-state e CF1 con tutti i trimestri (2013-2025) --
gen _D3_4q   = u_e*(i_u+i_e) + i_e*u_i                 if anno >= 2014
gen _piU3_4q = (e_u*(i_u+i_e) + i_u*e_i) / _D3_4q      if anno >= 2014
gen _piI3_4q = (e_i*(u_e+u_i) + e_u*u_i) / _D3_4q      if anno >= 2014
gen ur_ss3_4q = 100 * _piU3_4q / (1 + _piU3_4q + _piI3_4q)
drop _D3_4q _piU3_4q _piI3_4q

* Per i 6 tassi dei 4 trimestri, pre-crisi calcolato sulla parte 2013-2019
foreach r in e_u u_e e_i u_i i_u i_e {
    quietly summ `r' if anno >= 2014 & anno <= 2019
    local `r'_bar_4q = r(mean)
}
local D_cf1_4q "u_e*(`i_u_bar_4q'+`i_e_bar_4q') + `i_e_bar_4q'*`u_i_bar_4q'"
gen _D1_4q = `D_cf1_4q'                                              if anno >= 2014
gen _pU1_4q = (`e_u_bar_4q'*(`i_u_bar_4q'+`i_e_bar_4q') + `i_u_bar_4q'*`e_i_bar_4q') / _D1_4q
gen _pI1_4q = (`e_i_bar_4q'*(u_e+`u_i_bar_4q') + `e_u_bar_4q'*`u_i_bar_4q') / _D1_4q
gen ur_cf3_find_4q = 100 * _pU1_4q / (1 + _pU1_4q + _pI1_4q)
drop _D1_4q _pU1_4q _pI1_4q

preserve
    keep anno ur ur_ss3 ur_cf3_find ur_cf3_sep ur_cf3_inact ur_cf3_enonE ///
              ur_ss3_4q ur_cf3_find_4q
    sort anno
    label var anno                "Anno"
    label var ur                  "Tasso di disoccupazione osservato"
    label var ur_ss3              "Steady-state (3 flussi, Q1)"
    label var ur_cf3_find         "CF: solo U→E varia (Q1, rif. 2004-07)"
    label var ur_cf3_sep          "CF: solo E→U varia (Q1, rif. 2004-07)"
    label var ur_cf3_inact        "CF: solo flussi I variano (Q1)"
    label var ur_cf3_enonE        "CF: solo E→nonE varia (Q1)"
    label var ur_ss3_4q           "Steady-state (3 flussi, 4 trim.)"
    label var ur_cf3_find_4q      "CF: solo U→E varia (4 trim., rif. 2013-19)"
    export excel using "`figfile'", sheet("Fig3_pannello_b") sheetreplace firstrow(varlabels)
restore

drop ur_ss3 ur_cf3_* ur_ss3_4q ur_cf3_find_4q
