/****** SQL to extract Yesterday Labs, minimal filtering ******/
use Mosaiq
Set NOCOUNT On

 SELECT DISTINCT 
  Orders.orc_id,
  Ident.IDA as mrn,
  QUOTENAME(dbo.fn_GetPatientName(Orders.pat_id1, 'NAMELFM'),'"') as PatName,
  CONVERT(CHAR(10),Orders.Start_DtTm,112) as startAppDtTm, -- start
  QUOTENAME(ISNULL(dbo.fn_GetStaffName(Orders.Ord_Provider,'NAMELF'),''),'"') Ordering_Prov,--ordering md
  CPT.Hsp_Code as code, --code
  ISNULL(QUOTENAME(CPT.Description,'"'),'') as Lab, --desc
  ISNULL(QUOTENAME(Orders.Condition,'"'),'')as  cond


 FROM   ((((Orders 
 LEFT OUTER JOIN ObsReq ON (Orders.Pat_ID1=ObsReq.Pat_ID1) AND (Orders.ORC_Set_ID=ObsReq.ORC_Set_ID)) 
 LEFT OUTER JOIN Admin ON Orders.Pat_ID1=Admin.Pat_ID1) 
 LEFT OUTER JOIN Patient  ON Orders.Pat_ID1=Patient.Pat_ID1) 
 LEFT OUTER JOIN Ident ON Orders.Pat_ID1=Ident.Pat_Id1) 
 LEFT OUTER JOIN CPT  ON ObsReq.Hsp_Code=CPT.Hsp_Code
 

 WHERE Admin.Expired_DtTm IS  NULL  
 AND Patient.Clin_Status<>4 
 AND (Orders.Order_Type=1 or Orders.Order_Type=4)
 AND Orders.Version=0 
 AND ObsReq.Version=0 
 AND convert(varchar(8),Orders.Start_dtTm,112) >= convert(varchar(8),dateadd(day,-1,getdate()),112) 
 AND convert(varchar(8),Orders.Start_dtTm,112) < convert(varchar(8),getdate(),112)
 --AND Orders.Start_DtTm >= dateadd(day,-1,GETDATE())  -- Yesterday
-- AND Orders.Start_DtTm <= GETDATE() 
 AND CPT.CGroup='LAB' 
 AND Orders.Inst_ID<=2 --CRTC or RO
 
 AND Ident.IDA not in ('','0000','00000000000','001123456','123456','123')
 AND (Ident.IDA != ' ' OR Ident.IDA != '***************'  
     OR Ident.IDA IS NOT NULL OR Ident.IDA NOT LIKE '%Do Not Use%' 
     OR Patient.Last_Name != 'TEST')   
  --ORDER BY Orders.StartDate
  AND (  Orders.Status_Enum = 5 OR orders.Status_enum = 18 
     OR orders.Status_Enum = 3 OR orders.Status_enum = 2 )