#load function for reading csv data
source('portal_weather/csv_to_dataframe.r')

library(TTR)
library(zoo)

weathfile = "data/Monthly_ppt_1980_present_patched.csv"
weathframe = csv_to_dataframe(weathfile)

# ===================================================================================
# create time series 
end = tail(weathframe,1)
sumprecip.ts = ts(weathframe$sumprecip,start=c(1980,1),end=c(end$year,end$month),freq=12)
maxtemp.ts = ts(weathframe$maxtemp,start=c(1980,1),end=c(end$year,end$month),freq=12)
mintemp.ts = ts(weathframe$mintemp,start=c(1980,1),end=c(end$year,end$month),freq=12)

# ==================================================================================
# remove any remaining NAs using a linear approximation from the zoo package
sumprecip.ap = na.approx(sumprecip.ts)
maxtemp.ap = na.approx(maxtemp.ts)
mintemp.ap = na.approx(mintemp.ts)

# =================================================================================
# smoothing using SMA frmo TTR library (moving average)
smoothingfactor = 5*12

sumprecip.smooth = SMA(sumprecip.ap,smoothingfactor)
plot(sumprecip.smooth,xlab='',ylab='total precip',main=paste('n =',smoothingfactor))

maxtemp.smooth = SMA(maxtemp.ap,smoothingfactor)
plot(maxtemp.smooth,xlab='',ylab='max monthly temp',main=paste('n =',smoothingfactor))

mintemp.smooth = SMA(mintemp.ap,smoothingfactor)
plot(mintemp.smooth,xlab='',ylab='min monthly temp',main=paste('n =',smoothingfactor))


# ===============================================================================
# plots with enso
ensofile = "data/enso.csv"
ensoframe = csv_to_dataframe(ensofile)

enso.vec = as.vector(t(ensoframe[,c(2,3,4,5,6,7,8,9,10,11,12,13)]))
enso.ts = ts(enso.vec,start=c(1950,1),end=c(2013,6),freq=12)

enso.w = window(enso.ts,start=c(1980,1),end=c(2013,6))
precip.w = window(sumprecip.smooth,start=c(1980,1),end=c(2013,6))
maxtemp.w = window(maxtemp.smooth,start=c(1980,1),end=c(2013,6))
mintemp.w = window(mintemp.smooth,start=c(1980,1),end=c(2013,6))

par(mar = c(5, 4, 4, 4) + 0.3)  # Leave space for z axis
plot(enso.w) # first plot
par(new = TRUE)
plot(precip.w,col='red',xlab='',ylab='')

# ===============================================================================
# decompose timeseries
sumprecip.decom = decompose(sumprecip.ap)
plot(sumprecip.decom)
sumprecip.hw = HoltWinters(sumprecip.ap)
plot(sumprecip.hw$fitted)
seasonal = sumprecip.decom$seasonal
resids = sumprecip.ap-seasonal
plot(resids)

maxtemp.decom = decompose(maxtemp.ap)
plot(maxtemp.decom)

mintemp.decom = decompose(mintemp.ap)
plot(mintemp.decom)