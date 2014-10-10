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
  
  #grabbing user uploaded file and applies buildPortReg function on it.
  
  #Computer the GARCH part
  spec=ugarchspec(
    variance.model=list(
      model='sGARCH',
      garchOrder=c(1,1),
      submodel=NULL,
      external.regressors=NULL,
      variance.targeting=FALSE
    ),
    mean.model=list(
      armaOrder=c(0,0),
      include.mean=FALSE,
      archm=FALSE,
      archpow=0,
      arfima=FALSE,
      external.regressors=NULL,
      archex=FALSE
    ),
    distribution.model='sstd',
  )
  
  inFile=reactive({input$file})

  observe({
    if (is.null(inFile())) {
      output$greeting=renderText({"Please upload a file"})
    }else{
      reg=reactive({
        
        inFile<-input$file
        
        inFile=read.csv(inFile$datapath,head=FALSE)
        
        return(buildPortReg(inFile,input$dateRange[1],factors)[paste(input$dateRange[1],"/",input$dateRange[2],sep="")])
      })
      
      
      modelCAPM=reactive(lm(I(ret-RF)~MarketPremium,data=reg()))
      modelFF3=reactive(lm(I(ret-RF)~MarketPremium+SMB+HML,data=reg()))
      
      output$regTable <- renderPrint({        
        
        stargazer(modelCAPM()
                  ,modelFF3()
                  ,type="html"
                  ,title=paste("Factor Loadings from"
                               ,range(index(reg()))[1]
                               ,"to"
                               ,range(index(reg()))[2]
                               ,":")
                  ,dep.var.labels="Portfolio Returns"
                  ,dep.var.caption = "Dependant Variable:")
        
        
      })
      
      #Allows user to download output
      output$downloadData <- downloadHandler(
        filename = "PortfolioReturns.csv",
        content = function(con) {
          write.zoo(reg(),con,index.name="date")
        }
      )
      
      fit=reactive({ugarchfit(spec=spec,data=log(1+reg()$ret))})
      
      
      
      output$garchPlot=renderPlot({
        plot(fit(),which=garchWhichPlot())
      })
      
      
      garchWhichPlot=reactive({
        switch(input$garchPlotType,
               "Series with 1% VaR limites"=2,
               "QQ-Plot"=9
        )
      })
      
      output$downloadReport=downloadHandler(filename="quickQuantsReport.pdf",
                                            content=function(file){
                                              #Thanks, to brechtdv
                                              # generate PDF
                                              knit2pdf("report.Rnw")
                                              
                                              # copy pdf to 'file'
                                              file.copy("report.pdf", file)
                                              
                                              # delete generated files
                                              file.remove("report.pdf", "report.tex",
                                                          "report.aux", "report.log")
                                              
                                              # delete folder with plots
                                              unlink("figure", recursive = TRUE)
                                            },
                                            contentType = "application/pdf"
      )
      #end of else statement under the observe part
    }
    
    
    

  })
  
  
  
  
  
  
})










