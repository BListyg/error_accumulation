# error_accumulation
Simulation code demonstrating the propagation of error in sequential organizational systems (i.e. multiple hurdle selection system)

Pseudocode:

* Create applicant pool of size n

* Create "True Score" values drawn from MVN distribution
  * Number of hurdles determines # of dimensions in distribution
  
* Add MVN values as "error" to "True Score" values

* Assign applicants to Majority or Minority group status

* Filter out applicants based on user-set selection ratio

* Computes Adverse Impact at each hurdle

'''hurdle.data(propMin = 0.5, 
            nApplicants = 100, 
            nHurdles = 4, 
            rel = rep(1,4), 
            sr = rep(0.4, 4), 
            adverse.impact = FALSE)'''
