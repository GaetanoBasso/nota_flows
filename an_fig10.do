/*******************************************************************************
 FIGURA 10 – Funzione di matching e efficienza del mercato del lavoro
 Replicazione di Elsby et al. (2015), JEL 53(3):571-630, Figure 10 (panel A, C, D)

 Panel A: scatter log(job finding rate) vs log(tightness) → stima della
          funzione di matching di Cobb-Douglas:  log(f_t) = c + α·log(θ_t) + ε_t

 Panel C: efficienza di matching nel tempo → residui ε_t dalla funzione stimata
          (media mobile di 3 periodi per la serie principale)

 Panel D: tasso di disoccupazione controfattuale basato sull'efficienza di matching
          Metodologia:
            1. Stima:  log(f_t) = c + α·log(θ_t) + ε_t
            2. f_cf_t = f_t · exp(ε̄ - ε_t)  dove ε̄ = media pre-crisi dei residui
               → f_cf è il finding rate che si osserverebbe se l'efficienza
                 fosse rimasta al livello pre-crisi
            3. u*_cf = s_t / (s_t + f_cf_t)  [steady-state 2 flussi]

 Misure:
   Spec. principale:  log(u_e_q1only) ~ log(v10_u)  [U→E, Q1 only, 10+ addetti]
   Robustezza (1):    log(u_e_q1only) ~ log(v1_u)   [U→E, Q1 only, 1+ addetti, 2016+]
   Robustezza (2):    log(ui_e_q1only) ~ log(v10_ui) [nonE→E, Q1 only, 10+ addetti]

 Dataset: data_jvr_u_transitions_2004_2025.dta
 Output:  Figure 10.xlsx
*******************************************************************************/

clear
use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear
tsset anno

local figfile "${dta}/../Figure 10.xlsx"

/*==============================================================================
 PANEL A – Funzione di matching: scatter log(f) vs log(θ)
 Spec. principale: log(u_e) vs log(V10+/U), Q1 only, 2004-2025
==============================================================================*/

* --- Spec. principale: U→E vs V(10+)/U ---
twoway ///
    (scatter log_u_e_q1only log_v10_u, mlab(y_l) mlabsize(vsmall) ///
             mcolor(navy) msymbol(circle_hollow) connect(l) sort(anno)) ///
    (lfit    log_u_e_q1only log_v10_u, lcolor(cranberry) lwidth(medium)), ///
    xtitle("log(V(10+)/U)") ///
    ytitle("log(Job finding rate U→E, Q1)") ///
    ylab(, angle(0)) ///
    legend(order(1 "Osservazioni" 2 "Retta di regressione") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig10a_main, replace)
*graph export ${graphs}/fig10_pannello_a_v10u.png, replace

* --- Robustezza (1): U→E vs V(1+)/U, sottocampione 2016-2025 ---
twoway ///
    (scatter log_u_e_q1only log_v1_u if anno >= 2016, mlab(y_l) mlabsize(vsmall) ///
             mcolor(navy) msymbol(circle_hollow) connect(l) sort(anno)) ///
    (lfit    log_u_e_q1only log_v1_u if anno >= 2016, lcolor(cranberry) lwidth(medium)), ///
    xtitle("log(V(1+)/U)") ///
    ytitle("log(Job finding rate U→E, Q1)") ///
    ylab(, angle(0)) ///
    legend(order(1 "Osservazioni 2016-2025" 2 "Retta di regressione") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig10a_rob_v1u, replace)
*graph export ${graphs}/fig10_pannello_a_rob_v1u.png, replace

* --- Robustezza (2): nonE→E vs V(10+)/(U+I) ---
twoway ///
    (scatter log_ui_e_q1only log_v10_ui, mlab(y_l) mlabsize(vsmall) ///
             mcolor(forest_green) msymbol(circle_hollow) connect(l) sort(anno)) ///
    (lfit    log_ui_e_q1only log_v10_ui, lcolor(orange) lwidth(medium)), ///
    xtitle("log(V(10+)/(U+I))") ///
    ytitle("log(Finding rate nonE→E, Q1)") ///
    ylab(, angle(0)) ///
    legend(order(1 "Osservazioni" 2 "Retta di regressione") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig10a_vui, replace)
*graph export ${graphs}/fig10_pannello_a_vui.png, replace

/*==============================================================================
 Stima della funzione di matching (per Panel C e D)
 Modello:  log(f_t) = c + α·log(θ_t) + ε_t
==============================================================================*/

* --- Spec. principale: U→E vs V(10+)/U ---
reg log_u_e_q1only log_v10_u
local alpha_main   = _b[log_v10_u]
local const_main   = _b[_cons]
di "Spec. principale: α = `alpha_main', c = `const_main'"

predict ehat_u10_raw, resid

* Media mobile a 3 periodi (centrata)
gen ehat_u10 = (F.ehat_u10_raw + 2*ehat_u10_raw + L.ehat_u10_raw) / 4
replace ehat_u10 = ehat_u10_raw if anno == 2004 | anno == 2025

* --- Robustezza (1): U→E vs V(1+)/U (2016-2025) ---
reg log_u_e_q1only log_v1_u if anno >= 2016
local alpha_v1u = _b[log_v1_u]
di "Robustezza V(1+)/U: α = `alpha_v1u'"
predict ehat_u1_raw    if anno >= 2016, resid

gen ehat_u1 = (F.ehat_u1_raw + 2*ehat_u1_raw + L.ehat_u1_raw) / 4 if anno >= 2016
replace ehat_u1 = ehat_u1_raw if anno == 2016 | anno == 2025

* --- Robustezza (2): nonE→E vs V(10+)/(U+I) ---
reg log_ui_e_q1only log_v10_ui
local alpha_ui10 = _b[log_v10_ui]
di "nonE→E vs V(10+)/(U+I): α = `alpha_ui10'"
predict ehat_ui10_raw, resid

gen ehat_ui10 = (F.ehat_ui10_raw + 2*ehat_ui10_raw + L.ehat_ui10_raw) / 4
replace ehat_ui10 = ehat_ui10_raw if anno == 2004 | anno == 2025

/*==============================================================================
 PANEL C – Efficienza di matching nel tempo (residui dalla funzione stimata)
==============================================================================*/

* Spec. principale
twoway ///
    (line ehat_u10 anno, lcolor(navy) lwidth(medthick)) ///
    (line ehat_u10_raw anno, lcolor(navy) lp(dot) lwidth(thin)), ///
    yline(0, lcolor(gs10)) ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Residuo log (efficienza di matching)") ylab(, angle(0)) ///
    legend(order(1 "Media mobile 3p" 2 "Non smoothed") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig10c_main, replace)
*graph export ${graphs}/fig10_pannello_c_main.png, replace

* Robustezza con jvr1 (2016-2025)
twoway ///
    (line ehat_u1  anno if anno >= 2016, lcolor(cranberry) lwidth(medthick)) ///
    (line ehat_u10 anno if anno >= 2016, lcolor(navy)      lwidth(medium) lp(dash)), ///
    yline(0, lcolor(gs10)) ///
    xlabel(2016(1)2025) xtitle("") ///
    ytitle("Residuo log (efficienza di matching)") ylab(, angle(0)) ///
    legend(order(1 "V(1+)/U – 2016-2025" 2 "V(10+)/U – 2016-2025") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig10c_rob, replace)
*graph export ${graphs}/fig10_pannello_c_rob.png, replace

/*==============================================================================
 PANEL D – Tasso di disoccupazione controfattuale basato sull'efficienza
 Metodologia (Elsby et al. 2015):
   ε_t = residuo della funzione di matching (log efficienza)
   f_cf_t = f_t · exp(ε̄ - ε_t)
           = job finding rate controfattuale con efficienza = ε̄ (media pre-crisi)
   u*_cf_t = s_t / (s_t + f_cf_t)   [steady-state 2 flussi]

 Interpretazione:
   - Se ε_t < ε̄ (efficienza sotto la media), f_cf_t > f_t
     → u*_cf_t < u*_obs: parte della disoccupazione è attribuibile
       al calo dell'efficienza di matching
   - Il confronto u*_cf vs. u*_obs quantifica il ruolo dell'efficienza
==============================================================================*/

* --- Medie pre-crisi del residuo (2004-2007) ---
quietly summ ehat_u10_raw if anno <= 2007
local eps_bar07 = r(mean)

quietly summ ehat_u10_raw if anno <= 2019
local eps_bar19 = r(mean)

* Finding rate controfattuale (spec. principale, rif. 2004-07)
gen f_cf10_07 = u_e_q1only * exp(`eps_bar07' - ehat_u10_raw)

* Finding rate controfattuale (spec. principale, rif. 2004-19)
gen f_cf10_19 = u_e_q1only * exp(`eps_bar19' - ehat_u10_raw)

* UR steady-state osservato (2 flussi)
gen ur_ss2 = 100 * e_u_q1only / (e_u_q1only + u_e_q1only)

* UR controfattuale da efficienza (rif. 2004-07)
gen ur_cf10_eff_07 = 100 * e_u_q1only / (e_u_q1only + f_cf10_07)

* UR controfattuale da efficienza (rif. 2004-19)
gen ur_cf10_eff_19 = 100 * e_u_q1only / (e_u_q1only + f_cf10_19)

* Grafico principale
twoway ///
    (line ur             anno, lcolor(black)     lwidth(medthick)) ///
    (line ur_ss2         anno, lcolor(black)     lwidth(medium) lp(dash)) ///
    (line ur_cf10_eff_07 anno, lcolor(navy)      lwidth(medium) lp(longdash)) ///
    (line ur_cf10_eff_19 anno, lcolor(cranberry) lwidth(medium) lp(shortdash)), ///
    yline(0, lcolor(gs12)) ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
    legend(order(1 "Osservato" 2 "Steady-state (2 flussi)" ///
                 3 "CF: efficienza al 2004-07" 4 "CF: efficienza al 2004-19") row(2)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig10d_main, replace)
*graph export ${graphs}/fig10_pannello_d.png, replace

* --- Robustezza con jvr1 (2016-2025) ---
quietly summ ehat_u1_raw if anno >= 2016 & anno <= 2019
local eps_bar1_1619 = r(mean)

gen f_cf1_1619 = u_e_q1only * exp(`eps_bar1_1619' - ehat_u1_raw) if anno >= 2016
gen ur_cf1_eff_1619 = 100 * e_u_q1only / (e_u_q1only + f_cf1_1619) if anno >= 2016

twoway ///
    (line ur              anno if anno >= 2016, lcolor(black)     lwidth(medthick)) ///
    (line ur_ss2          anno if anno >= 2016, lcolor(black)     lwidth(medium) lp(dash)) ///
    (line ur_cf10_eff_07  anno if anno >= 2016, lcolor(navy)      lwidth(medium) lp(longdash)) ///
    (line ur_cf1_eff_1619 anno if anno >= 2016, lcolor(cranberry) lwidth(medium) lp(shortdash)), ///
    xlabel(2016(1)2025) xtitle("") ///
    ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
    legend(order(1 "Osservato" 2 "Steady-state" ///
                 3 "CF: eff. V(10+)/U al 2004-07" 4 "CF: eff. V(1+)/U al 2016-19") row(2)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig10d_rob, replace)
*graph export ${graphs}/fig10_pannello_d_rob.png, replace

* --- Contributo dell'efficienza alla variazione del UR ---
* Δu = Δu|_finding + Δu|_separation + Δu|_interaction
* Qui isola: Δu|_efficiency = u*_obs - u*_cf_efficiency
gen delta_ur_efficiency_07 = ur_ss2 - ur_cf10_eff_07
gen delta_ur_efficiency_19 = ur_ss2 - ur_cf10_eff_19

preserve
    keep anno ur ur_ss2 ehat_u10 ehat_u10_raw ehat_u1 ehat_u1_raw ///
              ur_cf10_eff_07 ur_cf10_eff_19 ur_cf1_eff_1619 ///
              delta_ur_efficiency_07 delta_ur_efficiency_19
    sort anno
    label var anno                    "Anno"
    label var ur                      "Tasso disoccupazione osservato (%)"
    label var ur_ss2                  "Steady-state (2 flussi)"
    label var ehat_u10                "Efficienza matching: ε (MA3, V10+/U)"
    label var ehat_u10_raw            "Efficienza matching: ε (raw, V10+/U)"
    label var ehat_u1                 "Efficienza matching: ε (MA3, V1+/U, dal 2016)"
    label var ehat_u1_raw             "Efficienza matching: ε (raw, V1+/U, dal 2016)"
    label var ur_cf10_eff_07          "CF: efficienza al 2004-07 (V10+/U)"
    label var ur_cf10_eff_19          "CF: efficienza al 2004-19 (V10+/U)"
    label var ur_cf1_eff_1619         "CF: efficienza al 2016-19 (V1+/U)"
    label var delta_ur_efficiency_07  "Δur da efficienza (rif. 2004-07)"
    label var delta_ur_efficiency_19  "Δur da efficienza (rif. 2004-19)"
    export excel using "`figfile'", sheet("Fig10_pannello_c_d") sheetreplace firstrow(varlabels)
restore

* Export Panel A
preserve
    keep anno log_u_e_q1only log_v10_u log_v1_u log_ui_e_q1only log_v10_ui y_l
    sort anno
    label var anno              "Anno"
    label var log_u_e_q1only   "log(Job finding rate U→E, Q1)"
    label var log_v10_u        "log(V(10+)/U)"
    label var log_v1_u         "log(V(1+)/U) – dal 2016"
    label var log_ui_e_q1only  "log(Finding rate nonE→E, Q1)"
    label var log_v10_ui       "log(V(10+)/(U+I))"
    export excel using "`figfile'", sheet("Fig10_pannello_a") sheetreplace firstrow(varlabels)
restore

drop ur_ss2 ehat_u10_raw ehat_u10 ehat_u1_raw ehat_u1 ehat_ui10_raw ehat_ui10 ///
     f_cf10_07 f_cf10_19 f_cf1_1619 ///
     ur_cf10_eff_07 ur_cf10_eff_19 ur_cf1_eff_1619 ///
     delta_ur_efficiency_07 delta_ur_efficiency_19
