/*******************************************************************************
 FIGURA 8 – Beveridge curve (tutti i panel)
 Replicazione di Elsby et al. (2015), JEL 53(3):571-630, Figure 8

 Quattro panel:
   A: tasso posti vacanti (jvr10, imprese 10+)  vs.  UR standard
   B: tasso posti vacanti (jvr10, imprese 10+)  vs.  UR allargato (+ scoraggiati)
   C: tasso posti vacanti (jvr1,  imprese 1+)   vs.  UR standard
   D: tasso posti vacanti (jvr1,  imprese 1+)   vs.  UR allargato (+ scoraggiati)

 Note sulla disponibilità dei dati:
   jvr10 (imprese 10+ addetti): disponibile per tutto il periodo campione
   jvr1  (imprese 1+ addetti):  disponibile dal 2016 (cambio rilevazione ISTAT)
   → Panel C e D prodotti anche per il sottocampione 2016-2025 (analisi principale)

 Colori per periodo:
   Blu     2004-2007 (pre-crisi)
   Verde   2008-2013 (grande recessione)
   Rosso   2014-2019 (ripresa pre-COVID)
   Nero    2020-2025 (COVID e post-COVID)

 Dataset: data_jvr_u_transitions_2004_2025.dta
 Output:  Figure 8.xlsx
*******************************************************************************/

clear
use ${dta}/data_jvr_u_transitions_2004_2025.dta, clear
tsset anno

local figfile "${dta}/../Figure 8.xlsx"

/*==============================================================================
 PANEL A – jvr10 (10+ addetti) vs. tasso di disoccupazione standard
==============================================================================*/

twoway ///
    (scatter jvr10 ur, mlab(y_l) mlabsize(vsmall) mcolor(gs8) msymbol(circle_hollow)) ///
    (line    jvr10 ur if anno >= 2004 & anno <= 2007, lcolor(blue)       sort(anno)) ///
    (line    jvr10 ur if anno >= 2007 & anno <= 2013, lcolor(midgreen)   sort(anno)) ///
    (line    jvr10 ur if anno >= 2013 & anno <= 2020, lcolor(red)        sort(anno)) ///
    (line    jvr10 ur if anno >= 2020 & anno <= 2025, lcolor(black)      sort(anno)), ///
    xtitle("Tasso di disoccupazione (%)") ///
    ytitle("Tasso posti vacanti – imprese 10+ addetti (%)") ///
    legend(order(2 "2004-2007" 3 "2008-2013" 4 "2014-2019" 5 "2020-2025") ///
           row(1) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig8a, replace)
*graph export ${graphs}/fig8_pannello_a.png, replace

/*==============================================================================
 PANEL B – jvr10 (10+ addetti) vs. tasso di disoccupazione allargato
==============================================================================*/

twoway ///
    (scatter jvr10 ur2, mlab(y_l) mlabsize(vsmall) mcolor(gs8) msymbol(circle_hollow)) ///
    (line    jvr10 ur2 if anno >= 2004 & anno <= 2007, lcolor(blue)     sort(anno)) ///
    (line    jvr10 ur2 if anno >= 2007 & anno <= 2013, lcolor(midgreen) sort(anno)) ///
    (line    jvr10 ur2 if anno >= 2013 & anno <= 2020, lcolor(red)      sort(anno)) ///
    (line    jvr10 ur2 if anno >= 2020 & anno <= 2025, lcolor(black)    sort(anno)), ///
    xtitle("Tasso di disoccupazione allargato (incl. scoraggiati, %)") ///
    ytitle("Tasso posti vacanti – imprese 10+ addetti (%)") ///
    legend(order(2 "2004-2007" 3 "2008-2013" 4 "2014-2019" 5 "2020-2025") ///
           row(1) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig8b, replace)
*graph export ${graphs}/fig8_pannello_b.png, replace

/*==============================================================================
 PANEL C – jvr1 (1+ addetti) vs. tasso di disoccupazione standard
 Analisi principale: 2016-2025 (inizio serie jvr1)
 Estensione con splicing: 2004-2025 (per confronto visivo)
==============================================================================*/

* Panel C principale (2016-2025)
twoway ///
    (scatter jvr1 ur if anno >= 2016, mlab(y_l) mlabsize(vsmall) ///
             mcolor(gs8) msymbol(circle_hollow)) ///
    (line    jvr1 ur if anno >= 2016 & anno <= 2019, lcolor(red)   sort(anno)) ///
    (line    jvr1 ur if anno >= 2019 & anno <= 2025, lcolor(black) sort(anno)), ///
    xtitle("Tasso di disoccupazione (%)") ///
    ytitle("Tasso posti vacanti – imprese 1+ addetti (%)") ///
    legend(order(2 "2016-2019" 3 "2020-2025") row(1) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig8c, replace)
*graph export ${graphs}/fig8_pannello_c.png, replace

/*==============================================================================
 PANEL D – jvr1 (1+ addetti) vs. tasso di disoccupazione allargato
 Analisi principale: 2016-2025
==============================================================================*/

twoway ///
    (scatter jvr1 ur2 if anno >= 2016, mlab(y_l) mlabsize(vsmall) ///
             mcolor(gs8) msymbol(circle_hollow)) ///
    (line    jvr1 ur2 if anno >= 2016 & anno <= 2019, lcolor(red)   sort(anno)) ///
    (line    jvr1 ur2 if anno >= 2019 & anno <= 2025, lcolor(black) sort(anno)), ///
    xtitle("Tasso di disoccupazione allargato (incl. scoraggiati, %)") ///
    ytitle("Tasso posti vacanti – imprese 1+ addetti (%)") ///
    legend(order(2 "2016-2019" 3 "2020-2025") row(1) span) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig8d, replace)
*graph export ${graphs}/fig8_pannello_d.png, replace

/*==============================================================================
 Export dati per tutti i panel
==============================================================================*/

preserve
    keep anno ur ur2 jvr10 jvr1
    sort anno
    label var anno   "Anno"
    label var ur     "Tasso di disoccupazione (%)"
    label var ur2    "Tasso disoccupazione allargato (incl. scoraggiati, %)"
    label var jvr10  "Tasso posti vacanti (imprese 10+ addetti, %)"
    label var jvr1   "Tasso posti vacanti (imprese 1+ addetti, %, dal 2016)"
    export excel using "`figfile'", sheet("Fig8_dati") sheetreplace firstrow(varlabels)
restore

/*==============================================================================
 Grafico combinato: confronto jvr10 e jvr1 nell'overlap 2016-2025
==============================================================================*/

twoway ///
    (line jvr10 anno if anno >= 2016, lcolor(navy)     lwidth(medthick)) ///
    (line jvr1  anno if anno >= 2016, lcolor(cranberry) lwidth(medthick)), ///
    xlabel(2016(1)2025) xtitle("") ///
    ytitle("Tasso posti vacanti (%)") ylab(, angle(0)) ///
    legend(order(1 "Imprese 10+ addetti" 2 "Imprese 1+ addetti") row(1)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    name(fig8_jvr_comparison, replace)
*graph export ${graphs}/fig8_confronto_jvr.png, replace

preserve
    keep anno ur ur2 jvr10 jvr1
    keep if anno >= 2016
    sort anno
    label var anno   "Anno"
    label var ur     "Tasso di disoccupazione (%)"
    label var ur2    "Tasso disoccupazione allargato (%)"
    label var jvr10  "Tasso posti vacanti (10+ addetti, %)"
    label var jvr1   "Tasso posti vacanti (1+ addetti, %)"
    export excel using "`figfile'", sheet("Fig8_rob_2016_2025") sheetreplace firstrow(varlabels)
restore
