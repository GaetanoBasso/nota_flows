clear
set more off
capture log close
set scheme s1color

global home         /home/group/main/892fl/pubblicazioni/RelazioneAnnuale/sul_2025/capitolo_7_lavoro
global do           ${home}/PROG
global dta    	    ${home}/DTA
global graphs       ${home}/GRAPHS
global source       /home/group/main/rdc/private/FLAV/dati/longitudinali/annuali
global source2      /home/group/main/892fl/dati/istat
global source3      /home/group/main/rdc/private/FLAV/dati/wave 	

*** Data creation
do ${do}/cr_job_findings_panel_rates.do
do ${do}/cr_unem.do

*** Analysis
do ${do}/an_graphs_findings_separations.do
do ${do}/an_beveridge_curve_yearly.do
do ${do}/an_efficiency.do
