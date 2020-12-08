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
  FROM [Mosaiq].[dbo].[vw_Schedule] 
  WHERE
--      App_DtTm>= dateadd(day,-2,Getdate())    --- this is when trying the query late in the day (for really yesterday)
--	  and       App_DtTm<= dateadd(day,-1,Getdate()) 
  App_DtTm >= DATEADD(day,-1,GETDATE())  
  AND App_DtTm <=getdate()
  AND  SysDefStatus in (' C','D','E','SC','FC', 'FD', 'FE',  'OC', 'OD', 'OE', 'SC', 'SD','SE')


