#PACKAGES 
install.packages("foreign")
install.packages('seasonal')
install.packages("timesSeries")
require(seasonal)
require(foreign)

# Download X13-ARIMA-SEATS from United States Census Bureau: 
# https://www.census.gov/srd/www/winx13/winx13_down.html, revisited 14 Jan-2016

#Set path for x13 (unzipped folder)
Sys.setenv(X13_PATH = "C:/Users/jc.meneses1480/Documents/Federico Filippini/x13ashtmlall_V1.1_B19/x13ashtml")
checkx13()

X <- read.dta("Base_Desestacionalizar_Stata12.dta")
Z <- ts(data = X[, 2:32], start = c(1990,1), freq = 12)
names<-variable.names(Z)
names

#Example: RentaV_CV (Equity)
Equity <- as.data.frame(X[139:310, 28])
Equity <- ts(Equity, start = c(2001,7), freq = 12) # Reading as a time series
plot(Equity) # Exploratory analysis
monthplot(Equity) #Seasonal Component
pacf(Equity)

#### Seasonal adjustment ###

Equity_SA <- final(seas(Equity))
plot(seas(Equity))
pacf(Equity_SA)
monthplot(Equity_SA) #Does not have seasonal component

###################################
####### ALL DATASET ###############
###################################


#(X11 Adjustment procedure)

for (i in 1:19) {
        y <- names[i]
        assign(y, final(seas(Z[,i],x11 = "")))
}

# SEATS Adjustment procedure 

for (i in 20:29) {
        t <- names[i]
        assign(t, final(seas(Z[,i])))      
}

## (BrRATE & RiesgoPais are not seasonally adjusted, unable to perform adjustment procedure):
#RiesgoPais
RiesgoP <- as.data.frame(X$RiesgoPais)
RiesgoP <- ts(RiesgoP, start = c(1997,1), freq = 12)
monthplot(RiesgoP)

Year <- time(WTI, offset = 1)
Month <- cycle(WTI)

FINAL_DATA <- as.data.frame(cbind(Year, Month, WTI, ITCRA, ITCR_US, Exp_InflacionM, Exp_InflacionD, Exp_Inflacion12, Exp_TRMM, Exp_TRMD, Exp_TRM12, EOF_ACCIONES1, EOF_ACCIONES2, EOF_BR1, EOF_BR2, EOF_TRM1, EOF_TRM2, EOF_SPREAD1, EOF_SPREAD2, IGBCPESA, COLCAPPESA, BRENT, LACI, DXY, TOT, TOTciti, DTF, MONTO_DIVISAS, RentaV_CV, RentaF_CV, TRM, RiesgoPais, BrRATE))
write.dta(FINAL_DATA, 'main_sa.dta')



