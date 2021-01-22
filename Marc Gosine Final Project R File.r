college = read.csv('scorecard.csv')
#importing dataset. Originally assembled in Python
college = na.omit(college)
#omitting NA and NULLs to avoid errors in regression. Code from R for Dummies
names(college)
#Showing column names

#Extra Data Cleaning
library('dplyr')
college2 = mutate(college, salary_to_rev = round(school.faculty_salary/school.tuition_revenue_per_fte,digits = 3))
#Creating unique variable which is the ratio of the faculty salary and tution revenue per full time student
college2 = filter(college2, !is.infinite(salary_to_rev))
#Getting rid of Inf values to avoid errors when running regression. Code from Quick R
college2 = rename(college2, SAT_Scores = latest.admissions.sat_scores.average.overall, Full_Time_Rate = school.ft_faculty_rate, 
       Percent_White = latest.student.demographics.race_ethnicity.white)
#Renaming colums to make names more comprehensible

r3 = lm(SAT_Scores ~ log(salary_to_rev) + Full_Time_Rate 
        + factor(school.region_id), data = college2)
#Initial Preferred Regression (No robust std errors) 
summary(r3)
#Calls upon regression analysis

library(estimatr)
#loaded in to run robust model
r4 = lm_robust(SAT_Scores ~ log(salary_to_rev) + Full_Time_Rate 
        + factor(school.region_id), data = college2)
#Finalized Regression (With robust standard errors to solve for heteroskedasticity)
summary(r4)

library(estimatr)
library(stargazer)
library(lmtest)  
library(sandwich)

cov1         = vcovHC(r3, type = "HC1")
robust_se    = sqrt(diag(cov1))
# Adjust standard errors

wald_results = waldtest(r3, vcov = cov1)
# Adjust F statistic 

stargazer(r3, r3, type = "html", column.labels = c("Normal","Robust"), se = list(NULL, robust_se),
          omit.stat = "f", model.names = FALSE,
          title            = "Data Results",
          covariate.labels = c("Salary to Revenue (logged)", "Full Time Rate","New England","Mid East","Great Lakes","Plains","Southeast",
                              "Southwest","Rocky Mountains","West Coast","Territories"),
          dep.var.labels   = "SAT Scores")
#Code for regression table
