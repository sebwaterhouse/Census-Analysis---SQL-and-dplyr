library(RSQLite)
library(microbenchmark)
library(dplyr)

#Create database connection(Serverless, in memory)
con <- dbConnect(RSQLite::SQLite(), ":memory:")

#Create tables
dbSendQuery(con,
            "CREATE TABLE census_income
       (SS_ID INTEGER PRIMARY KEY AUTOINCREMENT,
       AAGE NUM,
      ACLSWKR TEXT,
      ADTIND TEXT,
      ADTOCC TEXT,
      AHGA TEXT,
      AHRSPAY NUM,
      AHSCOL TEXT,
      AMARITL TEXT,
      AMJIND TEXT,
      AMJOCC TEXT,
      ARACE TEXT,
      AREORGN TEXT,
      ASEX TEXT,
      AUNMEM TEXT,
      AUNTYPE TEXT,
      AWKSTAT TEXT,
      CAPGAIN NUM,
      CAPLOSS NUM,
      DIVVAL NUM,
      FILESTAT TEXT,
      GRINREG TEXT,
      GRINST TEXT,
      HDFMX TEXT,
      HHDREL TEXT,
      MARSUPWT NUM,
      MIGMTR1 TEXT,
      MIGMTR3 TEXT,
      MIGMTR4 TEXT,
      MIGSAME TEXT,
      MIGSUN TEXT,
      NOEMP NUM,
      PARENT TEXT,
      PEFNTVTY TEXT,
      PEMNTVTY TEXT,
      PENATVTY TEXT,
      PRCITSHP TEXT,
      SEOTR TEXT,
      VETQVA TEXT,
      VETYN TEXT,
      WKSWORK NUM,
      YEAR TEXT,
      TRGT TEXT) ")
###not nullll


#Assigning table and column names to variable x, Strip white to get rid of leading whitespace
x <- read.table(file="census-income.data", sep = ",", strip.white = TRUE, col.names=c("AAGE","ACLSWKR", "ADTIND","ADTOCC","AHGA","AHRSPAY","AHSCOL","AMARITL","AMJIND","AMJOCC","ARACE","AREORGN","ASEX","AUNMEM","AUNTYPE","AWKSTAT","CAPGAIN", "CAPLOSS","DIVVAL","FILESTAT","GRINREG","GRINST","HDFMX","HHDREL","MARSUPWT","MIGMTR1","MIGMTR3","MIGMTR4","MIGSAME","MIGSUN","NOEMP","PARENT","PEFNTVTY","PEMNTVTY","PENATVTY","PRCITSHP","SEOTR","VETQVA","VETYN","WKSWORK","YEAR","TRGT"))

#Populating table with value X
dbWriteTable(con, "census_income", x, header = TRUE,overwrite=FALSE, append = TRUE)


#Selecting the number of females based on race
print(dbGetQuery(con, "SELECT ARACE, COUNT(*) 
                  FROM census_income 
                  WHERE ASEX= 'Female' 
                  GROUP BY ARACE"))

#Selecting the number of males based on race
print(dbGetQuery(con, "SELECT ARACE, COUNT(*) 
                  FROM census_income
                  WHERE ASEX= 'Male' 
                  GROUP BY ARACE"))

#Selecting the average pay where race is other and weeks worked 
print(dbGetQuery(con, "SELECT AVG(AHRSPAY*40)
                 FROM census_income 
                 WHERE AHRSPAY !=0  
                 AND ARACE = 'Other'")) 

#Selecting the average pay where race is white and weeks worked 
print(dbGetQuery(con, "SELECT AVG(AHRSPAY*40)  
                 FROM census_income 
                 WHERE AHRSPAY !=0  
                 AND ARACE = 'White'")) 

#Selecting the average pay where race is Black and weeks worked 
print(dbGetQuery(con, "SELECT AVG(AHRSPAY*40)
                 FROM census_income 
                 WHERE AHRSPAY !=0 
                 AND ARACE = 'Black'")) 

#Selecting the average pay where race is Asian or Pacific Islander and weeks 
print(dbGetQuery(con, "SELECT AVG(AHRSPAY*40)  
                 FROM census_income 
                 WHERE AHRSPAY !=0  
                 AND ARACE = 'Asian or Pacific Islander'"))

#Selecting the average pay where race is Amer Indian Aleut or Eskimo and weeks
print(dbGetQuery(con, "SELECT AVG(AHRSPAY*40) 
                 FROM census_income 
                 WHERE AHRSPAY !=0  
                 AND ARACE = 'Amer Indian Aleut or Eskimo'")) 

#Selecting the average pay for each race
print(dbGetQuery(con, "SELECT AVG(AHRSPAY*40),ARACE 
                 FROM census_income 
                 WHERE AHRSPAY !=0  
                 GROUP BY ARACE")) 

#Creating new table person from original table
print(dbSendQuery(con, "CREATE TABLE Person
                  AS SELECT SS_ID, 
                  AAGE, 
                  AHGA, 
                  ASEX, 
                  PRCITSHP, 
                  PARENT, 
                  GRINST, 
                  GRINREG, 
                  AREORGN, 
                  AWKSTAT 
                  FROM census_income"))

#Creating new table Job from orignal table
print(dbSendQuery(con, "CREATE TABLE Job
                  AS SELECT SS_ID, 
                  ADTIND, 
                  ADTOCC, 
                  AMJOCC, 
                  AMJIND 
                  FROM census_income"))

#Creating new table pay from original table
print(dbSendQuery(con, "CREATE TABLE Pay 
                  AS SELECT SS_ID, 
                  AHRSPAY, 
                  WKSWORK 
                  FROM census_income"))

#Selecting the number of people with max pay, in each state, by state 
print(dbGetQuery(con, "SELECT MAX(AHRSPAY), 
                 GRINST, COUNT(*), 
                 AMJOCC, AMJIND
                 FROM PAY INNER JOIN PERSON ON PAY.SS_ID = PERSON.SS_ID
                 INNER JOIN JOB ON PERSON.SS_ID = JOB.SS_ID
                 GROUP BY GRINST"))

print(dbGetQuery(con, "SELECT AVG(AHRSPAY),
                 AVG(WKSWORK),
                 AMJOCC,
                 AHGA,
                 AMJIND 
                 FROM PAY INNER JOIN PERSON ON PAY.SS_ID = PERSON.SS_ID 
                 INNER JOIN JOB ON PERSON.SS_ID = JOB.SS_ID 
                 WHERE AHGA = 'Bachelors degree(BA AB BS)' 
                 OR AHGA = 'Masters degree(MA MS MEng MEd MSW MBA)' 
                 OR AHGA ='Doctorate degree(PhD EdD)' 
                 AND AREORGN != 'All other'
                 AND AREORGN != 'Do not know'
                 AND AREORGN != 'NA'
                 GROUP BY AMJIND"))


                        


