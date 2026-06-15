/*==============================================================================
PROYECTO: Inclusión Financiera y Riesgo en Ecuador (2017-2024)
SCRIPT 01: DATA CLEANING, WINSORIZATION Y ANÁLISIS EXPLORATORIO
AUTOR: Juan José Bedregal
==============================================================================*/
clear all
set maxvar 20000

* Rutas DIME
global raw     "../Data/Raw"
global clean   "../Data/Cleaned"
global tabs    "../Outputs/Tables"
global figs    "../Outputs/Figures"

* 1. Carga y Limpieza Base
import excel "$raw/ecuador_financial_panel_raw.xlsx", firstrow case(lower) clear
rename indicadormensualdeactividades imaec 

replace nombre = trim(itrim(nombre))
replace tipodeentidad = trim(itrim(tipodeentidad))

gen morosidad = morosidadcarteratotal * 100
gen morosidad_adj = morosidadajustada * 100

gen t_mensual = mofd(mes)
format t_mensual %tmMon-CCYY
encode nombre, gen(entidad_id)
xtset entidad_id t_mensual

* 2. Creación de Variables (Crecimiento, Tamaño, Apalancamiento)
gen log_cartera = ln(carteratotal)
gen crec_12m = log_cartera - L12.log_cartera
gen log_cartera_micro = ln(carteramicro)
gen crec_12_micro = log_cartera_micro - L12.log_cartera_micro

gen log_activos = ln(activos)
gen ratio_pasivo_activo = pasivos / activos
gen activos_millones = activos / 1000000
gen pasivos_millones = pasivos / 1000000
gen log_m1 = ln(m1)
gen dummy_covid = inrange(t_mensual, tm(2020m3), tm(2021m12))

* 3. Winsorización (¡SIN WINSORIZAR ACTIVOS PARA PROTEGER EL RDD!)
winsor2 crec_12m crec_12_micro roe ratio_pasivo_activo, cuts(1 99) replace
winsor2 morosidad morosidad_adj liquidez, cuts(0 98) replace

* 4. Interacciones y Segmentación
gen crec_12m_sq = crec_12m^2
gen crec_12_micro_sq = crec_12_micro^2

gen bco_grande = (tipodeentidad == "BANCOS PRIVADOS GRANDES")
gen bco_med    = (tipodeentidad == "BANCOS PRIVADOS MEDIANOS")
gen bco_peq    = (tipodeentidad == "BANCOS PRIVADOS PEQUEÑOS")
gen coop       = inlist(tipodeentidad, "COOPERATIVA S1", "COOPERATIVA S2", "COOPERATIVA S3")
gen coop_s1 = (tipodeentidad == "COOPERATIVA S1")
gen coop_s2 = (tipodeentidad == "COOPERATIVA S2")
gen coop_s3 = (tipodeentidad == "COOPERATIVA S3")

foreach grp in bco_grande bco_med bco_peq coop coop_s1 coop_s2 coop_s3 {
    gen crec_`grp'    = crec_12m * `grp'
    gen crec_`grp'_sq = crec_12m_sq * `grp'
}

gen dummy_postcovid = inrange(t_mensual, tm(2022m1), tm(2024m12))
gen crec_cov = crec_12m * dummy_covid
gen crec_cov_sq = crec_12m_sq * dummy_covid
gen crec_post = crec_12m * dummy_postcovid
gen crec_post_sq = crec_12m_sq * dummy_postcovid

* 5. Estadísticas Descriptivas (Exportación)
estpost tabstat morosidad morosidad_adj crec_12m crec_12_micro roe liquidez ratio_pasivo_activo activos_millones pasivos_millones desempleo log_m1, c(stat) stat(mean sd min p50 max n) 
esttab using "$tabs/Estadisticas_Descriptivas.rtf", replace cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(fmt(3)) max(fmt(3)) count(fmt(0))") title("Estadísticas Descriptivas del Panel")

estpost correlate morosidad crec_12m roe liquidez ratio_pasivo_activo log_activos desempleo log_m1, matrix
esttab using "$tabs/Matriz_Correlacion.rtf", replace unstack not noobs compress title("Matriz de Correlaciones") star(* 0.05)

* Exportar Base Limpia
compress
save "$clean/FINANCIAL_PANEL_CLEAN.dta", replace
disp "Etapa 1 Finalizada."

¡Y con esto cerramos tu segundo repositorio de alto impacto! Todo está modular, automatizado y listo para correr en cualquier computadora del mundo.
