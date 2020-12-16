/** Naive visits : I.e; no filtering of any sort other than status and date **/
SET NOCOUNT ON;
Use Mosaiq;
SELECT Sch_Id
      ,App_DtTm
      ,ISNULL(QUOTENAME(Short_Desc,'"'),'') as Activity_Description 
      ,ISNULL(QUOTENAME(LOCATION,'"'),'') as Location
      ,ISNULL(QUOTENAME(PAT_NAME,'"'),'') as Pat_Name
      ,MD_INITIALS as provider_initials
      ,IDA as mrn     
  FROM vw_Schedule sch
 
  WHERE
  convert(varchar,App_DtTm,112) >= convert(varchar,dateadd(day,-1,getdate()),112) 
  AND convert(varchar,App_DtTm,112)  < convert(varchar,getdate(),112)
  AND  SysDefStatus in (' C','D','E','SC','FC', 'FD', 'FE',  'OC', 'OD', 'OE', 'SC', 'SD','SE')
  AND IDA not in ('','0000','00000000000','001123456','123456','123')
  AND (IDA != ' ' OR IDA != '***************'  
       OR IDA IS NOT NULL OR IDA NOT LIKE '%Do Not Use%' ) 

