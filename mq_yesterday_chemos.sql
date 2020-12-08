/** Naive chemo orders extract **/
SET NOCOUNT ON;
Use Mosaiq;
SELECT  
    orc.orc_id,
    ident.ida as MRN,
    isNULL(QUOTENAME(MOSAIQ.dbo.fn_GetPatientName(orc.pat_id1, 'NAMELFM'),'"'),"") as PatName,
    isNULL(QUOTENAME(convert(char(10), orc.Start_dtTm, 112),'"'),"") as AppDt,
    isNULL(QUOTENAME(MOSAIQ.dbo.fn_GetStaffName(orc.Ord_Provider ,'NAMELF'),'"'),"") as Ordering_Prov,			
    isNULL(QUOTENAME(rtrim(Drug.Drug_Label),'"'),"") as Drug_label
--    ISNULL(QUOTENAME(Orc.Condition,'"'),'')as  comment

FROM MOSAIQ.dbo.Orders orc
INNER JOIN MOSAIQ.dbo.Ident on orc.pat_id1 = Ident.pat_id1
INNER JOIN MOSAIQ.dbo.PharmOrd RXO on orc.orc_set_id = rxo.ORC_set_ID and RXO.Version = 0 AND  ORC.Order_Type = 4 -- To get all in-House Treatment Pharmacy Orders (but not Observation Orders)  
LEFT JOIN MOSAIQ.dbo.Drug on  RXO.Req_Give_Code = Drug.drg_id

WHERE 
  orc.Start_dtTm >= dateadd(day,-1,getdate()) 
 AND orc.Start_dtTm  <= getdate()
 AND orc.version = 0		       -- select tip records only 
 AND (  orc.Status_Enum = 5 OR orc.Status_enum = 18 
     OR orc.Status_Enum = 3 OR orc.Status_enum = 2 
     OR rxo.Status_Enum = 5 OR RXO.Status_enum= 18
     OR rxo.Status_Enum = 2 OR RXO.Status_enum= 3)
