
DECLARE  @n_No        INT = 0
      ,  @c_ReportID  NVARCHAR(10) = ''

     
GET_REPORTNO:       
;WITH numbers AS (
                  SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM 
                  (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) x1(x),
                  (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) x2(x),
                  (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) x3(x),
                  (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) x4(x)
               )
SELECT TOP 1 @n_No = numbers.n
FROM numbers
LEFT OUTER JOIN dbo.WMREPORT AS w (NOLOCK) ON 'R' + RIGHT('000000000' +  CONVERT(NVARCHAR(9),numbers.n),9) = w.ReportID
WHERE w.ReportID IS NULL
ORDER BY numbers.n


IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Adjustment' AND ReportType= 'ADJDET')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'Adjustment','WM','ADJDET','ADJDET - Adjustment Detail','2','ADJUSTMENT.AdjustmentKey','@c_UserName','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='InventoryQC' AND ReportType= 'IQCRPT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'InventoryQC','WM','IQCRPT','IQCRPT - Inventory QC Report','1','InventoryQC.QC_Key','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Loadplan' AND ReportType= 'PLISTC')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'Loadplan','WM','PLISTC','PLISTC - Consolidated Pickslip','1','LOADPLAN.LoadKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Loadplan' AND ReportType= 'PLISTN')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;   
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'Loadplan','WM','PLISTN','PLISTC - Normal Pickslip','1','LOADPLAN.LoadKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Loadplan' AND ReportType= 'POPUPPLIST')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'Loadplan','WM','POPUPPLIST','POPUPPLIST - Popup Pick List','1','LOADPLAN.LoadKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='MBOL' AND ReportType= 'DISPLBL')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'MBOL','WM','DISPLBL','DISPLBL - Dispatch Label','3','MBOLDETAIL.MBOLKey','MBOLDETAIL.Orderkey','MBOLDETAIL.TotalCartons','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='MBOL' AND ReportType= 'DO')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'MBOL','WM','DO','DO - Delivery Orders','1','MBOL.MBOLKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='MBOL' AND ReportType= 'MANSUM')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'MBOL','WM','MANSUM','MANSUM - Manifest Summary','1','MBOL.MBOLKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='MBOL' AND ReportType= 'MBOL')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'MBOL','WM','MBOL','MBOL - Master Bill of Landing','1','MBOL.MBOLKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1      
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Orders' AND ReportType= 'DELNOTE')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'Orders','WM','DELNOTE','DELNOTE - Delivery Note','1','ORDERS.OrderKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1      
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptA' AND ReportType= 'RCPSUMM')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'ReceiptA','WM','RCPSUMM','RCPSUMM - Receipt Summary Report','1','Receipt.receiptkey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1      
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptA' AND ReportType= 'PRETALSHT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'ReceiptA','WM','PRETALSHT','PRETALSHT - Pre-Tally Sheet','1','receipt.receiptkey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1      
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptA' AND ReportType= 'PTWYRPT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'ReceiptA','WM','PTWYRPT','PTWYRPT - Putaway Report','3','RECEIPT.ReceiptKey','RECEIPT.ReceiptKey','@c_UserName','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1      
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptA' AND ReportType= 'TallySHT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'ReceiptA','WM','TallySHT','TallySHT - Tally Sheet','5','RECEIPT.ReceiptKey','RECEIPT.ReceiptKey','RECEIPT.StorerKey','RECEIPT.StorerKey','@c_UserName','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1      
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptR' AND ReportType= 'PTWYRPT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'ReceiptR','WM','PTWYRPT','PTWYRPT - Putaway Report','3','RECEIPT.ReceiptKey','RECEIPT.ReceiptKey','@c_UserName','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1      
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptR' AND ReportType= 'TallySHT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'ReceiptR','WM','TallySHT','TallySHT - Tally Sheet','5','RECEIPT.ReceiptKey','RECEIPT.ReceiptKey','RECEIPT.StorerKey','RECEIPT.StorerKey','@c_UserName','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptX' AND ReportType= 'PTWYRPT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5)
    VALUES ( @c_ReportID ,'ReceiptX','WM','PTWYRPT','PTWYRPT - Putaway Report','3','RECEIPT.ReceiptKey','RECEIPT.ReceiptKey','@c_UserName','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='ReceiptX' AND ReportType= 'TallySHT')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'ReceiptX','WM','TallySHT','TallySHT - Tally Sheet','5','RECEIPT.ReceiptKey','RECEIPT.ReceiptKey','RECEIPT.StorerKey','RECEIPT.StorerKey','@c_UserName','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Replenishment' AND ReportType= 'REPLEN')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'Replenishment','WM','REPLEN','Replen - Replenishment Report','15','REPLENISHMENTPARMS.Facility','REPLENISHMENTPARMS.Zone02','REPLENISHMENTPARMS.Zone03','REPLENISHMENTPARMS.Zone04','REPLENISHMENTPARMS.Zone05','REPLENISHMENTPARMS.Zone06','REPLENISHMENTPARMS.Zone07','REPLENISHMENTPARMS.Zone08','REPLENISHMENTPARMS.Zone09','REPLENISHMENTPARMS.Zone10','REPLENISHMENTPARMS.Zone11','REPLENISHMENTPARMS.Zone12','REPLENISHMENTPARMS.StorerKey','REPLENISHMENTPARMS.ReplenishmentGroup','P','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='StockTakeSheetParameters' AND ReportType= 'CCSHEET')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'StockTakeSheetParameters','WM','CCSHEET','CCSHEET - Cycle Count Sheet','15','StockTakeSheetParameters.StockTakeKey','StockTakeSheetParameters.StockTakeKey','','zzzzzzzzzzzz','','zzzzzzzzzzzz','','zzzzzzzzzzzz','','zzzzzzzzzzzz','','zzzzzzzzzzzz','0','999999999','N','{DF:StockTakeSheetParameters.FinalizeStage+1}{T:1|2|3}{D:1|2|3}','Y','','','','StockTake # - Start','StockTake # - End','Sku - Start','Sku - End','Class - Start','Class - End','Storer - Start','Storer - End','Location - Start','Location - End','Zone - Start','Zone - End','CCSheet # - Start','CCSheet # - End','WithQty','Count No','FinalizeFlag','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='StockTakeSheetParameters' AND ReportType= 'CCVARIANCE')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'StockTakeSheetParameters','WM','CCVARIANCE','CCVARIANCE - Variance Report','15','StockTakeSheetParameters.StockTakeKey','','zzzzzzzzzzzz','','zzzzzzzzzzzz','','zzzzzzzzzzzz','','zzzzzzzzzzzz','','zzzzzzzzzzzz','0','999999999','N','{T:1|2|3}{D:1|2|3}','','','','','','StockTake #','Storerkey - Start','Storerkey - End','SKU - Start','SKU - End','Loc - Start','Loc - End','Class - Start','Class - End','Zone - Start','Zone - End','CCSheet # - Start','CCSheet # - End','FinalizeFlag','Count #','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Wave' AND ReportType= 'PLIST_WAVE')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
   VALUES ( @c_ReportID ,'Wave','WM','PLIST_WAVE','PLIST_WAVE - Generate Pick Slip','5','Wave.WaveKey','0','ZZZZZZZZZZ','0','ZZZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='Wave' AND ReportType= 'WAVPLISTC')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   INSERT INTO WMREPORT(ReportID,ModuleID,PrintMethod,ReportType,ReportTitle,NoOfKeyFieldParms,KeyFieldName1,KeyFieldName2,KeyFieldName3,KeyFieldName4,KeyFieldName5,KeyFieldName6,KeyFieldName7,KeyFieldName8,KeyFieldName9,KeyFieldName10,KeyFieldName11,KeyFieldName12,KeyFieldName13,KeyFieldName14,KeyFieldName15,ExtendedParmDefault1,ExtendedParmDefault2,ExtendedParmDefault3,ExtendedParmDefault4,ExtendedParmDefault5,KeyFieldParmLabel1,KeyFieldParmLabel2,KeyFieldParmLabel3,KeyFieldParmLabel4,KeyFieldParmLabel5,KeyFieldParmLabel6,KeyFieldParmLabel7,KeyFieldParmLabel8,KeyFieldParmLabel9,KeyFieldParmLabel10,KeyFieldParmLabel11,KeyFieldParmLabel12,KeyFieldParmLabel13,KeyFieldParmLabel14,KeyFieldParmLabel15,ExtendedParm1,ExtendedParm2,ExtendedParm3,ExtendedParm4,ExtendedParm5) 
      VALUES ( @c_ReportID ,'Wave','WM','WAVPLISTC','WAVPLISTC - Generate Consolidated Pick List','1','WAVE.WaveKey','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','')
   SET @n_No = @n_No + 1   
END


--NextGen Ecom
IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='EPACKING' AND ReportType= 'PACKLIST')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;

   INSERT INTO WMREPORT (ReportID, ReportTitle, ModuleID, PrintMethod, ReportType, NoOfKeyFieldParms, KeyFieldName1, KeyFieldName2, KeyFieldName3,  KeyFieldParmLabel1, KeyFieldParmLabel2 ,KeyFieldParmLabel3)
   VALUES (@c_ReportID, 'Print Packing List','EPACKING',	'WM',	'PACKLIST','1', 'PACKHEADER.PickSlipNo','','','','','')
   
   SET @n_No = @n_No + 1   
END

IF NOT EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ModuleID='EPACKING' AND ReportType= 'CTNMARKLBL')
BEGIN
   SET @c_ReportID = 'R' + RIGHT('000000000' + CONVERT(NVARCHAR(9),@n_No),9)
   IF EXISTS (SELECT 1 FROM WMREPORT (NOLOCK) WHERE ReportID = @c_ReportID) GOTO GET_REPORTNO;
   
   INSERT INTO WMREPORT (ReportID, ReportTitle, ModuleID, PrintMethod, ReportType, NoOfKeyFieldParms, KeyFieldName1, KeyFieldName2, KeyFieldName3, KeyFieldParmLabel1, KeyFieldParmLabel2 ,KeyFieldParmLabel3)
   VALUES (@c_ReportID, 'Print Carton Mark Label','EPACKING',	'WM',	'CTNMARKLBL','3', 'PACKDETAIL.PickSlipNo','PACKDETAIL.CartonNo','PACKDETAIL.CartonNo','PickSlipNo#','FromCartonNo','ToCartonNo')
   
   SET @n_No = @n_No + 1   
END
--SELECT TOP 25 w.adddate, w.addwho,* FROM wmreport w(NOLOCK) ORDER BY w.adddate desc, w.reportid DESC

--SELECT  w.adddate, w.addwho,* FROM wmreport w(NOLOCK) ORDER BY w.reportid 

