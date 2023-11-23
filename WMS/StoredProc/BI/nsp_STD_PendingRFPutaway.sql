SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/***********************************************************************  
TITLE: PENDING RF PUTAWAY  https://jiralfl.atlassian.net/browse/WMS-23979
   
DATE    VER  CREATEDBY   PURPOSE  
23-OCT-2023   1.0  ROD   SP CREATION   
  
************************************************************************/  

CREATE OR ALTER   PROC [BI].[nsp_STD_PendingRFPutaway] --NAME OF SP
			@PARAM_GENERIC_STORERKEY NVARCHAR(30)=''
			, @PARAM_GENERIC_FACILITY NVARCHAR(10)=''

AS
BEGIN
 SET NOCOUNT ON;  -- keeps the output generated to a minimum 
   SET ANSI_NULLS OFF;
   SET QUOTED_IDENTIFIER OFF;
   SET CONCAT_NULL_YIELDS_NULL OFF;

	IF ISNULL(@PARAM_GENERIC_StorerKey, '') = ''
		SET @PARAM_GENERIC_Storerkey= ''
	IF ISNULL(@PARAM_GENERIC_Facility, '') = ''
		SET @PARAM_GENERIC_Facility= ''

   DECLARE @Debug	BIT = 0
		 , @LogId   INT
       , @Schema    NVARCHAR(128) = ISNULL(OBJECT_SCHEMA_NAME(@@PROCID),'')
       , @Proc      NVARCHAR(128) = ISNULL(OBJECT_NAME(@@PROCID),'') --NAME OF SP
       , @cParamOut NVARCHAR(4000)= ''
       , @cParamIn  NVARCHAR(4000)= CONCAT('{ "PARAM_GENERIC_StorerKey":"'    ,@PARAM_GENERIC_StorerKey,'"'
											, ', "PARAM_GENERIC_FACILITY":"'    ,@PARAM_GENERIC_FACILITY,'"'
											 , ' }')
		
   EXEC BI.dspExecInit @ClientId = @PARAM_GENERIC_StorerKey
   , @Proc = @Proc
   , @ParamIn = @cParamIn
   , @LogId = @LogId OUTPUT
   , @Debug = @Debug OUTPUT
   , @Schema = @Schema;

DECLARE @Stmt NVARCHAR(MAX) = '' -- for dynamic SQL only
	
/****** START YOUR SELECT STATEMENT HERE USE @Stmt FOR DYNAMIC SQL ******/
set @Stmt = '  
SELECT 
	DISTINCT
		RFP.StorerKey,
		RFP.SKU,
		RFP.Lot,
		RFP.FromLoc,
		RFP.FromID,
		RFP.SuggestedLoc,
		RFP.ID,
		RFP.Qty,
		RFP.AddDate,
		RFP.AddWho,
		RFP.EditDate,
		RFP.EditWho

FROM 
	BI.V_RFPUTAWAY RFP WITH (NOLOCK)
	JOIN BI.V_LOC LOC  (NOLOCK) ON (RFP.FromLoc = LOC.Loc)  
	JOIN BI.V_SKU SKU  (NOLOCK) ON (SKU.StorerKey = RFP.StorerKey AND SKU.Sku = RFP.Sku)  

WHERE
	(
	RFP.StorerKey = '''+@PARAM_GENERIC_STORERKEY+'''  
	AND LOC.Facility = '''+@PARAM_GENERIC_FACILITY+'''
	
	)

ORDER BY   
  9'

-- USE VIEW TABLES WITH BI SCHEMA : BI.V_DM_ORDERS for PH_DATAMART, BI.V_ORDERS for PHWMS

/*************************** FOOTER *******************************/
   EXEC BI.dspExecStmt @Stmt = @stmt
   , @LogId = @LogId
   , @Debug = @Debug;

END
GO

GRANT EXEC ON BI.nsp_STD_PendingRFPutaway TO JReportRole --NAME OF SP
GO


/*
EXEC AS LOGIN = 'JReportUserPH'

SELECT SUSER_SNAME()


EXEC BI.nsp_STD_PendingRFPutaway

revert;
*/