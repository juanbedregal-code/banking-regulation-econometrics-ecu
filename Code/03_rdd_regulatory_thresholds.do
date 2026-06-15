/*==============================================================================
PROYECTO: Inclusión Financiera y Riesgo en Ecuador (2017-2024)
SCRIPT 03: REGRESIÓN DISCONTINUA (SHARP RDD Y MCCRARY TESTS)
AUTOR: Juan José Bedregal
==============================================================================*/
clear all
global clean   "../Data/Cleaned"
global interim "../Data/Interim"
global tabs    "../Outputs/Tables"
global figs    "../Outputs/Figures"

use "$clean/FINANCIAL_PANEL_CLEAN.dta", clear
keep if coop == 1 

global covs_rdd_clean "desempleo log_m1"

* Variables Centradas
gen act_cen_80 = activos_millones - 80
gen act_cen_20 = activos_millones - 20
gen act_cen_5  = activos_millones - 5
gen act_cen_60 = activos_millones - 60 // Placebo
gen act_cen_40 = activos_millones - 40 // Placebo

save "$interim/Base_Cooperativas_RDD.dta", replace

* 1. UMBRAL $80 MILLONES (BUNCHING)
preserve
collapse (mean) act_cen_80, by(entidad_id)
rddensity act_cen_80, c(0) kernel(triangular) p(1)
restore

rdplot morosidad_adj act_cen_80 if inrange(act_cen_80, -40, 40), c(0) binselect(qsmv) p(1) graph_options(title("Efecto del Umbral S1 en Morosidad Ajustada") xline(0, lcolor(red) lpattern(dash)))
graph export "$figs/RDD_Plot_80M_Moro_Adj.png", replace width(2000)

est sto clear
rdrobust morosidad_adj act_cen_80, c(0) covs($covs_rdd_clean) kernel(triangular) p(1) bwselect(mserd) vce(cluster entidad_id) all
estadd scalar Bandwidth = e(h_l)
est sto RDD_80_Adj_p1

* 2. UMBRAL $20 MILLONES (SHOCK DE SINCERIDAD)
rdplot morosidad_adj act_cen_20 if inrange(act_cen_20, -5, 5), c(0) binselect(qsmv) p(2) graph_options(title("Efecto Umbral S2 en Morosidad Ajustada") xline(0, lcolor(red) lpattern(dash)))
graph export "$figs/RDD_Plot_20M_Moro_Adj.png", replace width(2000)

rdrobust morosidad_adj act_cen_20, c(0) covs($covs_rdd_clean) kernel(triangular) p(2) bwselect(mserd) vce(cluster entidad_id) all
estadd scalar Bandwidth = e(h_l)
est sto RDD_20_Adj_p2

* 3. UMBRAL $5 MILLONES
rdrobust crec_12m act_cen_5, c(0) covs($covs_rdd_clean) kernel(triangular) p(1) bwselect(mserd) vce(cluster entidad_id) all
estadd scalar Bandwidth = e(h_l)
est sto RDD_5_Crec_p1

* 4. EXPORTACIÓN CONJUNTA DE RESULTADOS RDD
esttab RDD_80_Adj_p1 RDD_20_Adj_p2 RDD_5_Crec_p1 using "$tabs/RDD_Resultados_Globales.rtf", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    stats(Bandwidth N_h_l N_h_r, labels("Ventana (h)" "Obs. Izq." "Obs. Der.")) ///
    mtitle("Umbral $80M (Moro)" "Umbral $20M (Moro)" "Umbral $5M (Crecimiento)") compress

* 5. PRUEBAS PLACEBO
rdrobust morosidad_adj act_cen_60, c(0) covs($covs_rdd_clean) kernel(triangular) p(1) bwselect(mserd) vce(cluster entidad_id) all
estadd scalar Bandwidth = e(h_l)
est sto Placebo_60M
rdrobust desempleo act_cen_80, c(0) kernel(triangular) p(1) bwselect(mserd) vce(cluster entidad_id) all
estadd scalar Bandwidth = e(h_l)
est sto Placebo_Cov_80M

esttab Placebo_60M Placebo_Cov_80M using "$tabs/RDD_Placebos.rtf", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(Bandwidth) compress

disp "Etapa 3 Finalizada."
