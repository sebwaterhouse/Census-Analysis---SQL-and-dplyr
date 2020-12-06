library(dplyr)

#Reading data from file
data <- read.csv("census-income.data", sep = ",", strip.white = TRUE, check.names = FALSE)    
#Assigning collumn names
colnames(data) <- c("AAGE",  "ACLSWKR",  "ADTIND",  "ADTOCC",  "AHGA",  "AHRSPAY",  "AHSCOL",  "AMARITL",  "AMJIND",  "AMJOCC",  "ARACE",  "AREORGN",  "ASEX",  "AUNMEM",  "AUNTYPE",  "AWKSTAT",  "CAPGAIN",  "CAPLOSS",  "DIVVAL",  "FILESTAT",  "GRINREG",  "GRINST",  "HDFMX",  "HHDREL",  "MARSUPWT",  "MIGMTR1",  "MIGMTR3",  "MIGMTR4",  "MIGSAME",  "MIGSUN",  "NOEMP",  "PARENT",  "PEFNTVTY",  "PEMNTVTY",  "PENATVTY",  "PRCITSHP",  "SEOTR",  "VETQVA",  "VETYN",  "WKSWORK",  "YEAR",  "TRGT")
##Incrementing SS_ID based on no. of rownames
data <-  mutate(data, SS_ID = rownames(data))


##Number of each sex by race
print(sex_race_numbers <- data %>%
        group_by(ARACE, ASEX) %>%
        tally() %>% arrange(desc(ARACE)))

##Mean income for each race
print(incomeByRace<-select(data, ARACE, AHRSPAY, WKSWORK) %>%
        group_by(ARACE) %>%
        filter(AHRSPAY !=0) %>%
        summarise(avgIncome =mean(AHRSPAY * 40)) %>%
        arrange(desc(avgIncome)))


#Create new person DF
personDf <- data %>% select(SS_ID, AAGE, AHGA, ASEX, PRCITSHP,
         PARENT, GRINST, GRINREG, AREORGN, AWKSTAT)

#Create new job DF
jobDf<- data %>% select(SS_ID, ADTIND, ADTOCC, AMJOCC, AMJIND)

#Create new payDf 
payDf <- data %>% select(SS_ID, AHRSPAY, WKSWORK)

#Created a combined table using inner join
combinedTbl<-data %>% inner_join(personDf, payDf, 
  by= 'SS_ID',suffix = c("_original", "_new")) %>%
  inner_join(., jobDf, by= 'SS_ID', suffix = c("_original", "_new") )


#Max wage
print(maxWage <- combinedTbl %>% summarise(max(AHRSPAY)))

#Get max wage ID
maxWageID <- combinedTbl %>%
  filter(AHRSPAY == max(AHRSPAY)) %>%
  select(SS_ID, AHRSPAY) %>% .$`SS_ID`

#get best paid job
print(highJob <- combinedTbl %>%
        filter(SS_ID ==  maxWageID) %>% .$`AMJOCC_new`)
      
#number in job 
print(number_in_job <- combinedTbl %>% filter(AMJOCC_new == highJob) %>%
  tally())

#states with high paying job
print(state <- combinedTbl %>% filter(SS_ID == maxWageID) %>% .$`GRINST_new`)

#number of people in high paying job by state
print(number_in_state <- combinedTbl %>% filter(GRINST_new == state) %>%
  group_by(GRINST_new) %>% tally())

#Highest paid industry
print(Industry <- combinedTbl %>% filter(AHRSPAY == max(AHRSPAY)) %>% .$`AMJIND_new`)

#Number in industry
print(numberInIndustry <- combinedTbl %>% filter(AMJIND_new == Industry) %>%
  tally())
        
    
##Hispanic professional with degree
print(hispanicProfessionalsWage<-
        select(combinedTbl, AREORGN_new, AHGA_new, AMJIND_new, AHRSPAY, WKSWORK) %>%
        filter(AREORGN_new != 'All other',
               AREORGN_new != 'Do not know',
               AREORGN_new != 'NA',
               AHGA_new %in% c('Bachelors degree(BA AB BS)',
                               'Masters degree(MA MS MEng MEd MSW MBA)',
                               'Doctorate degree(PhD EdD)')) )



print(hispanicProfessionalsDistinct<- hispanicProfessionalsWage %>% distinct(AMJIND_new))

##Hispanic professional average wage assuming 40 weeks worked
print(hispanicProfessionalsAvgWage <-hispanicProfessionalsWage %>%
  summarise(avgIncome = mean(AHRSPAY * 40)))

##Hispanic Professionals averaged weeks worked

print(hispanicProfessionalsAvgWeeks <-hispanicProfessionalsWage %>%
  summarise(avgWeek = mean(WKSWORK)))
 











        
  