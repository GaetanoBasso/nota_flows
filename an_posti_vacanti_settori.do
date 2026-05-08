cap mkdir "${figures}/posti_vacanti_settori"
global fig75file "${figures}/dati_per_grafici/Fig_7.5.xlsx"

*** Vacancy rate by sector
use "${jobvac}/DCSC_POSTIVAC_1.dta", clear

keep if correz == "Y" //seasonally adjusted
keep if inlist(ateco_2007,"0037","0011","0020","F","0013","0039","I","J","M")|inlist(ateco_2007,"0015")
replace ateco_2007 = "B_S" if ateco_2007 == "0037"
replace ateco_2007 = "B_F" if ateco_2007 == "0011"
replace ateco_2007 = "B_E" if ateco_2007 == "0020"
replace ateco_2007 = "G_N" if ateco_2007 == "0013"
replace ateco_2007 = "P_S" if ateco_2007 == "0039"
replace ateco_2007 = "BSO" if ateco_2007 == "0015"		// Totale

drop if value == .
gen year = real(substr(time,1,4))
gen quarter = real(substr(time,-1,1))
drop time
gen time = yq(year,quarter)
format time %tq

keep year quarter time value ateco
rename value jvr
reshape wide jvr, i(year quarter time) j(ateco, string)

format time %tq
keep if year>=2019

two line jvrB_E jvrF jvrG_N  jvrI jvrJ jvrM jvrP_S time, lw(0.5 ...) ///
	legend(order(1 "ISS" 2 "Costruzioni" 3 "Servizi privati" ///
	4 "Alloggio e ristorazione" 5 "Informazione e comunicazione" 6 "Att. professionali" 7 "Altri servizi") size(*1) pos(6) ring(1) r(2)) ///
	tline(2019q4) yti("Tasso di posti vacanti") xti("")
graph export "${figures}/figure_711a.png", replace width(2000)

tset time
foreach sfd of varlist jvrF jvrI jvrJ jvrM jvrBSO  {
	tssmooth ma `sfd'_ma = `sfd', window(1 1 1) 
}

*legend(order(1 "Costruzioni" 2 "Alloggio e risto.razione" 3 "Informazione e comunicazione" 4 "Att. professionali, scientifiche e tecniche" 5 "Totale") size(*1) pos(6) ring(1) r(2))
two line jvrF_ma jvrI_ma jvrJ_ma jvrM_ma jvrBSO_ma time, lw(0.5 ...) ///
	legend(order(1 "Costruzioni" 2 "Alloggio e risto."  ///
	3 "ICT" 4 "Att. professionali, scientifiche" 5 "Totale") size(*1) pos(6) ring(1) r(2)) ///
	tline(2019q4) yti("Tasso di posti vacanti") xti("")
graph export "${figures}/posti_vacanti_settori/posti_vacanti_settori.png", replace width(2000)

* export
keep year quarter time jvrB_E jvrF jvrG_N jvrP_S jvrB_S
order year quarter time jvrB_E jvrF jvrG_N jvrP_S jvrB_S
la var year "Anno"
la var quarter "Trimestre"
la var time "Time"
la var jvrB_E "ISS"
la var jvrF "Costruzioni"
la var jvrG_N "Servizi privati"
la var jvrP_S "Altri servizi"
la var jvrB_S "Totale"
export excel using "$fig75file", sheet("pannello a", replace) firstrow(varlabels)

gr drop _all
