SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***********************************************************************  
 TITLE: NIKE Wave Pre-Cartonization Report  https://jiralfl.atlassian.net/browse/WMS-22171
  
DATE    VER  CREATEDBY   PURPOSE  
2023-02-02   1.0  JAM   MIGRATE FROM HYPERION
************************************************************************/  
  
CREATE  OR ALTER PROC [BI].[nsp_NIKE_WavePreCartonizationReport] --NAME OF SP  
   @PARAM_GENERIC_STORERKEY NVARCHAR(30)=''  
   ,@PARAM_ORDERS_USERDEFINE09 NVARCHAR(30)=''  
   ,@PARAM_ORDERS_EXTERNORDERKEY NVARCHAR(30)=''  
  
AS  
BEGIN  
 SET NOCOUNT ON;  -- keeps the output generated to a minimum   
   SET ANSI_NULLS OFF;  
   SET QUOTED_IDENTIFIER OFF;  
   SET CONCAT_NULL_YIELDS_NULL OFF;  
  
 IF ISNULL(@PARAM_GENERIC_STORERKEY, '') = ''  
  SET @PARAM_GENERIC_STORERKEY = ''  
   
 IF ISNULL(@PARAM_ORDERS_USERDEFINE09, '') = ''  
  SET @PARAM_ORDERS_USERDEFINE09 = ''  
  
 IF ISNULL(@PARAM_ORDERS_EXTERNORDERKEY, '') = ''  
  SET @PARAM_ORDERS_EXTERNORDERKEY = ''  
  
  DECLARE @Debug BIT = 0  
   , @LogId   INT  
       , @Schema    NVARCHAR(128) = ISNULL(OBJECT_SCHEMA_NAME(@@PROCID),'')  
       , @Proc      NVARCHAR(128) = ISNULL(OBJECT_NAME(@@PROCID),'')  
       , @cParamOut NVARCHAR(4000)= ''  
       , @cParamIn  NVARCHAR(4000)= '{ "PARAM_GENERIC_STORERKEY":"'    +@PARAM_GENERIC_STORERKEY+'", '  
         + '"PARAM_ORDERS_USERDEFINE09":"'    +@PARAM_ORDERS_USERDEFINE09+'",  '  
         + '"PARAM_ORDERS_EXTERNORDERKEY":"'    +@PARAM_ORDERS_EXTERNORDERKEY+'"  '  
                                    + ' }'  
  
   EXEC BI.dspExecInit @ClientId = @PARAM_GENERIC_StorerKey  
   , @Proc = @Proc  
   , @ParamIn = @cParamIn  
   , @LogId = @LogId OUTPUT  
   , @Debug = @Debug OUTPUT  
   , @Schema = @Schema;  
 DECLARE @Stmt NVARCHAR(MAX) = '' -- for dynamic SQL only  
  
/****** START YOUR SELECT STATEMENT HERE USE @Stmt FOR DYNAMIC SQL ******/  
/**********************************************************************  
 NOTES:  
 USE BI SCHEMA - PHWMS=BI.V_ORDERS , PH_DATAMART=BI.V_DM_ORDERS, PHDTSITF=BI.V_DTS_IN_FILE  
 USE NO LOCK  
 USE JOIN TABLES INSTEAD OF COMMA, FOR EASY & READABLE QUERY  
 **********************************************************************/  
  
set @Stmt = 'SELECT   
  DISTINCT OD.StorerKey,   
  SUM (PKD.Qty * SKU.STDCUBE) as ''Ttl Sku CMB'',   
  OD.UserDefine09 as Wavekey,   
  OD.ExternOrderKey,   
  COUNT (DISTINCT PAI.CartonNo) as  ''Total Cartons'',  
  SUM (PAI.Cube) as ''Total Carton Cube'',   
  OD.OrderKey   
  
FROM   
BI.V_PackInfo PAI  
JOIN BI.V_PackHeader PH (nolock) on PH.PickSlipNo = PAI.PickSlipNo  
JOIN BI.V_ORDERS OD (nolock) on OD.OrderKey = PH.OrderKey and OD.StorerKey = PH.StorerKey  
JOIN BI.V_PICKDETAIL PKD (nolock) on PKD.Pickslipno=PH.PickslipNO  
JOIN BI.V_SKU SKU (nolock) on PKD.Storerkey=SKU.Storerkey and PKD.SKU=SKU.SKU   
WHERE   
  OD.StorerKey =''NIKEPH'' '  
if isnull(@PARAM_ORDERS_USERDEFINE09,'') <> ''  
 set @stmt = @stmt + ' AND PKD.Wavekey in ('''+@PARAM_ORDERS_USERDEFINE09+''') '  
  
if isnull(@PARAM_ORDERS_externORDERKEY,'') <> ''  
 set @stmt = @stmt + ' AND OD.ExternOrderKey in ('''+@PARAM_ORDERS_externORDERKEY+''') '  

set @Stmt = @STMT+'   
GROUP BY   
  OD.StorerKey,   
  OD.UserDefine09,   
  OD.ExternOrderKey,   
  OD.OrderKey '  
  
  
/*************************** FOOTER *******************************/  
  
   EXEC BI.dspExecStmt @Stmt = @Stmt  
   , @LogId = @LogId  
   , @Debug = @Debug;  
  
END
GO

GRANT EXEC ON BI.nsp_NIKE_WavePreCartonizationReport TO JReportRole --NAME OF SP
GO

/*
   EXEC AS LOGIN = 'JReportUserPH'
   SELECT SUSER_SNAME()
   EXEC BI.nsp_NIKE_WavePreCartonizationReport
   REVERT;

   SELECT TOP 99 * 
   FROM dbo.ExecutionLog WITH (NOLOCK)
   WHERE sp ='nsp_NIKE_WavePreCartonizationReport' 
   ORDER BY 1 DESC
*/
