********************************************************************************
* NET EMPLOYMENT CHANGES OF YOUNG AND OLD WORKERS
* Full Stata code
* Export tables to Excel instead of tex
********************************************************************************

clear all
set more off

********************************************************************************
* 1. LOAD DATA
********************************************************************************

use "${data}/firm_panel_inps.dta", clear
keep if inrange(anno, 2019, 2024)

isid firm_id anno, sort
xtset firm_id anno

********************************************************************************
* 2. CONSTRUCT NET CHANGES, RATES, AND CONTROLS
********************************************************************************

gen L_emp_firm  = L.emp_firm
gen L_dip_15_34 = L.dip_15_34
gen L_dip_55    = L.dip_55
gen L_dip_f     = L.dip_f
gen L_dip_pt    = L.dip_partime
gen L_dip_det   = L.dip_det
gen L_dip_stag  = L.dip_stag

gen d_young = dip_15_34 - L_dip_15_34
gen d_old   = dip_55    - L_dip_55
gen d_emp   = emp_firm  - L_emp_firm

gen rate_young = d_young / L_emp_firm if L_emp_firm > 0
gen rate_old   = d_old   / L_emp_firm if L_emp_firm > 0
gen rate_emp   = d_emp   / L_emp_firm if L_emp_firm > 0

gen rate_young_own = d_young / L_dip_15_34 if L_dip_15_34 > 0
gen rate_old_own   = d_old   / L_dip_55    if L_dip_55 > 0

gen share_young_lag = L_dip_15_34 / L_emp_firm if L_emp_firm > 0
gen share_old_lag   = L_dip_55    / L_emp_firm if L_emp_firm > 0
gen share_f_lag     = L_dip_f     / L_emp_firm if L_emp_firm > 0
gen share_pt_lag    = L_dip_pt    / L_emp_firm if L_emp_firm > 0
gen share_det_lag   = L_dip_det   / L_emp_firm if L_emp_firm > 0
gen share_stag_lag  = L_dip_stag  / L_emp_firm if L_emp_firm > 0

gen firm_age = anno - year(birthdate) if !missing(birthdate)
replace firm_age = . if firm_age < 0

gen ln_L_emp_firm = ln(L_emp_firm) if L_emp_firm > 0
gen ln_firm_age   = ln(firm_age) if firm_age > 0

egen sector2 = group(ateco07_2), label
egen prov    = group(codprov_inps), label

keep if !missing(d_young, d_old, rate_young, rate_old, L_emp_firm)

********************************************************************************
* 3. WINSORIZE RATES
********************************************************************************

sum rate_young, detail
local p1_y  = r(p1)
local p99_y = r(p99)

sum rate_old, detail
local p1_o  = r(p1)
local p99_o = r(p99)

sum rate_emp, detail
local p1_e  = r(p1)
local p99_e = r(p99)

gen rate_young_w = rate_young
replace rate_young_w = `p1_y'  if rate_young < `p1_y'  & !missing(rate_young)
replace rate_young_w = `p99_y' if rate_young > `p99_y' & !missing(rate_young)

gen rate_old_w = rate_old
replace rate_old_w = `p1_o'  if rate_old < `p1_o'  & !missing(rate_old)
replace rate_old_w = `p99_o' if rate_old > `p99_o' & !missing(rate_old)

gen rate_emp_w = rate_emp
replace rate_emp_w = `p1_e'  if rate_emp < `p1_e'  & !missing(rate_emp)
replace rate_emp_w = `p99_e' if rate_emp > `p99_e' & !missing(rate_emp)

********************************************************************************
* 4. CREATE EXCEL FILE
********************************************************************************

local xlsxfile "${tables}/net_changes_young_old.xlsx"
cap erase "`xlsxfile'"

********************************************************************************
* 5. DESCRIPTIVE STATISTICS -> EXCEL
********************************************************************************

putexcel set "`xlsxfile'", replace sheet("sumstats")

putexcel A1 = "Variable" ///
        B1 = "N" ///
        C1 = "Mean" ///
        D1 = "SD" ///
        E1 = "Min" ///
        F1 = "P50" ///
        G1 = "Max"

local vars ///
    d_young d_old d_emp ///
    rate_young rate_old rate_emp ///
    rate_young_w rate_old_w rate_emp_w ///
    rate_young_own rate_old_own ///
    L_emp_firm ln_L_emp_firm firm_age ln_firm_age ///
    share_young_lag share_old_lag share_f_lag ///
    share_pt_lag share_det_lag share_stag_lag

local r = 2
foreach v of local vars {
    quietly sum `v', detail
    putexcel A`r' = "`v'" ///
            B`r' = (r(N)) ///
            C`r' = (r(mean)) ///
            D`r' = (r(sd)) ///
            E`r' = (r(min)) ///
            F`r' = (r(p50)) ///
            G`r' = (r(max))
    local ++r
}

putexcel A1:G1, bold border(bottom)
putexcel B2:G`=`r'-1', nformat(number_d2)

********************************************************************************
* 6. CORRELATION TABLE -> EXCEL
********************************************************************************

putexcel set "`xlsxfile'", modify sheet("correlations")

local corrvars d_young d_old rate_young rate_old rate_emp
local nvars : word count `corrvars'

forvalues i = 1/`nvars' {
    local vi : word `i' of `corrvars'
    putexcel `=char(64+`i'+1)'1 = "`vi'"
    putexcel A`=`i'+1' = "`vi'"
}

matrix C = J(`nvars', `nvars', .)

forvalues i = 1/`nvars' {
    local vi : word `i' of `corrvars'
    forvalues j = 1/`nvars' {
        local vj : word `j' of `corrvars'
        quietly corr `vi' `vj'
        matrix C[`i',`j'] = r(rho)
    }
}

putexcel B2 = matrix(C), nformat(number_d3)
putexcel A1:`=char(64+`nvars'+1)'1, bold border(bottom)
putexcel A1:A`=`nvars'+1', bold

********************************************************************************
* 7. TIME SERIES OF MEANS -> EXCEL + GRAPHS
********************************************************************************

preserve
collapse ///
    (mean) d_young d_old rate_young rate_old rate_young_w rate_old_w ///
    (count) N = d_young, ///
    by(anno)

putexcel set "`xlsxfile'", modify sheet("means_by_year")

putexcel A1 = "anno" ///
        B1 = "mean_d_young" ///
        C1 = "mean_d_old" ///
        D1 = "mean_rate_young" ///
        E1 = "mean_rate_old" ///
        F1 = "mean_rate_young_w" ///
        G1 = "mean_rate_old_w" ///
        H1 = "N"

forvalues i = 1/`=_N' {
    local rr = `i' + 1
    putexcel A`rr' = (anno[`i']) ///
            B`rr' = (d_young[`i']) ///
            C`rr' = (d_old[`i']) ///
            D`rr' = (rate_young[`i']) ///
            E`rr' = (rate_old[`i']) ///
            F`rr' = (rate_young_w[`i']) ///
            G`rr' = (rate_old_w[`i']) ///
            H`rr' = (N[`i'])
}

putexcel A1:H1, bold border(bottom)
putexcel B2:G`=_N+1', nformat(number_d4)
putexcel H2:H`=_N+1', nformat(number_sep)

twoway ///
    (connected d_young anno, msymbol(O)) ///
    (connected d_old anno, msymbol(D)), ///
    xlabel(2020(1)2024) ///
    xtitle("Year") ///
    ytitle("Average net employment change") ///
    legend(order(1 "Young 15-34" 2 "Old 55+")) ///
    graphregion(color(white)) ///
    name(gr_levels, replace)
graph export "${figures}/young_old_flows/avg_net_changes_levels_young_old.png", replace

twoway ///
    (connected rate_young anno, msymbol(O)) ///
    (connected rate_old anno, msymbol(D)), ///
    xlabel(2020(1)2024) ///
    xtitle("Year") ///
    ytitle("Average net change / lagged employment") ///
    legend(order(1 "Young 15-34" 2 "Old 55+")) ///
    graphregion(color(white)) ///
    name(gr_rates, replace)
graph export "${figures}/young_old_flows/avg_net_changes_rates_young_old.png", replace
restore

********************************************************************************
* 8. SCATTER PLOTS
********************************************************************************
binscatter d_old d_young, ///
    xtitle("Net change young workers") ///
    ytitle("Net change old workers") 
    
graph export "${figures}/young_old_flows/scatter_net_changes_levels_all.png", replace

binscatter rate_old_w rate_young_w, ///
    xtitle("Young net change rate") ///
    ytitle("Old net change rate") 

graph export "${figures}/young_old_flows/scatter_net_changes_rates_all.png", replace

********************************************************************************
* 9. STATIC REGRESSIONS
********************************************************************************
reghdfe d_old d_young, absorb(anno) vce(cluster firm_id)
estimates store m1

reghdfe d_old d_young ///
    ln_L_emp_firm ln_firm_age ///
    share_young_lag share_old_lag share_f_lag ///
    share_pt_lag share_det_lag share_stag_lag ///
    i.still_open, ///
    absorb(anno sector2 prov) ///
    vce(cluster firm_id)
estimates store m2

reghdfe d_old d_young ///
    ln_L_emp_firm ln_firm_age ///
    share_young_lag share_old_lag share_f_lag ///
    share_pt_lag share_det_lag share_stag_lag ///
    i.still_open, ///
    absorb(firm_id anno) ///
    vce(cluster firm_id)
estimates store m3

reghdfe rate_old_w rate_young_w, absorb(anno) vce(cluster firm_id)
estimates store m4

reghdfe rate_old_w rate_young_w ///
    ln_L_emp_firm ln_firm_age ///
    share_young_lag share_old_lag share_f_lag ///
    share_pt_lag share_det_lag share_stag_lag ///
    i.still_open, ///
    absorb(anno sector2 prov) ///
    vce(cluster firm_id)
estimates store m5

reghdfe rate_old_w rate_young_w ///
    ln_L_emp_firm ln_firm_age ///
    share_young_lag share_old_lag share_f_lag ///
    share_pt_lag share_det_lag share_stag_lag ///
    i.still_open, ///
    absorb(firm_id anno) ///
    vce(cluster firm_id)
estimates store m6

reghdfe rate_old_w rate_young_w rate_emp_w ///
    ln_L_emp_firm ln_firm_age ///
    share_young_lag share_old_lag share_f_lag ///
    share_pt_lag share_det_lag share_stag_lag ///
    i.still_open, ///
    absorb(firm_id anno) ///
    vce(cluster firm_id)
estimates store m7

********************************************************************************
* 10. EXPORT REGRESSIONS TO EXCEL
********************************************************************************

putexcel set "`xlsxfile'", modify sheet("regressions")

putexcel A1 = "Variable" ///
        B1 = "m1" C1 = "m2" D1 = "m3" E1 = "m4" F1 = "m5" G1 = "m6" H1 = "m7"

local row = 2
local regvars d_young rate_young_w rate_emp_w ln_L_emp_firm ln_firm_age ///
              share_young_lag share_old_lag share_f_lag ///
              share_pt_lag share_det_lag share_stag_lag 1.still_open

foreach v of local regvars {
    putexcel A`row' = "`v'"
    
    forvalues m = 1/7 {
        quietly estimates restore m`m'
        capture local b  = _b[`v']
        capture local se = _se[`v']
        
        if _rc == 0 {
            putexcel `=char(65+`m')'`row'     = (`b')
            putexcel `=char(65+`m')'`=`row'+1' = (`se')
        }
    }
    
    local row = `row' + 2
}

* Add N and R2
putexcel A`row' = "N"
forvalues m = 1/7 {
    quietly estimates restore m`m'
    putexcel `=char(65+`m')'`row' = (e(N))
}
local ++row

putexcel A`row' = "R2"
forvalues m = 1/7 {
    quietly estimates restore m`m'
    capture putexcel `=char(65+`m')'`row' = (e(r2))
}

putexcel A1:H1, bold border(bottom)
putexcel B2:H`row', nformat(number_d4)

********************************************************************************
* 11. YEAR-BY-YEAR REGRESSIONS
********************************************************************************

tempfile coeffs_by_year
tempname posth

postfile `posth' ///
    int anno ///
    double beta se lb ub N ///
    using `coeffs_by_year', replace

levelsof anno, local(years)

foreach y of local years {

    quietly reghdfe rate_old_w rate_young_w ///
        ln_L_emp_firm ln_firm_age ///
        share_young_lag share_old_lag share_f_lag ///
        share_pt_lag share_det_lag share_stag_lag ///
        i.still_open ///
        if anno == `y', ///
        absorb(sector2 prov) ///
        vce(cluster firm_id)

    local b  = _b[rate_young_w]
    local se = _se[rate_young_w]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    local NN = e(N)

    post `posth' (`y') (`b') (`se') (`lb') (`ub') (`NN')
}

postclose `posth'

use `coeffs_by_year', clear

putexcel set "`xlsxfile'", modify sheet("coef_by_year")

putexcel A1 = "anno" ///
        B1 = "beta" ///
        C1 = "se" ///
        D1 = "lb_95" ///
        E1 = "ub_95" ///
        F1 = "N"

forvalues i = 1/`=_N' {
    local rr = `i' + 1
    putexcel A`rr' = (anno[`i']) ///
            B`rr' = (beta[`i']) ///
            C`rr' = (se[`i']) ///
            D`rr' = (lb[`i']) ///
            E`rr' = (ub[`i']) ///
            F`rr' = (N[`i'])
}

putexcel A1:F1, bold border(bottom)
putexcel B2:E`=_N+1', nformat(number_d4)
putexcel F2:F`=_N+1', nformat(number_sep)

twoway ///
    (rcap lb ub anno) ///
    (connected beta anno, msymbol(O)), ///
    yline(0, lpattern(dash)) ///
    xlabel(2020(1)2024) ///
    xtitle("Year") ///
    ytitle("Coefficient on young net change rate") ///
    graphregion(color(white)) ///
    legend(off) ///
    name(beta_by_year, replace)

graph export "${figures}/young_old_flows/coef_by_year_old_on_young.png", replace

********************************************************************************
* 12. OPTIONAL: DYNAMIC SINGLE-REGRESSION SPECIFICATION
********************************************************************************

use "${data}/firm_panel_inps.dta", clear
keep if inrange(anno, 2019, 2024)

isid firm_id anno, sort
xtset firm_id anno

gen L_emp_firm  = L.emp_firm
gen L_dip_15_34 = L.dip_15_34
gen L_dip_55    = L.dip_55
gen L_dip_f     = L.dip_f
gen L_dip_pt    = L.dip_partime
gen L_dip_det   = L.dip_det
gen L_dip_stag  = L.dip_stag

gen d_young = dip_15_34 - L.dip_15_34
gen d_old   = dip_55    - L.dip_55
gen d_emp   = emp_firm  - L.emp_firm

gen rate_young = d_young / L.emp_firm if L.emp_firm > 0
gen rate_old   = d_old   / L.emp_firm if L.emp_firm > 0
gen rate_emp   = d_emp   / L.emp_firm if L.emp_firm > 0

sum rate_young, detail
local p1_y  = r(p1)
local p99_y = r(p99)

sum rate_old, detail
local p1_o  = r(p1)
local p99_o = r(p99)

sum rate_emp, detail
local p1_e  = r(p1)
local p99_e = r(p99)

gen rate_young_w = rate_young
replace rate_young_w = `p1_y'  if rate_young < `p1_y'  & !missing(rate_young)
replace rate_young_w = `p99_y' if rate_young > `p99_y' & !missing(rate_young)

gen rate_old_w = rate_old
replace rate_old_w = `p1_o'  if rate_old < `p1_o'  & !missing(rate_old)
replace rate_old_w = `p99_o' if rate_old > `p99_o' & !missing(rate_old)

gen rate_emp_w = rate_emp
replace rate_emp_w = `p1_e'  if rate_emp < `p1_e'  & !missing(rate_emp)
replace rate_emp_w = `p99_e' if rate_emp > `p99_e' & !missing(rate_emp)

gen share_young_lag = L.dip_15_34 / L.emp_firm if L.emp_firm > 0
gen share_old_lag   = L.dip_55    / L.emp_firm if L.emp_firm > 0
gen share_f_lag     = L.dip_f     / L.emp_firm if L.emp_firm > 0
gen share_pt_lag    = L.dip_partime / L.emp_firm if L.emp_firm > 0
gen share_det_lag   = L.dip_det   / L.emp_firm if L.emp_firm > 0
gen share_stag_lag  = L.dip_stag  / L.emp_firm if L.emp_firm > 0

gen firm_age = anno - year(birthdate) if !missing(birthdate)
replace firm_age = . if firm_age < 0

gen ln_L_emp_firm = ln(L.emp_firm) if L.emp_firm > 0
gen ln_firm_age   = ln(firm_age) if firm_age > 0

keep if !missing(rate_old_w, rate_young_w, rate_emp_w, L.emp_firm)

reghdfe rate_old_w ib2021.anno##c.rate_young_w ///
    ln_L_emp_firm ln_firm_age ///
    share_young_lag share_old_lag share_f_lag ///
    share_pt_lag share_det_lag share_stag_lag ///
    i.still_open, ///
    absorb(firm_id anno) ///
    vce(cluster firm_id)

tempfile coeffs_interacted
tempname posth2

postfile `posth2' ///
    int anno ///
    double beta se lb ub ///
    using `coeffs_interacted', replace

lincom rate_young_w
post `posth2' (2021) (r(estimate)) (r(se)) (r(lb)) (r(ub))

lincom rate_young_w + 2020.anno#c.rate_young_w
post `posth2' (2020) (r(estimate)) (r(se)) (r(lb)) (r(ub))

lincom rate_young_w + 2022.anno#c.rate_young_w
post `posth2' (2022) (r(estimate)) (r(se)) (r(lb)) (r(ub))

lincom rate_young_w + 2023.anno#c.rate_young_w
post `posth2' (2023) (r(estimate)) (r(se)) (r(lb)) (r(ub))

lincom rate_young_w + 2024.anno#c.rate_young_w
post `posth2' (2024) (r(estimate)) (r(se)) (r(lb)) (r(ub))

postclose `posth2'

use `coeffs_interacted', clear
sort anno

putexcel set "`xlsxfile'", modify sheet("coef_dynamic_interacted")

putexcel A1 = "anno" ///
        B1 = "beta" ///
        C1 = "se" ///
        D1 = "lb_95" ///
        E1 = "ub_95"

forvalues i = 1/`=_N' {
    local rr = `i' + 1
    putexcel A`rr' = (anno[`i']) ///
            B`rr' = (beta[`i']) ///
            C`rr' = (se[`i']) ///
            D`rr' = (lb[`i']) ///
            E`rr' = (ub[`i'])
}

putexcel A1:E1, bold border(bottom)
putexcel B2:E`=_N+1', nformat(number_d4)

twoway ///
    (rcap lb ub anno) ///
    (connected beta anno, msymbol(O)), ///
    yline(0, lpattern(dash)) ///
    xlabel(2020(1)2024) ///
    xtitle("Year") ///
    ytitle("Coefficient on young net change rate") ///
    graphregion(color(white)) ///
    legend(off) ///
    name(beta_interacted, replace)

graph export "${figures}/young_old_flows/coef_dynamic_interacted_old_on_young.png", replace
