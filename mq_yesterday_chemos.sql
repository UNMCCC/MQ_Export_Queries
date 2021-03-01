/** Naive chemo orders extract **/
SET NOCOUNT ON;
Use Mosaiq;
SELECT  
   orc.orc_id,
   ident.ida as MRN,
   QUOTENAME(MOSAIQ.dbo.fn_GetPatientName(orc.pat_id1, 'NAMELFM'),'"') as PatName,
   QUOTENAME(convert(char(10), orc.Start_dtTm, 112),'"') as AppDt,
   QUOTENAME(MOSAIQ.dbo.fn_GetStaffName(orc.Ord_Provider ,'NAMELF'),'"') as Ordering_Prov,			
   QUOTENAME(rtrim(Drug.Drug_Label),'"') as Drug_label,
   ISNULL(orc.Cycle_Number,'') as cycle_number, -- Rick added 
   ISNULL(orc.Cycle_Day,''), as cycle_day -- Rick added 
   ISNULL(orc.Delayed,'') as delayed -- Rick added
--    ISNULL(QUOTENAME(Orc.Condition,'"'),'')as  comment

FROM MOSAIQ.dbo.Orders orc
INNER JOIN MOSAIQ.dbo.Ident on orc.pat_id1 = Ident.pat_id1
INNER JOIN MOSAIQ.dbo.PharmOrd RXO on orc.orc_set_id = rxo.ORC_set_ID and RXO.Version = 0 AND  ORC.Order_Type = 4 -- To get all in-House Treatment Pharmacy Orders (but not Observation Orders)  
LEFT JOIN MOSAIQ.dbo.Drug on  RXO.Req_Give_Code = Drug.drg_id

WHERE 
 convert(varchar(8),orc.Start_dtTm,112) >= CASE
		WHEN DATENAME(DW, GETDATE()) = 'Monday' -- check if today is a Monday
			THEN convert(varchar(8),dateadd(day,-3,getdate()),112) -- pulls last 3 days if Monday
			ELSE convert(varchar(8),dateadd(day,-1,getdate()),112) -- pulls yesterday if not a Monday
		END
 AND convert(varchar(8),orc.Start_dtTm,112)  < convert(varchar(8),getdate(),112)
 AND orc.version = 0		       -- select tip records only 
 AND (  orc.Status_Enum = 5 OR orc.Status_enum = 18 
     OR orc.Status_Enum = 3 OR orc.Status_enum = 2 
     OR rxo.Status_Enum = 5 OR RXO.Status_enum= 18
     OR rxo.Status_Enum = 2 OR RXO.Status_enum= 3)
 AND Ident.IDA not in ('','0000','00000000000','001123456','123456','123')
 AND (Ident.IDA != ' ' OR Ident.IDA != '***************'  
     OR Ident.IDA IS NOT NULL OR Ident.IDA NOT LIKE '%Do Not Use%' )   
