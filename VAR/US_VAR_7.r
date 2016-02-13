###
### ���������� VAR ������ ��������� ��� - ��� �� R
### 08.02.2016
### �����: ��������� ��������
### 
### �������� ������ (Matlab):
###     http://www.mathworks.com/help/econ/examples/modeling-the-united-states-economy.html
###
###
### ���� �������: 
###      https://github.com/epogrebnyak/cmf-macro#22-var-������
###


# ��� ����� ������� (��� ����������): 
# 15:19 08.02.2016
# - �������� ������ �������� �� FRED� �� URL + ��������� ���������� ������ � ���� ������
# - ������� � ������� - ���� ������ ������� ��� ����� ������� ����������� AR ������ (2-3 ����������)
#   �� �� ������ ������, � ������ - ����� �������� �������� ��� ����� ������ +  ����������� � �������
# - ��������, ����� VAR �� ����������� - ��� ������ ��������� �������, ������� � �.�. - � ��� ������� ����������� ������
# - ����� �������� ��������� �������� ������ - ������������ �������� � �.�. 
# - ���������� �������?


install.packages("vars")
install.packages("car")
install.packages("lmtest")
install.packages("strucchange")
install.packages("het.test")
install.packages("sandwich")
library(strucchange)
library(vars)
library(lmtest)
library(car)
library(het.test)
library(datasets)
library(FinTS)
library(fGarch)
library(evd)
library(stats)
library(datasets)
library(mFilter)
library(forecast)
library(sandwich)

#������ ������
setwd("C:\Users\�������\Documents\GitHub\bis\cmf-macro\VAR")
GDP <- read.csv("GDP.csv", header=TRUE, sep=";")
ThreeMTrBill <- read.csv("ThreeMTrBill.csv", header=TRUE, sep=";")
TenTrBill <- read.csv("TenTrBill.csv", header=TRUE, sep=";")
COE <- read.csv("COE.csv", header=TRUE, sep=";")
CPI <- read.csv("CPI.csv", header=TRUE, sep=";")
GDPDEF <- read.csv("GDPDEF.csv", header=TRUE, sep=";")
GI <- read.csv("GI.csv", header=TRUE, sep=";")
M1 <- read.csv("M1.csv", header=TRUE, sep=";")
M2 <- read.csv("M2.csv", header=TRUE, sep=";")
NonFarmInd <- read.csv("NonFarmInd.csv", header=TRUE, sep=";")
PerCons <- read.csv("PerCons.csv", header=TRUE, sep=";")
PrInv <- read.csv("PrInv.csv", header=TRUE, sep=";")
RES <- read.csv("RES.csv", header=TRUE, sep=";")
UNRATE <- read.csv("UNRATE.csv", header=TRUE, sep=";")

# ��������� ��� (��������� �� ��� ������ ����� ���������� ����� � �������������, ����� �������� � ������ �������)

StartDate <- "01.01.1959"
EndDate <- "01.07.2015"
StartDate_1 <- "01.02.1959"
StartYear <- 1959
EndYear <- 2015
Add <- 2
T <- 4*(EndYear - StartYear) + Add

# �������, ���������� ������� ������, �� ����� �������� � � ���������� ��������
cutting <- function (x)
{
StartInd <- which (x[,1]==StartDate)
EndInd <- which (x[,1]==EndDate)
x <- x[StartInd:EndInd,]
if (x[2,1] == StartDate_1) 
	{
		j <- 1
		for (i in 1:T)
		{
			x[i,1] <- x[j,1]
			x[i,2] <- x[j,2]
			j <- j + 3
		}
	}
x[,2] <- log(x[,2], base = exp(1))
return (x[1:T,2])
}

# �������� ������

GDP <- cutting(GDP)
ThreeMTrBill <- cutting(ThreeMTrBill)
TenTrBill <- cutting(TenTrBill)
COE <- cutting(COE)
CPI <- cutting(CPI)
GDPDEF <- cutting(GDPDEF)
GI <- cutting(GI)
M1 <- cutting(M1)
M2 <- cutting(M2)
NonFarmInd <- cutting(NonFarmInd)
PerCons <- cutting(PerCons)
PrInv <- cutting(PrInv)
RES <- cutting(RES)
UNRATE <- cutting(UNRATE)

# ���������� ������ � ������� ������� (��������� ��������� � ���� � �.�.)

rRES <- 0.01*(RES)
rTenTrBill <- 0.01*(TenTrBill)
rThreeMTrBill <- 0.01*(ThreeMTrBill)
rUNRATE <- 0.01*(UNRATE)

ret2tick <- function (x)
{
y <- rep(x[1]*0.25, times=T)
for (i in 2:T)
y[i] <- y[i-1]*(1+x[i]*0.25)
return(y)
}

RES <-log(ret2tick(rRES))
TenTrBill <- log(ret2tick(rTenTrBill))
ThreeMTrBill <- log(ret2tick(rThreeMTrBill))
UNRATE <-log(ret2tick(rUNRATE))

# ������� �������� � ������� ��������� � ��������� � ���������

annual <- function(x)
{
j <- 1
for (i in 1:(T/4))
	{
	x[i] <- (x[j+1]+x[j+2]+x[j+3]+x[j+4]-4*x[j])
	j <- j + 4
	}
return(x[1:(T/4)])
}

# ������� � ������� ��������� � ��������� � ���������

rCons <- annual(PerCons)
rCPI <- annual(CPI) 
rDEF <- annual(GDPDEF)
rGCE <- annual(GI) 
rGDP <- annual(GDP)
rHOURS <- annual(NonFarmInd)
rINV <- annual(PrInv)
rM1 <- annual(M1)
rM2 <- annual(M2)
rWAGES <- annual(COE)

# ������ ������, ��� �������� � ����� ������� VAR

dat <- cbind(rGDP, rDEF, rWAGES, rHOURS, rThreeMTrBill, rCons, rINV, rUNRATE)

# ������� �����

TimeSeries <- rep(0, times=(T/4))
for (i in 1:(T/4))
TimeSeries[i] <- i

# �������� ��������� �������� ��� ������������ ��������� ������

plot(TimeSeries, rINV,type="l")
lines(rGDP,col="red")

plot(TimeSeries, rCPI,type="l")
lines(rDEF,col="red")

# �������� ������� VAR (������ �������� ������� 10, ������ ����� ������� ������� ����� � ��������� �������� 
# �� ���� �� ������� (�� ���� �� ������� ������� ������� NA), �������  ������ ���������� ������� 5

VARselect(dat, lag.max = 30, type = c("const"),
season = NULL, exogen = NULL)

# ������ VAR

dataVAR <- VAR(dat, p = 5, type = c("const"),
season = NULL, exogen = NULL, lag.max = NULL,
ic = c("AIC", "HQ", "SC", "FPE"))
print(dataVAR)

# �������� VAR �� ������ (�������������� � �������������� � ��������������������), ������ ������ ���������
# �� ����, ��� ��������, ��� ��� �� ����, ��� ����������� ������� ����-����� (����� ������� �������� ����������, � ��� ������� �� ��� �������� �� �������)

arch.test(dataVAR, lags.single = 16, lags.multi = 5, multivariate.only = TRUE)

normality.test(dataVAR, multivariate.only = TRUE)

serialtest <- serial.test(dataVAR, lags.pt = 16, lags.bg = 5,
type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"))
#err1 <- rnorm(T)
#dwtest(dataVAR ~ err1)
whites.htest(dataVAR)

var.2c.stabil <- stability(dataVAR, type = "Rec-CUSUM")
plot(var.2c.stabil)

stability(dataVAR, type = c("OLS-CUSUM", "Rec-CUSUM", "Rec-MOSUM",
"OLS-MOSUM", "RE", "ME", "Score-CUSUM", "Score-MOSUM", "fluctuation"),
h = 0.15, dynamic = FALSE, rescale = TRUE)

# covmatrix <- NeweyWest(dataVAR, lag = NULL, order.by = NULL, prewhite = 5, adjust = FALSE, 
  diagnostics = FALSE, sandwich = TRUE, ar.method = "ols", data = list(),
  verbose = FALSE)

# ����� ��������� VAR

plot(dataVAR, boundary = TRUE)

# ������������� ��������� 10 ��������, �������� ������� �� ��������� � ��������

data_for_prediction <- dat[1:216,]
VARselect(data_for_prediction, lag.max = 30, type = c("const"),
season = NULL, exogen = NULL)
dataVAR_for_pr <- VAR(data_for_prediction, p = 5, type = c("const"),
season = NULL, exogen = NULL, lag.max = NULL,
ic = c("AIC", "HQ", "SC", "FPE"))

# �������, ���������� ������� �������� � ���������� ��������

dataVARpred <- predict(dataVAR_for_pr, n.ahead = 10, ci = 0.95)
plot(dataVARpred)
print(dataVAR)

# �������� �������� ��������, ���������� �������� MAPE

Len <- length(dat)/8
print(dat[(Len-9):Len,8]-dataVARpred$fcst$rUNRATE[,1])
print((dat[(Len-9):Len,8]-dataVARpred$fcst$rUNRATE[,1])/dat[(Len-9):Len,8])

# ����������� the forecast error variance decomposition of a VAR(p) for n.ahead steps

fevd(dataVAR, n.ahead = 10)

# �������� ���������� ������

irfdata <- irf(dataVAR, impulse = NULL, response = NULL, n.ahead = 10, ortho = TRUE,
cumulative = FALSE, boot = TRUE, ci = 0.95, runs = 100, seed = NULL)

plot(irfdata)

# ������ ������������� �������� ��� � ���������� ���������

dataAbs <- cbind(GDP, GDPDEF, COE, NonFarmInd, ThreeMTrBill, PerCons, PrInv, UNRATE)
VARselect(dataAbs, lag.max = 20, type = c("const"),
season = NULL, exogen = NULL)

# ����������� ���������� �������� 2-�� �������, ������ ������ �������� 10, �� 10 ������� ������� �������, ������� 2-��

dataVARAbs <- VAR(dataAbs, p = 2, type = c("const"),
season = NULL, exogen = NULL, lag.max = NULL,
ic = c("AIC", "HQ", "SC", "FPE"))

# ����������� VAR

print(dataVARAbs)

# ������������� �� 10 ��������� ������ (������� ������� ���� ���������, ����� ������ ��� ������������ �� ��������)

dataVARpredAbs <- predict(dataVARAbs, n.ahead = 10, ci = 0.95)
plot(dataVARpredAbs)
plot(dataVARpredAbs$fcst$GDP[,1]-dataVARpredAbs$fcst$GDPDEF[,1])

# ����������� ����������������� ���

print(dataVARpredAbs$fcst$GDP[,1]-dataVARpredAbs$fcst$GDPDEF[,1])

# �������� ����� � ���� � ������ ��

y <- ts(log(dataVARpredAbs$fcst$GDP[,1]-dataVARpredAbs$fcst$GDPDEF[,1]), start = c(1959, 8), freq = 2)
stl.y <- stl(y,s.window="periodic",robust=FALSE)

trend <- stl.y$time.series[,"trend"]
seasonal <- stl.y$time.series[,"seasonal"]
remainder <- stl.y$time.series[,"remainder"]
hp.trend <- hpfilter(stl.y$time.series[,"trend"], type="lambda", freq=NULL, drift=FALSE)
cycle <- hpfilter(hp.trend$cycle, type="lambda", freq=NULL)$trend
x <- c(y,my_answer)
trend1 <- hp.trend$trend
plot(trend1)
plot(cycle)

