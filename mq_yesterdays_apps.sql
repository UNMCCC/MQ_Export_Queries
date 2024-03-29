/** Naive visits : I.e; no filtering of any sort other than status and date 
	Added "catchup code" to get prior dates missed over MQ upgrade 12/3-12/6
**/
SET NOCOUNT ON;
Use Mosaiq;
SELECT Sch_Id
      ,App_DtTm
      ,ISNULL(QUOTENAME(Short_Desc,'"'),'') as Activity_Description
      ,ISNULL(QUOTENAME(LOCATION,'"'),'') as Location
      ,ISNULL(QUOTENAME(PAT_NAME,'"'),'') as Pat_Name
      --,MD_INITIALS as provider_initials -- removed...update MD initials to provider/attending lastname + comma + first name
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
	convert(varchar,App_DtTm,112) >= CASE
		WHEN DATENAME(DW, GETDATE()) = 'Monday' -- check if today is a Monday
			THEN convert(varchar,dateadd(day,-3,getdate()),112) -- pulls last 3 days if Monday
		ELSE convert(varchar,dateadd(day,-1,getdate()),112) -- pulls yesterday if not a Monday
		END
	-- convert(varchar,App_DtTm,112) >= convert(varchar,dateadd(day,-5, getdate()),112) -- catch up code pulls 5 days ago
  AND convert(varchar,App_DtTm,112)  < convert(varchar,getdate(),112)
  AND  SysDefStatus in (' C','D','E','SC','FC', 'FD', 'FE',  'OC', 'OD', 'OE', 'SC', 'SD','SE')
  AND IDA not in ('','0000','00000000000','001123456','123456','123')
  AND (IDA != ' ' OR IDA != '***************'  
       OR IDA IS NOT NULL OR IDA NOT LIKE '%Do Not Use%' )
