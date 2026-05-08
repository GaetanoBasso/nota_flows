/*******************************************************************************
 FIGURA 11 – Composizione della disoccupazione e UR controfattuale
 Replicazione di Elsby et al. (2015), JEL 53(3):571-630, Figure 11 (panel A, B)

 Panel A: composizione della disoccupazione nel tempo
          → quota di disoccupazione di lungo periodo (≥12 mesi)
          → quote per età (15-34, 35-54, 55+)
          → quote per genere, nazionalità, istruzione
          → durata media dell'episodio di disoccupazione

 Panel B: tasso di disoccupazione controfattuale aggiustato per la composizione
          Metodologia (Elsby et al. 2015):
            Decomposizione del job finding aggregato:
              f_t = Σ_g ω_g,t · f_g,t
            Controfattuale con composizione al livello pre-crisi:
              f_cf_t = Σ_g ω̄_g · f_g,t   (quote fisse, within-group rates variano)
            Controfattuale con within-group rates al livello pre-crisi:
              f_cf_t = Σ_g ω_g,t · f̄_g   (quote variano, rates fisse)
            UR controfattuale:  u*_cf = s_t / (s_t + f_cf_t)

          Per Panel B sono usati tre gruppi di età (15-34, 35-54, 55+)
          e, per robustezza, la decomposizione breve/lungo periodo.

 Fonti:
   Composizione demo:  unempl_composition_rfl.dta  (dalla RFL cross-section)
   Finding rates:      data_jvr_u_transitions_2004_2025.dta
   LT share:           ltshare da data_jvr_u_transitions_2004_2025.dta

 Dataset input: data_jvr_u_transitions_2004_2025.dta
                unempl_composition_rfl.dta
 Output:  Figure 11.xlsx
*******************************************************************************/

local figfile "${dta}/../Figure 11.xlsx"

/*==============================================================================
 PANEL A – Composizione della disoccupazione nel tempo
 Fonte: data aggregata da data_jvr_u_transitions_2004_2025.dta (ltur, ltshare)
        e unempl_composition_rfl.dta (quote demografiche)
==============================================================================*/

* -- 1. LT unemployment share e LT rate (da dataset principale) --
use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear
tsset anno

twoway ///
    (tsline ltshare, lcolor(navy)     lwidth(medthick) yaxis(1)) ///
    (tsline ltur,    lcolor(cranberry) lwidth(medthick) yaxis(2)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Quota disoccupazione ≥12 mesi (%)", axis(1)) ///
    ytitle("Tasso di disoccupazione ≥12 mesi (%)", axis(2)) ///
    legend(order(1 "Quota LT (≥12m, sx.)" 2 "Tasso LT (≥12m, dx.)") row(1)) ///
    ylab(, angle(0)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig11a_lt, replace)
*graph export ${graphs}/fig11_pannello_a_lt.png, replace

* -- 2. Quote demografiche (da unempl_composition_rfl) --
preserve
    use ${dta}/unempl_composition_rfl.dta, clear

    * Composizione di genere e nazionalità
    twoway ///
        (tsline female, lcolor(cranberry) lwidth(medthick)) ///
        (tsline fborn,  lcolor(navy)      lwidth(medthick) lp(dash)), ///
        xlabel(2004(2)2025) xtitle("") ///
        ytitle("Quota (%)") ylab(, angle(0)) ///
        legend(order(1 "Quota donne" 2 "Quota nati all'estero") row(1)) ///
        graphregion(color(white)) plotregion(color(white)) ///
        name(fig11a_gender_fborn, replace)
    *graph export ${graphs}/fig11_pannello_a_gender_fborn.png, replace

    * Composizione per istruzione
    twoway ///
        (tsline less, lcolor(navy)         lwidth(medthick)) ///
        (tsline HS,   lcolor(forest_green) lwidth(medthick) lp(dash)) ///
        (tsline coll, lcolor(cranberry)    lwidth(medthick) lp(longdash)), ///
        xlabel(2004(2)2025) xtitle("") ///
        ytitle("Quota (%)") ylab(, angle(0)) ///
        legend(order(1 "< diploma" 2 "Diploma" 3 "Laurea+") row(1)) ///
        graphregion(color(white)) plotregion(color(white)) ///
        name(fig11a_edu, replace)
    *graph export ${graphs}/fig11_pannello_a_edu.png, replace

    * Durata media della disoccupazione
    twoway ///
        (tsline durad, lcolor(navy) lwidth(medthick)), ///
        xlabel(2004(2)2025) xtitle("") ///
        ytitle("Mesi") ylab(, angle(0)) ///
        legend(off) ///
        graphregion(color(white)) plotregion(color(white)) ///
        name(fig11a_durata, replace)
    *graph export ${graphs}/fig11_pannello_a_durata.png, replace

    sort anno
    label var anno    "Anno"
    label var female  "Quota donne (%)"
    label var fborn   "Quota nati all'estero (%)"
    label var less    "Quota < diploma (%)"
    label var HS      "Quota con diploma (%)"
    label var coll    "Quota con laurea+ (%)"
    label var durad   "Durata media (mesi)"
    label var esplav  "Quota con esperienza lavorativa precedente (%)"
    export excel using "`figfile'", sheet("Fig11_pannello_a_demo") sheetreplace firstrow(varlabels)
restore

preserve
    keep anno ltshare ltur ur
    sort anno
    label var anno    "Anno"
    label var ltshare "Quota disoccupazione LT ≥12m (%)"
    label var ltur    "Tasso di disoccupazione LT ≥12m (%)"
    label var ur      "Tasso di disoccupazione totale (%)"
    export excel using "`figfile'", sheet("Fig11_pannello_a_LT") sheetreplace firstrow(varlabels)
restore

/*==============================================================================
 PANEL B – UR controfattuale aggiustato per la composizione

 Parte 1: decomposizione per classi di età (15-34, 35-54, 55+)
   f_t     = ω_1t·f_1t + ω_2t·f_2t + ω_3t·f_3t
   dove ω_gt = quota del gruppo g nella disoccupazione totale,
         f_gt = job finding rate del gruppo g

   I finding rates per gruppo di età (u_e1534_q1only, u_e3554_q1only, u_e55_q1only)
   sono disponibili nel dataset principale.
   Le quote ω_gt devono essere ricostruite: si usano le numerosità assolute
   (unempl_t0 per gruppo) dal file intermedio jobfinding_q1_agegr_2004_2024.dta
   (nota: il file contiene i tassi divisi per le numerosità; per recuperare
    le quote si calcola la numerosità relativa usando le variabili *empl*).

   Se le numerosità assolute per gruppo non sono disponibili nel file aggregato,
   si usa un'approssimazione: le quote vengono derivate da unempl_composition_rfl.dta
   convertendo le variabili di età in quote di disoccupazione per fascia.

 Parte 2: decomposizione per durata (breve/lungo periodo)
   Utilizzando ltshare_t e il finding rate aggregato, si stima la decomposizione
   imponendo un rapporto ρ = f_LT/f_ST calibrato sui dati italiani.
==============================================================================*/

* --- Carica dataset con finding rates per età ---
use ${dta}/jobfinding_q1_agegr_2004_2024.dta, clear

* Il dataset ha shape: anno_t0, agegr (1534/3554/55), u_e (rates), unempl_t0 (counts)
* Verificare presenza di unempl_t0 per gruppo
cap confirm var unempl_t01534
if _rc {
    di as error "NOTA: Le numerosità di disoccupazione per età non sono nel dataset."
    di as error "Per produrre Fig 11B con decomposizione per età è necessario"
    di as error "modificare cr_job_findings_panel_rates.do aggiungendo:"
    di as error "  'keep unempl_t0 ui_e u_e e_ui e_u i_u u_i e_i i_e anno_t0 agegr'"
    di as error "prima del reshape wide."
    di as error "Procedendo con la decomposizione per durata (breve/lungo periodo)."
    local use_age = 0
}
else {
    local use_age = 1
}

if `use_age' == 1 {
    * Ricostruisce quote per età dal dataset per gruppi
    gen total_unempl = unempl_t01534 + unempl_t03554 + unempl_t055
    gen omega_1534   = unempl_t01534 / total_unempl
    gen omega_3554   = unempl_t03554 / total_unempl
    gen omega_55     = unempl_t055   / total_unempl

    * Finding rate aggregato implicito dalle quote e dai tassi per gruppo
    gen f_agg_implicit = omega_1534*u_e1534_q1only + omega_3554*u_e3554_q1only + omega_55*u_e55_q1only

    * Media pre-crisi delle quote
    quietly summ omega_1534 if anno_t0 <= 2007;  local om1534_bar = r(mean)
    quietly summ omega_3554 if anno_t0 <= 2007;  local om3554_bar = r(mean)
    quietly summ omega_55   if anno_t0 <= 2007;  local om55_bar   = r(mean)

    * CF1: composizione fissa al pre-crisi, within-group rates variano
    gen f_cf_omega_bar = `om1534_bar'*u_e1534_q1only + ///
                         `om3554_bar'*u_e3554_q1only + ///
                         `om55_bar'  *u_e55_q1only

    * Media pre-crisi dei within-group rates
    quietly summ u_e1534_q1only if anno_t0 <= 2007;  local f1534_bar = r(mean)
    quietly summ u_e3554_q1only if anno_t0 <= 2007;  local f3554_bar = r(mean)
    quietly summ u_e55_q1only   if anno_t0 <= 2007;  local f55_bar   = r(mean)

    * CF2: within-group rates fissi al pre-crisi, composizione varia
    gen f_cf_f_bar = omega_1534*`f1534_bar' + omega_3554*`f3554_bar' + omega_55*`f55_bar'

    * Merge con dataset principale per separazione e UR osservato
    rename anno_t0 anno_t1
    merge 1:1 anno_t1 using ${dta}/data_jvr_u_transitions_2004_2025.dta, ///
        keepusing(ur e_u_q1only ur_ss2) nogen
    rename anno_t1 anno

    * UR controfattuale: solo composizione varia (within-group rates al pre-crisi)
    gen ur_cf11b_rates_bar = 100 * e_u_q1only / (e_u_q1only + f_cf_f_bar)
    * UR controfattuale: solo within-group rates variano (composizione al pre-crisi)
    gen ur_cf11b_omega_bar = 100 * e_u_q1only / (e_u_q1only + f_cf_omega_bar)

    twoway ///
        (line ur                  anno, lcolor(black)     lwidth(medthick)) ///
        (line ur_cf11b_rates_bar  anno, lcolor(navy)      lwidth(medium) lp(longdash)) ///
        (line ur_cf11b_omega_bar  anno, lcolor(cranberry) lwidth(medium) lp(longdash)), ///
        xlabel(2004(2)2025) xtitle("") ///
        ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
        legend(order(1 "Osservato" ///
                     2 "CF: solo rates per età variano" ///
                     3 "CF: solo composizione per età varia") row(2)) ///
        graphregion(color(white)) plotregion(color(white)) ///
        name(fig11b_age, replace)
    *graph export ${graphs}/fig11_pannello_b_eta.png, replace

    preserve
        keep anno ur ur_cf11b_rates_bar ur_cf11b_omega_bar ///
                  f_agg_implicit f_cf_omega_bar f_cf_f_bar omega_1534 omega_3554 omega_55
        sort anno
        label var anno                  "Anno"
        label var ur                    "Tasso disoccupazione osservato (%)"
        label var ur_cf11b_rates_bar    "CF: rates per età al pre-crisi (compos. varia)"
        label var ur_cf11b_omega_bar    "CF: composizione per età al pre-crisi (rates variano)"
        label var f_agg_implicit        "Finding rate aggregato implicito"
        label var f_cf_omega_bar        "Finding CF: composizione pre-crisi"
        label var f_cf_f_bar            "Finding CF: rates pre-crisi"
        label var omega_1534            "Quota 15-34 anni in disoccupazione"
        label var omega_3554            "Quota 35-54 anni in disoccupazione"
        label var omega_55              "Quota 55+ anni in disoccupazione"
        export excel using "`figfile'", sheet("Fig11_pannello_b_eta") sheetreplace firstrow(varlabels)
    restore
}

/*==============================================================================
 Parte 2: decomposizione per durata (breve/lungo periodo)
 Fonte: ltshare (quota LT ≥12m) e u_e_q1only (finding aggregato)
 Calibrazione: ρ = f_LT / f_ST (rapporto tra finding rate LT e ST)
   → stimato imponendo che il finding rate aggregato sia consistente con
     la quota LT osservata, o calibrato a ρ = 0.15 (valore plausibile per IT)
==============================================================================*/

use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear
tsset anno

* Rapporto di finding rates: LT vs ST (calibrato)
* f_t = (1-λ_t)·f_ST_t + λ_t·f_LT_t = [(1-λ_t) + ρ·λ_t]·f_ST_t
* → f_ST_t = f_t / [(1-λ_t) + ρ·λ_t]
* → f_LT_t = ρ·f_ST_t

foreach rho in 0.10 0.15 0.25 {
    local rholbl : di %02.0f `rho'*100

    * Quota LT normalizzata (0-1)
    gen lts = ltshare/100

    * Finding rates per gruppo
    gen fST_rho`rholbl' = u_e_q1only / ((1-lts) + `rho'*lts)
    gen fLT_rho`rholbl' = `rho' * fST_rho`rholbl'

    * Media pre-crisi della quota LT
    quietly summ lts if anno <= 2007
    local lts_bar07 = r(mean)
    quietly summ lts if anno <= 2019
    local lts_bar19 = r(mean)

    * CF: composizione LT al pre-crisi (2004-07), within-group rates variano
    gen f_cf_lt07_rho`rholbl' = (1-`lts_bar07')*fST_rho`rholbl' + `lts_bar07'*fLT_rho`rholbl'
    gen ur_cf_lt07_rho`rholbl' = 100 * e_u_q1only / (e_u_q1only + f_cf_lt07_rho`rholbl')

    * CF: composizione LT al pre-crisi (2004-19)
    gen f_cf_lt19_rho`rholbl' = (1-`lts_bar19')*fST_rho`rholbl' + `lts_bar19'*fLT_rho`rholbl'
    gen ur_cf_lt19_rho`rholbl' = 100 * e_u_q1only / (e_u_q1only + f_cf_lt19_rho`rholbl')

    drop lts fST_rho`rholbl' fLT_rho`rholbl' f_cf_lt07_rho`rholbl' f_cf_lt19_rho`rholbl'
    * (mantieni solo i UR controfattuali per il plot)
}

* Ricostruisce le serie per il grafico (ρ = 0.15 come caso base)
local rho = 0.15
local rholbl : di %02.0f `rho'*100

gen lts = ltshare/100
gen fST  = u_e_q1only / ((1-lts) + `rho'*lts)
gen fLT  = `rho' * fST

quietly summ lts if anno <= 2007;  local lts_bar07 = r(mean)
quietly summ lts if anno <= 2019;  local lts_bar19 = r(mean)

gen f_cf_lt_07 = (1-`lts_bar07')*fST + `lts_bar07'*fLT
gen f_cf_lt_19 = (1-`lts_bar19')*fST + `lts_bar19'*fLT

gen ur_cf_lt_07 = 100 * e_u_q1only / (e_u_q1only + f_cf_lt_07)
gen ur_cf_lt_19 = 100 * e_u_q1only / (e_u_q1only + f_cf_lt_19)

twoway ///
    (line ur            anno, lcolor(black)     lwidth(medthick)) ///
    (line ur_cf_lt_07   anno, lcolor(navy)      lwidth(medium) lp(longdash)) ///
    (line ur_cf_lt_19   anno, lcolor(cranberry) lwidth(medium) lp(shortdash)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
    note("Calibrazione: f_LT/f_ST = `rho'") ///
    legend(order(1 "Osservato" ///
                 2 "CF: quota LT al 2004-07" ///
                 3 "CF: quota LT al 2004-19") row(2)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig11b_lt, replace)
*graph export ${graphs}/fig11_pannello_b_lt.png, replace

* Sensitività a ρ (confronto ρ = 0.10, 0.15, 0.25)
twoway ///
    (line ur                     anno, lcolor(black)         lwidth(medthick)) ///
    (line ur_cf_lt07_rho10       anno, lcolor(navy)          lwidth(medium) lp(dot)) ///
    (line ur_cf_lt07_rho15       anno, lcolor(navy)          lwidth(medium) lp(longdash)) ///
    (line ur_cf_lt07_rho25       anno, lcolor(navy)          lwidth(medium) lp(dash)), ///
    xlabel(2004(2)2025) xtitle("") ///
    ytitle("Tasso di disoccupazione (%)") ylab(, angle(0)) ///
    legend(order(1 "Osservato" ///
                 2 "CF (quota LT 04-07, ρ=0.10)" ///
                 3 "CF (quota LT 04-07, ρ=0.15)" ///
                 4 "CF (quota LT 04-07, ρ=0.25)") row(2)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig11b_lt_sensit, replace)
*graph export ${graphs}/fig11_pannello_b_lt_sensit.png, replace

preserve
    keep anno ur ltshare ltur ///
              ur_cf_lt_07 ur_cf_lt_19 ///
              ur_cf_lt07_rho10 ur_cf_lt07_rho15 ur_cf_lt07_rho25 ///
              ur_cf_lt19_rho10 ur_cf_lt19_rho15 ur_cf_lt19_rho25
    sort anno
    label var anno                  "Anno"
    label var ur                    "Tasso disoccupazione osservato (%)"
    label var ltshare               "Quota disoccupazione LT (≥12m, %)"
    label var ltur                  "Tasso disoccupazione LT (≥12m, %)"
    label var ur_cf_lt_07           "CF: quota LT al 2004-07 (ρ=0.15)"
    label var ur_cf_lt_19           "CF: quota LT al 2004-19 (ρ=0.15)"
    label var ur_cf_lt07_rho10      "CF: quota LT al 2004-07 (ρ=0.10)"
    label var ur_cf_lt07_rho15      "CF: quota LT al 2004-07 (ρ=0.15)"
    label var ur_cf_lt07_rho25      "CF: quota LT al 2004-07 (ρ=0.25)"
    label var ur_cf_lt19_rho10      "CF: quota LT al 2004-19 (ρ=0.10)"
    label var ur_cf_lt19_rho15      "CF: quota LT al 2004-19 (ρ=0.15)"
    label var ur_cf_lt19_rho25      "CF: quota LT al 2004-19 (ρ=0.25)"
    export excel using "`figfile'", sheet("Fig11_pannello_b_LT") sheetreplace firstrow(varlabels)
restore

drop lts fST fLT f_cf_lt_07 f_cf_lt_19 ur_cf_lt_*
