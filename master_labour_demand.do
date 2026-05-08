clear
set more off
capture log close
set scheme s1color

global home         /home/group/main/892fl/pubblicazioni/RelazioneAnnuale/sul_2025/capitolo_7_lavoro
global do           ${home}/PROG
global dta    	    ${home}/DTA
global graphs       ${home}/GRAPHS
global figures      ${home}/FIGURE_EXCEL          /* cartella output Excel per le figure */
global source       /home/group/main/rdc/private/FLAV/dati/longitudinali/annuali
global source2      /home/group/main/892fl/dati/istat
global source3      /home/group/main/rdc/private/FLAV/dati/wave

*** Data creation
do ${do}/cr_job_findings_panel_rates.do
do ${do}/cr_unem.do

*** Analisi – Figure Elsby et al. (2015)
* Fig 1 (A,B) e Fig 3 (A,B): flussi U-E/E-U e UR controfattuale (2 e 3 flussi)
do ${do}/an_fig1_3.do

* Fig 8 (tutti i panel): Beveridge curve con misure alternative di vacancies e UR
do ${do}/an_fig8.do

* Fig 9 (A,B): tightness e Beveridge curve controfattuale
do ${do}/an_fig9.do

* Fig 10 (A,C,D): funzione di matching, efficienza e UR controfattuale
do ${do}/an_fig10.do

* Fig 11 (A,B): composizione della disoccupazione e UR controfattuale aggiustato
do ${do}/an_fig11.do

*** Analisi aggiuntive (bozze precedenti, mantenute per riferimento)
*do ${do}/an_graphs_findings_separations.do
*do ${do}/an_beveridge_curve_yearly.do
*do ${do}/an_efficiency.do
