/* Forecasting Traded Volume */

*Loading Data

set more off
set matsize 5000

cd "C:\Users\jc.meneses1480\Documents\Federico Filippini\Series Desestacionalizadas\BVC Número de Operaciones\FINAL DATASET"
use main_111.dta, clear
/*******************************************************************
****************************** DATA ********************************
*******************************************************************/

keep if year > 2004
drop if year == 2015 & Month > 10
drop if year == 2005 & Month < 6
/*Variables:
*
*1- Oil: WTI, BRENT - in US$
*2- Ext_Curr: DXY, LACIX - indexes
*3- Dom_Curr: TRM, ITCRA, ITCR_US, TOTX, 
*4- Inf_Exp: Exp_Inflacion12 Exp_InflacionD Inf_Exp3
*5- ER_Exp: Exp_TRMM Exp_TRM12 Exp_TRMD
*6- Conf: EOF_ACCIONES* EOF_BR* EOF_SPREAD* EOF_TRM*
*7- Prod: IMACO IPRIM IPI
*8- Int: BrRATE DTF
*9- Risk: RiesgoPais*/
*10  PE Ratio : Colcap & IGBC PE Ratio

*#delimit;
gen LACIX = 1/LACI*10000
gen TOTX = 1/TOT*10000*1.5
gen TOTX2= 1/TOTciti*10000*.5
gen Inf_Exp3 = Exp_InflacionM*10

/*******************************************************************
***************PRINCIPAL COMPONENT ANALYSIS*************************
*******************************************************************/

/*1- Oil
*pca  WTI BRENT*/
pca  WTI BRENT
predict OIL_COMP1 OIL_COMP2, score  
label var WTI "WTI Oil Price (in US$)"
label var BRENT "BRENT Oil Price (in US$)"
label var OIL_COMP1 "Oil Component 1"
label var OIL_COMP2 "Oil Component 2"
/*tsline WTI, yaxis(1) || tsline BRENT, yaxis(1)|| tsline OIL_COMP, yaxis(2) title("Group 1: Oil Price")*/

/*2- Ext_Curr*/
tsline DXY LACIX
pca  DXY LACIX
predict Ext_Curr_COMP1 Ext_Curr_COMP2, score  
label var DXY "Dolar Index"
label var LACIX "(Inverse) LAC Currency Index"
/*label var Ext_Curr_COMP "Ext_Curr"
tsline DXY, yaxis(1) || tsline LACIX, yaxis(1)|| tsline Ext_Curr_COMP, yaxis(2) title("Group 2: External Currencies")*/

/*3- Dom_Curr*/
tsline TRM, yaxis(1) || tsline ITCR_US ITCRA TOTX TOTX2, yaxis(2)
pca TRM ITCR_US ITCRA TOTX TOTX2 MONTO_DIVISAS
predict Dom_Curr_COMP1 Dom_Curr_COMP2, score  
/*label var Dom_Curr_COMP "Dom_Curr"
tsline TRM, yaxis(1) || tsline Dom_Curr_COMP, yaxis(2) title("Group 3: Domestic Currencies")*/

/*4- Inf_Exp*/
tsline Exp_Inflacion12 Exp_InflacionD Inf_Exp3
pca Exp_Inflacion12 Exp_InflacionD Inf_Exp3
predict Inf_Exp_COMP1 Inf_Exp_COMP2, score  
/*label var Inf_Exp_COMP "Inf_Exp PCA 1st Component"
tsline Exp_Inflacion12 Exp_InflacionD Inf_Exp3, yaxis(1) || tsline Inf_Exp_COMP, yaxis(2) title("Group 4: Inflation Expectations")*/


/*5- ER_Exp*/
tsline Exp_TRMM Exp_TRM12 Exp_TRMD
pca Exp_TRMM Exp_TRM12 Exp_TRMD
predict ER_Exp_COMP1 ER_Exp_COMP2, score  
/*label var ER_Exp_COMP "ER_Exp Inf_Exp PCA 1st Component"
tsline Exp_TRMM Exp_TRM12 Exp_TRMD, yaxis(1) || tsline ER_Exp_COMP, yaxis(2) title("Group 5: Exchange Rate Expectations")*/

/*6- Confidence*/
tsline EOF_ACCIONES1 EOF_BR1 EOF_SPREAD1 EOF_TRM1
pca EOF_ACCIONES1 EOF_BR1 EOF_SPREAD1 EOF_TRM1 EOF_ACCIONES2 EOF_BR2 EOF_SPREAD2 EOF_TRM2
predict EOF_COMP1 EOF_COMP2 EOF_COMP3 EOF_COMP4 EOF_COMP5, score
/*label var EOF_COMP1 "EOF PCA 1st Component"
*label var EOF_COMP2 "EOF PCA 2nd Component"
*label var EOF_COMP3 "EOF PCA 3rd Component"
*label var EOF_COMP4 "EOF PCA 4th Component"
tsline EOF_COMP* title("Group 6: Dispersion in Expectations")*/

/*
/*7- Production*/
tsline IVM IPI || tsline IPRIM, yaxis(2)
pca IVM IPI IPRIM, components(2)
predict PROD_COMP1 PROD_COMP2, score
label var PROD_COMP1 "Prod PCA 1st Component"
label var PROD_COMP2 "Prod PCA 2nd Component"
tsline PROD_COMP1 || tsline IVM IPI IPRIM, yaxis(2)
/*tsline PROD_COMP*, title("Group 7: Production")*/
*/

 
/*8- Interest Rates*/
egen mean_BrRATE = mean(BrRATE)
gen INT_COMP1 = BrRATE - mean_BrRATE
egen mean_DTF = mean(DTF)
gen INT_COMP2 = DTF - mean_DTF

/*9- Risk*/
egen mean_RiesgoPais = mean(RiesgoPais)
gen RISK_COMP = RiesgoPais - mean_RiesgoPais

/*10-Pe Ratio Stock Index*/
replace COLCAPPESA = IGBC if COLCAPPESA == .
*Note: COLCAP series is equal to IGBC, for PCA. 
tsline COLCAPPESA || tsline IGBCPESA, yaxis(2)
pca COLCAPPES IGBCPESA
predict PERATIO_COMP1 PERATIO_COMP2, score
tsline PERATIO_COMP1 PERATIO_COMP2 || tsline IGBCPESA  COLCAPPESA, yaxis(2)
label var PERATIO_COMP1 "PE Ratio PCA 1st Component"
label var PERATIO_COMP2 "PE Ratio PCA 2nd Component"

/*******************************************************************
*************************** HODRICK-PRESCOTT ***********************
*******************************************************************/

tsfilter hp RentaV_CV_CYCLE = RentaV_CV, trend(RentaV_CV_TREND) smooth(1000)
tsline RentaV_CV_TREND  RentaV_CV

tsfilter hp RentaF_CV_CYCLE = RentaF_CV, trend(RentaF_CV_TREND) smooth(1000)
tsline RentaF_CV_TREND RentaF_CV_CYCLE RentaF_CV 

/* Note that we use a smaller \lambda to capture the fluctuations missed when 
used the canonical \lambda=14400 */
gen RentaV_CV_CYCLEX = RentaV_CV_CYCLE/RentaV_CV_TREND
gen RentaF_CV_CYCLEX = RentaF_CV_CYCLE/RentaF_CV_TREND


/*******************************************************************
*************************** TRANSFORMATION *************************
*******************************************************************/

foreach var of varlist RentaV_CV* RentaF_CV* *_COMP* {
	egen st_`var' = std(`var')
} 

/*******************************************************************
*************************** ESTACIONALITY **************************
*******************************************************************/

dfuller RentaV_CV_TREND, regress lags(12)  
dfuller RentaF_CV_TREND, regress lags(12) /*I(0)*/
dfuller OIL_COMP1, regress lags(12)  /* I(1) */
dfuller Ext_Curr_COMP1, regress lags(12)  /* I(1) */
dfuller Dom_Curr_COMP1, regress lags(12)  /* I(2) */
dfuller Inf_Exp_COMP1, regress lags(12)  /* I(2) */
dfuller ER_Exp_COMP1, regress lags(12)  /* I(2) */
dfuller EOF_COMP1, regress lags(12)  /* I(1) */
*dfuller PROD_COMP1, regress lags(12)  /* I(0) */
dfuller INT_COMP1, regress lags(12)  /* I(2) */
dfuller RISK_COMP, regress lags(12)  /* I(2) */
dfuller D2.PERATIO_COMP1, regress lags(12) /* I(2) */  
dfuller D2.PERATIO_COMP2, regress lags(12) /* I(2) */  

save basenormal.dta, replace

/*****************************************************************
************************* TREND RENTA V **************************
*****************************************************************/
use basenormal.dta, clear 
/*
vecrank st_RentaV_CV_TREND st_OIL_COMP1 st_OIL_COMP2 st_EOF_COMP1 st_RISK_COMP
varsoc st_RentaV_CV_TREND st_OIL_COMP1 st_OIL_COMP2 st_EOF_COMP1 st_RISK_COMP
*/
vec st_RentaV_CV_TREND st_OIL_COMP1 st_OIL_COMP2 st_EOF_COMP1 st_RISK_COMP, lags(3)
vecstable
veclmar, mlag(12)
vecnorm
*/


/***** Model 1 *****/
 
varsoc st_RentaV_CV_TREND  st_Inf_Exp_COMP1 st_INT_COMP1 st_INT_COMP2 st_Ext_Curr_COMP1   /* 4 LAGS */
vecrank st_RentaV_CV_TREND  st_Inf_Exp_COMP1 st_INT_COMP1 st_INT_COMP2 st_Ext_Curr_COMP1  /* At least 3 cointegrating equations */
vec st_RentaV_CV_TREND  st_Inf_Exp_COMP1 st_INT_COMP1 st_INT_COMP2 st_Ext_Curr_COMP1, lags(3)
eststo quietly
estimate store VE1

/* FEVDS*/
irf create ve1, set(VE1,replace) step(18)
irf graph fevd, impulse(st_Inf_Exp_COMP1 st_INT_COMP1 st_INT_COMP2 st_Ext_Curr_COMP1) response(st_RentaV_CV_TREND) 
irf table fevd, impulse(st_Inf_Exp_COMP1 st_INT_COMP1 st_INT_COMP2 st_Ext_Curr_COMP1) response(st_RentaV_CV_TREND)
 
esttab using vec_trend.xls, replace   
vecstable
veclmar, mlag(12) /*Auto correlation */ 
vecnorm /*Normal*/
predict e0, resid eq(#1)
jb e0 /* Normal */
swilk e0
wntestq e0
corrgram e0
actest e0, lags(12) bp small /*Serial Correlation */


/***** Model 2 *****/


varsoc st_RentaV_CV_TREND  st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1 /* 4 LAGS */
vecrank st_RentaV_CV_TREND  st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1, lags(3)
vec st_RentaV_CV_TREND  st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1 , lags(3)
estimate store VE2
/*FEVDS*/
irf create ve2, set(VE2, replace) step(18)
irf graph fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1) response(st_RentaV_CV_TREND)
irf table fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1) response(st_RentaV_CV_TREND)

eststo quietly 
esttab using vec_trend.xls, append 
veclmar,  mlag(12) /*Auto Correlation */
vecnorm /*Normal Eq(#1) */
predict e1
jb e1 /* No normal */
swilk e1
wntestq e1
corrgram e1
actest e1, lags(12) bp small /*Serial Correlation */

/* ****Model 3 *****/

varsoc st_RentaV_CV_TREND st_EOF_COMP1  st_Inf_Exp_COMP1  st_Ext_Curr_COMP1 st_ER_Exp_COMP1 /* 4 LAGS */
vecrank st_RentaV_CV_TREND st_EOF_COMP1  st_Inf_Exp_COMP1  st_Ext_Curr_COMP1 st_ER_Exp_COMP1 
vec st_RentaV_CV_TREND st_EOF_COMP1  st_Inf_Exp_COMP1  st_Ext_Curr_COMP1 st_ER_Exp_COMP1  , lags(3)
estimate store VE3
/*FEVDS*/
irf create ve3, set(VE3, replace) step(18)
irf graph fevd, impulse(st_EOF_COMP1  st_Inf_Exp_COMP1  st_Ext_Curr_COMP1 st_ER_Exp_COMP1) response(st_RentaV_CV_TREND)
irf table fevd, impulse(st_EOF_COMP1  st_Inf_Exp_COMP1  st_Ext_Curr_COMP1 st_ER_Exp_COMP1) response(st_RentaV_CV_TREND)

eststo quietly 
esttab using vec_trend.xls, append 
predict e2, resid eq(#1)
veclmar, mlag(12) /* Auto Correlation */
vecnorm /*/ Normal Eq (#1) */
jb e2 /* Normal */
swilk e2
wntestq e2
corrgram e2
actest e2, lags(12) bp small /*Serial Correlation */



/****** Model 4 *****/

varsoc st_RentaV_CV_TREND  st_EOF_COMP1 st_Dom_Curr_COMP1 st_PERATIO_COMP1 /* 4 LAGS */
vecrank st_RentaV_CV_TREND  st_EOF_COMP1 st_Dom_Curr_COMP1 st_PERATIO_COMP1, lags(3) /* At Least 2 cointegrating equations */
vec st_RentaV_CV_TREND  st_EOF_COMP1 st_Dom_Curr_COMP1 st_PERATIO_COMP1, lags(3)

/***** Model 5 *****/

varsoc  st_RentaV_CV_TREND   st_Ext_Curr_COMP1 st_PERATIO_COMP1 st_RISK_COMP st_OIL_COMP1 /* 4 LAGS */
vecrank st_RentaV_CV_TREND   st_Ext_Curr_COMP1 st_PERATIO_COMP1 st_RISK_COMP st_OIL_COMP1, lags(3) /* At least 2 integrating equations */
vec st_RentaV_CV_TREND  st_Ext_Curr_COMP1 st_PERATIO_COMP1 st_RISK_COMP st_OIL_COMP1, lags(3)


/****** Model 6 ******/

vec st_RentaV_CV_TREND st_INT_COMP1  st_RISK_COMP st_ER_Exp_COMP1 , lags(3)



/*****************************************************************
************************* CYCLE RENTA V **************************
*****************************************************************/

/* Variables : Dep Var -> RentaV_CV_CYCLEX 
               IndepVars -> OIL_COMP1  st_OIL_COMP2 st_Inf_Exp_COMP2
			   Exogeneous -> st_EOF_COMP2 st_Dom_Curr_COMP2 
*/

/***** Model 1 *****/
varsoc st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2, exog(st_EOF_COMP2 st_Dom_Curr_COMP2) /* Optimum lag # 2 */
var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2, exog(st_EOF_COMP2 st_Dom_Curr_COMP2) lags(1/3)
/**Granger Test**/
vargranger
* In Equation RentaV_CV : Reject at 5% sig level the null hypothesis that dep vars does not Granger cause cycle of RentaV_CV
* In Equation 2/3: Unable to reject the null hyphotesis that cycle of RentaV_CV does not cause Dep.Vars  
estimate store VAE1
irf create vae1, set(VAE1, replace) step(18)
irf graph fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2) response(st_RentaV_CV_CYCLEX)
irf table fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2) response(st_RentaV_CV_CYCLEX)

varlmar /* NO autoccorelation */
varnorm /* Normal */

predict e11, residuals
jb e11 /* Normal */
swilk e11
wntestq e11
corrgram e11
actest e11, lags(12) bp small /*No Correlation */


eststo quietly 
esttab using Cycle_V.xls, replace 

/*
fcast compute f_, step(18) estimate(var1)
fcast graph f_st_RentaV_CV_CYCLEX
tsline f_st_RentaV_CV_CYCLEX f_st_RentaV_CV_CYCLEX_UB f_st_RentaV_CV_CYCLEX_LB  if time >= tm(2015m8), lpattern(shortdashed) || tsline st_RentaV_CV_CYCLEX
tsline f_st_RentaV_CV_CYCLEX  fv_st_RentaV_CV_TREND if time >= tm(2015m8) || tsline st_RentaV_CV_CYCLEX st_RentaV_CV_TREND if  time <= tm(2015m8)
*/ 

/***** Model 2 ******/

var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_Dom_Curr_COMP2, lags(1/3)
/** Granger Test **/ 
vargranger 
* In Equation RentaV_CV : Reject at 5% sig level the null hypothesis that dep vars does not Granger cause cycle of RentaV_CV 
* In Equation 2/5: Unable to reject the null hyphotesis that cycle of RentaV_CV does not cause Dep.Vars  
estimate store VAE2
irf create vae2, set(VAE2, replace) step(18)
irf graph fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_Dom_Curr_COMP2) response(st_RentaV_CV_CYCLEX) 
irf table fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_Dom_Curr_COMP2) response(st_RentaV_CV_CYCLEX) 

varlmar /* No autocorrelation */ 
varnorm /* +/- Normal (Kurtosis) */
 
predict e21, residuals
jb e21 /* Normal */
swilk e21
wntestq e21 /* white noise */ 
corrgram e21
actest e21, lags(12) bp small /*No Correlation */


eststo quietly 
esttab using Cycle_V.xls, append 

/***** Model 3 *****/

var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_ER_Exp_COMP2, lags(1/3)
/** Granger Test **/
vargranger
* In Equation RentaV_CV_CYCLEX: OIL:COMP1 & ER_Exp_COMP2 doesn't cuase in the sense of Granger st_RentaV_CV_CYCLEX
* In Equation 2/5: Unable to reject the null hyphotesis that cycle of RentaV_CV does not cause Dep.Vars  
estimate store VAE3
estimate store VAE3
irf create vae2, set(VAE3, replace) step(18)
irf graph fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_ER_Exp_COMP2) response(st_RentaV_CV_CYCLEX)
irf table fevd, impulse(st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_ER_Exp_COMP2) response(st_RentaV_CV_CYCLEX)

varlmar /* Auto Correlation Lag 2 */ 
varnorm /* No normal */ 

predict e31, residuals
jb e31 /* No Normal */
swilk e31
wntestq e31 /* White noise */ 
corrgram e31
actest e31, lags(12) bp small /*No Correlation */

eststo quietly 
esttab using Cycle_V.xls, append

/***** Model 4 *****/
preserve 
var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_ER_Exp_COMP2 st_INT_COMP1 , lags(1/3)
vargranger
restore

drop e*

/*****************************************************************
************************* CYCLE RENTA F **************************
*****************************************************************/

/* Variables : Dep Var -> RentaF_CV_CYCLEX 
               IndepVars -> OIL_COMP1 Ext_Curr_COMP1 Dom_Curr_COMP1 
Inf_Exp_COMP1 ER_Exp_COMP1 EOF_COMP1 EOF_COMP2 PROD_COMP1 INT_COMP1 RISK_COMP PERATIO_COMP1*/ 



/*** Model 1 ***/
var st_RentaF_CV_CYCLEX  st_Dom_Curr_COMP2 st_INT_COMP2, exog(st_RISK_COMP) lags(1/3)
/** Granger Test **/  
vargranger
*In Equation st_RentaF_CV_CYCLEX: Reject at 5% sig level the null hypothesis that dep vars does not Granger cause cycle of RentaV_CV 
* In Equation 2/3: Unable to reject the null hyphotesis that cycle of RentaV_CV does not cause Dep.Vars  
estimate store VAF1
irf create vaf1, set(VAF1, replace) step(18)
irf graph fevd, impulse(st_Dom_Curr_COMP2 st_INT_COMP2) response(st_RentaF_CV_CYCLEX)
irf table fevd, impulse(st_Dom_Curr_COMP2 st_INT_COMP2) response(st_RentaF_CV_CYCLEX)

varlmar /* auto Correlation at Lag 1 */
varnorm /* +/- Norm : Kurtosis */ 

predict e1, resid
jb e1 /* Normal */
swilk e1
wntestq e1 /* White noise */ 
corrgram e1
actest e1, lags(12) bp small /*No Serial Correlation */

eststo quietly 
esttab using Cycle_F.xls, replace 


*fcast compute f_, step(18) estimate(var2)
*fcast graph f_st_RentaF_CV_CYCLEX
*tsline f_st_RentaF_CV_CYCLEX f_st_RentaF_CV_CYCLEX_UB f_st_RentaF_CV_CYCLEX_LB  if time >= tm(2015m8), lpattern(shortdashed) || tsline st_RentaF_CV_CYCLEX
*restore 


/*** Model 2 ***/

var st_RentaF_CV_CYCLEX st_INT_COMP2 st_Inf_Exp_COMP2 st_PERATIO_COMP2, lags(1/3)
/** Granger Test **/
vargranger
*In Equation st_RentaF_CV_CYCLEX: Inf_Exp_COMP2 doesn't cause dep var in Granger Sense
*In Equation 2/4: Unable to reject the null hyphotesis that cycle of RentaV_CV does not cause Dep.Vars  
estimate store VAF2
irf create vaf2, set(VAF2, replace) step(18)
irf graph fevd, impulse(st_INT_COMP2 st_Inf_Exp_COMP2 st_PERATIO_COMP2) response(st_RentaF_CV_CYCLEX)
irf table fevd, impulse(st_INT_COMP2 st_Inf_Exp_COMP2 st_PERATIO_COMP2) response(st_RentaF_CV_CYCLEX)

varlmar /* Auto Correlation */ 
varnorm /* No normal */ 

predict e2, resid
jb e2 /* No Normal */
swilk e2
wntestq e2 /* White noise */ 
corrgram e2
actest e2, lags(12) bp small /*No Serial Correlation */

eststo quietly 
esttab using Cycle_F.xls, append


/*** Model 3 *****/ 

var st_RentaF_CV_CYCLEX st_ER_Exp_COMP2 st_Dom_Curr_COMP2 st_INT_COMP2, lags(1/3)
/** Granger Test **/
vargranger
*In Equation st_RentaF_CV_CYCLEX: ER_Exp_COMP2 doesn't cause dep var in Granger Sense
*In Equation 2/4: Unable to reject the null hyphotesis that cycle of RentaV_CV does not cause Dep.Vars  
estimate store VAF3
irf create vaf3, set(VAF3, replace) step(18)
irf graph fevd, impulse(st_ER_Exp_COMP2 st_Dom_Curr_COMP2 st_INT_COMP2) response(st_RentaF_CV_CYCLEX)
irf table fevd, impulse(st_ER_Exp_COMP2 st_Dom_Curr_COMP2 st_INT_COMP2) response(st_RentaF_CV_CYCLEX)

varlmar /* Auto Correlation */ 
varnorm /* No normal */ 

predict e3, resid
jb e3 /* No Normal */
swilk e3
wntestq e3 /* White noise */ 
corrgram e3
actest e3, lags(12) bp small /*No Serial Correlation */

eststo quietly 
esttab using Cycle_F.xls, append

drop e*
/*****************************************************************
*************************** TREND RENTA F ************************
*****************************************************************/


*preserve
varsoc st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1 st_Dom_Curr_COMP1  st_RISK_COMP /* optimum number of lags: 4 */
vecrank st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1 st_Dom_Curr_COMP1  st_RISK_COMP /* there is 2 cointegrating relationship */
pwcorr st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1 st_Dom_Curr_COMP1  st_RISK_COMP, sig star(95)  /* the correlation is 0.5 with comp1 and -0.6 with comp2*/
vec st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1 st_Dom_Curr_COMP1 st_RISK_COMP , lags(3)
estimate store VEC1
fcast compute fv_, step(18) estimate(VEC1)
fcast graph fv_st_RentaF_CV_TREND
tsline fv_st_RentaF_CV_TREND fv_st_RentaF_CV_TREND_UB fv_st_RentaF_CV_TREND_LB  if time >= tm(2015m8), lpattern(shortdashed) || tsline st_RentaF_CV_TREND


/**Model 1 **/
vec st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1  st_Dom_Curr_COMP1 st_Ext_Curr_COMP1, lags(3) 
estimate store VEF1
irf create vef1, set(VEF1, replace) step(18)
irf graph fevd, impulse(st_OIL_COMP1 st_Inf_Exp_COMP1  st_Dom_Curr_COMP1 st_Ext_Curr_COMP1) response(st_RentaF_CV_TREND)
irf table fevd, impulse(st_OIL_COMP1 st_Inf_Exp_COMP1  st_Dom_Curr_COMP1 st_Ext_Curr_COMP1) response(st_RentaF_CV_TREND)

eststo quietly 
esttab using vec_trendF.xls, replace


veclmar, mlag(12) /* Auto Correlation*/
vecnorm /*Normal*/
predict e4, resid 
jb e4 /* Normal */ 
swilk e4
wntestq e4 /* No white Noiise */ 
corrgram e4
actest e4, lags(12) bp small /* Serial Correlation */

/** Model 2 **/
vec st_RentaF_CV_TREND  st_INT_COMP1 st_Ext_Curr_COMP1 st_INT_COMP2 st_OIL_COMP1  st_Dom_Curr_COMP1, lags(3) 
estimate store VEF2
irf create vef2, set(VEF2, replace) step(18)
irf graph fevd, impulse(st_INT_COMP1 st_Ext_Curr_COMP1 st_INT_COMP2 st_OIL_COMP1  st_Dom_Curr_COMP1) response(st_RentaF_CV_TREND)
irf table fevd, impulse(st_INT_COMP1 st_Ext_Curr_COMP1 st_INT_COMP2 st_OIL_COMP1  st_Dom_Curr_COMP1) response(st_RentaF_CV_TREND)


eststo quietly 
esttab using vec_trendF.xls, append 

veclmar, mlag(12) /* Autocorrelation */ 
vecnorm /* Normal */
predict e5, resid 
jb e5 /*Normal*/
swilk e5
wntestq e5 /* NO white noise */ 
corrgram e5
actest e5, lags(12) bp small /* Serial Correlation */ 


/**Model 3 **/
vec st_RentaF_CV_TREND  st_INT_COMP1 st_INT_COMP2 st_EOF_COMP1, lags(3) 
estimate store VEF3
irf create vef3, set(VEF3, replace) step(18)
irf graph fevd, impulse(st_INT_COMP1 st_INT_COMP2 st_EOF_COMP1) response(st_RentaF_CV_TREND)
irf table fevd, impulse(st_INT_COMP1 st_INT_COMP2 st_EOF_COMP1) response(st_RentaF_CV_TREND)


eststo quietly 
esttab using vec_trendF.xls, append 


veclmar, mlag(12) /* Autocorrelation */
vecnorm /* Normal */ 
predict e6, resid  
jb e6 /* Normal */ 
swilk e6
wntestq e6 /* No white Noise*/
corrgram e6
actest e6, lags(12) bp small /* serial Correlation */ 


/**Model 4 **/
*Domestic currency and Inflation Expectations makes RISK no signif *** 
vec st_RentaF_CV_TREND st_OIL_COMP1 st_RISK_COMP st_Ext_Curr_COMP1, lags(3)
veclmar, mlag(12)
vecnorm
predict e7, resid 
jb e7
swilk e7
wntestq e7
corrgram e7
actest e7, lags(12) bp small



*tsline st_RentaF_CV_TREND st_RentaF_CV_CYCLEX if time <= tm(2015m8) || tsline fv_st_RentaF_CV_TREND if time >= tm(2015m8), lpattern(shortdashed) || tsline f_st_RentaF_CV_CYCLEX if time >= tm(2015m8), lpattern(shortdashed) 



/************************************************************************
******************* ARIMA Forecast for predictors ***********************
************************************************************************/
cd "C:\Users\jc.meneses1480\Documents\Federico Filippini\Series Desestacionalizadas\BVC Número de Operaciones\FINAL DATASET"
use basenormal.dta, replace 
tsappend, add(18)
/*Variables: OIL_COMP1 Ext_Curr_COMP1 Dom_Curr_COMP1 
Inf_Exp_COMP1 ER_Exp_COMP1 EOF_COMP1 EOF_COMP2 PROD_COMP1 INT_COMP1 RISK_COMP PERATIO_COMP1 */

***OIL_COMP1***
*br time OIL_COMP1
dfuller D.OIL_COMP1, regress lags(12)

ac D.OIL_COMP1
pac D.OIL_COMP1

arima OIL_COMP1, arima(1,1,4) /* Más significativo*/
predict residuals1, residuals
wntestq residuals1
forvalues i=1/18 {
local n= 125 + `i'
predict OILF, y 
replace OIL_COMP1 = OILF in `n'  
drop OILF 
}
*
tsline OIL_COMP1 if time <=tm(2015m10) || tsline OIL_COMP1 if time > tm(2015m10), lpattern(shortdashed) 
tsline OIL_COMP1

****OIL_COMP2 ***
dfuller D.OIL_COMP2, regress lags(12) /*I(1)*/ 

ac D.OIL_COMP2
pac D.OIL_COMP2
/* MA(3)*/
arima OIL_COMP2, arima(0,1,3) 
predict residuals12, residuals
wntestq residuals12 /* No white noise*/
forvalues i=1/18 {
local n= 125 + `i'
predict OILF2, y 
replace OIL_COMP2 = OILF2 in `n'  
drop OILF2 
}
*
tsline OIL_COMP2 if time <=tm(2015m10) || tsline OIL_COMP2 if time > tm(2015m10), lpattern(shortdashed) 
tsline OIL_COMP2


***Ext_Curr_COMP1***
dfuller D.Ext_Curr_COMP1, regress lags(12)
*br time Ext_Curr_COMP1

ac D.Ext_Curr_COMP1
pac D.Ext_Curr_COMP1

arima Ext_Curr_COMP1, arima(1,1,1)
predict residuals2, residuals
wntestq residuals2
forvalues i=1/18 {
local n= 125 + `i'
predict EXTF, y 
replace Ext_Curr_COMP1 = EXTF in `n'  
drop EXTF
}
*
tsline Ext_Curr_COMP1 if time <=tm(2015m10) || tsline Ext_Curr_COMP1 if time > tm(2015m10), lpattern(shortdashed) 
tsline Ext_Curr_COMP1

***Ext_Curr_COMP2***

dfuller D.Ext_Curr_COMP2, regress lags(12) /*I(1)*/

ac D.Ext_Curr_COMP2
pac D.Ext_Curr_COMP2

arima Ext_Curr_COMP2, arima(3,1,3)
predict residuals21, residuals
wntestq residuals21 /*White Noise*/
forvalues i=1/18 {
local n= 125 + `i'
predict EXTF2, y 
replace Ext_Curr_COMP2 = EXTF2 in `n'  
drop EXTF2
}
*
tsline Ext_Curr_COMP2 if time <=tm(2015m10) || tsline Ext_Curr_COMP2 if time > tm(2015m10), lpattern(shortdashed) 
tsline Ext_Curr_COMP2


***Dom_Curr_COMP1*** /* No plausible forecast*/
*br time Dom_Curr_COMP1
dfuller D2.Dom_Curr_COMP1, regress lags(12)

ac D2.Dom_Curr_COMP1
pac D2.Dom_Curr_COMP1

arima Dom_Curr_COMP1, arima(0,2,1)
predict residuals3, residuals
wntestq residuals3
*br time Dom_Curr_COMP1
forvalues i=1/18 {
local n= 125 + `i'
predict DOMF, y 
replace Dom_Curr_COMP1 = DOMF in `n'  
drop DOMF
}
*
tsline Dom_Curr_COMP1 if time <=tm(2015m10) || tsline Dom_Curr_COMP1 if time > tm(2015m10), lpattern(shortdashed) 
tsline Dom_Curr_COMP1

***Dom_Curr_COMP2*** /*Similar Forecast to first component*/
dfuller D2.Dom_Curr_COMP2, regress lags(12) /*I(2)*/

ac D2.Dom_Curr_COMP2
pac D2.Dom_Curr_COMP2
/*ARMA(2, 1)*/
arima Dom_Curr_COMP2, arima(2,2,1)
predict residuals32, residuals
wntestq residuals32
*br time Dom_Curr_COMP1
forvalues i=1/18 {
local n= 125 + `i'
predict DOMF2, y 
replace Dom_Curr_COMP2 = DOMF2 in `n'  
drop DOMF2
}
*
tsline Dom_Curr_COMP2 if time <=tm(2015m10) || tsline Dom_Curr_COMP2 if time > tm(2015m10), lpattern(shortdashed) 
tsline Dom_Curr_COMP2



***Inf_Exp_COMP1***
*br time Inf_Exp_COMP1
dfuller D2.Inf_Exp_COMP1, regress lags(12)

ac D2.Inf_Exp_COMP1
pac D2.Inf_Exp_COMP1

arima Inf_Exp_COMP1, arima(10,2,2)
predict residuals4, residuals
wntestq residuals4
*br time Inf_Exp_COMP1
forvalues i=1/18 {
local n= 125 + `i'
predict EXPIF, y 
replace Inf_Exp_COMP1 = EXPIF in `n'  
drop EXPIF
}
*
tsline Inf_Exp_COMP1 if time <=tm(2015m10) || tsline Inf_Exp_COMP1 if time > tm(2015m10), lpattern(shortdashed) 
tsline Inf_Exp_COMP1


***Inf_Exp_COMP2***
dfuller Inf_Exp_COMP2, regress lags(12) /*I(0)*/

ac Inf_Exp_COMP2
pac Inf_Exp_COMP2
/*ARMA(1,1) - (2,2) */ 
arima Inf_Exp_COMP2, arima(1,0,1)
predict residuals42, residuals
wntestq residuals42
*br time Inf_Exp_COMP2
forvalues i=1/18 {
local n= 125 + `i'
predict EXPIF2, y 
replace Inf_Exp_COMP2 = EXPIF2 in `n'  
drop EXPIF2
}
*
tsline Inf_Exp_COMP2 if time <=tm(2015m10) || tsline Inf_Exp_COMP2 if time > tm(2015m10), lpattern(shortdashed) 
tsline Inf_Exp_COMP2 /*Estable Exp of Inflation */


***ER EXP COMP1 *** /* NO plausible Forecast */

dfuller D2.ER_Exp_COMP1, regress lags(12)

ac D2.ER_Exp_COMP1
pac D2.ER_Exp_COMP1

arima ER_Exp_COMP1, arima(0,2,1)
predict residuals5, residuals
wntestq residuals5
*br time ER_Exp_COMP1
forvalues i=1/18 {
local n= 125 + `i'
predict ERF, y 
replace ER_Exp_COMP1 = ERF in `n'  
drop ERF
}
*
tsline ER_Exp_COMP1 if time <=tm(2015m10) || tsline ER_Exp_COMP1 if time > tm(2015m10), lpattern(shortdashed) 
tsline ER_Exp_COMP1

***ER EXP COMP2 *** 

dfuller D.ER_Exp_COMP2, regress lags(12) /*I(1)*/

ac D.ER_Exp_COMP2
pac D.ER_Exp_COMP2
/*MA(2)*/

arima ER_Exp_COMP2, arima(0,1,2)
predict residuals52, residuals
wntestq residuals52 /*White Noise*/ 
*br time ER_Exp_COMP2
forvalues i=1/18 {
local n= 125 + `i'
predict ERF2, y 
replace ER_Exp_COMP2 = ERF in `n'  
drop ERF2
}
*
tsline ER_Exp_COMP2 if time <=tm(2015m10) || tsline ER_Exp_COMP2 if time > tm(2015m10), lpattern(shortdashed) 
tsline ER_Exp_COMP2



***EOF_COMP1*** /*No plausible forecast */
dfuller D2.EOF_COMP1, regress lags(12) /* I(2)*/

ac D2.EOF_COMP1
pac D2.EOF_COMP1

arima EOF_COMP1, arima(10,2,1)
predict residuals6, residuals
wntestq residuals6
*br time EOF_COMP1
forvalues i=1/18 {
local n= 125 + `i'
predict EOF_F, y 
replace EOF_COMP1 = EOF_F in `n'  
drop EOF_F
}
*
tsline EOF_COMP1 if time <=tm(2015m10) || tsline EOF_COMP1 if time > tm(2015m10), lpattern(shortdashed) 
tsline EOF_COMP1

***EOF_COMP2***
dfuller EOF_COMP2, regress lags(12) /* I(0)*/

ac D2.EOF_COMP2
pac D2.EOF_COMP2

arima EOF_COMP1, arima(1,0,1)
predict residuals7, residuals
wntestq residuals7 /* No white noise*/
*br time EOF_COMP2
forvalues i=1/18 {
local n= 125 + `i'
predict EOF2_F, y 
replace EOF_COMP2 = EOF2_F in `n'  
drop EOF2_F
}
*
tsline EOF_COMP2 if time <=tm(2015m10) || tsline EOF_COMP2 if time > tm(2015m10), lpattern(shortdashed) 
tsline EOF_COMP2

***INT_COMP1***
dfuller D2.INT_COMP1, regress lags(12) /*I(2)*/

ac D2.INT_COMP1
pac D2.INT_COMP1

arima D.INT_COMP1, arima(2,2,1)
predict residuals9, residuals
wntestq residuals9
*br time INT_COMP1
forvalues i=1/18 {
local n= 125 + `i'
predict INTF, y 
replace INT_COMP1 = INTF in `n'  
drop INTF
}
*
tsline INT_COMP1 if time <=tm(2015m10) || tsline INT_COMP1 if time > tm(2015m10), lpattern(shortdashed) 

***INT_COMP2***
dfuller D2.INT_COMP2, regress lags(12) /*I(2)*/

ac D2.INT_COMP2
pac D2.INT_COMP2

arima D.INT_COMP2, arima(3,2,2)
predict residuals10, residuals
wntestq residuals10
*br time INT_COMP2
forvalues i=1/18 {
local n= 125 + `i'
predict INT2F, y 
replace INT_COMP2 = INT2F in `n'  
drop INT2F
}
*
tsline INT_COMP2 if time <=tm(2015m10) || tsline INT_COMP2 if time > tm(2015m10), lpattern(shortdashed) 

***RISK_COMP***
dfuller D2.RISK_COMP, regress lags(12) /*I(2)*/

ac D2.RISK_COMP
pac D2.RISK_COMP
/* ARMA4 -2 */

arima RISK_COMP, arima(4,2,1)
predict residuals11, residuals
wntestq residuals11
*br time RISK_COMP
forvalues i=1/18 {
local n= 125 + `i'
predict RISKF, y 
replace RISK_COMP = RISKF in `n'  
drop RISKF
}
*
tsline RISK_COMP if time <=tm(2015m10) || tsline RISK_COMP if time > tm(2015m10), lpattern(shortdashed) 
tsline RISK_COMP

***PERATIO_COMP1***
dfuller D2.PERATIO_COMP1, regress lags(12) /* I(2)*/

ac D2.PERATIO_COMP1
pac D2.PERATIO_COMP1

/* ARMA c(0, 2) */

arima PERATIO_COMP1, arima(0,2,2)
predict residuals122, residuals
wntestq residuals122
*br time PERATIO_COMP1
forvalues i=1/18 {
local n= 125 + `i'
predict PEF, y 
replace PERATIO_COMP1 = PEF in `n'  
drop PEF
}
*
tsline PERATIO_COMP1 if time <=tm(2015m10) || tsline PERATIO_COMP1 if time > tm(2015m10), lpattern(shortdashed) 
tsline PERATIO_COMP1

***PERATIO_COMP2***
/* Similar to First Component Forecast */ 
dfuller D2.PERATIO_COMP2, regress lags(12) /* I(2)*/

ac D2.PERATIO_COMP2
pac D2.PERATIO_COMP2

/* ARMA (4,1)  */
arima PERATIO_COMP2, arima(4,2,1)
predict residuals123, residuals
wntestq residuals123
*br time PERATIO_COMP2
forvalues i=1/18 {
local n= 125 + `i'
predict PEF2, y 
replace PERATIO_COMP2 = PEF2 in `n'  
drop PEF2
}
*
tsline PERATIO_COMP2 if time <=tm(2015m10) || tsline PERATIO_COMP2 if time > tm(2015m10), lpattern(shortdashed) 
tsline PERATIO_COMP2

drop residuals*
br 

save predict1.dta, replace

/********************************************************************************
***************************                        ******************************
*************************** Out of Sample Forecast ******************************
***************************                        ******************************
*********************************************************************************/

use predict1.dta, replace 
set more off 
drop st_*
foreach var of varlist RentaV_CV* RentaF_CV* *_COMP* {
	egen st_`var' = std(`var')
} 
save predict2.dta, replace


/********************************************************************************
********************** FORECAST CONDITIONAL ON ARIMA PATH ***********************
********************************************************************************/

/************************************************************************
****************************   EQUITY    ********************************
************************************************************************/

*Trend
*Model 1

vec st_RentaV_CV_TREND  st_Inf_Exp_COMP1 st_INT_COMP1 st_INT_COMP2 st_Ext_Curr_COMP1, lags(3)
estimate store VEC1 
forecast create model, replace
forecast estimates VEC1
forecast solve, prefix(ft1_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(stv1_)) reps(25))
gen ci_u_tv1 = ft1_st_RentaV_CV_TREND + invnormal(0.975)*stv1_st_RentaV_CV_TREND
gen ci_l_tv1 = ft1_st_RentaV_CV_TREND + invnormal(0.025)*stv1_st_RentaV_CV_TREND

tsline ci_u_tv1 ci_l_tv1  ft1_st_RentaV_CV_TREND /* Forecast: Decreasing trend */ 

*Model 2 

vec st_RentaV_CV_TREND  st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1 , lags(3)
estimate store VEC2 
forecast create model, replace
forecast estimates VEC2
forecast solve, prefix(ft2_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(stv2_)) reps(25))
gen ci_u_tv2 = ft2_st_RentaV_CV_TREND + invnormal(0.975)*stv2_st_RentaV_CV_TREND
gen ci_l_tv2 = ft2_st_RentaV_CV_TREND + invnormal(0.025)*stv2_st_RentaV_CV_TREND

tsline st_RentaV_CV_TREND || tsline ci_u_tv2 ci_l_tv2 ft2_st_RentaV_CV_TREND /* Fit Similar to Especification 1 */ 

*Model 3  
preserve
vec st_RentaV_CV_TREND st_EOF_COMP1  st_Inf_Exp_COMP1  st_Ext_Curr_COMP1 st_ER_Exp_COMP1  , lags(3)
estimate store VEC3
forecast create model, replace
forecast estimates VEC3
forecast solve, prefix(ft3_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(stv3_)) reps(25))
gen ci_u_tv3 = ft3_st_RentaV_CV_TREND + invnormal(0.975)*stv3_st_RentaV_CV_TREND
gen ci_l_tv3 = ft3_st_RentaV_CV_TREND + invnormal(0.025)*stv3_st_RentaV_CV_TREND

tsline st_RentaV_CV_TREND || tsline ci_u_tv3 ci_l_tv3 ft3_st_RentaV_CV_TREND /* Forecast a reverse in trend: Could be a benchmark */ 
restore

*Cycle

*use predict2.dta , clear
*Model 1
var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2
estimate store VAR1 
forecast create modelc, replace
forecast estimates VAR1
forecast solve, prefix(fc1_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(scv1_)) reps(25))
gen ci_u_cv1 = fc1_st_RentaV_CV_CYCLEX + invnormal(0.975)*scv1_st_RentaV_CV_CYCLEX
gen ci_l_cv1 = fc1_st_RentaV_CV_CYCLEX + invnormal(0.025)*scv1_st_RentaV_CV_CYCLEX
tsline fc1_st_RentaV_CV_CYCLEX
tsline fc1_st_RentaV_CV_CYCLEX st_RentaV_CV_CYCLEX  ci_u_cv1 ci_l_cv1 /* Forecast: Increase in cycle */
/*
gen Forecast1 = t1_st_RentaV_CV_TREND +  fc1_st_RentaV_CV_CYCLEX
egen CI_U = rowtotal(ci_u1  ci_u2)
egen CI_L = rowtotal(ci_l1  ci_l2)

tsline st_RentaV_CV || tsline CI_U  if time > tm(2015m10), lpattern(shortdash) || tsline  CI_L if time > tm(2015m10), lpattern(shortdash) || tsline Forecast1 if time >= tm(2015m10), lpattern(shordash) || tsline Forecast1 if time <= tm(2015m9),  name(f1, replace) title("Pronóstico para el volumen transado de Renta Variable" " Compra Venta" "Octubre 2015") caption(Fuente: BVC-Bloomberg-Banco de la República - Cálculos Propios) note("Dashed lines represent 95% interval, based on uncertainity and normally distributed erors")
*/

*Model 2

var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_Dom_Curr_COMP2, lags(1/3)
estimate store VAR2 
forecast create modelc, replace
forecast estimates VAR2
forecast solve, prefix(fc2_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(scv2_)) reps(25))
gen ci_u_cv2 = fc2_st_RentaV_CV_CYCLEX + invnormal(0.975)*scv2_st_RentaV_CV_CYCLEX
gen ci_l_cv2 = fc2_st_RentaV_CV_CYCLEX + invnormal(0.025)*scv2_st_RentaV_CV_CYCLEX
tsline fc2_st_RentaV_CV_CYCLEX
tsline fc2_st_RentaV_CV_CYCLEX st_RentaV_CV_CYCLEX  ci_u_cv2 ci_l_cv2 /*Forecast : Slight fluctuations : Decreasing Cycle*/

*Model 3 

var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2 st_RISK_COMP st_ER_Exp_COMP2, lags(1/3)
estimate store VAR1 
forecast create modelc, replace
forecast estimates VAR1
forecast solve, prefix(fc3_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(scv3_)) reps(25))
gen ci_u_cv3 = fc3_st_RentaV_CV_CYCLEX + invnormal(0.975)*scv3_st_RentaV_CV_CYCLEX
gen ci_l_cv3 = fc3_st_RentaV_CV_CYCLEX + invnormal(0.025)*scv3_st_RentaV_CV_CYCLEX
tsline fc3_st_RentaV_CV_CYCLEX
tsline fc3_st_RentaV_CV_CYCLEX st_RentaV_CV_CYCLEX  ci_u_cv3 ci_l_cv3 /*Forecast : Initial Jump, then Estable Cycle*/

/******* Choosing between alternative trend & cycle forecast ********/
*Increasing Forecast in RentaV_CV

preserve 

/* SUM OF CI */
egen CI_U = rowtotal(ci_u_tv3 ci_u_cv1)
egen CI_L = rowtotal(ci_l_tv3 ci_l_cv1)

/* FORECAST */ 
gen FORECAST = ft3_st_RentaV_CV_TREND + fc1_st_RentaV_CV_CYCLEX

/*GRAPH*/
twoway rarea CI_U CI_L time if time >= tm(2015m11), finten(inten20) lwidth(thin) lcolor(red) color(eltblue)  || tsline FORECAST if time <= tm(2015m11) || tsline FORECAST if time >= tm(2015m11), lpattern(shortdash) || tsline st_RentaV_CV     
restore


/****************************************************************
*********************** FIXED INCOME ****************************
****************************************************************/

*Model 1 
*use predict2.dta, replace 
vec st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1  st_Dom_Curr_COMP1 st_Ext_Curr_COMP1, lags(3) /**Model 1 **/
estimate store VECF1 
forecast create model, replace
forecast estimates VECF1
forecast solve, prefix(FT1_) actuals  begin(tm(2015m10)) sim(betas, stat(stddev, prefix(stf1_)) reps(25))
gen ci_u_tf1 = FT1_st_RentaF_CV_TREND + invnormal(0.975)*stf1_st_RentaF_CV_TREND
gen ci_l_tf1 = FT1_st_RentaF_CV_TREND + invnormal(0.025)*stf1_st_RentaF_CV_TREND

tsline FT1_st_RentaF_CV_TREND st_RentaF_CV_TREND  ci_u_tf1 ci_l_tf1 /* Forecast : decreasing trend */ 


/*
gen Forecast_RF = FC1_st_RentaF_CV_CYCLEX + FT1_st_RentaF_CV_TREND
egen CI_U = rowtotal(ci_u1  ci_u2)
egen CI_L = rowtotal(ci_l1  ci_l2)
*/

*tsline st_RentaF_CV || tsline CI_U if time >= tm(2015m10), lpattern(shortdash) || tsline CI_L if time >= tm(2015m10), lpattern(shortdash)  || tsline  Forecast_RF if time >= tm(2015m10), lpattern(shortdash) || tsline Forecast_RF if time <= tm(2015m10), name(ff, replace) title("Forecast of Fixed Income Trading Volume" "October 2015") caption(Fuente: BVC-Bloomberg-Banco de la República - Own estimations) note("Dashed lines represent 95% interval, based on uncertainity and normally distributed erors")

*Model 2 

vec st_RentaF_CV_TREND  st_INT_COMP1 st_Ext_Curr_COMP1 st_INT_COMP2 st_OIL_COMP1  st_Dom_Curr_COMP1, lags(3) /** Model 2 **/
estimate store VECF2 
forecast create model, replace
forecast estimates VECF2
forecast solve, prefix(FT2_) actuals begin(tm(2015m10)) sim(betas, stat(stddev, prefix(stf2_)) reps(25))
gen ci_u_tf2 = FT2_st_RentaF_CV_TREND + invnormal(0.975)*stf2_st_RentaF_CV_TREND
gen ci_l_tf2 = FT2_st_RentaF_CV_TREND + invnormal(0.025)*stf2_st_RentaF_CV_TREND

tsline FT2_st_RentaF_CV_TREND st_RentaF_CV_TREND ci_u_tf2 ci_l_tf2 /* Forecast a decrease in trend: less than with model 1 */ 

*Modelo 3 

vec st_RentaF_CV_TREND  st_INT_COMP1 st_INT_COMP2 st_EOF_COMP1, lags(3) /**Model 3 **/
estimate store VECF3 
forecast create model, replace
forecast estimates VECF3
forecast solve, prefix(FT3_) actuals begin(tm(2015m10)) sim(betas, stat(stddev, prefix(stf3_)) reps(25))
gen ci_u_tf3 = FT3_st_RentaF_CV_TREND + invnormal(0.975)*stf3_st_RentaF_CV_TREND
gen ci_l_tf3 = FT3_st_RentaF_CV_TREND + invnormal(0.025)*stf3_st_RentaF_CV_TREND

tsline FT3_st_RentaF_CV_TREND st_RentaF_CV_TREND ci_u_tf3 ci_l_tf3 /* Forecast a decrease in trend: less than with previous models*/ 


*Cycle

*Model 1
var st_RentaF_CV_CYCLEX  st_Dom_Curr_COMP2 st_INT_COMP2, exog(st_RISK_COMP) lags(1/3)  
estimate store VARF1 
forecast create model, replace
forecast estimates VARF1
forecast solve, prefix(FC1_) actuals  begin(tm(2015m10)) sim(betas, stat(stddev, prefix(scf1_)) reps(25))
gen ci_u_scf1 = FC1_st_RentaF_CV_CYCLEX + invnormal(0.975)*scf1_st_RentaF_CV_CYCLEX
gen ci_l_scf1 = FC1_st_RentaF_CV_CYCLEX + invnormal(0.025)*scf1_st_RentaF_CV_CYCLEX

tsline FC1_st_RentaF_CV_CYCLEX st_RentaF_CV_CYCLEX  ci_u_scf1 ci_l_scf1 /* Forecast : Increasing cycle, decaying in last periods */ 

*Model 2 
*use predict2.dta, clear

var st_RentaF_CV_CYCLEX st_INT_COMP2 st_Inf_Exp_COMP2 st_PERATIO_COMP2, lags(1/3)
estimate store VARF2 
forecast create model, replace
forecast estimates VARF2
forecast solve, prefix(FC2_) actuals  sim(betas, stat(stddev, prefix(scf2_)) reps(100))
gen ci_u_scf2 = FC2_st_RentaF_CV_CYCLEX + invnormal(0.975)*scf2_st_RentaF_CV_CYCLEX
gen ci_l_scf2 = FC2_st_RentaF_CV_CYCLEX + invnormal(0.025)*scf2_st_RentaF_CV_CYCLEX

tsline FC2_st_RentaF_CV_CYCLEX   ci_u_scf2 ci_l_scf2 /* Forecast: plunge in cycle, and then recover. Good fit */


*Model 3 

var st_RentaF_CV_CYCLEX st_ER_Exp_COMP2 st_Dom_Curr_COMP2 st_INT_COMP2, lags(1/3)
estimate store VARF3 
forecast create model, replace
forecast estimates VARF3
forecast solve, prefix(FC3_) sim(betas, stat(stddev, prefix(scf3_)) reps(50))
gen ci_u_scf3 = FC3_st_RentaF_CV_CYCLEX + invnormal(0.975)*scf3_st_RentaF_CV_CYCLEX
gen ci_l_scf3 = FC3_st_RentaF_CV_CYCLEX + invnormal(0.025)*scf3_st_RentaF_CV_CYCLEX 


tsline FC3_st_RentaF_CV_CYCLEX   ci_u_scf3 ci_l_scf3 /* Forecast: Estable cycle. Not good fit */

/******* Choosing between alternative forecast of trend & cycle *******/ 


*Model 3 of trend & model 2 of cycle : decrease in trend and plunge in cycle*
preserve 

/*SUM OF CI*/
egen CI_U = rowtotal(ci_u_tf3 ci_u_scf2)
egen CI_L = rowtotal(ci_l_scf2 ci_l_tf3)

/* FORECAST */ 
gen FORECAST = FT3_st_RentaF_CV_TREND + FC2_st_RentaF_CV_CYCLEX

/*GRAPH*/
twoway rarea CI_U CI_L time if time >= tm(2015m11), finten(inten20) lwidth(thin) lcolor(red) color(eltblue)  || tsline FORECAST if time <= tm(2015m11) || tsline FORECAST if time >= tm(2015m11), lpattern(shortdash) || tsline st_RentaF_CV     
restore 


/*********************************************************************
******************  HYPOTHETICAL PATHS FOR EXOG: VAR *****************
*********************************************************************/


** Equity **

*Forecast 1 

*Suppose that, instead of the path specified by ARIMA, Oil Component 1 has a shock
*of a 10% increase in the first  9  periods, and then a sharp rise of 20% over the
*mean value of the previously fitted ARIMA model.
*Cycle is the variable that would be affected by this shock usign model 1, and 
*trend using model 2*

preserve 
use predict2.dta, replace 
/* FORCAST OF THE MODEL CONDITIONAL ON ARIMA PATHS*/
vec st_RentaV_CV_TREND  st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1 , lags(3)
estimate store VEC2Z 
forecast create model, replace
forecast estimates VEC2Z
forecast solve, prefix(z_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(sz_)) reps(25))
gen ci_u_z = z_st_RentaV_CV_TREND + invnormal(0.975)*sz_st_RentaV_CV_TREND
gen ci_l_z = z_st_RentaV_CV_TREND + invnormal(0.025)*sz_st_RentaV_CV_TREND
var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2
estimate store VAR1Y 
forecast create modelc, replace
forecast estimates VAR1Y
forecast solve, prefix(y_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(sy_)) reps(25))
gen ci_u_c = y_st_RentaV_CV_CYCLEX + invnormal(0.975)*sy_st_RentaV_CV_CYCLEX
gen ci_l_c = y_st_RentaV_CV_CYCLEX + invnormal(0.025)*sy_st_RentaV_CV_CYCLEX

gen FORECAST_M = y_st_RentaV_CV_CYCLEX + z_st_RentaV_CV_TREND

/*REPLACE OIL VALUES*/
replace st_OIL_COMP1 = -1.39 if time >= tm(2015m11) & time < tm(2016m8)
replace st_OIL_COMP1 = -1.24 if time >= tm(2016m8)

/* FORECAST CONDITIONAL ON SHOCK */ 
 
vec st_RentaV_CV_TREND  st_OIL_COMP1 st_OIL_COMP2 st_RISK_COMP st_Inf_Exp_COMP1 , lags(3)
estimate store VEC2ALT 
forecast create model, replace
forecast estimates VEC2ALT
forecast solve, prefix(alt1_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(salt1_)) reps(25))
gen ci_u_alt1 = alt1_st_RentaV_CV_TREND + invnormal(0.975)*salt1_st_RentaV_CV_TREND
gen ci_l_alt1 = alt1_st_RentaV_CV_TREND + invnormal(0.025)*salt1_st_RentaV_CV_TREND

var st_RentaV_CV_CYCLEX st_OIL_COMP1 st_OIL_COMP2 st_Inf_Exp_COMP2
estimate store VAR1ALT 
forecast create modelc, replace
forecast estimates VAR1ALT
forecast solve, prefix(alt2_) actuals begin(tm(2015m11)) sim(betas, stat(stddev, prefix(salt2_)) reps(25))
gen ci_u_alt2 = alt2_st_RentaV_CV_CYCLEX + invnormal(0.975)*salt2_st_RentaV_CV_CYCLEX
gen ci_l_alt2 = alt2_st_RentaV_CV_CYCLEX + invnormal(0.025)*salt2_st_RentaV_CV_CYCLEX


gen FORECAST_ALT = alt1_st_RentaV_CV_TREND + alt2_st_RentaV_CV_CYCLEX

/*GENERATE DIFFERENCE IN FORECAST */ 
gen diff_F = FORECAST_ALT - FORECAST_M

/*GRAPH*/

tsline diff_F if time >= tm(2015m11), title("Oil's Effect on Equity Traded Volume" "10% - 20% Positive Shock") ytitle("Change (%) in standardized Equity volume") note("Assumes oil first component increases 10% in the first nine months" "thereafter the shock increases up to 20%") name(ALT1, replace)  

restore

*** Fixed Income **** 

*Forecast 1 

*Where are going to assume the same shock for Oil component as before, but add a shock to the  
*inflation expectations' second component, that affects the cycle of the fixed income series. The shock consist of setting
*expectations at its maximum of the ongoing year. In order to do so, where are going to use de estimations result for the 
*model 1 of tren and model 2 of the cycle.

preserve 
use predict2.dta, replace 

/* FORCAST OF THE MODEL CONDITIONAL ON ARIMA PATHS*/
vec st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1  st_Dom_Curr_COMP1 st_Ext_Curr_COMP1, lags(3) /**Model 1 **/
estimate store VECF1Z 
forecast create model, replace
forecast estimates VECF1Z
forecast solve, prefix(Z_) actuals  begin(tm(2015m10)) sim(betas, stat(stddev, prefix(sZ_)) reps(25))
gen ci_u_Z = Z_st_RentaF_CV_TREND + invnormal(0.975)*sZ_st_RentaF_CV_TREND
gen ci_l_Z = Z_st_RentaF_CV_TREND + invnormal(0.025)*sZ_st_RentaF_CV_TREND
var st_RentaF_CV_CYCLEX st_INT_COMP2 st_Inf_Exp_COMP2 st_PERATIO_COMP2, lags(1/3)
estimate store VARF2Y 
forecast create model, replace
forecast estimates VARF2Y
forecast solve, prefix(Y_) actuals  sim(betas, stat(stddev, prefix(sY_)) reps(100))
gen ci_u_Y = Y_st_RentaF_CV_CYCLEX + invnormal(0.975)*sY_st_RentaF_CV_CYCLEX
gen ci_l_Y = Y_st_RentaF_CV_CYCLEX + invnormal(0.025)*sY_st_RentaF_CV_CYCLEX

gen FORECAST_A = Y_st_RentaF_CV_CYCLEX+ Z_st_RentaF_CV_TREND

/*REPLACE OIL & INFLATION EXPECTATIONS VALUES*/
replace st_OIL_COMP1 = -1.39 if time >= tm(2015m11) & time < tm(2016m8)
replace st_OIL_COMP1 = -1.24 if time >= tm(2016m8)
replace st_Inf_Exp_COMP2 = 2.1  if time >= tm(2015m11)
 
/* FORECAST CONDITIONAL ON SHOCK (altternative) */ 
vec st_RentaF_CV_TREND st_OIL_COMP1 st_Inf_Exp_COMP1  st_Dom_Curr_COMP1 st_Ext_Curr_COMP1, lags(3) /**Model 1 **/
estimate store VECF1ZALT 
forecast create model, replace
forecast estimates VECF1ZALT
forecast solve, prefix(Zalt_) actuals  begin(tm(2015m10)) sim(betas, stat(stddev, prefix(sZalt_)) reps(25))
gen ci_u_Zalt = Zalt_st_RentaF_CV_TREND + invnormal(0.975)*sZalt_st_RentaF_CV_TREND
gen ci_l_Zalt = Zalt_st_RentaF_CV_TREND + invnormal(0.025)*sZalt_st_RentaF_CV_TREND
var st_RentaF_CV_CYCLEX st_INT_COMP2 st_Inf_Exp_COMP2 st_PERATIO_COMP2, lags(1/3)
estimate store VARF2YALT 
forecast create model, replace
forecast estimates VARF2YALT
forecast solve, prefix(Yalt_) actuals  sim(betas, stat(stddev, prefix(sYalt_)) reps(100))
gen ci_u_Yalt = Yalt_st_RentaF_CV_CYCLEX + invnormal(0.975)*sYalt_st_RentaF_CV_CYCLEX
gen ci_l_Yalt = Yalt_st_RentaF_CV_CYCLEX + invnormal(0.025)*sYalt_st_RentaF_CV_CYCLEX

gen FORECAST_ALT = Yalt_st_RentaF_CV_CYCLEX + Zalt_st_RentaF_CV_TREND

/*GENERATE DIFFERENCE IN FORECAST */ 
gen diff_FF = FORECAST_A - FORECAST_ALT

/*GRAPH*/

tsline diff_FF if time >= tm(2015m11), title("Oil's & Inflation Expectations Effect on Fixed Income Traded Volume" "10% - 20% Positive Shock") ytitle("Change (%) in standardized Equity volume") note("Assumes oil first component increases 10% in the first nine months" "thereafter the shock increases up to 20%" "Inflation exp is assumed to remain at the maximum of 2015") name(ALT2, replace)  
restore


