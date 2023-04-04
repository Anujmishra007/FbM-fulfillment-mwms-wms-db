SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/***********************************************************************
	TITLE: nsp_NIKE_InvoiceDatabase https://jiralfl.atlassian.net/browse/WMS-22171

DATE				VER		CREATEDBY   PURPOSE
04-APR-2023			1.0		JAM			MIGRATE FROM HYPERION 
************************************************************************/

CREATE OR ALTER   PROC [BI].[nsp_NIKE_InvoiceDatabase] --NAME OF SP
			@PARAM_GENERIC_STORERKEY NVARCHAR(30)=''
			, @PARAM_GENERIC_EXTERNORDERKEY NVARCHAR(10)=''
			, @PARAM_MBOL_MBOLKEY NVARCHAR(10)=''
			

AS
BEGIN
 SET NOCOUNT ON;  -- keeps the output generated to a minimum 
   SET ANSI_NULLS OFF;
   SET QUOTED_IDENTIFIER OFF;
   SET CONCAT_NULL_YIELDS_NULL OFF;

	IF ISNULL(@PARAM_GENERIC_StorerKey, '') = ''
		SET @PARAM_GENERIC_StorerKey = ''

   DECLARE @Debug	BIT = 0
		 , @LogId   INT
       , @Schema    NVARCHAR(128) = ISNULL(OBJECT_SCHEMA_NAME(@@PROCID),'')
       , @Proc      NVARCHAR(128) = ISNULL(OBJECT_NAME(@@PROCID),'')
       , @cParamOut NVARCHAR(4000)= ''
       , @cParamIn  NVARCHAR(4000)= '{  "PARAM_GENERIC_StorerKey":"'    +@PARAM_GENERIC_StorerKey+'", '
                                    + ' "PARAM_GENERIC_EXTERNORDERKEY":"'    +@PARAM_GENERIC_EXTERNORDERKEY+'", '
									+ ' "PARAM_MBOL_MBOLKEY":"'    +@PARAM_MBOL_MBOLKEY+'" '
                                    + ' }'

   EXEC BI.dspExecInit @ClientId = @PARAM_GENERIC_STORERKEY
   , @Proc = @Proc
   , @ParamIn = @cParamIn
   , @LogId = @LogId OUTPUT
   , @Debug = @Debug OUTPUT
   , @Schema = @Schema;
	DECLARE @Stmt NVARCHAR(MAX) = '' -- for dynamic SQL only
	
/****** START YOUR SELECT STATEMENT HERE USE @Stmt FOR DYNAMIC SQL ******/
set @Stmt = '


SELECT 
  DISTINCT AL1.MbolKey AS   ''01MBOLKey'', 
  AL2.ExternOrderKey AS     ''02ExternOrderKey'', 
  AL2.LoadKey AS            ''03LoadKey'', 
  AL4.EditDate AS           ''04EditDate'', 
  AL1.PCMNum AS             ''05PCMNum'', 
  AL1.ExternReason AS       ''06ExternReason'', 
  AL1.InvoiceStatus AS      ''07InvoiceStatus'', 
  AL2.UserDefine09 AS       ''08UserDefine09'', 
  AL2.ConsigneeKey AS       ''09ConsigneeKey'', 
  AL2.C_Company AS          ''10C_Company'', 
  SUM (AL3.Qty) AS          ''11Qty'' , 
  COUNT (DISTINCT AL3.CaseID) AS ''12DistinctID'', 
  AL2.OrderKey AS           ''13OrderKey'', 
  AL4.ShipDate AS           ''14ShipDate'', 
  AL1.UserDefine06 AS       ''15UserDefine06'', 
  AL1.UserDefine07 AS       ''16UserDefine07'' 
FROM BI.V_MBOLDETAIL AL1 (nolock)
JOIN BI.V_ORDERS AL2 (nolock) on  AL1.MBOLKey = AL2.MbolKey AND AL1.OrderKey = AL2.OrderKey
JOIN BI.V_PICKDETAIL AL3 (nolock) on  AL3.OrderKey = AL2.OrderKey AND AL3.Storerkey = AL2.Storerkey
JOIN BI.V_MBOL AL4 (nolock) on AL1.MbolKey = AL4.MbolKey 
WHERE  
    (
      AL2.StorerKey = '''+@PARAM_GENERIC_STORERKEY+'''
      AND AL2.ExternOrderKey = '''+@PARAM_GENERIC_EXTERNORDERKEY+'''
      AND AL2.MBOLKey = '''+@PARAM_MBOL_MBOLKEY+'''
    ) 
GROUP BY 
  AL1.MbolKey, 
  AL2.ExternOrderKey, 
  AL2.LoadKey, 
  AL4.EditDate, 
  AL1.PCMNum, 
  AL1.ExternReason, 
  AL1.InvoiceStatus, 
  AL2.UserDefine09, 
  AL2.ConsigneeKey, 
  AL2.C_Company, 
  AL2.OrderKey, 
  AL4.ShipDate, 
  AL1.UserDefine06, 
  AL1.UserDefine07
'

   EXEC BI.dspExecStmt @Stmt = @Stmt
   , @LogId = @LogId
   , @Debug = @Debug;

END
GO

GRANT EXEC ON BI.nsp_NIKE_InvoiceDatabase TO JReportRole --NAME OF SP
GO
/*
EXEC AS LOGIN ='JReportUserPH'

SELECT SUSER_SNAME()

EXEC BI.nsp_NIKE_InvoiceDatabase 'NIKEPH','0011994821','0011994821'
EXEC BI.nsp_NIKE_InvoiceDatabase '','',''
EXEC BI.nsp_NIKE_InvoiceDatabase NULL,NULL,NULL

REVERT

SELECT TOP 99 * 
FROM ExecutionLog WITH (NOLOCK)
WHERE SP = 'nsp_NIKE_InvoiceDatabase'
ORDER BY 1 DESC
*/
