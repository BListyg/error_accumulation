hurdle.data = function(propMin, nApplicants, nHurdles, rel, sr,adverse.impact){
  hurdle.gen = function(propMin, nApplicants, nHurdles, rel, sr){#, #sr
    
    #Load libraries
    library(MASS) #generate multivariate normal data for applicant scores
    library(stringi) #generate random alphanumeric values for applicant IDs
    
    #Function to mirror lower/upper triangle in matrix
    f <- function(m) {
      m[lower.tri(m)] <- t(m)[lower.tri(m)]
      m
    }
    
    #Mean MU equals 0 for each hurdle
    mu <- rep(0,nHurdles)
    
    #Generate standard deviations values for each hurdles and applicant
    sigma.hurdles <- diag(1,nrow = nHurdles)
    #Between assessment correlations from Roth et al. (2011) meta-analysis
    sigma.hurdles[upper.tri(sigma.hurdles)] = c(.31,.03,.40,.13,.37,.17)
    #Mirror lower triangle of Var-CoVar matrix over diagonal
    sigma.hurdles <- f(sigma.hurdles)
    
    error_var = ((1 - rel)/rel)
    
    #Errors are uncorrelated, 1's on diagonal, zeroes elsewhere
    sigma.error <- diag(error_var,nrow = nHurdles)
    
    # Generate sample of potential true scores with 
    #mean = 0, sd = 1, and correlations from above
    potential = mvrnorm(nApplicants, mu = mu, Sigma = sigma.hurdles, empirical = TRUE)
    
    #Generate random m.v. normal data to represent error with
    #mean = 0, sd = 1, and correlation = 0
    error = mvrnorm(nApplicants, mu = mu, Sigma = sigma.error )
    
    #Generate matrix to put applicant hurdle scores, generated all at once
    appscore = matrix(ncol=nHurdles,nrow=nApplicants)
    
    
    #Application score is based on formula by Scullen et al., 2005
    #For each value in the reliability vector, 
    #The corresponding column in the appscore matrix
    #is the reliability value times the potential (i.e. true score) of a given applicant
    #times the square root of 1 minus reliability time error
    for(i in 1:length(rel)){
      appscore[,i] = potential[,i]+error[,i]
    }
    
    #Assigning group membership to applicants
    group.membership = rbind(matrix(rep(0,propMin*nApplicants)),
                             matrix(rep(1,(1-propMin)*nApplicants)))
    
    #0 = minority, 1 = majority
    group.membership = group.membership[sample(nrow(group.membership)),]
    
    #Giving applicants random alphanumeric ID
    out = data.frame(cbind(stri_rand_strings(nrow(appscore), 5),group.membership,appscore))
    
    #Making these columns numeric
    out[,-c(1,2)] = apply(X = out[,-c(1,2)],MARGIN = 2,FUN = as.numeric)
    
    #Setting column names
    colnames(out) = c("applicant.id", "group.membership", paste("hurdle",".",1:nHurdles,sep = ""))
    
    return(out)
    
  }
  
  #Generating an initial applicant pool with hurdle.gen inner function
  hurdle0 = hurdle.gen(propMin = propMin,nApplicants = nApplicants,nHurdles = nHurdles, rel = rel, sr = sr)
  
  #dividing function
  divide = function(x){x[1]/x[2]}
  
  #Sequentially removing applicants based on percentile rank
  for(i in 1:nHurdles)
  {
    eval(parse(text = paste("hurdle",i, "=", "subset(hurdle",i-1,",","hurdle",i-1,"$hurdle.",i,"> quantile(hurdle",i-1,"$hurdle.",i,", prob = 1- sr[",i,"]))",sep = "")))
  }
  
  #Creating empty list
  out = list()
  
  #Putting applicant pool after each hurdle into "out" list
  for(i in 0:nHurdles){
    out[[i+1]] = eval(parse(text = paste("hurdle",i,sep="")))
  }
  
  if(adverse.impact == TRUE){
    return(list(table(out[[1]]$group.membership)/nrow(out[[1]]),
                (table(out[[2]]$group.membership) / table(out[[1]]$group.membership)),
                (table(out[[3]]$group.membership) / table(out[[2]]$group.membership)),
                (table(out[[4]]$group.membership) / table(out[[3]]$group.membership)),
                (table(out[[5]]$group.membership) / table(out[[4]]$group.membership)),
                (table(out[[5]]$group.membership) / table(out[[1]]$group.membership))
                 ))
  }
  else if(adverse.impact==FALSE){
    return(out)}
  else if(adverse.impact=="ALL"){
    return(list(
      out = out,
      list(table(out[[1]]$group.membership)/nrow(out[[1]]),
           (table(out[[2]]$group.membership) / table(out[[1]]$group.membership)),
           (table(out[[3]]$group.membership) / table(out[[2]]$group.membership)),
           (table(out[[4]]$group.membership) / table(out[[3]]$group.membership)),
           (table(out[[5]]$group.membership) / table(out[[4]]$group.membership)),
           (table(out[[5]]$group.membership) / table(out[[1]]$group.membership))
      ),
      lapply(list(table(out[[1]]$group.membership)/nrow(out[[1]]),
                  (table(out[[2]]$group.membership) / table(out[[1]]$group.membership)),
                  (table(out[[3]]$group.membership) / table(out[[2]]$group.membership)),
                  (table(out[[4]]$group.membership) / table(out[[3]]$group.membership)),
                  (table(out[[5]]$group.membership) / table(out[[4]]$group.membership)),
                  (table(out[[5]]$group.membership) / table(out[[1]]$group.membership))
      ),FUN = divide),
      cbind(table(out[[1]]$group.membership),
            table(out[[2]]$group.membership),
            table(out[[3]]$group.membership),
            table(out[[4]]$group.membership),
            table(out[[5]]$group.membership))
    ))
  }
}
