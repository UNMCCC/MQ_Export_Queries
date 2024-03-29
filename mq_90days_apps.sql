/** Naive visits : I.e; no filtering of any sort other than status and date 
	1/13/2022: Modified to pull 3 months back ~ 90 days
**/
SET NOCOUNT ON;
Use Mosaiq;

SELECT Sch_Id
      ,App_DtTm
      ,ISNULL(QUOTENAME(Short_Desc,'"'),'') as Activity_Description
      ,ISNULL(QUOTENAME(LOCATION,'"'),'') as Location
      ,ISNULL(QUOTENAME(PAT_NAME,'"'),'') as Pat_Name
	  ,CASE 
			WHEN sch.[STF_LAST_NAME] LIKE 'Infusion%'
				THEN ISNULL(QUOTENAME(TRIM(stf.Last_Name) + ', ' + TRIM(stf.First_Name),'"'),'') --attending
			WHEN sch.STF_LAST_NAME IS NULL
				THEN ISNULL(QUOTENAME(TRIM(stf.Last_Name) + ', ' + TRIM(stf.First_Name),'"'),'') --attending
			ELSE ISNULL(QUOTENAME(TRIM(sch.STF_LAST_NAME) + ', ' + TRIM(sch.STF_First_NAME),'"'),'') --provider
		END AS provider_initials
	  ,IDA as mrn --,DATENAME(DW, GETDATE())
  FROM vw_Schedule sch
	LEFT JOIN Staff stf ON sch.[Attending_Md_Id] = stf.[Staff_ID] -- add staff table to get provider full name
  WHERE
	convert(varchar,App_DtTm,112) >= convert(varchar,dateadd(day,-91,getdate()),112) -- pulls prior 91 days if not a Monday
  AND convert(varchar,App_DtTm,112)  < convert(varchar,getdate(),112)
  AND  SysDefStatus in (' C','D','E','SC','FC', 'FD', 'FE',  'OC', 'OD', 'OE', 'SC', 'SD','SE')
  AND IDA not in ('','0000','00000000000','001123456','123456','123')
  AND (IDA != ' ' OR IDA != '***************'  
       OR IDA IS NOT NULL OR IDA NOT LIKE '%Do Not Use%' )