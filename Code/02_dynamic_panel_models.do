/*==============================================================================
PROYECTO: Inclusión Financiera y Riesgo en Ecuador (2017-2024)
SCRIPT 02: PANELES DINÁMICOS (DRISCOLL-KRAAY Y GMM)
AUTOR: Juan José Bedregal
==============================================================================*/
clear all
global clean   "../Data/Cleaned"
global tabs    "../Outputs/Tables"
global figs    "../Outputs/Figures"

use "$clean/FINANCIAL_PANEL_CLEAN.dta", clear

* Definición de Macros
global vars_crec "crec_12m crec_12m_sq crec_cov crec_cov_sq crec_post crec_post_sq"
global controles_exo "desempleo log_m1 dummy_covid dummy_postcovid"
global controles_endo "roe liquidez log_activos ratio_pasivo_activo"

* 1. NIVEL GLOBAL (Bracketing)
est sto clear
reg morosidad_adj L(1 2).morosidad_adj $vars_crec $controles_endo $controles_exo, vce(cluster entidad_id)
est sto OLS_Dyn
xtreg morosidad_adj L(1 2).morosidad_adj $vars_crec $controles_endo $controles_exo, fe vce(cluster entidad_id)
est sto FE_Dyn
xtabond2 morosidad_adj L(1 2).morosidad_adj $vars_crec $controles_endo $controles_exo, gmm(L.morosidad_adj $vars_crec $controles_endo, lag(2 3) collapse) iv($controles_exo) noleveleq robust twostep small
est sto Diff_GMM
xtabond2 morosidad_adj L(1 2).morosidad_adj $vars_crec $controles_endo $controles_exo, gmm(L.morosidad_adj $vars_crec $controles_endo, lag(2 3) collapse) iv($controles_exo, eq(level)) orthogonal robust twostep small
est sto Sys_GMM
xtscc morosidad_adj L(1 2).morosidad_adj $vars_crec $controles_endo $controles_exo, fe lag(2)
est sto DK_Dyn

esttab OLS_Dyn FE_Dyn Diff_GMM Sys_GMM DK_Dyn using "$tabs/Modelos_Globales.rtf", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) stats(N N_g instruments ar2p hansenp) mtitle("OLS" "FE" "Diff-GMM" "Sys-GMM" "Driscoll-Kraay") compress

* 2. NIVEL BANCARIO VS COOPERATIVO
global vars_n2 "crec_bco_grande crec_bco_grande_sq crec_bco_med crec_bco_med_sq crec_bco_peq crec_bco_peq_sq crec_coop crec_coop_sq"
xtscc morosidad_adj L(1 2).morosidad_adj $vars_n2 $controles_endo $controles_exo, fe lag(2)
est sto DK_N2
esttab DK_N2 using "$tabs/Modelos_Nivel2_Tipo.rtf", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) compress

* 3. NIVEL INTRA-COOPERATIVAS (S1, S2, S3)
preserve
keep if coop == 1
global vars_n3 "crec_coop_s1 crec_coop_s1_sq crec_coop_s2 crec_coop_s2_sq crec_coop_s3 crec_coop_s3_sq"
xtscc morosidad_adj L(1 2).morosidad_adj $vars_n3 $controles_endo $controles_exo, fe lag(2)
est sto DK_N3

esttab DK_N3 using "$tabs/Modelos_Nivel3_Coops.rtf", replace b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) compress

* Cálculo de Umbral Óptimo para Segmento 1 (Forma de U de Moyi)
local b1 = _b[crec_coop_s1]
local b2 = _b[crec_coop_s1_sq]
local umbral_s1 = -`b1' / (2 * `b2')

qui sum morosidad_adj if coop_s1 == 1
local mean_moro = r(mean)
qui sum crec_12m if coop_s1 == 1
local mean_crec = r(mean)
local constante = `mean_moro' - (`b1'*`mean_crec' + `b2'*(`mean_crec'^2))

qui sum crec_12m if coop_s1 == 1
twoway (scatter morosidad_adj crec_12m if coop_s1 == 1, msize(vsmall) color(gs12) msymbol(circle_hollow)) ///
       (function y = `constante' + `b1'*x + `b2'*x^2, range(`r(min)' `r(max)') lcolor(red) lwidth(thick)), ///
       xline(`umbral_s1', lcolor(black) lpattern(dash) lwidth(medthick)) ///
       title("Efecto Causal: Crecimiento vs. Morosidad (Segmento 1)") xtitle("Crecimiento") ytitle("Morosidad") legend(off)
graph export "$figs/Curva_U_Moyi_S1.png", replace width(2000)
restore

disp "Etapa 2 Finalizada."
