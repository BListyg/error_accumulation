# error_accumulation

This is simulation code for a symposium I presented at on the utility of agent-based / computational modelling in the organizational sciences. This is joint work with Dr. Michael Braun, Christina Barnett, Michelle Kaplan, and Shannon Cooney from the University of South Florida.

This simulation code demonstrates the inferrential errors that can occur in sequential organizational systems (e.g. a multiple hurdle selection system)

Pseudocode:

* Create applicant pool of size n

* Create "True Score" values drawn from MVN distribution
  * Number of hurdles determines # of dimensions in distribution
  
* Add MVN values as "error" to "True Score" values

* Assign applicants to Majority or Minority group status

* Filter out applicants based on user-set selection ratio

* Computes Adverse Impact at each hurdle

```
hurdle.data(propMin = 0.5, 
            nApplicants = 100, 
            nHurdles = 4, 
            rel = rep(1,4), 
            sr = rep(0.4, 4), 
            adverse.impact = FALSE)
```
