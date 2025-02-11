#load libraries
library(rpatrec)

####################################### fast response simulation ####################################
noise.levels=seq(0.01,1,0.01)
iter = length(noise.levels)
n = 100
AIC.sens <- matrix(NA, nrow=iter, ncol=n)
AIC.lm <- matrix(NA, nrow=iter, ncol=n)
tSNR <- matrix(NA, nrow=iter, ncol=n)

for (j in 1:n){
  signal.offset<-sort(round(runif(n = 2,min = 1000,1100))) #randomly produce a BOLD signal range
  for (i in 1:length(noise.levels)){ #loop through increasing noise levels
    x <- as.matrix(seq(-60,110,1)) #define on/off period
    
    #design BOLD signal with noise
    x.model = ifelse(x <= 0, 0,1)
    y <- as.matrix(sigmoid(x)) #create sigmoid curve 
    time <- as.numeric(1:length(y)) #add time parameter
    y.noise <- noise(y,'white',noise.levels[i]) #add white noise to sigmoid curve
    y.noise <- scales::rescale(y.noise,to=signal.offset) #scale data to signal range 
    y       <- scales::rescale(y,to=signal.offset) #scale data to signal range 
    
    lm.paradigm <- as.matrix(read.csv(file = "/Users/kayleymarchena/Documents/CVR_SOP/for_CVR/cvr_sop/R files/data4simulation.txt",header = F,stringsAsFactors = F,sep = " "))
    lm.paradigm <- scales::rescale(lm.paradigm,to=c(0,1))
    lm.paradigm <- lm.paradigm[c(1:171)]
    sig.model <- as.data.frame(cbind(y.noise,time,y,x.model,lm.paradigm))
    names(sig.model) <- c("sigANDnoise","time","truth","paradigm","lm.paradigm")
    
    # Model fitting
    sig.model <- sig.model[c(1:(colSums(x<=0)*2)),] #limit sens slope analysis to equal on/off period
    sig.sens  <- senss(sigANDnoise ~ time, sig.model) #calculate sens slope
    sig.lm    <- lm(sigANDnoise ~ lm.paradigm, sig.model) #calculate slope from linear regression
    
    # calculate AIC measure
    AIC.sens[i,j] <- AIC(sig.sens)
    AIC.lm[i,j] <- AIC(sig.lm)
    
    #calculate tSNR
    mean.y <- mean(y.noise[c(20:50)],)
    std.y <- sd(y.noise[c(20:50)],)
    tSNR[i,j] <- mean.y/std.y
  }
  
  ####################################### slow response simulation ####################################
  # declare variables to print out
  noise.levels=seq(0.01,1,0.01)
  iter = length(noise.levels)
  n = 100
  AIC.sens    <- matrix(NA, nrow=iter, ncol=n)
  AIC.lm   <- matrix(NA, nrow=iter, ncol=n)
  tSNR <- matrix(NA, nrow=iter, ncol=n)
  
  for (j in 1:n){
    signal.offset<-sort(round(runif(n = 2,min = 1000,1100))) # random produce BOLD signal range
    for (i in 1:length(noise.levels)){ #loop through increasing noise levels
      ramp <- f(1:170, 60, 50, 0, 1, "ramp")
      x <- as.matrix(ramp$y)
      x.model <- ifelse(ramp$y==0,0, ifelse(ramp$y==1,1,NA))
      ramp$y.noise <- noise(ramp$y,'white',noise.levels[i])
      y.noise <- ramp$y.noise
      y <- ramp$y
      time <- ramp$x
      y.noise <- scales::rescale(y.noise,to=signal.offset) #scale data to original preprocessed signal range 
      y       <- scales::rescale(y,to=signal.offset)
      
      lm.paradigm <- as.matrix(read.csv(file = "/Users/kayleymarchena/Documents/CVR_SOP/for_CVR/cvr_sop/R files/data4simulation.txt",header = F,stringsAsFactors = F,sep = " "))
      lm.paradigm <- scales::rescale(lm.paradigm,to=c(0,1))
      lm.paradigm <- lm.paradigm[c(1:171)]
      sig.model <- as.data.frame(cbind(y.noise,time,y,x.model,lm.paradigm))
      names(sig.model) <- c("sigANDnoise","time","truth","paradigm","lm.paradigm")
      
      # Model fitting
      sig.sens  <- senss(sigANDnoise ~ time, sig.model) #calculate sens slope
      sig.lm    <- lm(sigANDnoise ~ lm.paradigm, sig.model) #calculate slope from linear regression
      
      # calculate AIC measure
      AIC.sens[i,j] <- AIC(sig.sens)
      AIC.lm[i,j] <- AIC(sig.lm)
      
      #calculate tSNR
      mean.y <- mean(y.noise[c(20:50)],)
      std.y <- sd(y.noise[c(20:50)],)
      tSNR[i,j] <- mean.y/std.y
    }
    print(j)
  }