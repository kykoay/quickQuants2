library(shiny)
library(quantmod)
library(xts)
library(rugarch)
library(stargazer)
library(knitr)

shinyServer(function(input,output){
  source("buildPortReg.R")
  #Download factor data from Ken French's website. Possibily to extend to higher dimensions, but have to harmonise factor time series.
  #This script is from Evan, and it extracts the FF-3 Factors and names it factors.
  download.file("http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/ftp/F-F_Research_Data_Factors_daily.zip","factors.zip")
  
  factors=unz("factors.zip","F-F_Research_Data_Factors_daily.txt")
  factors=read.table(factors,header=TRUE,skip=4,fill=TRUE)
  n=nrow(factors)-1
  
  factors=unz("factors.zip","F-F_Research_Data_Factors_daily.txt")
  factors=read.table(factors,header=TRUE,skip=4,fill=TRUE,nrows=n)
  row.names(factors)=(as.Date(row.names(factors),format="%Y%m%d"))
  names(factors)[names(factors)=="Mkt.RF"]="MarketPremium"
  
  
  factors=as.xts(factors/100,dateFormat="Date")
  
  #read the file uploaded by user
  inFile=input$file
  
  #Copy Evan's reactive part,that is, the BuildReg part.
  
  
  
  
  #Make the selected dates and uploaded tickers and weights reactive.
  dataInput<-reactive({
    inFile<-input$file
    
    getSymbols(as.character(read.csv(inFile$datapath,head=FALSE)[,1]),src="yahoo",from=input$dates[1],to=input$dates[2],auto.assign=TRUE)
    Adjusted<-do.call(merge, lapply(as.character(read.csv(inFile$datapath,head=FALSE)[,1]), function(x) Ad(get(x))))
  })
  
  portret=0
  ret=NA
  for (j in 1:length(weights)){
    for(i in 2:nrow(Adjusted)){
      ret[i]=(as.numeric(Adjusted[i,j])/as.numeric(Adjusted[i-1,j]))-1
    }
    portret=portret+(weight[j]*ret)
  }
  portret=na.omit(portret)
  
  #As an illustration, let's plot portfolio returns.  
  #portret=0
  #ret=NA
  #for (j in 1:length(weights)){
  #for(i in 2:nrow(Adjusted)){
  #ret[i]=(as.numeric(Adjusted[i,j])/as.numeric(Adjusted[i-1,j]))-1
  #}
  #portret=portret+(weight[j]*ret)
  #}
  #portret=na.omit(portret)
  
  output$plot<-renderPlot({
    plot(portret, 
         type = "line", TA = NULL,ylim=c(-0.20,0.2))
  })
  
  
  
})













