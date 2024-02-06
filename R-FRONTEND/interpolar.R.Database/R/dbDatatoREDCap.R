# load libraries
library(redcapAPI)
library(RPostgres)
library(DBI)

#get data from patient view / tabelle, schema _out
#establish connection to db
dbcon<-dbConnect(RPostgres::Postgres(),dbname=dbname,host=dbhost,port=dbport,user=dbfrontenduser,password=dbfrontendpassword,
                 options=dbfrontendoptionsout)

#get relevant columns
NewData<-dbGetQuery(dbcon, "SELECT record_id,pat_id,pat_name,pat_vorname,pat_ak_alter FROM patient")

#connect to REDCap project
redcapcon<- redcapConnection(url = url,token = token)

#send data to REDCap
importRecords(redcapcon,data = NewData,logfile = "log.txt")

#disconnect from db
dbDisconnect(dbcon)
rm(dbConnect)
rm(redcapcon)
