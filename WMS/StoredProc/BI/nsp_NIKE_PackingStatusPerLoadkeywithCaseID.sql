SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***********************************************************************
TITLE: PH_LogiReport - Customized Reports - OrderProcessing [SP] https://jiralfl.atlassian.net/browse/WMS-21816 

DATE				VER		CREATEDBY   PURPOSE
19-FEB-2022			1.0		PCN			CONVERT SCRIPT TO SP 
2023-03-21			1.2		Crisnah		Change para datatype and filter condition .
************************************************************************/

CREATE OR ALTER   PROC [BI].[nsp_NIKE_PackingStatusPerLoadkeywithCaseID] --NAME OF SP */		
			@PARAM_GENERIC_Wavekey NVARCHAR(50) 
			, @PARAM_GENERIC_Loadkey NVARCHAR(50) 
			, @PARAM_GENERIC_ExternOrderKey NVARCHAR(50) 
			
AS
BEGIN
 SET NOCOUNT ON;  -- keeps the output generated to a minimum 
   SET ANSI_NULLS OFF;
   SET QUOTED_IDENTIFIER OFF;
   SET CONCAT_NULL_YIELDS_NULL OFF;

	
  IF ISNULL(@PARAM_GENERIC_Wavekey, '') = ''  
    SET @PARAM_GENERIC_Wavekey = ''
  IF ISNULL(@PARAM_GENERIC_Loadkey, '') = ''  
    SET @PARAM_GENERIC_Loadkey = ''
  IF ISNULL(@PARAM_GENERIC_ExternOrderKey, '') = ''  
    SET @PARAM_GENERIC_ExternOrderKey = ''

   DECLARE @Debug	BIT = 0
		 , @LogId   INT
       , @Schema    NVARCHAR(128) = ISNULL(OBJECT_SCHEMA_NAME(@@PROCID),'')
       , @Proc      NVARCHAR(128) = ISNULL(OBJECT_NAME(@@PROCID),'')
       , @cParamOut NVARCHAR(4000)= ''
       , @cParamIn  NVARCHAR(4000)= '{  '
									+ '"PARAM_GENERIC_Wavekey":"'    +@PARAM_GENERIC_Wavekey+'", ' 
									+ '"PARAM_GENERIC_Loadkey":"'    +@PARAM_GENERIC_Loadkey+'", '
									+ '"PARAM_GENERIC_ExternOrderKey":"'    +@PARAM_GENERIC_ExternOrderKey+'" '
                                    + ' }'  

   EXEC BI.dspExecInit @ClientId = 'NIKEPH'
   , @Proc = @Proc
   , @ParamIn = @cParamIn
   , @LogId = @LogId OUTPUT
   , @Debug = @Debug OUTPUT
   , @Schema = @Schema;
	DECLARE @Stmt NVARCHAR(MAX) = '' -- for dynamic SQL only
	
/****** START YOUR SELECT STATEMENT HERE USE @Stmt FOR DYNAMIC SQL ******/
set @Stmt = '
	SELECT 
	  DISTINCT AL2.MBOLKey as ''01MBOLKey'', 
	  AL2.LoadKey as ''02LoadKey'', 
	  AL2.OrderKey as ''03OrderKey'', 
	  AL2.ExternOrderKey as ''04ExternOrderKey'', 
	  AL1.Status as ''05Status'', 
	  case AL1.Status 
		when ''0'' then ''Open''
		when ''9'' then ''Packed''
	  end as ''06PackStatus'',	
	  AL1.PickSlipNo as ''07PickSlipNo'', 
	  AL3.Loc as ''08Loc'', 
	  AL3.DropID as ''09DropID'', 
	  AL2.PrintFlag as ''10PrintFlag'', 
	  AL2.UserDefine09 as ''11WaveKey'', 
	  SUM (AL3.Qty) as ''12Qty'', 
	  AL3.ID as ''13ID'', 
	  AL3.CaseID ''14CaseID''
	FROM 
	  BI.V_ORDERS AL2 (NOLOCK)
	  JOIN BI.V_PackHeader AL1 (NOLOCK) on (AL1.StorerKey = AL2.StorerKey AND AL1.OrderKey = AL2.OrderKey AND AL1.LoadKey = AL2.LoadKey)  
	  JOIN BI.V_PICKDETAIL AL3 (NOLOCK) on (AL2.Storerkey = AL3.StorerKey AND AL2.OrderKey = AL3.OrderKey AND AL2.UserDefine09 = AL3.WaveKey AND AL1.PickSlipNo = AL3.PickSlipNo )
	WHERE 
		  AL1.StorerKey = ''NIKEPH'' 
		  AND AL2.UserDefine09 = '''+@PARAM_GENERIC_Wavekey+''' 
		  AND 
		  (
      		  AL2.LoadKey = COALESCE(NULLIF(isnull('''+@PARAM_GENERIC_Loadkey+''',''''), ''''),AL2.LoadKey)  
			  OR 
			  AL2.ExternOrderKey = COALESCE(NULLIF(isnull('''+@PARAM_GENERIC_ExternOrderKey+''',''''), ''''),AL2.ExternOrderKey) 
		  )   
	GROUP BY 
	  AL2.MBOLKey, 
	  AL2.UserDefine09, 
	  AL2.LoadKey, 
	  AL2.OrderKey, 
	  AL2.ExternOrderKey, 
	  AL1.Status, 
	  AL1.PickSlipNo, 
	  AL3.Loc, 
	  AL3.DropID, 
	  AL2.PrintFlag, 
	  AL3.ID, 
	  AL3.CaseID 
	ORDER BY 
	  3, 
	  4

'  

/*************************** FOOTER *******************************/
   EXEC BI.dspExecStmt @Stmt = @Stmt
   , @LogId = @LogId
   , @Debug = @Debug;

END
GO

GRANT EXEC ON BI.nsp_NIKE_PackingStatusPerLoadkeywithCaseID TO JReportRole --NAME OF SP
GO

/*
EXEC AS LOGIN ='JReportUserPH'

SELECT SUSER_SNAME()

EXEC BI.nsp_NIKE_PackingStatusPerLoadkeywithCaseID '0000325141' ,'0006054687','0676213810' 
EXEC BI.nsp_NIKE_PackingStatusPerLoadkeywithCaseID '','',''
EXEC BI.nsp_NIKE_PackingStatusPerLoadkeywithCaseID NULL,NULL,NULL

REVERT

SELECT TOP 99 * 
FROM ExecutionLog WITH (NOLOCK)
WHERE SP = 'nsp_Nike_PackingStatusPerLoadkeywithCaseID'
ORDER BY 1 DESC
*/
