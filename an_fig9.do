/*******************************************************************************
 FIGURA 9 – Tightness del mercato del lavoro e Beveridge curve controfattuale
 Replicazione di Elsby et al. (2015), JEL 53(3):571-630, Figure 9 (panel A, B)

 Panel A: evoluzione del labour market tightness (V/U e V/(U+I))
 Panel B: Beveridge curve controfattuale
          → aggiusta per le variazioni del job finding rate mantenendo
            la separazione al livello pre-crisi, seguendo Elsby et al. (2015)

 Due misure di tightness:
   θ_u  = V(10+) / U  e  V(1+) / U   (denominatore: disoccupati)
   θ_ui = V(10+) / (U+I)  e  V(1+) / (U+I) (denominatore: non-occupati)

 Per il panel B, tre controfattuali (Elsby et al. 2015):
   (i)   Beveridge curve osservata
   (ii)  BC controfattuale: u_cf = s_t/(s_t + f̄),
         dove f̄ = media pre-crisi del job finding rate U→E
         → rimuove la variazione del finding rate, lascia variare solo la separazione
   (iii) BC controfattuale: u_cf = s̄/(s̄ + f_t),
         → rimuove la variazione della separazione, lascia variare solo il finding rate
   In tutti e tre i casi la vacancy rate è quella osservata.

 Robustezza per Panel A e B con jvr1 (imprese 1+): sottocampione 2016-2025

 Dataset: data_jvr_u_transitions_2004_2025.dta
 Output:  Figure 9.xlsx
*******************************************************************************/

clear
use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear
tsset anno

local figfile "${dta}/../Figure 9.xlsx"

/*==============================================================================
 PANEL A – Evoluzione del labour market tightness
==============================================================================*/

* Tightness con denominatore U (disoccupati)
twoway ///
    (tsline v10_u, lcolor(navy)     lwidth(medthick)) ///
    (tsline v1_u,  lcolor(cranberry) lwidth(medthick) lp(dash)) if anno >= 2016, ///
    yline(1, lcolor(gs12)) ///
    xlabel(2016(1)2025) xtitle("") ///
    ytitle("V/U") ylab(, angle(0)) ///
    legend(order(1 "V(10+)/U" 2 "V(1+)/U") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig9a_vu_rob, replace)
*graph export ${graphs}/fig9_pannello_a_vu_2016.png, replace

* Tightness con denominatore U+I (non-occupati)
twoway ///
    (tsline v10_ui, lcolor(navy)     lwidth(medthick)) ///
    (tsline v1_ui,  lcolor(cranberry) lwidth(medthick) lp(dash)) if anno >= 2016, ///
    yline(1, lcolor(gs12)) ///
    xlabel(2016(1)2025) xtitle("") ///
    ytitle("V/(U+I)") ylab(, angle(0)) ///
    legend(order(1 "V(10+)/(U+I)" 2 "V(1+)/(U+I)") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig9a_vui_rob, replace)
*graph export ${graphs}/fig9_pannello_a_vui_2016.png, replace

* Tightness lunga con jvr10 (2004-2025)
twoway ///
    (tsline v10_u,  lcolor(navy)         lwidth(medthick)) ///
    (tsline v10_ui, lcolor(cranberry)    lwidth(medthick) lp(dash)), ///
    yline(1, lcolor(gs12)) ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tightness") ylab(, angle(0)) ///
    legend(order(1 "V(10+)/U" 2 "V(10+)/(U+I)") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig9a_v10_long, replace)
*graph export ${graphs}/fig9_pannello_a_v10_2004.png, replace

preserve
    keep anno v10_u v10_ui v1_u v1_ui
    sort anno
    label var anno    "Anno"
    label var v10_u   "V(10+)/U"
    label var v10_ui  "V(10+)/(U+I)"
    label var v1_u    "V(1+)/U (dal 2016)"
    label var v1_ui   "V(1+)/(U+I) (dal 2016)"
    export excel using "`figfile'", sheet("Fig9_pannello_a") sheetreplace firstrow(varlabels)
restore

/*==============================================================================
 PANEL B – Beveridge curve controfattuale
 Metodologia: Elsby et al. (2015)

 Per costruire la BC controfattuale, si usa:
   u_cf_t = f(s_t, f_bar)  o  f(s_bar, f_t)
 dove f_bar e s_bar sono le medie pre-crisi.
 La vacancy rate osservata jvr_t è invariata.
 Si plottano (u_cf_t, jvr_t) contro (u_obs_t, jvr_t).

 Interpretazione:
   BC con u_cf usando f_bar > f_t (post-crisi):
     → u_cf < u_obs (unemployment sarebbe minore se il finding rate
       non fosse calato): la BC "controfattuale" è a SINISTRA di quella
       osservata, mostrando che parte dello spostamento verso l'esterno
       è dovuto al calo dell'efficienza di matching.
==============================================================================*/

* --- Periodi di riferimento ---
* (i) Pre-crisi finanziaria (2004-2007)
quietly summ e_u_q1only if anno <= 2007
local s_bar07 = r(mean)
quietly summ u_e_q1only if anno <= 2007
local f_bar07 = r(mean)

* (ii) Pre-COVID (2004-2019)
quietly summ e_u_q1only if anno <= 2019
local s_bar19 = r(mean)
quietly summ u_e_q1only if anno <= 2019
local f_bar19 = r(mean)

* Unemployment controfattuale (rif. 2004-07):
*   solo trovare lavoro varia (separazione al pre-crisi): segnala calo del finding rate
gen ur_cf_fonly_07 = 100 * `s_bar07' / (`s_bar07' + u_e_q1only)
*   solo separare varia (finding al pre-crisi): segnala aumento della separazione
gen ur_cf_sonly_07 = 100 * e_u_q1only / (e_u_q1only + `f_bar07')

* Idem rif. 2004-19
gen ur_cf_fonly_19 = 100 * `s_bar19' / (`s_bar19' + u_e_q1only)
gen ur_cf_sonly_19 = 100 * e_u_q1only / (e_u_q1only + `f_bar19')

* --- Beveridge curve osservata e controfattuali (jvr10, 2004-2025) ---

* BC osservata
twoway ///
    (scatter jvr10 ur, mlab(y_l) mlabsize(vsmall) mcolor(gs8) msymbol(circle_hollow)) ///
    (line    jvr10 ur if anno <= 2007, lcolor(blue)     sort(anno)) ///
    (line    jvr10 ur if anno >= 2007 & anno <= 2013, lcolor(midgreen) sort(anno)) ///
    (line    jvr10 ur if anno >= 2013 & anno <= 2020, lcolor(red)      sort(anno)) ///
    (line    jvr10 ur if anno >= 2020 & anno <= 2025, lcolor(black)    sort(anno)), ///
    xtitle("Tasso di disoccupazione (%)") ///
    ytitle("Tasso posti vacanti – imprese 10+ addetti (%)") ///
    legend(order(2 "2004-2007" 3 "2008-2013" 4 "2014-2019" 5 "2020-2025") row(1) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig9b_obs, replace)

* BC controfattuale "solo trovare lavoro varia" (rif. 2004-07)
twoway ///
    (scatter jvr10 ur, mlab(y_l) mlabsize(vsmall) mcolor(gs12) msymbol(circle_hollow)) ///
    (scatter jvr10 ur_cf_fonly_07, mlab(y_l) mlabsize(vsmall) ///
             mcolor(navy) msymbol(diamond_hollow)) ///
    (line    jvr10 ur if anno <= 2007, lcolor(blue)     sort(anno)) ///
    (line    jvr10 ur if anno >= 2007 & anno <= 2013, lcolor(midgreen) sort(anno)) ///
    (line    jvr10 ur if anno >= 2013 & anno <= 2020, lcolor(red)      sort(anno)) ///
    (line    jvr10 ur if anno >= 2020 & anno <= 2025, lcolor(black)    sort(anno)) ///
    (line    jvr10 ur_cf_fonly_07 if anno >= 2013, lcolor(navy) lp(dash) sort(anno)), ///
    xtitle("Tasso di disoccupazione (%)") ///
    ytitle("Tasso posti vacanti – imprese 10+ addetti (%)") ///
    legend(order(1 "UR osservato" 2 "UR controfattuale (finding fisso al 2004-07)" ///
                 7 "BC controfattuale (post-2013)") row(3) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig9b_cf_fonly, replace)
*graph export ${graphs}/fig9_pannello_b_cf_fonly.png, replace

* BC controfattuale "solo separazione varia" (rif. 2004-07)
twoway ///
    (scatter jvr10 ur, mlab(y_l) mlabsize(vsmall) mcolor(gs12) msymbol(circle_hollow)) ///
    (scatter jvr10 ur_cf_sonly_07, mlab(y_l) mlabsize(vsmall) ///
             mcolor(cranberry) msymbol(diamond_hollow)) ///
    (line    jvr10 ur if anno <= 2007, lcolor(blue)       sort(anno)) ///
    (line    jvr10 ur if anno >= 2007 & anno <= 2013, lcolor(midgreen) sort(anno)) ///
    (line    jvr10 ur if anno >= 2013 & anno <= 2020, lcolor(red)      sort(anno)) ///
    (line    jvr10 ur if anno >= 2020 & anno <= 2025, lcolor(black)    sort(anno)) ///
    (line    jvr10 ur_cf_sonly_07 if anno >= 2013, lcolor(cranberry) lp(dash) sort(anno)), ///
    xtitle("Tasso di disoccupazione (%)") ///
    ytitle("Tasso posti vacanti – imprese 10+ addetti (%)") ///
    legend(order(1 "UR osservato" 2 "UR controfattuale (separazione fissa al 2004-07)" ///
                 7 "BC controfattuale (post-2013)") row(3) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig9b_cf_sonly, replace)
*graph export ${graphs}/fig9_pannello_b_cf_sonly.png, replace

* --- Robustezza: jvr1 (1+ addetti), sottocampione 2016-2025 ---
twoway ///
    (scatter jvr1 ur if anno >= 2016, mlab(y_l) mlabsize(vsmall) ///
             mcolor(gs8) msymbol(circle_hollow)) ///
    (scatter jvr1 ur_cf_fonly_07 if anno >= 2016, mlab(y_l) mlabsize(vsmall) ///
             mcolor(navy) msymbol(diamond_hollow)) ///
    (line    jvr1 ur             if anno >= 2016 & anno <= 2019, lcolor(red)   sort(anno)) ///
    (line    jvr1 ur             if anno >= 2019 & anno <= 2025, lcolor(black) sort(anno)) ///
    (line    jvr1 ur_cf_fonly_07 if anno >= 2016, lcolor(navy) lp(dash) sort(anno)), ///
    xtitle("Tasso di disoccupazione (%)") ///
    ytitle("Tasso posti vacanti – imprese 1+ addetti (%)") ///
    legend(order(1 "UR osservato" 2 "UR controfattuale (finding fisso al 2004-07)" ///
                 5 "BC controfattuale") row(3) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig9b_rob_jvr1, replace)
*graph export ${graphs}/fig9_pannello_b_rob_2016_jvr1.png, replace

preserve
    keep anno ur ur2 jvr10 jvr1 v10_u v1_u ///
              ur_cf_fonly_07 ur_cf_sonly_07 ur_cf_fonly_19 ur_cf_sonly_19
    sort anno
    label var anno               "Anno"
    label var ur                 "Tasso disoccupazione osservato (%)"
    label var ur2                "Tasso disoccupazione allargato (%)"
    label var jvr10              "Tasso posti vacanti (10+, %)"
    label var jvr1               "Tasso posti vacanti (1+, %, dal 2016)"
    label var v10_u              "Tightness V(10+)/U"
    label var v1_u               "Tightness V(1+)/U (dal 2016)"
    label var ur_cf_fonly_07     "UR_cf: solo U→E varia (rif. 2004-07)"
    label var ur_cf_sonly_07     "UR_cf: solo E→U varia (rif. 2004-07)"
    label var ur_cf_fonly_19     "UR_cf: solo U→E varia (rif. 2004-19)"
    label var ur_cf_sonly_19     "UR_cf: solo E→U varia (rif. 2004-19)"
    export excel using "`figfile'", sheet("Fig9_pannello_b") sheetreplace firstrow(varlabels)
restore

drop ur_cf_*
